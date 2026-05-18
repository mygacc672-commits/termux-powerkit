#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  termux-powerkit — Installer
# ============================================================
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; WHITE='\033[1;37m'; RESET='\033[0m'

OK="${GREEN}[✔]${RESET}"
INFO="${CYAN}[i]${RESET}"
WARN="${YELLOW}[!]${RESET}"

INSTALL_DIR="$HOME/.termux-powerkit"
BIN_LINK="$PREFIX/bin/powerkit"

echo -e "${CYAN}"
cat << 'EOF'
  ╔══════════════════════════════════════════════════════╗
  ║      ⚡  TERMUX POWERKIT  —  INSTALLER              ║
  ╚══════════════════════════════════════════════════════╝
EOF
echo -e "${RESET}"
echo -e "  ${INFO} This will install termux-powerkit to: $INSTALL_DIR"
echo -e "  ${INFO} A 'powerkit' command will be added to PATH\n"
read -rp "  Continue? [Y/n]: " ans
[[ "$ans" =~ ^[Nn]$ ]] && echo "  Cancelled." && exit 0

# ── Step 1: Update repos ─────────────────────────────────────
echo -e "\n  ${INFO} Updating package lists..."
apt update -qq 2>/dev/null

# ── Step 2: Install base dependencies ───────────────────────
echo -e "  ${INFO} Installing dependencies...\n"
BASE_DEPS=(curl wget git python python-pip openssh net-tools bc)
for dep in "${BASE_DEPS[@]}"; do
  echo -ne "    $dep... "
  apt install -y "$dep" -qq 2>/dev/null && echo -e "${OK}" || echo -e "${WARN}"
done

# ── Step 3: Copy files ───────────────────────────────────────
echo -e "\n  ${INFO} Installing powerkit..."
rm -rf "$INSTALL_DIR"
cp -r "$(dirname "$0")" "$INSTALL_DIR"

# Make all scripts executable
find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;

# ── Step 4: Create bin symlink ───────────────────────────────
cat > "$BIN_LINK" << EOF2
#!/data/data/com.termux/files/usr/bin/bash
exec bash "$INSTALL_DIR/powerkit.sh" "\$@"
EOF2
chmod +x "$BIN_LINK"

# ── Step 5: Add to .bashrc / .zshrc ─────────────────────────
ALIAS_LINE='alias powerkit="bash ~/.termux-powerkit/powerkit.sh"'
for rcfile in "$HOME/.bashrc" "$HOME/.zshrc"; do
  if [[ -f "$rcfile" ]] && ! grep -q "powerkit" "$rcfile"; then
    echo "$ALIAS_LINE" >> "$rcfile"
  fi
done

# ── Done ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}  ╔══════════════════════════════════╗"
echo -e "  ║   ✅  Installation Complete!   ║"
echo -e "  ╚══════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${OK} Installed to: ${INSTALL_DIR}"
echo -e "  ${OK} Command:      ${WHITE}powerkit${RESET}"
echo ""
echo -e "  ${INFO} Start now:    ${CYAN}powerkit${RESET}"
echo -e "  ${INFO} Or:           ${CYAN}bash ~/.termux-powerkit/powerkit.sh${RESET}"
echo ""
