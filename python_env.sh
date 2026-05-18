#!/data/data/com.termux/files/usr/bin/bash
# ── Python Environment Module ────────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

VENVS_DIR="$HOME/.powerkit/venvs"
mkdir -p "$VENVS_DIR"

py_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   🐍  PYTHON ENVIRONMENT        ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  Python version info"
  echo -e "  [2]  Manage virtual environments"
  echo -e "  [3]  Install packages (pip)"
  echo -e "  [4]  List installed packages"
  echo -e "  [5]  Update all packages"
  echo -e "  [6]  Run Python script"
  echo -e "  [7]  Launch Jupyter Notebook"
  echo -e "  [8]  Quick HTTP server"
  echo -e "  [9]  Install popular data science stack"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) py_version ;;
    2) py_venv ;;
    3) py_install ;;
    4) py_list ;;
    5) py_upgrade ;;
    6) py_run ;;
    7) py_jupyter ;;
    8) py_httpserver ;;
    9) py_datascience ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; py_menu ;;
  esac
}

py_version() {
  echo ""
  require python3 || { pause; py_menu; return; }
  python3 -c "
import sys, platform
print(f'  Python     : {sys.version}')
print(f'  Platform   : {platform.platform()}')
print(f'  Executable : {sys.executable}')
print(f'  Pip version: ', end='')
import subprocess
r = subprocess.run(['pip', '--version'], capture_output=True, text=True)
print(r.stdout.strip())
"
  pause; py_menu
}

py_venv() {
  echo ""
  echo -e "${CYAN}  ── Virtual Environments ────────────────${RESET}"
  echo -e "  [1] Create new venv"
  echo -e "  [2] List venvs"
  echo -e "  [3] Activate venv"
  echo -e "  [4] Delete venv"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c

  case "$c" in
    1)
      read -rp "  Name: " name
      python3 -m venv "$VENVS_DIR/$name"
      echo -e "  ${OK} Created: $VENVS_DIR/$name"
      echo -e "  ${INFO} Activate: source $VENVS_DIR/$name/bin/activate"
      ;;
    2)
      echo ""
      ls "$VENVS_DIR" 2>/dev/null | sed 's/^/  🐍 /' || echo "  No venvs found."
      ;;
    3)
      echo "  Available:"; ls "$VENVS_DIR" 2>/dev/null | sed 's/^/    /'
      read -rp "  Name: " name
      echo -e "  ${INFO} Run: source $VENVS_DIR/$name/bin/activate"
      ;;
    4)
      echo "  Available:"; ls "$VENVS_DIR" 2>/dev/null | sed 's/^/    /'
      read -rp "  Name to delete: " name
      confirm "Delete $name?" && rm -rf "$VENVS_DIR/$name" && echo -e "  ${OK} Deleted."
      ;;
  esac
  pause; py_menu
}

py_install() {
  echo ""
  read -rp "  Package(s) to install (space-separated): " pkgs
  echo ""
  pip install $pkgs 2>&1 | tail -5
  pause; py_menu
}

py_list() {
  echo ""
  pip list 2>/dev/null | column | sed 's/^/  /'
  pause; py_menu
}

py_upgrade() {
  echo -e "\n  ${ARROW} Upgrading all pip packages...\n"
  pip list --outdated --format=freeze 2>/dev/null | \
    grep -v '^\-e' | cut -d = -f 1 | \
    xargs -n1 pip install -U 2>&1 | grep -E 'Successfully|already' | sed 's/^/  /'
  echo -e "\n  ${OK} Done."
  pause; py_menu
}

py_run() {
  echo ""
  read -rp "  Script path: " script
  [[ ! -f "$script" ]] && { echo -e "${RED}  File not found${RESET}"; pause; py_menu; return; }
  echo ""
  python3 "$script"
  pause; py_menu
}

py_jupyter() {
  if ! command -v jupyter &>/dev/null; then
    echo -e "  ${INFO} Install: pip install jupyter"
    read -rp "  Install now? [y/N]: " yn
    [[ "$yn" =~ ^[Yy]$ ]] && pip install jupyter
  else
    echo -e "  ${ARROW} Starting Jupyter Notebook..."
    echo -e "  ${INFO} Open browser to: http://localhost:8888"
    jupyter notebook --ip=0.0.0.0 2>&1
  fi
  pause; py_menu
}

py_httpserver() {
  echo ""
  read -rp "  Port [8080]: " port
  port="${port:-8080}"
  read -rp "  Directory [current]: " dir
  dir="${dir:-.}"
  echo -e "\n  ${OK} Serving ${dir} on http://0.0.0.0:${port}"
  echo -e "  ${INFO} Ctrl+C to stop\n"
  python3 -m http.server "$port" --directory "$dir"
  pause; py_menu
}

py_datascience() {
  echo -e "\n  ${INFO} Installing data science stack..."
  echo -e "  ${INFO} This may take a while...\n"
  local pkgs=(numpy pandas matplotlib seaborn scikit-learn jupyter ipython requests beautifulsoup4)
  for pkg in "${pkgs[@]}"; do
    echo -ne "  Installing $pkg..."
    pip install "$pkg" -q && echo -e " ${OK}" || echo -e " ${FAIL}"
  done
  echo -e "\n  ${OK} Data science stack ready!"
  pause; py_menu
}

py_menu
