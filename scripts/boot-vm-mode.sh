#!/bin/bash

# --- CONFIGURATION ---
# The string to add to GRUB
VFIO_GRUB_PARAMS="amd_iommu=on iommu=pt vfio-pci.ids=10de:2520,10de:228e"
# The IDs for the modprobe file
GPU_IDS="10de:2520,10de:228e"

echo "Checking system state..."

# 1. HANDLE GRUB
# Check if params are already present
if grep -q "vfio-pci.ids" /etc/default/grub; then
    echo "GRUB is already configured for VFIO. Skipping GRUB edit."
else
    echo "Backing up GRUB..."
    cp /etc/default/grub /etc/default/grub.bak
    
    echo "Injecting VFIO parameters into GRUB..."
    # This sed command prepends your params inside the quotes of GRUB_CMDLINE_LINUX_DEFAULT
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$VFIO_GRUB_PARAMS /" /etc/default/grub
    
    echo "Updating GRUB..."
    update-grub
fi

# 2. HANDLE MODPROBE
echo "Creating /etc/modprobe.d/vfio.conf..."
cat <<EOF > /etc/modprobe.d/vfio.conf
options vfio-pci ids=$GPU_IDS
softdep nvidia pre: vfio-pci
EOF

# 3. UPDATE INITRAMFS
# Required to ensure vfio-pci is attached early in the boot process
echo "Updating Initramfs..."
update-initramfs -u

echo "----------------------------------------------------"
echo "DONE! VFIO mode enabled."
echo "Please REBOOT your system for changes to take effect."
echo "----------------------------------------------------"
