#!/bin/bash
set -x

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
chmod o=r /etc/pacman.conf
chown root /etc/default/grub
chmod u=r /etc/default/grub
chmod g=r /etc/default/grub
chmod o=r /etc/default/grub

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
pacman -S --noconfirm cups{,-pdf} avahi nss-mdns sane-airscan
mv nsswitch.conf /etc/nsswitch.conf
echo "Finished CUPS setup."

# Setup Bluetooth
echo "Setting up bluetooth"
pacman -S --noconfirm bluez bluez-utils 

# Install snapper
echo "Setting up snapper..."
pacman -S --noconfirm snapper snap-pac
snapper -c root create-config /
echo "Finished snapper setup."

# Install grub
echo "Installing GRUB..."
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
grub-mkconfig -o /boot/grub/grub.cfg
echo "Finished GRUB install"

# Installing sudo and su
pacman -S --noconfirm sudo util-linux

# Setup user with zsh
echo "Setting up user with zsh..."
pacman -S --noconfirm zsh xdg-user-dirs
useradd -m -G wheel -s /usr/bin/zsh "$USER"
echo "Set user password..."
passwd "$USER"
pacman -S --noconfirm grml-zsh-config

# Install yay and pamac-aur
pacman -S --noconfirm --needed git base-devel
cd /home/"$USER"
echo "Enter user password..."
sudo -u "$USER" git clone https://aur.archlinux.org/yay.git
cd yay
sudo -u "$USER" /usr/bin/bash makepkg -si
cd ..
sudo -u "$USER" yay -Syy
sudo -u "$USER" yay -S pamac-aur
rm -rf yay
cd /

# Setup Oh My ZSH
mv omz_install.sh /home/"$USER"/
mv omz_post_install.sh /home/"$USER"/
chown "$USER" /home/"$USER"/omz_install.sh
chmod +x /home/"$USER"/omz_install.sh
sudo -u "$USER" ./home/"$USER"/omz_install.sh
rm /home/"$USER"/omz_install.sh

# Setup plymouth
echo "Setting up plymouth..."
sudo -u "$USER" yay -S plymouth-git plymouth-theme-arch-agua
plymouth-set-default-theme -R arch-agua
echo "Finished plymouth setup."


# Enable services assumed from default package install list
systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable snapper-cleanup.timer
systemctl enable cups.service
systemctl enable avahi-daemon.service
systemctl enable bluetooth.service

cd /
rm post_install.sh






