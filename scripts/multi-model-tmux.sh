#!/usr/bin/env bash
# ============================================================================
# multi-model-tmux.sh — Lightweight Multi-Model Orchestrator for Claude Code
# Everest Capital USA / BidDeed.AI
# Replaces oh-my-claudecode's multi-model spawning in ~80 lines
# ============================================================================
# Usage:
#   ./multi-model-tmux.sh <command> [args]
#
# Commands:
#   start                 Start orchestrator session
#   gemini  "<prompt>"    Spawn Gemini worker pane with prompt
#   deepseek "<prompt>"   Spawn DeepSeek worker pane with prompt
#   claude  "<prompt>"    Spawn additional Claude Code pane
#   status                Show all active worker panes
#   kill <pane_id>        Kill a specific worker pane
#   killall               Tear down entire orchestrator session
#
# Requirements:
#   - tmux, curl, jq
#   - GEMINI_API_KEY env var (for Gemini)
#   - LITELLM_BASE_URL env var (for DeepSeek via LiteLLM, default http://localhost:4000)
# ============================================================================

set -euo pipefail

SESSION="mmo"  # multi-model-orchestrator
LITELLM_BASE="${LITELLM_BASE_URL:-http://localhost:4000}"
LOG_DIR="${HOME}/.mmo/logs"
mkdir -p "$LOG_DIR"

_ts() { date '+%Y-%m-%d %H:%M:%S'; }

_log() { echo "[$(_ts)] $1" >> "$LOG_DIR/orchestrator.log"; }

_ensure_session() {
  if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION" -n "orchestrator"
    tmux send-keys -t "$SESSION:orchestrator" "echo '🏔️  MMO Orchestrator Ready — $(_ts)'" Enter
    _log "Session created"
  fi
}

_spawn_pane() {
  local name="$1" cmd="$2"
  _ensure_session
  local pane_id
  pane_id=$(tmux split-window -t "$SESSION" -h -P -F '#{pane_id}' "$cmd")
  tmux select-layout -t "$SESSION" tiled 2>/dev/null || true
  _log "Spawned $name in pane $pane_id"
  echo "✅ $name worker: pane $pane_id"
}

cmd_start() {
  _ensure_session
  echo "🏔️  MMO session '$SESSION' ready. Use: gemini/deepseek/claude to spawn workers."
}

cmd_gemini() {
  local prompt="${1:?Usage: $0 gemini \"<prompt>\"}"
  local script="curl -s 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY:-MISSING}' \
    -H 'Content-Type: application/json' \
    -d '{\"contents\":[{\"parts\":[{\"text\":\"$(echo "$prompt" | sed 's/"/\\"/g')\"}]}]}' \
    | jq -r '.candidates[0].content.parts[0].text // \"ERROR: No response\"' \
    | tee '$LOG_DIR/gemini-$(date +%s).txt'; \
    echo ''; echo '--- Gemini complete ---'; read -p 'Press Enter to close...'"
  _spawn_pane "Gemini" "bash -c \"$script\""
}

cmd_deepseek() {
  local prompt="${1:?Usage: $0 deepseek \"<prompt>\"}"
  local script="curl -s '${LITELLM_BASE}/v1/chat/completions' \
    -H 'Content-Type: application/json' \
    -d '{\"model\":\"deepseek/deepseek-chat\",\"messages\":[{\"role\":\"user\",\"content\":\"$(echo "$prompt" | sed 's/"/\\"/g')\"}],\"max_tokens\":4096}' \
    | jq -r '.choices[0].message.content // \"ERROR: No response\"' \
    | tee '$LOG_DIR/deepseek-$(date +%s).txt'; \
    echo ''; echo '--- DeepSeek complete ---'; read -p 'Press Enter to close...'"
  _spawn_pane "DeepSeek" "bash -c \"$script\""
}

cmd_claude() {
  local prompt="${1:?Usage: $0 claude \"<prompt>\"}"
  _spawn_pane "Claude" "claude --print \"$prompt\""
}

cmd_status() {
  if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "No active MMO session."
    return 1
  fi
  echo "🏔️  MMO Workers:"
  tmux list-panes -t "$SESSION" -F '  Pane #{pane_id} | #{pane_current_command} | #{pane_width}x#{pane_height} | Active: #{pane_active}'
}

cmd_kill() {
  local pane="${1:?Usage: $0 kill <pane_id>}"
  tmux kill-pane -t "$pane" && _log "Killed pane $pane" && echo "Killed $pane"
}

cmd_killall() {
  tmux kill-session -t "$SESSION" 2>/dev/null && _log "Session destroyed" && echo "🏔️  MMO session destroyed." || echo "No session to kill."
}

# --- Dispatch ---
case "${1:-help}" in
  start)    cmd_start ;;
  gemini)   cmd_gemini "${2:-}" ;;
  deepseek) cmd_deepseek "${2:-}" ;;
  claude)   cmd_claude "${2:-}" ;;
  status)   cmd_status ;;
  kill)     cmd_kill "${2:-}" ;;
  killall)  cmd_killall ;;
  *)
    echo "Usage: $0 {start|gemini|deepseek|claude|status|kill|killall} [args]"
    echo ""
    echo "  start              Initialize orchestrator tmux session"
    echo "  gemini  \"prompt\"   Spawn Gemini 2.5 Flash worker"
    echo "  deepseek \"prompt\"  Spawn DeepSeek V3.2 via LiteLLM"
    echo "  claude  \"prompt\"   Spawn Claude Code worker"
    echo "  status             List active worker panes"
    echo "  kill <pane_id>     Kill specific worker"
    echo "  killall            Destroy orchestrator session"
    ;;
esac
