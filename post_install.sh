#!/bin/bash
# variables to change for specific installation
export HOSTNAME=arch-desktop
export USER=user

# fix some file permissions
chown root /etc/mkinitcpio.conf
chmod u=rw /etc/mkinitcpio.conf
chmod g=r /etc/mkinitcpio.conf
chmod o=r /etc/mkinitcpio.conf
chown root /etc/locale.conf
chmod u=rw /etc/locale.conf
chmod g=r /etc/locale.conf
chmod o=r /etc/locale.conf
chown root /etc/locale.gen
chmod u=rw /etc/locale.gen
chmod g=r /etc/locale.gen
chmod o=r /etc/locale.gen
chown root /etc/sudoers
chmod u=r /etc/sudoers
chmod g=r /etc/sudoers
chmod o= /etc/sudoers
chown root /etc/pacman.conf
chmod u=r /etc/pacman.conf
chmod g=r /etc/pacman.conf
chmod o= /etc/pacman.conf

# Timezone
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc

# Localization
echo "Locale generation..."
locale-gen
echo "Locale generation complete."

# Host name
echo "Setting hostname..."
echo "$HOSTNAME" > /etc/hostname
echo "Finished setting hostname."

# Set root password
echo "Enter root password..."
passwd

# Setup CUPS
echo "Setting up CUPS..."
pacman -Syu cups{,-pdf} avahi
echo "Finished CUPS setup."

# Setup Bluetooth
echo "Setting up bluetooth"
pacman -Syu bluez bluez-utils 

# Install snapper
echo "Setting up snapper..."
pacman -Syu snappper snap-pac
snapper -c root create-config /
echo "Finished snapper setup."

# Install grub
echo "Installing GRUB..."
pacman -Syyu grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
grub-mkconfig -o /boot/grub/grub.cfg
echo "Finished GRUB install"

# Installing sudo and su
pacman -S sudo su

# Setup user with oh-my-zsh
echo "Setting up user with zsh..."
pacman -S zsh xdg-user-dirs
useradd -m -G wheel -s /usr/bin/zsh "$USER"
echo "Set user password..."
passwd "$USER"
pacman -S grml-zsh-config
cp omz_install.sh /home/"$USER"/
cp .zshrc /home/"$USER"/.zshrc.omz

# Install yay and pamac-aur
pacman -S --needed git base-devel && cd /home/"$USER" && echo "Enter user password..."  && su "$USER" -c "git clone https://aur.archlinux.org/yay.git" && cd yay && sudo -u "$USER" /usr/bin/bash makepkg -si
cd ..
rm -rf yay
yay -Syu pamac-aur
cd /

# Setup plymouth
echo "Setting up plymouth..."
sudo -u "$USER" yay -Syu plymouth-git plymouth-theme-arch-agua
plymouth-set-default-theme -R arch-agua
echo "Finished plymouth setup. To enable add quiet splash vt.global_cursor_default=0 to kernel parameters"


# Enable services assumed from default package install list
systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable snapper-cleanup.timer
systemctl enable cups.service
systemctl enable avahi-daemon.service
systemctl enable bluetooth.service

cd /
rm .zshrc
rm omz_install.sh
rm post_install.sh






