#!/usr/bin/env zsh
echo "Run this script using zsh omz_install.sh twice"

sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/chrissicool/zsh-256color ~/.oh-my-zsh/custom/plugins/zsh-256color
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
yay -Syu ttf-meslo-nerd-font-powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

echo "Run 'omz theme use 'powerlevel10k/powerlevel10k' && omz plugin load git zsh-autosuggestions history zsh-256color z sudo zsh-syntax-highlighting' to complete the installation."
