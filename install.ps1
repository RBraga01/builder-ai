# install.ps1 — Add builder-ai skills and agents to any project
# Usage:
#   irm https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.ps1 | iex
#   irm https://raw.githubusercontent.com/RBraga01/builder-ai/main/install.ps1 | iex; Install-BuilderAI -Dest "C:\Projects\my-project"

param(
  [string]$Dest = (Get-Location).Path
)

$Repo   = "https://github.com/RBraga01/builder-ai.git"
$Tmp    = Join-Path $env:TEMP "builder-ai-install-$(Get-Random)"
$Copied = 0
$Skipped = 0

function Write-Info    { param($m) Write-Host "[builder-ai] $m" -ForegroundColor Cyan }
function Write-Success { param($m) Write-Host "[builder-ai] $m" -ForegroundColor Green }
function Write-Warn    { param($m) Write-Host "[builder-ai] $m" -ForegroundColor Yellow }
function Write-Err     { param($m) Write-Host "[builder-ai] ERROR: $m" -ForegroundColor Red; exit 1 }

# Preflight
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Write-Err "git is required but not installed." }
if (-not (Test-Path $Dest)) { Write-Err "Destination directory does not exist: $Dest" }

Write-Host ""
Write-Host "builder-ai — Build LLM Products That Don't Fail Silently" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host "Installing into: $Dest"
Write-Host ""

# Sparse clone
Write-Info "Cloning builder-ai (sparse, latest)..."
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
try {
  git clone --filter=blob:none --sparse --depth 1 --quiet $Repo "$Tmp\builder-ai"
  Push-Location "$Tmp\builder-ai"
  git sparse-checkout set skills .claude/agents
  Pop-Location
} catch {
  Write-Err "Failed to clone repository: $_"
}

# Copy helper
function Copy-Dir {
  param([string]$Src, [string]$DstBase)
  if (-not (Test-Path $Src)) { Write-Warn "Source not found: $Src (skipping)"; return }
  Get-ChildItem -Path $Src -File -Recurse | ForEach-Object {
    $rel    = $_.FullName.Substring($Src.Length).TrimStart('\','/')
    $target = Join-Path $DstBase $rel
    if (Test-Path $target) {
      $script:Skipped++
    } else {
      $dir = Split-Path $target -Parent
      if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
      Copy-Item $_.FullName $target
      $script:Copied++
    }
  }
}

Write-Info "Copying skills..."
Copy-Dir "$Tmp\builder-ai\skills"         "$Dest\skills"

Write-Info "Copying agents..."
Copy-Dir "$Tmp\builder-ai\.claude\agents"  "$Dest\.claude\agents"

# Cleanup
Remove-Item -Recurse -Force $Tmp -ErrorAction SilentlyContinue

# Done
Write-Host ""
Write-Success "Done! $Copied file(s) installed, $Skipped skipped (already exist)."
Write-Host ""
Write-Host "  Skills installed:  $Dest\skills\" -ForegroundColor White
Write-Host "  Agents installed:  $Dest\.claude\agents\" -ForegroundColor White
Write-Host ""
Write-Host "  Hard gates (use before shipping):" -ForegroundColor White
Write-Host "    eval-before-ship · prompt-versioning · fallback-required"
Write-Host ""
Write-Host "  Workflow skills:" -ForegroundColor White
Write-Host "    rag-pipeline-design · model-benchmarking · context-optimization"
Write-Host "    ai-cost-audit · ai-safety-review"
Write-Host ""
Write-Host "  Agents:" -ForegroundColor White
Write-Host "    prompt-engineer · eval-designer · rag-architect"
Write-Host "    model-selector · ai-safety-reviewer"
Write-Host ""
Write-Host "  Docs: https://github.com/RBraga01/builder-ai" -ForegroundColor Cyan
Write-Host ""
