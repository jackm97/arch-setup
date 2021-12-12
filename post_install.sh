#!/bin/bash
# variables to change for specific installation
export HOSTNAME=arch-desktop
export USER=user

# Timezone
ln -sf /usr/share/zoneinfo/America/Los_Angeles
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

# Install yay and pamac-aur
pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -Syu pamac-aur

# Setup plymouth
echo "Setting up plymouth..."
yay -Syu plymouth-git plymouth-theme-arch-agua
plymouth-set-default-theme -R arch-agua
echo "Finished plymouth setup. To enable add quiet splash vt.global_cursor_default=0 to kernel parameters"

# Install snapper
echo "Setting up snapper..."
pacman -Syu snappper snap-pac
snapper -c root create-config /
echo "Finished snapper setup."

# Install grub
echo "Installing GRUB..."
pacman -Syyu grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
echo "Finished GRUB install"

# Installing sudo and su
pacman -S sudo su

# Setup user with oh-my-zsh
echo "Setting up user with oh-my-zsh..."
pacman -S zsh xdg-user-dirs
useradd -m -G wheel -s /usr/bin/zsh "$USER"
echo "Set user password..."
passwd "$USER"
pacman -S wget
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
( cd $ZSH_CUSTOM/plugins && git clone https://github.com/chrissicool/zsh-256color )
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
cp .zshrc /home/"$USER"


# Enable services assumed from default package install list
systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable snapper-cleanup.timer
systemctl enable cups.service
systemctl enable avahi-daemon.service
systemctl enable bluetooth.service

# fix some file permissions
chown root /etc/mkinitcipio.conf
chmod u=rw /etc/mkinitcipio.conf
chmod g=r /etc/mkinitcipio.conf
chmod o=r /etc/mkinitcipio.conf
chown root /etc/locale.conf
chmod u=rw /etc/locale.conf
chmod g=r /etc/locale.conf
chmod o=r /etc/locale.conf
chown root /etc/sudoers
chmod u=r /etc/sudoers
chmod g=r /etc/sudoers
chmod o= /etc/sudoers






