#!/bin/bash

if [[ "$EUID" -eq 0 ]]; then
  echo "Please do not run this script as root. Use a regular user with sudo access."
  exit 1
fi

echo "==> Updating system..."
sudo pacman -Syu --noconfirm

echo "==> Installing base-devel and git (required for yay)..."
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v yay &> /dev/null; then
  echo "==> Installing yay..."
  cd ~
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
fi

echo "==> Installing dunst..."

if ! command -v dunst &> /dev/null; then
  git clone https://github.com/dunst-project/dunst.git
  cd dunst
  make
  sudo make install
fi

echo "==> Installing packages..."

PKGS=(
  git
  alacritty
  zsh
  zsh-completions
  wofi
  vim
  openssh
  pavucontrol
  ttf-dejavu
  ttf-liberation
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  discord
  waybar
  dosfstools
  python-pip
  playerctl
)

sudo pacman -S --noconfirm "${PKGS[@]}"

AUR_PKGS=(
  hyprland
  hyprpaper
  spotify
  zen-browser-bin
  obsidian
  notion-app-enhanced
  pokemon-colorscripts
  bitwarden
  waybar
  oh-my-zsh-git
  visual-studio-code-bin
  thunar-git
  insomnia
)

yay -S --noconfirm "${AUR_PKGS[@]}"

echo "==> Setting Zsh as the default shell..."
chsh -s /bin/zsh

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Moving config files..."
mkdir -p ~/.config
cp -r dotfiles/dunst ~/.config/
cp -r dotfiles/.wallpaper ~/.config/
cp -r dotfiles/waybar ~/.config/
cp -r dotfiles/wofi ~/.config/
cp -r dotfiles/hypr ~/.config/

echo "==> Moving home configuration files..."
cp dotfiles/.vimrc ~/
cp dotfiles/.zshrc ~/

rm -rf dotfiles

echo "==> Updating font cache..."
fc-cache -fv

echo "==> Enabling and starting SSH service..."
sudo systemctl enable sshd
sudo systemctl start sshd

echo "==> All done!"

echo "==> Rebooting in 3 seconds..."
for i in 3 2 1; do
  echo "$i..."
  sleep 1
done

sudo reboot
