#!/usr/bin/env bash
# ENFILADE installer — CachyOS / Arch. Idempotent: run it again any time.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
say()  { printf '\n\033[1;36m──▸ %s\033[0m\n' "$*"; }
note() { printf '\033[0;33m    %s\033[0m\n' "$*"; }

# ── 0 · AUR helper ───────────────────────────────────────────────────────────
if command -v paru >/dev/null; then AUR=paru
elif command -v yay >/dev/null; then AUR=yay
else say "Bootstrapping paru"; sudo pacman -S --needed --noconfirm base-devel git
     t=$(mktemp -d); git clone https://aur.archlinux.org/paru-bin.git "$t"
     (cd "$t" && makepkg -si --noconfirm); AUR=paru
fi

# ── 1 · Official repos ───────────────────────────────────────────────────────
say "Official packages (pacman)"
sudo pacman -S --needed --noconfirm \
  hyprland hyprlock hypridle hyprpicker xdg-desktop-portal-hyprland \
  kitty waybar fuzzel mako swww \
  polkit-gnome qt5-wayland qt6-wayland \
  pipewire pipewire-pulse wireplumber playerctl wiremix pavucontrol \
  mpd mpc rmpc cava \
  yazi btop lazygit fastfetch starship \
  bluez bluez-utils \
  khal vdirsyncer \
  grim slurp satty cliphist wl-clipboard \
  brightnessctl jq socat fish fzf zoxide eza bat ripgrep fd \
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols noto-fonts noto-fonts-emoji \
  steam obsidian firefox zathura zathura-pdf-mupdf imv mpv
# steam: enable [multilib] in /etc/pacman.conf first if it errors.

# ── 2 · AUR ──────────────────────────────────────────────────────────────────
say "AUR packages ($AUR)"
$AUR -S --needed --noconfirm \
  bluetui \
  calcure \
  swayosd-git \
  vesktop-bin \
  mpd-mpris \
  python-pillow                      # endcord media rendering dep
# endcord — prefer AUR, fall back to upstream pipx:
if ! $AUR -S --needed --noconfirm endcord 2>/dev/null; then
  note "endcord not in AUR mirror right now → installing from source via pipx"
  sudo pacman -S --needed --noconfirm python-pipx
  pipx install 'git+https://github.com/sparklost/endcord' || \
    note "endcord skipped — install later; CABLES works with Vesktop alone."
fi

# ── 3 · The wifi decision (read this one) ────────────────────────────────────
say "Wi-Fi TUI — impala needs the iwd backend"
note "CachyOS ships NetworkManager. Options:"
note "  [1] Keep NetworkManager, use it with the iwd backend  → impala works"
note "  [2] Keep NetworkManager as-is                          → nmtui fallback"
read -rp "    choose [1/2, default 2]: " wifi; wifi=${wifi:-2}
if [ "$wifi" = 1 ]; then
  sudo pacman -S --needed --noconfirm iwd impala
  sudo mkdir -p /etc/NetworkManager/conf.d
  printf '[device]\nwifi.backend=iwd\n' | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf >/dev/null
  sudo systemctl restart NetworkManager
  note "impala installed; NM now drives wifi through iwd."
else
  note "Skipping impala. SUPER+W will open nmtui in the same console skin."
fi

# ── 4 · System24 theme for Vesktop (the ToS-safe terminal costume) ───────────
say "system24 — TUI-style Discord theme"
mkdir -p "$CFG/vesktop/themes"
curl -fsSL \
  https://raw.githubusercontent.com/refact0r/system24/main/theme/system24.theme.css \
  -o "$CFG/vesktop/themes/system24.theme.css" \
  || note "fetch failed — grab it later from github.com/refact0r/system24"
cp "$DIR/apps/vesktop/enfilade-cables.theme.css" "$CFG/vesktop/themes/" 2>/dev/null || true

# ── 5 · Link configs ─────────────────────────────────────────────────────────
say "Linking configs into $CFG"
# Anything already living at a target path (e.g. illogical-impulse's dirs) is
# moved — not deleted — into a timestamped backup. Re-runs skip our own links.
BK="$CFG/enfilade-backup-$(date +%Y%m%d-%H%M%S)"
keep() {
  local t="$1"
  if [ -e "$t" ] || [ -L "$t" ]; then
    case "$(readlink -f "$t" 2>/dev/null)" in "$DIR"/*) return 0;; esac
    mkdir -p "$BK"; mv "$t" "$BK/"
    printf '    \033[0;33m↪ existing %s → %s\033[0m\n' "$(basename "$t")" "$BK"
  fi
}
link() { mkdir -p "$(dirname "$CFG/$2")"; keep "$CFG/$2"; ln -sfT "$DIR/$1" "$CFG/$2"; printf '    %s\n' "$2"; }
link hypr               hypr
link kitty              kitty
link waybar             waybar
link fuzzel             fuzzel
link mako               mako
link engine             enfilade/engine
link tuis/yazi          yazi
link tuis/btop          btop
link tuis/rmpc          rmpc
link tuis/lazygit       lazygit
link tuis/calcure       calcure
link tuis/cava          cava
link tuis/wiremix       wiremix
link tuis/fastfetch     fastfetch
link tuis/mpd           mpd
link apps/endcord       endcord
mkdir -p "$CFG/fish/conf.d"; ln -sf "$DIR/fish/enfilade.fish" "$CFG/fish/conf.d/enfilade.fish"
mkdir -p "$HOME/.local/bin"
for s in "$DIR"/scripts/*; do ln -sf "$s" "$HOME/.local/bin/$(basename "$s")"; done
chmod +x "$DIR"/scripts/* "$DIR/engine/spaced"

# starship: per-room accent comes from ANSI, one config suffices
keep "$CFG/starship.toml"
ln -sf "$DIR/tuis/starship.toml" "$CFG/starship.toml"
[ -d "$BK" ] && note "Previous configs parked in $BK — rollback = move them back."

# ── 6 · Runtime state, walls, services ───────────────────────────────────────
say "Runtime state & services"
mkdir -p "$CFG/enfilade" "$HOME/Pictures/walls" "$HOME/.local/share/mpd/playlists"
ln -sfn "$DIR/engine/spaces/1-atelier" "$CFG/enfilade/current"
touch "$HOME/.local/share/mpd/"{database,state}
systemctl --user enable --now mpd.service mpd-mpris.service 2>/dev/null || true
sudo systemctl enable --now bluetooth.service
note "Drop six wallpapers in ~/Pictures/walls/ named:"
note "  atelier.* cables.* archive.* listening.* canvas.* arcade.*  (any ext)"

# ── 7 · Obsidian canvas kit ──────────────────────────────────────────────────
say "Obsidian / Excalidraw kit"
note "Vault path needed to place the CSS snippet + template:"
read -rp "    vault path (blank = skip, do manually per apps/obsidian/README): " VAULT
if [ -n "${VAULT:-}" ] && [ -d "$VAULT" ]; then
  mkdir -p "$VAULT/.obsidian/snippets" "$VAULT/Canvas/templates"
  cp "$DIR/apps/obsidian/snippets/enfilade-canvas.css" "$VAULT/.obsidian/snippets/"
  cp "$DIR/apps/obsidian/templates/Canvas Template.md" "$VAULT/Canvas/templates/"
  note "Now in Obsidian: enable the snippet (Appearance→CSS snippets) and set"
  note "Excalidraw → Basic → Template file = Canvas/templates/Canvas Template.md"
fi

say "Done. Log out → pick Hyprland → SUPER+1..6 walks the rooms."
note "First run: SUPER+SHIFT+R reloads, 'enfilade-doctor' sanity-checks."
