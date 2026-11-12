# dotfiles

> **Modern, modular, and cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/) and built upon [grml-zsh-config](https://grml.org/zsh/).**

Designed for smooth operation across **macOS** development workstations, **Linux** desktop machines, and **remote headless servers** (VPS, containers, jump hosts).

---

## 🌟 Highlights & Philosophy

* **Tiered Architecture (Base + Local Modular)**:
  * **Base layer**: Leverages [grml-zsh-config](https://grml.org/zsh/) for rock-solid shell options, Zstyle completions, and robust `vcs_info`.
  * **Modular local layer**: A clean `~/.zshrc.local` dynamically loads modular configuration fragments (`0*.zsh`), while conditionally injecting platform-specific setups (`80-darwin.zsh`, `80-linux.zsh`) via chezmoi templates.
* **Graceful Degradation (Tool Probing)**:
  * Opportunistic detection for modern CLI utilities (`starship`, `zoxide`, `eza`, `bat`, `fzf`).
  * If installed, modern enhancements activate automatically; if absent, the shell seamlessly falls back to standard coreutils and native prompts with zero errors or lag.
* **Zero-Install Server Capsule**:
  * Includes a standalone `server.zshrc.local` file that can be `curl`ed onto any server in seconds without cloning the repository or installing chezmoi.
* **Security & Privacy First**:
  * SSH configuration is split into public rules (in Git) and local uncommitted topologies (`Include config.local`, `Include config.d/*`).
  * `.chezmoiignore` strictly blocks private keys (`id_*`, `*.ppk`), ephemeral state (`known_hosts`, `agent`), and internal network definitions.

---

## 📂 Repository Structure

```text
.
├── .chezmoiignore          # Prevents private keys, local configs, and metadata from syncing
├── dot_config/
│   ├── starship.toml       # Starship prompt configuration (2-line layout, textual git status)
│   └── fontconfig/         # Font fallback and emoji rendering configuration
├── dot_vimrc               # Vim editing configuration
├── dot_zsh/                # Modular Zsh components
│   ├── config.d/           # Numbered modular configs (options, completion, bindings, aliases, env, OS)
│   ├── functions/          # Custom helper functions (proxy_on/off, smartcd, mkcd, etc.)
│   └── Completion/         # Custom completion definitions
├── dot_zshrc               # Primary Zsh initialization (loads modules & hooks into zshrc.local)
├── dot_zshrc.local.tmpl    # Chezmoi template generating ~/.zshrc.local with OS-specific injection
├── private_dot_ssh/        # SSH client configuration (enforces strict 0600 / 0700 permissions)
│   ├── config              # Public client configuration (with local include directives)
│   └── allowed_signers     # Public SSH keys trusted for git commit signing
├── server.zshrc.local      # Standalone single-file Zsh config for remote headless servers
└── bin/                    # User scripts and CLI utilities
```

---

## 🚀 Quick Start & Installation

### Option 1: Full Workstation Setup (macOS / Linux Desktop)

Using [chezmoi](https://www.chezmoi.io/) to manage and synchronize configuration files:

```bash
# 1. Install chezmoi (macOS: brew install chezmoi, Arch: pacman -S chezmoi, etc.)
# 2. Initialize and apply this dotfiles repository
chezmoi init --apply KenOokamiHoro

# Or, if working from an existing local clone:
mkdir -p ~/.local/share
ln -sfn ~/dotfiles ~/.local/share/chezmoi
chezmoi apply -v
```

### Option 2: Remote Headless Servers (Zero-Toolchain Setup)

For cloud VPS, testing containers, or minimal remote servers where you do not wish to install chezmoi or clone the full repository:

```bash
# 1. Install grml-zsh-config (available in Debian/Ubuntu/Arch repositories)
#    Or download grml's single .zshrc:
curl -fLo ~/.zshrc https://git.grml.org/f/grml-etc-core/etc/zsh/zshrc

# 2. Download the standalone local configuration
curl -fLo ~/.zshrc.local https://raw.githubusercontent.com/KenOokamiHoro/dotfiles/master/server.zshrc.local
```

### Option 3: Ephemeral Bootstrap (`--one-shot`)

If you want the complete dotfiles rendered on a server without leaving chezmoi or git state behind:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot KenOokamiHoro
```

---

## 💡 Cherry-Picking Guide (How to Borrow Parts)

If you only want specific features from this setup for your own dotfiles:

### 1. Starship Prompt with Readable Text Git Status
* **File**: `dot_config/starship.toml`
* **Features**:
  * Clean two-line prompt with full un-truncated directory path (`truncation_length = 0`).
  * Git status uses human-readable textual labels (`[modified]`, `[staged]`, `[untracked]`) instead of obscure symbols.
  * Right-side status showing high-contrast clock and execution time.

### 2. Graceful Degradation Aliases
* **File**: `dot_zsh/config.d/03-alias.zsh`
* **Features**:
  * Automatically switches between `eza` $\to$ `lsd` $\to$ native `ls` based on binary availability.
  * Safe defaults (no custom glyphs by default to prevent broken question marks without Nerd Fonts).
  * `cat` fallback to `bat --paging=never`.
  * Quick network proxy toggles (`proxy_on [port]`, `proxy_off`, `nonet`).

### 3. Layered `zshrc.local` Template
* **File**: `dot_zshrc.local.tmpl`
* **Features**:
  * Uses `{{- if eq .chezmoi.os "darwin" }}` to selectively load OS-specific paths and tools.
  * Guards against duplicate sourcing if running alongside an existing modular `.zshrc`.
  * Preserves an uncommitted hook for machine-local secrets (`~/.zshrc.local.private`).

### 4. Safe SSH Separation Architecture
* **Files**: `private_dot_ssh/config` and `.chezmoiignore`
* **Features**:
  * Keeps the public repository safe by including `Include config.local` and `Include config.d/*`.
  * Place internal server topologies, VPN jump hosts, and home LAN IPs in `~/.ssh/config.local` or `~/.ssh/config.d/`.
  * `.chezmoiignore` guarantees that private keys (`id_*`, `*.ppk`), internal configurations, and `known_hosts` remain local.

---

## 🔒 Security & Local Overrides

To keep private tokens, corporate proxies, and sensitive infrastructure strictly off Git:

1. **Shell secrets & local variables**:
   Place machine-specific exports in `~/.zshrc.local.private`. It is automatically sourced by `~/.zshrc.local` and ignored by Git.
2. **Private SSH hosts & jump boxes**:
   Place personal hosts and internal IP configs in `~/.ssh/config.local` or drop snippets into `~/.ssh/config.d/`.

---

## 🤝 Credits & Acknowledgements

* [grml-zsh-config](https://grml.org/zsh/) — Standard-setting, robust Zsh configuration base.
* [Lilydjwg (dotzsh)](https://github.com/lilydjwg/dotzsh) — Inspiring Zsh functions, zle widgets, and completion tricks.
* [chezmoi](https://www.chezmoi.io/) — Declarative personal configuration manager.
