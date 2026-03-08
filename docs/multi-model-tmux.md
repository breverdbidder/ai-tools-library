# Multi-Model Tmux Orchestrator (MMO)

Lightweight alternative to oh-my-claudecode for spawning parallel AI workers in tmux panes during Claude Code sessions.

## Why This Exists

oh-my-claudecode (v4.7.5) offers multi-model orchestration but brings 28 agents, 37 skills, and plugin lock-in. MMO extracts the only valuable piece — parallel tmux panes for Gemini/DeepSeek/Claude — in ~90 lines of bash with zero dependencies beyond tmux, curl, and jq.

## Setup

```bash
# Set required env vars
export GEMINI_API_KEY="your-key"
export LITELLM_BASE_URL="http://localhost:4000"  # optional, defaults to localhost:4000

# Make executable
chmod +x scripts/multi-model-tmux.sh
```

## Usage

```bash
# Start the orchestrator session
./scripts/multi-model-tmux.sh start

# Spawn parallel workers
./scripts/multi-model-tmux.sh gemini "review this codebase architecture"
./scripts/multi-model-tmux.sh deepseek "optimize these SQL queries"
./scripts/multi-model-tmux.sh claude "refactor the auth module"

# Check what's running
./scripts/multi-model-tmux.sh status

# Clean up
./scripts/multi-model-tmux.sh killall
```

## Architecture

```
┌─────────────────────────────────────────────┐
│  tmux session: mmo                          │
├──────────────┬──────────────┬───────────────┤
│ Gemini 2.5   │ DeepSeek V3.2│ Claude Code   │
│ Flash (FREE) │ via LiteLLM  │ --print       │
│              │ ($0.28/1M)   │ (Max plan)    │
├──────────────┴──────────────┴───────────────┤
│  Logs: ~/.mmo/logs/                         │
└─────────────────────────────────────────────┘
```

## Integration with Claude Code Sessions

From within a Claude Code session, call directly:

```bash
bash scripts/multi-model-tmux.sh gemini "analyze src/ for security vulnerabilities"
```

Results land in `~/.mmo/logs/` with timestamps for later review.

## Cost

- Gemini 2.5 Flash: FREE tier
- DeepSeek V3.2: $0.28/1M input tokens via LiteLLM
- Claude Code: Included in Max subscription
- **Total overhead: $0/month** (Gemini free, DeepSeek only on use)
