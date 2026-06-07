#!/usr/bin/env bash
# install.sh — Add builder-ai skills and agents to any project
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.sh)
#   bash <(curl -fsSL https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.sh) /path/to/project

set -euo pipefail

# ── Colours ─────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${BLUE}[builder-ai]${RESET} $*"; }
success() { echo -e "${GREEN}[builder-ai]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[builder-ai]${RESET} $*"; }
die()     { echo -e "${RED}[builder-ai] ERROR:${RESET} $*" >&2; exit 1; }

REPO="https://github.com/RBraga01/builder-ai.git"
DEST="${1:-$(pwd)}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# ── Preflight ────────────────────────────────────────────────────────────────
command -v git >/dev/null 2>&1 || die "git is required but not installed."
[[ -d "$DEST" ]] || die "Destination directory does not exist: $DEST"

echo ""
echo -e "${BOLD}builder-ai — Build LLM Products That Don't Fail Silently${RESET}"
echo "Installing into: $DEST"
echo ""

# ── Sparse clone ─────────────────────────────────────────────────────────────
info "Cloning builder-ai (sparse, latest)..."
git clone \
  --filter=blob:none \
  --sparse \
  --depth 1 \
  --quiet \
  "$REPO" "$TMP/builder-ai"

cd "$TMP/builder-ai"
git sparse-checkout set skills .claude/agents

# ── Copy files ───────────────────────────────────────────────────────────────
COPIED=0; SKIPPED=0

copy_dir() {
  local src="$1" dst="$2"
  [[ -d "$src" ]] || { warn "Source not found: $src (skipping)"; return; }
  mkdir -p "$dst"
  while IFS= read -r -d '' file; do
    rel="${file#$src/}"
    target="$dst/$rel"
    if [[ -e "$target" ]]; then
      SKIPPED=$((SKIPPED + 1))
    else
      mkdir -p "$(dirname "$target")"
      cp "$file" "$target"
      COPIED=$((COPIED + 1))
    fi
  done < <(find "$src" -type f -print0)
}

info "Copying skills..."
copy_dir "$TMP/builder-ai/skills"        "$DEST/skills"

info "Copying agents..."
copy_dir "$TMP/builder-ai/.claude/agents" "$DEST/.claude/agents"

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
success "Done! $COPIED file(s) installed, $SKIPPED skipped (already exist)."
echo ""
echo -e "  ${BOLD}Skills installed:${RESET}       $DEST/skills/"
echo -e "  ${BOLD}Agents installed:${RESET}       $DEST/.claude/agents/"
echo ""
echo -e "  ${BOLD}Hard gates (use before shipping):${RESET}"
echo -e "    eval-before-ship · prompt-versioning · fallback-required"
echo ""
echo -e "  ${BOLD}Workflow skills:${RESET}"
echo -e "    rag-pipeline-design · model-benchmarking · context-optimization"
echo -e "    ai-cost-audit · ai-safety-review"
echo ""
echo -e "  ${BOLD}Agents:${RESET}"
echo -e "    prompt-engineer · eval-designer · rag-architect"
echo -e "    model-selector · ai-safety-reviewer"
echo ""
echo -e "  ${BLUE}Docs:${RESET} https://github.com/RBraga01/builder-ai"
echo ""
