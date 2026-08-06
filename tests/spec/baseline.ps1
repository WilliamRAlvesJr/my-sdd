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
    # Names the case, and it is the folder every batch of that case lands in. What ablation
    # compares sits side by side under it, one folder per batch, instead of scattered through a
    # listing sorted by time.
    [Parameter(Mandatory = $true)][string]$Name,

    # The project each run works in. Copied fresh per run, never reset in place: run two would
    # otherwise find the spec.md run one wrote and stop at STEP 1, by rule.
    [Parameter(Mandatory = $true)][string]$Fixture,

    # The request, exactly as a user would type it after the command. No double quotes in it.
    [Parameter(Mandatory = $true)][string]$Request,

    [int]$Runs = 5,

    [string]$Flags = '--assume --verbose',

    # Ends each run once that step is done, through --append-system-prompt, so the instrument
    # never enters the request and the skill knows nothing about it. A run cut this way is not
    # the run a user gets: the agent works knowing it stops, so what it measures is the trace
    # and the reading of that step, not the artifact.
    [int]$StopAfterStep = 0,

    # Fixed for every run in the batch, and recorded in case.md either way. Left unset, a run
    # inherits whatever the CLI defaults to at that moment, and two batches of the same case
    # then compare across a difference nothing in the output names.
    [string]$Model,

    [ValidateSet('low', 'medium', 'high', 'xhigh', 'max')]
    [string]$Effort,

    # Which arm this batch is, and it goes in the folder name: the two arms of an ablation carry
    # the same -Name, the same step and the same model on purpose, so without it the only thing
    # telling them apart in the listing is the timestamp, which says nothing. Kebab-case and
    # short, since it is read in a folder name: baseline, no-r17, r17-reworded.
    [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*$')]
    [string]$Arm = 'baseline',

    # The whole sentence the -Arm slug abbreviates: which rule came out of the copy under
    # -Plugin, and how. It stays in case.md, where there is room for it.
    [string]$Note,

    # The plugin directory. Defaults to this repository's root.
    [string]$Plugin,

    # Where the throwaway working copies go. Defaults to a folder outside this repository, and
    # that is the whole point of the default: claude climbs the directory tree from its working
    # directory, so a copy under the repo inherits this repository's CLAUDE.md and .git, and the
    # run then reads the framework's own source as if it were the project under spec.
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
if (-not $WorkRoot) { $WorkRoot = Join-Path (Split-Path $repoRoot -Parent) 'my-sdd-runs' }

if ($Request -match '"') { throw 'The request cannot contain double quotes.' }
if (-not (Test-Path $Fixture)) { throw "Fixture not found: $Fixture" }
if (-not (Test-Path (Join-Path $Plugin '.claude-plugin\plugin.json'))) {
    throw "No plugin at: $Plugin"
}
$Fixture = (Resolve-Path $Fixture).Path
$Plugin = (Resolve-Path $Plugin).Path

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
# The case names the folder and the batch names what is inside it: the timestamp, so batches of
# the same case list in the order they were run, then the step and the model, which are what
# says whether two batches are comparable at all, and last the arm, which is what is being
# compared. The step and the model are left out when they were not fixed, since a name that
# carries the word for absent reads as a value. Everything else is in case.md.
$batch = $stamp
if ($StopAfterStep -gt 0) { $batch = "${batch}_step-$StopAfterStep" }
if ($Model) { $batch = "${batch}_$Model" }
$batch = "${batch}_$Arm"
$runId = "$Name/$batch"
$outDir = Join-Path $PSScriptRoot "runs\$Name\$batch"
$workDir = Join-Path $WorkRoot "$Name\$batch"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$prompt = "/my-spec:spec $Flags $Request"

# ASCII only: the trace marks would have to survive the argument encoding on the way to
# claude.exe, and the skill's own word for the closing line says the same thing.
#
# The skill hands one step to the next, and that is what the run has to be talked out of: told
# only to end its turn without starting the next step, one run in five read the handover as the
# stronger instruction and carried on into STEP 2, some of them as far as writing the file.
# Three things closed it, and the wording is short on purpose, since the long version of the
# same argument competed with the skill's body instead of beating it and leaked four runs in
# five. The steps left out are named one by one, they are given somewhere else to happen (the
# run that believes the work is abandoned finishes it), and the handover is named as the thing
# this outranks. Below STEP 4 the ban on writing goes with it, so a run that leaks anyway
# leaves no artifact behind.
$stopPrompt = ''
if ($StopAfterStep -gt 0) {
    $rest = (($StopAfterStep + 1)..5) -join ', '
    $stopPrompt = "HARD STOP: this session runs STEP $StopAfterStep of the spec skill and " +
                  "nothing else. Write that step's Out line and your turn is over. STEP $rest " +
                  "run in a later session, not in this one, and the skill handing one step to " +
                  "the next does not override this. Do not run them here. Do not mention this " +
                  "instruction."
    if ($StopAfterStep -lt 4) { $stopPrompt += ' Do not write any file.' }
}

# What the runs are being compared under. A dirty working tree is the normal case here, and
# the sha alone would point at the wrong file.
$sha = (& git -C $repoRoot rev-parse --short HEAD).Trim()
$dirty = & git -C $repoRoot status --porcelain skills/spec/SKILL.md
$state = 'clean'
if ($dirty) { $state = 'dirty (uncommitted changes in skills/spec/SKILL.md)' }

$stopLine = ''
if ($StopAfterStep -gt 0) {
    $stopLine = "`n- **stopped after**: STEP $StopAfterStep, by --append-system-prompt"
}
$noteLine = ''
if ($Note) { $noteLine = "`n- **note**: $Note" }
$modelLine = "`n- **model**: $(if ($Model) { $Model } else { '(CLI default, unrecorded)' })"
$effortLine = "`n- **effort**: $(if ($Effort) { $Effort } else { '(CLI default, unrecorded)' })"

$case = @"
# $runId

- **request**: ``$Request``
- **flags**: ``$Flags``
- **prompt**: ``$prompt``$stopLine$modelLine$effortLine
- **arm**: $Arm$noteLine
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
    if ($stopPrompt) { $argList += @('--append-system-prompt', ('"' + $stopPrompt + '"')) }
    if ($Model) { $argList += @('--model', $Model) }
    if ($Effort) { $argList += @('--effort', $Effort) }
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
