!#/bin/bash

set -x

# Update System Clock
echo "Updating system clock..."
timedatectl set-ntp true
echo "Finished updating system clock."

# Partition Disk
echo "Formatting partitions and mounting..."
export EFIPART=/dev/sda1
export ROOTPART=/dev/sda2
mkfs.fat -F 32 "$EFIPART"
mkfs.btrfs "$ROOTPART"
mount "$ROOTPART" /mnt
btrfs subvol create /mnt/@ #root
btrfs subvol create /mnt/@home 
btrfs subvol create /mnt/@snapshots
btrfs subvol create /mnt/@var_log
btrfs subvol create /mnt/@vm_images 
umount /mnt
mount "$ROOTPART" /mnt -o subvol=@
mkdir /mnt/boot
mount "$EFIPART" /mnt/boot
mkdir /mnt/home
mount "$ROOTPART" /mnt/home -o subvol=@home
mkdir -p /mnt/var/log
mkdir -p /mnt/var/vm-images
mount "$ROOTPART" /mnt/var/log -o subvol=@var_log
mount "$ROOTPART" /mnt/var/vm-images -o subvol=@vm_images,nodatacow
echo "Finished partitioning."

# Install system and packages
echo "Installing system and packages listed in packages.txt..."
cp pacman.conf /etc/pacman.conf
pacman -Syy
pacstrap /mnt base linux linux-firmware $(cat packages.txt)
echo "Finished installation."

# Configure System
echo "Configuring system..."
cp mkinitcpio.conf /mnt/etc/mkinitcpio.conf
genfstab -U /mnt >> /mnt/etc/fstab
"Finished configuration."

# chroot and run post-install
"Post-installation..."
cp pacman.conf /mnt/etc/pacman.conf
cp grub /mnt/default/grub
cp sudoers /mnt/etc/sudoers
cp locale.conf /mnt/etc/locale.conf
cp locale.gen /mnt/etc/locale.gen
cp post_install.sh /mnt
cp .zshrc /mnt
cp omz_install.sh /mnt
arch-chroot /mnt sh post_install.sh
echo "Installation complete. Reboot the system."

