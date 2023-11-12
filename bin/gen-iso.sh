#!/usr/bin/env -S bash -eo pipefail
workdir="$(dirname "$0")/.."

# /dev/disk/by-id/ata-Intenso_SSD_Sata_III_AYSNU0412OUT001587
flash_disk='/dev/disk/by-id/usb-USB_SanDisk_3.2Gen1_04019291b4b401a913da1b979ce4a7f3892c4631cb848f0ccde379e17b35055c7fe200000000000000000000f88b10a6ff9e0e188155810712ac409f-0:0'

echo -e '#!/bin/bash\npoweroff' > "$workdir/post.sh"

"$workdir/bin/butane.sh" --pretty --strict --output "$workdir/server.ign"

rm -f "$workdir/fcos-custom.iso"


coreos-installer iso customize \
    --dest-device /dev/disk/by-id/nvme-Samsung_SSD_950_PRO_512GB_S2GMNX0H918030M \
    --dest-ignition "$workdir/server.ign" \
    --post-install "$workdir/post.sh" \
    --output "$workdir/fcos-custom.iso" "$@"

rm -f "$workdir/post.sh" "$workdir/server.ign" "$workdir/server.bu"

sudo dd if="$workdir/fcos-custom.iso" of="$flash_disk" status=progress

rm -f "$workdir/fcos-custom.iso"