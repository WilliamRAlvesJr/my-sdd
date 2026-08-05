<#
.SYNOPSIS
Runs one request through the installed spec skill N times and records what each run produced.

.DESCRIPTION
The baseline arm: nothing is changed between runs, so the spread across the N outputs is the
measurement. Where the runs agree the prompt holds; where they diverge is a rule that is
missing or too weak to survive.

Each run is a real `claude -p` session with its own copy of the fixture as its working
directory, so STEP 1 reads a project that is not this repository and STEP 4 writes into a
copy that is thrown away. The skill comes from --plugin-dir, which loads the working tree
rather than the marketplace cache: the file under review is the file that runs.

--assume is what makes an unattended run possible at all, since there is no channel to answer
STEP 3. That is also what it does not cover: the confirmation cycle never runs here.
--verbose is always on, since without the trace there is no telling where two runs diverged.

.EXAMPLE
.\baseline.ps1 -Name create-board -Fixture ..\..\Temp\Fixtures\kanban-clean -Request "criar um board"
#>
[CmdletBinding()]
param(
    # Names the case. Becomes the output folder, with a timestamp.
    [Parameter(Mandatory = $true)][string]$Name,

    # The project each run works in. Copied fresh per run, never reset in place: run two would
    # otherwise find the spec.md run one wrote and stop at STEP 1, by rule.
    [Parameter(Mandatory = $true)][string]$Fixture,

    # The request, exactly as a user would type it after the command. No double quotes in it.
    [Parameter(Mandatory = $true)][string]$Request,

    [int]$Runs = 5,

    [string]$Flags = '--assume --verbose',

    # The plugin directory. Defaults to this repository's root.
    [string]$Plugin,

    # Where the throwaway working copies go. Defaults to the ignored working folder.
    [string]$WorkRoot
)

$ErrorActionPreference = 'Stop'

# Set-Content -Encoding utf8 writes a BOM in PowerShell 5.1, which then shows up as garbage at
# the head of every recorded file the moment anything greps it.
$utf8 = New-Object System.Text.UTF8Encoding $false
function Write-Text([string]$Path, [string]$Body) {
    [System.IO.File]::WriteAllText($Path, $Body, $utf8)
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
if (-not $Plugin) { $Plugin = $repoRoot }
if (-not $WorkRoot) { $WorkRoot = Join-Path $repoRoot 'Temp\Runs' }

if ($Request -match '"') { throw 'The request cannot contain double quotes.' }
if (-not (Test-Path $Fixture)) { throw "Fixture not found: $Fixture" }
if (-not (Test-Path (Join-Path $Plugin '.claude-plugin\plugin.json'))) {
    throw "No plugin at: $Plugin"
}
$Fixture = (Resolve-Path $Fixture).Path
$Plugin = (Resolve-Path $Plugin).Path

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$runId = "$Name-$stamp"
$outDir = Join-Path $PSScriptRoot "runs\$runId"
$workDir = Join-Path $WorkRoot $runId
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$prompt = "/my-spec:spec $Flags $Request"

# What the runs are being compared under. A dirty working tree is the normal case here, and
# the sha alone would point at the wrong file.
$sha = (& git -C $repoRoot rev-parse --short HEAD).Trim()
$dirty = & git -C $repoRoot status --porcelain skills/spec/SKILL.md
$state = 'clean'
if ($dirty) { $state = 'dirty (uncommitted changes in skills/spec/SKILL.md)' }

$case = @"
# $runId

- **request**: ``$Request``
- **flags**: ``$Flags``
- **prompt**: ``$prompt``
- **runs**: $Runs
- **fixture**: ``$Fixture``
- **plugin**: ``$Plugin`` at ``$sha``, $state
- **started**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@
Write-Text (Join-Path $outDir 'case.md') $case

Write-Host "$runId : starting $Runs runs"

$procs = @()
foreach ($i in 1..$Runs) {
    $ws = Join-Path $workDir "run-$i\ws"
    New-Item -ItemType Directory -Force -Path (Split-Path $ws) | Out-Null
    Copy-Item -Recurse -Force $Fixture $ws

    $argList = @(
        '-p', ('"' + $prompt + '"'),
        '--plugin-dir', ('"' + $Plugin + '"'),
        '--permission-mode', 'acceptEdits',
        '--allowedTools', 'Read', 'Glob', 'Grep', 'Write', 'Edit',
        '--output-format', 'stream-json', '--verbose'
    )
    $p = Start-Process -FilePath 'claude.exe' -ArgumentList $argList `
        -WorkingDirectory $ws -NoNewWindow -PassThru `
        -RedirectStandardOutput (Join-Path $workDir "run-$i\raw.jsonl") `
        -RedirectStandardError (Join-Path $workDir "run-$i\err.txt")
    $procs += [pscustomobject]@{ Index = $i; Process = $p; Ws = $ws }
    Write-Host "  run-$i : pid $($p.Id)"
}

$procs | ForEach-Object { $_.Process.WaitForExit() }
Write-Host "$runId : all runs finished, collecting"

$rows = @()
foreach ($r in $procs) {
    $i = $r.Index
    $runOut = Join-Path $outDir "run-$i"
    New-Item -ItemType Directory -Force -Path $runOut | Out-Null
    $raw = Join-Path $workDir "run-$i\raw.jsonl"

    $text = New-Object System.Collections.Generic.List[string]
    $tools = New-Object System.Collections.Generic.List[string]
    $result = $null

    foreach ($line in (Get-Content $raw -Encoding utf8)) {
        $o = $null
        try { $o = $line | ConvertFrom-Json } catch { continue }
        if ($o.type -eq 'assistant') {
            foreach ($c in $o.message.content) {
                if ($c.type -eq 'text' -and $c.text.Trim()) { $text.Add($c.text) }
                if ($c.type -eq 'tool_use') {
                    $target = ''
                    foreach ($k in 'file_path', 'pattern', 'path', 'command', 'skill') {
                        if ($c.input.PSObject.Properties.Name -contains $k -and -not $target) {
                            $target = "$($c.input.$k)"
                        }
                    }
                    $tools.Add("$($c.name)`t$target")
                }
            }
        }
        elseif ($o.type -eq 'result') { $result = $o }
    }

    Write-Text (Join-Path $runOut 'trace.md') ($text -join "`n`n")
    Write-Text (Join-Path $runOut 'tools.txt') ($tools -join "`n")

    # Whatever the run wrote into its copy of the fixture. Anything outside specs/ is a run
    # that wrote where it was not asked to, and copying it here is how that gets seen.
    $written = @()
    foreach ($f in (Get-ChildItem -Recurse -File $r.Ws)) {
        $rel = $f.FullName.Substring($r.Ws.Length + 1)
        if (Test-Path (Join-Path $Fixture $rel)) { continue }
        $written += $rel
        $dest = Join-Path $runOut "written\$rel"
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Copy-Item $f.FullName $dest
    }

    $specs = $written | Where-Object { $_ -like '*spec.md' }
    $b = 0; $s = 0; $a = 0
    foreach ($sp in $specs) {
        $body = Get-Content (Join-Path $runOut "written\$sp") -Encoding utf8
        $b += ([regex]::Matches(($body -join "`n"), '(?m)^##\s+B\d+')).Count
        $s += ([regex]::Matches(($body -join "`n"), '(?m)^\s*Scenario(\s+Outline)?:')).Count
        $a += ([regex]::Matches(($body -join "`n"), '(?m)^\s+-\s+(?!\*\*Assumed)')).Count
    }

    $meta = [ordered]@{
        exit_code         = $r.Process.ExitCode
        is_error          = $result.is_error
        stop_reason       = $result.stop_reason
        num_turns         = $result.num_turns
        duration_ms       = $result.duration_ms
        total_cost_usd    = $result.total_cost_usd
        permission_denied = ($result.permission_denials | Measure-Object).Count
        session_id        = $result.session_id
        files_written     = ($written -join ', ')
    }
    Write-Text (Join-Path $runOut 'meta.txt') `
        (($meta.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }) -join "`n")

    $rows += [pscustomobject]@{
        run       = "run-$i"
        specs     = ($specs | Measure-Object).Count
        behaviors = $b
        scenarios = $s
        assumed   = $a
        turns     = $result.num_turns
        seconds   = [math]::Round($result.duration_ms / 1000)
        usd       = [math]::Round($result.total_cost_usd, 3)
        written   = ($written -join ' ')
    }
}

# Counting only. What the runs disagree about is read by a human, in the traces.
$summary = New-Object System.Collections.Generic.List[string]
$summary.Add("# $runId")
$summary.Add('')
$summary.Add('| run | specs | behaviors | scenarios | assumed | turns | seconds | usd |')
$summary.Add('|---|---|---|---|---|---|---|---|')
foreach ($row in $rows) {
    $summary.Add("| $($row.run) | $($row.specs) | $($row.behaviors) | $($row.scenarios) | $($row.assumed) | $($row.turns) | $($row.seconds) | $($row.usd) |")
}
$summary.Add('')
foreach ($row in $rows) { $summary.Add("- **$($row.run)** wrote: $($row.written)") }
Write-Text (Join-Path $outDir 'summary.md') ($summary -join "`n")

$rows | Format-Table -AutoSize
Write-Host "recorded in $outDir"
