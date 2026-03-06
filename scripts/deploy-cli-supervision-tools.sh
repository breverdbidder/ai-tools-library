#!/bin/bash
###############################################################################
# CLI Supervision Tools - One-Command Deploy
# For: Ariel Shapira's WSL/Ubuntu environment
# Tools: jq, LazyGit, Zoxide + shell config
# Run: curl -sL <raw_url> | bash
###############################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; }

echo ""
echo "=========================================="
echo "  CLI Supervision Stack — BidDeed.AI"
echo "  LazyGit + Zoxide + jq"
echo "=========================================="
echo ""

# -----------------------------------------------------------
# 1. jq — JSON parsing for Supabase/LangGraph state debugging
# -----------------------------------------------------------
if command -v jq &>/dev/null; then
    log "jq already installed ($(jq --version))"
else
    warn "Installing jq..."
    sudo apt-get update -qq && sudo apt-get install -y -qq jq
    log "jq installed ($(jq --version))"
fi

# -----------------------------------------------------------
# 2. LazyGit — Visual commit review for Claude Code sessions
# -----------------------------------------------------------
if command -v lazygit &>/dev/null; then
    log "LazyGit already installed ($(lazygit --version | head -1))"
else
    warn "Installing LazyGit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    if [ -z "$LAZYGIT_VERSION" ]; then
        # Fallback version if GitHub API fails
        LAZYGIT_VERSION="0.44.1"
        warn "GitHub API rate limited, using fallback version ${LAZYGIT_VERSION}"
    fi
    curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    cd /tmp && tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin/
    rm -f /tmp/lazygit /tmp/lazygit.tar.gz
    log "LazyGit v${LAZYGIT_VERSION} installed"
fi

# -----------------------------------------------------------
# 3. Zoxide — Smart directory jumping across repos
# -----------------------------------------------------------
if command -v zoxide &>/dev/null; then
    log "Zoxide already installed ($(zoxide --version))"
else
    warn "Installing Zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    log "Zoxide installed"
fi

# -----------------------------------------------------------
# 4. Shell Configuration
# -----------------------------------------------------------
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    MARKER="# === BidDeed.AI CLI Supervision Tools ==="
    
    if grep -q "$MARKER" "$SHELL_RC" 2>/dev/null; then
        log "Shell config already present in $(basename $SHELL_RC)"
    else
        warn "Adding config to $(basename $SHELL_RC)..."
        cat >> "$SHELL_RC" << 'SHELLCONFIG'

# === BidDeed.AI CLI Supervision Tools ===

# Zoxide — smart cd replacement
# Usage: z zonewise → jumps to most-used zonewise directory
eval "$(zoxide init bash 2>/dev/null || zoxide init zsh 2>/dev/null)"

# LazyGit alias
alias lg="lazygit"

# Quick review aliases for 20-min oversight sessions
alias review="lazygit"
alias repos="cd ~/repos && ls -la"

# jq shortcuts for Supabase/API debugging
alias jqp="jq '.' -C | less -R"           # Pretty-print JSON with colors
alias jqkeys="jq 'keys'"                   # Show top-level keys
alias jqcount="jq 'length'"               # Count array items

# Quick Supabase query formatter (pipe curl output into this)
alias sqfmt="jq '.[] | {id, created_at, status}'"

# === End BidDeed.AI CLI Tools ===
SHELLCONFIG
        log "Shell config added to $(basename $SHELL_RC)"
    fi
else
    warn "No .bashrc or .zshrc found — skipping shell config"
fi

# -----------------------------------------------------------
# 5. Verify Installation
# -----------------------------------------------------------
echo ""
echo "=========================================="
echo "  Installation Summary"
echo "=========================================="

PASS=0
FAIL=0

for tool in jq lazygit zoxide; do
    if command -v $tool &>/dev/null; then
        log "$tool → ready"
        ((PASS++))
    else
        err "$tool → FAILED"
        ((FAIL++))
    fi
done

echo ""
if [ $FAIL -eq 0 ]; then
    log "All ${PASS} tools installed successfully"
    echo ""
    echo "  Quick Start:"
    echo "  ─────────────────────────────────────"
    echo "  lg              → Launch LazyGit (review Claude Code commits)"
    echo "  z zonewise      → Jump to zonewise directory"
    echo "  z bidder        → Jump to brevard-bidder directory"
    echo "  curl ... | jqp  → Pretty-print any API/Supabase response"
    echo "  ─────────────────────────────────────"
    echo ""
    echo "  Restart your shell or run: source ${SHELL_RC}"
    echo ""
else
    err "${FAIL} tool(s) failed to install. Check errors above."
fi
