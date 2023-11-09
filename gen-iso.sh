#!/usr/bin/env bash
set -o pipefail -e

postscript="$(mktemp)"
echo -e '#!/bin/bash\npoweroff' > "${postscript}"

butane --pretty --strict --files-dir . ./server.bu > ./server.ign

rm -f ./fcos-image.iso

# /dev/disk/by-id/ata-Intenso_SSD_Sata_III_AYSNU0412OUT001587

coreos-installer iso customize \
    --dest-device /dev/disk/by-id/nvme-Samsung_SSD_950_PRO_512GB_S2GMNX0H918030M \
    --dest-ignition server.ign \
    --post-install "${postscript}" \
    --output fcos-image.iso "$@"

rm -f "${postscript}"

sudo dd if=fcos-image.iso of=/dev/disk/by-id/usb-USB_SanDisk_3.2Gen1_04019291b4b401a913da1b979ce4a7f3892c4631cb848f0ccde379e17b35055c7fe200000000000000000000f88b10a6ff9e0e188155810712ac409f-0:0 status=progress
