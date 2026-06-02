Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-VerdictFromReport {
    param([string]$Content)

    # Extract the Verdict section up to the next top-level heading.
    $sectionMatch = [regex]::Match(
        $Content,
        '(?ms)^##\s*Verdict\s*$\s*(?<section>.*?)(?=^##\s+|\z)',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    if (-not $sectionMatch.Success) {
        return $null
    }

    $section = $sectionMatch.Groups['section'].Value

    if ($section -match '(?i)⛔\s*blocked|\bblocked\b') {
        return 'blocked'
    }

    if ($section -match '(?i)⚠️?\s*pass\s*with\s*warnings|\bpass\s*with\s*warnings\b') {
        return 'pass with warnings'
    }

    if ($section -match '(?i)✅\s*pass|\bpass\b') {
        return 'pass'
    }

    return $null
}

$scriptDir = Split-Path -Parent $PSCommandPath
$repoRoot = Split-Path -Parent $scriptDir
$reportPath = Join-Path $repoRoot "reports/last-agent-review.md"

try {
    $null = git -C $repoRoot rev-parse --is-inside-work-tree 2>$null
} catch {
    Write-Host "Checklist gate skipped: folder is not a Git repository ($repoRoot)."
    exit 0
}

$stagedDiff = git -C $repoRoot diff --cached --no-color -U0
if ([string]::IsNullOrWhiteSpace($stagedDiff)) {
    Write-Host "Checklist gate: no staged changes."
    exit 0
}

if (-not (Test-Path $reportPath)) {
    Write-Host "Commit blocked: review report not found at $reportPath"
    Write-Host "Run the Change Checklist Reviewer agent first so it can save the report."
    exit 1
}

try {
    $report = Get-Content -Raw -Path $reportPath
} catch {
    Write-Host "Commit blocked: unable to read report file at $reportPath"
    Write-Host $_.Exception.Message
    exit 1
}

$verdict = Get-VerdictFromReport -Content $report
if (-not $verdict) {
    Write-Host "Commit blocked: could not parse verdict from $reportPath"
    Write-Host "Expected a report with a '## Verdict' section containing pass/pass with warnings/blocked."
    exit 1
}

Write-Host ""
Write-Host "Checklist gate report verdict: $verdict"

if ($verdict -eq 'blocked') {
    Write-Host "Commit blocked: report verdict is blocked."
    exit 1
}

if ($verdict -eq 'pass with warnings') {
    Write-Host "Commit allowed with warnings based on saved report."
    exit 0
}

Write-Host "Commit allowed: report verdict is pass."
exit 0