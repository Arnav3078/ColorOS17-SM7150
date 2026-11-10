#!/usr/bin/env python3
import struct, gzip, sys, os, re

def patch_boot_image(boot_path, out_path):
    print(f"[*] Patching Samsung Boot Image: {boot_path} -> {out_path}")
    with open(boot_path, 'rb') as f:
        boot_data = f.read()

    hdr = boot_data[:4096]
    magic = hdr[:8]
    assert magic == b'ANDROID!', f"Invalid boot magic: {magic}"

    ksize, kaddr, rsize, raddr, ssize, saddr, taddr, psize, hver, osver = struct.unpack('<IIIIIIIIII', hdr[8:48])
    print(f"[*] Original boot: Header v{hver}, PageSize {psize}, Kernel {ksize}b, Ramdisk {rsize}b")

    # Read cmdline (512 bytes at offset 64)
    cmdline = hdr[64:64+512].decode('ascii', errors='ignore').rstrip('\x00')
    print(f"[*] Original cmdline: {cmdline}")

    # Add permissive flag if not present
    if 'androidboot.selinux=permissive' not in cmdline:
        cmdline = cmdline.strip() + ' androidboot.selinux=permissive'
    print(f"[*] Target cmdline: {cmdline}")

    # Extract kernel and ramdisk
    k_pages = (ksize + psize - 1) // psize
    r_offset = (1 + k_pages) * psize
    kernel_data = boot_data[psize : psize + ksize]
    ramdisk_raw = boot_data[r_offset : r_offset + rsize]

    # Decompress ramdisk
    is_gzip = ramdisk_raw[:2] == b'\x1f\x8b'
    if is_gzip:
        ramdisk_cpio = gzip.decompress(ramdisk_raw)
    else:
        ramdisk_cpio = ramdisk_raw

    # Parse CPIO entries and modify fstab.default
    new_cpio_entries = []
    idx = 0
    fstab_patched = False

    while idx + 110 <= len(ramdisk_cpio):
        if ramdisk_cpio[idx:idx+6] != b'070701':
            break
        header_bytes = ramdisk_cpio[idx:idx+110]
        namesize = int(header_bytes[94:102], 16)
        filesize = int(header_bytes[54:62], 16)

        name = ramdisk_cpio[idx+110 : idx+110+namesize-1].decode('ascii', errors='ignore')

        content_start = idx + 110 + namesize
        if content_start % 4 != 0:
            content_start += 4 - (content_start % 4)

        file_content = ramdisk_cpio[content_start : content_start + filesize]

        if name in ('fstab.default', 'fstab.qcom', 'fstab.sm7150'):
            print(f"[+] Found {name} in boot ramdisk! Injecting EROFS & ColorOS dynamic partitions...")
            lines = file_content.decode('utf-8', errors='ignore').splitlines()
            new_lines = []
            has_erofs_sys = False
            has_erofs_prod = False
            has_sys_ext = False

            for line in lines:
                # Remove Samsung ICE encryption
                if 'fileencryption=ice' in line:
                    line = line.replace('fileencryption=ice', 'encryptable')

                # Strip AVB on dynamic partitions
                if any(line.startswith(p) for p in ['system', 'product', 'vendor', 'odm']):
                    line = re.sub(r',avb_keys=[^\s]+', '', line)
                    line = re.sub(r',avb=[^\s,]+', '', line)
                    line = re.sub(r',avb\b', '', line)

                if line.startswith('system\t') and 'erofs' in line:
                    has_erofs_sys = True
                if line.startswith('product\t') and 'erofs' in line:
                    has_erofs_prod = True
                if line.startswith('system_ext'):
                    has_sys_ext = True

                new_lines.append(line)

            # Insert EROFS entries for system, system_ext, product
            extra_entries = []
            if not has_erofs_sys:
                extra_entries.append("system\t/system\terofs\tro\twait,logical,first_stage_mount")
            if not has_sys_ext:
                extra_entries.append("system_ext\t/system_ext\terofs\tro\twait,logical,first_stage_mount")
                extra_entries.append("system_ext\t/system_ext\text4\tro\twait,logical,first_stage_mount")
            if not has_erofs_prod:
                extra_entries.append("product\t/product\terofs\tro\twait,logical,first_stage_mount")

            # ColorOS custom dynamic partitions
            for cpart in ['my_product', 'my_stock', 'my_heytap', 'my_carrier', 'my_region', 'my_bigball', 'my_manifest', 'my_engineering']:
                extra_entries.append(f"{cpart}\t/{cpart}\terofs\tro\twait,logical,first_stage_mount,nofail")

            # Place extra entries right before system
            final_lines = []
            for line in new_lines:
                if line.startswith('system\t/system\text4'):
                    final_lines.extend(extra_entries)
                final_lines.append(line)

            file_content = ('\n'.join(final_lines) + '\n').encode('utf-8')
            filesize = len(file_content)

            # Update filesize in header (8 hex characters)
            new_header = (
                header_bytes[:54] +
                f"{filesize:08X}".encode('ascii') +
                header_bytes[62:]
            )
            header_bytes = new_header
            fstab_patched = True

        new_cpio_entries.append((header_bytes, (name + '\x00').encode('ascii'), file_content))

        next_idx = content_start + len(ramdisk_cpio[content_start:content_start+int(ramdisk_cpio[idx+54:idx+62], 16)])
        if next_idx % 4 != 0:
            next_idx += 4 - (next_idx % 4)
        idx = next_idx
        if name == 'TRAILER!!!':
            break

    if not fstab_patched:
        print("[!] Warning: No fstab.default found in ramdisk; repacking with cmdline patch only.")

    # Reassemble CPIO
    rebuilt_cpio = bytearray()
    for h, n, c in new_cpio_entries:
        rebuilt_cpio.extend(h)
        rebuilt_cpio.extend(n)
        while len(rebuilt_cpio) % 4 != 0:
            rebuilt_cpio.append(0)
        rebuilt_cpio.extend(c)
        while len(rebuilt_cpio) % 4 != 0:
            rebuilt_cpio.append(0)

    # Re-compress ramdisk with gzip
    if is_gzip:
        new_ramdisk = gzip.compress(bytes(rebuilt_cpio), mtime=0)
    else:
        new_ramdisk = bytes(rebuilt_cpio)

    new_rsize = len(new_ramdisk)
    print(f"[*] Patched ramdisk size: {new_rsize}b")

    # Reconstruct boot header (v2)
    new_cmdline_bytes = cmdline.encode('ascii')[:512].ljust(512, b'\x00')
    hdr_bytearray = bytearray(hdr)
    hdr_bytearray[16:20] = struct.pack('<I', new_rsize)
    hdr_bytearray[64:64+512] = new_cmdline_bytes

    # Assemble final boot image
    out_boot = bytearray()
    out_boot.extend(hdr_bytearray)
    while len(out_boot) % psize != 0:
        out_boot.append(0)

    out_boot.extend(kernel_data)
    while len(out_boot) % psize != 0:
        out_boot.append(0)

    out_boot.extend(new_ramdisk)
    while len(out_boot) % psize != 0:
        out_boot.append(0)

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, 'wb') as f:
        f.write(out_boot)

    print(f"[SUCCESS] Patched boot image generated: {out_path} ({len(out_boot)} bytes)")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: patch_boot.py <input_boot.img> <output_boot.img>")
        sys.exit(1)
    patch_boot_image(sys.argv[1], sys.argv[2])
