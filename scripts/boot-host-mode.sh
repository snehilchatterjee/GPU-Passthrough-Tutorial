#!/bin/bash
set -x

# --- CONFIGURATION ---
# These are the individual items we want to delete
PARAM1="amd_iommu=on"
PARAM2="iommu=pt"
# We escape the dots/colons for sed just to be safe, though usually not strictly required in simple substitution
PARAM3="vfio-pci.ids=10de:2520,10de:228e"

echo "Restoring Host Mode..."

# 1. HANDLE GRUB
# We remove each parameter individually. This is much safer.
# We replace them with an empty string.

# Remove amd_iommu=on
sed -i "s/$PARAM1//g" /etc/default/grub

# Remove iommu=pt
sed -i "s/$PARAM2//g" /etc/default/grub

# Remove vfio-pci.ids
sed -i "s/$PARAM3//g" /etc/default/grub

# CLEANUP:
# The removals above might leave double spaces (e.g., "  quiet splash").
# This command replaces any double space with a single space.
sed -i "s/  / /g" /etc/default/grub

# CLEANUP:
# Remove any accidental leading space at the start of the quote
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=" /GRUB_CMDLINE_LINUX_DEFAULT="/g' /etc/default/grub

echo "Updating GRUB..."
update-grub

# 2. HANDLE MODPROBE
if [ -f /etc/modprobe.d/vfio.conf ]; then
    echo "Removing /etc/modprobe.d/vfio.conf..."
    rm /etc/modprobe.d/vfio.conf
else
    echo "vfio.conf not found. Skipping."
fi

# 3. UPDATE INITRAMFS
echo "Updating Initramfs..."
update-initramfs -u

echo "----------------------------------------------------"
echo "DONE! NVIDIA Host mode restored."
echo "Please REBOOT your system."
echo "----------------------------------------------------"
