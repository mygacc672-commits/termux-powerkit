# ⚡ termux-powerkit

> A powerful, modular toolkit for Termux — network tools, system monitoring, security, dev environment, SSH management, and more. All in one interactive menu.

```
╔══════════════════════════════════════════════════════╗
║      ⚡  TERMUX  P O W E R K I T  v2.0  ⚡          ║
╚══════════════════════════════════════════════════════╝
```

---

## Features

| Module | Description |
|--------|-------------|
| 📡 **Network** | IP info, ping, port scan, DNS, traceroute, WiFi, headers, speed test |
| 🖥️ **System** | CPU, memory, storage, battery, processes, live monitor |
| 🔐 **Security** | Hash tools, password gen, subdomain finder, recon, SSL inspector |
| 📁 **File Manager** | Browse, search, archive, extract, bulk rename, dedup |
| 📦 **Packages** | Update, search, install, essential/hacking tool bundles |
| 🐍 **Python** | venv manager, pip, Jupyter, HTTP server, data science stack |
| 🌐 **Web Tools** | cURL builder, site checker, WHOIS, scraper, yt-dlp, Wayback |
| 🔧 **Dev Tools** | Git, Node.js, compile, JSON, Base64, cron, UUID |
| 🔑 **SSH Manager** | Saved hosts, key generation, SSH server, port forwarding |

---

## Quick Install

```bash
# One-line install (from Termux)
pkg install git -y && git clone https://github.com/YOUR_USERNAME/termux-powerkit && cd termux-powerkit && bash install.sh
```

Or manually:
```bash
git clone https://github.com/YOUR_USERNAME/termux-powerkit
cd termux-powerkit
chmod +x install.sh
bash install.sh
```

---

## Usage

After installation:
```bash
powerkit
```

Or run directly:
```bash
bash ~/.termux-powerkit/powerkit.sh
```

Run individual modules:
```bash
bash ~/.termux-powerkit/modules/network.sh
bash ~/.termux-powerkit/modules/security.sh
```

---

## Enhanced Shell (Optional)

Add powerful aliases, a git-aware prompt, and utility functions to your shell:

```bash
# Add to your ~/.bashrc or ~/.zshrc:
source ~/.termux-powerkit/config/bashrc_extras.sh
```

Includes:
- Colorized prompt with git branch display
- 50+ time-saving aliases (`ll`, `gs`, `py`, `myip`, `extract`, ...)
- Useful functions: `mkcd`, `backup`, `weather`, `cheat`, `qr`, `ipinfo`

---

## Module Details

### 📡 Network Toolkit
- My IP (public + geolocation + local interfaces)
- Ping test with configurable count
- Port scanner (quick/full/version/UDP via nmap)
- DNS lookup (A, MX, NS, TXT, reverse)
- HTTP headers inspector
- WiFi info (requires Termux:API)
- Download manager with resume support
- Speed test via speedtest-cli

### 🔐 Security Toolkit
> ⚠️ **For educational and authorized testing ONLY. Never use on systems you don't own.**

- Hash generator (MD5/SHA1/SHA256/SHA512) + wordlist cracker
- Secure password generator (configurable length/count)
- Subdomain enumeration via crt.sh
- Directory brute-force (gobuster)
- SQL injection test (sqlmap)
- Login brute-force (hydra)
- Recon: WHOIS + Shodan InternetDB
- SSL/TLS certificate inspector

### 🔑 SSH Manager
- Save and quickly connect to multiple SSH hosts
- SSH key generation (Ed25519 or RSA-4096)
- ssh-copy-id integration
- Start SSH server on your device (port 8022)
- Local, remote, and SOCKS5 port forwarding

### 🐍 Python Environment
- Version info and pip management
- Named virtual environments manager
- Jupyter Notebook launcher
- One-command data science stack install (numpy, pandas, matplotlib, sklearn, ...)

---

## Requirements

- **Termux** (latest from F-Droid recommended)
- Internet connection for first-time package installs
- Some modules require **Termux:API** app (battery, WiFi info, notifications)

### Base dependencies (auto-installed)
```
curl wget git python python-pip openssh net-tools bc
```

### Optional dependencies (per module)
```
nmap hydra sqlmap gobuster whois dnsutils
speedtest-cli yt-dlp jupyter nodejs gcc
```

---

## Directory Structure

```
termux-powerkit/
├── powerkit.sh              # Main launcher
├── install.sh               # Installer
├── README.md
├── config/
│   ├── colors.sh            # ANSI colors
│   ├── globals.sh           # Shared variables & utilities
│   └── bashrc_extras.sh     # Optional shell enhancements
└── modules/
    ├── network.sh
    ├── sysinfo.sh
    ├── security.sh
    ├── filemanager.sh
    ├── packages.sh
    ├── python_env.sh
    ├── webtools.sh
    ├── devtools.sh
    └── ssh_manager.sh
```

---

## Uninstall

```bash
rm -rf ~/.termux-powerkit
rm -f $PREFIX/bin/powerkit
# Also remove the source line from ~/.bashrc if added
```

---

## Contributing

PRs and issues welcome! To add a new module:
1. Create `modules/yourmodule.sh` using the existing modules as templates
2. Add a menu entry in `powerkit.sh`
3. Source `config/colors.sh` and `config/globals.sh` at the top

---

## License

MIT — see [LICENSE](LICENSE)

---

> Made for hackers, devs, and power users on Android 🤖
