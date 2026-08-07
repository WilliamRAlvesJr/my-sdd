<#
.SYNOPSIS
Runs one request through the installed spec skill N times and records what each run produced.

.DESCRIPTION
The baseline arm: nothing is changed between runs, so the spread across the N outputs is the
measurement. Where the runs agree the prompt holds; where they diverge is a rule that is
missing or too weak to survive.

Each run is a real `claude -p` session in a container of its own, with its own copy of the
fixture as its working directory, so STEP 1 reads a project that is not this repository and
STEP 4 writes into a copy that is thrown away. The skill comes from --plugin-dir, which loads
the working tree rather than the marketplace cache: the file under review is the file that
runs.

The container is what keeps a batch from measuring the machine along with the prompt.
Everything a session would otherwise be lent without being asked stays outside it: the logged
in user's CLAUDE.md, which runs did read and then quote back as the project's own convention,
their settings.json with whatever hooks and permissions are in it, whatever ls and find are
installed, and a python that may or may not be there, which is the difference R71 exists to
survive. Two mounts is all a run gets, the copy of the fixture and the copy of the plugin.

--assume is what makes an unattended run possible at all, since there is no channel to answer
STEP 3. That is also what it does not cover: the confirmation cycle never runs here.
--verbose is always on, since without the trace there is no telling where two runs diverged.

.EXAMPLE
.\baseline.ps1 -Name create-board -Fixture kanban-clean -Request "criar um board"
#>
[CmdletBinding()]
param(
    # Names the case, and it is the folder every batch of that case lands in. What ablation
    # compares sits side by side under it, one folder per batch, instead of scattered through a
    # listing sorted by time.
    [Parameter(Mandatory = $true)][string]$Name,

    # The project each run works in, as a path or as the name of a folder in fixtures/, next to
    # this script. Copied fresh per run, never reset in place: run two would otherwise find the
    # spec.md run one wrote and stop at STEP 1, by rule.
    [Parameter(Mandatory = $true)][string]$Fixture,

    # The request, exactly as a user would type it after the command. No double quotes in it.
    [Parameter(Mandatory = $true)][string]$Request,

    [int]$Runs = 5,

    [string]$Flags = '--assume --verbose',

    # Kills each run the moment it opens the step after this one, so a batch measuring STEP 1
    # pays for STEP 1. Nothing is said to the run: the session is the session a user gets, and
    # what the batch then measures is the trace and the reading of that step, not the artifact.
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
    [string]$WorkRoot,

    # The image every run of the batch is a container of, built from the Dockerfile next to
    # this script.
    [string]$Image = 'my-sdd-runner'
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

# A name that is not a path is looked up in fixtures/, next to this script: the folder travels
# empty and git ignored, the way runs/ does, so a clone has somewhere to drop the project it
# runs against without any of it landing in the repository. A path still works, which is what a
# project kept elsewhere on the machine uses.
if (-not (Test-Path $Fixture)) {
    $inFixtures = Join-Path $PSScriptRoot "fixtures\$Fixture"
    if (Test-Path $inFixtures) {
        $Fixture = $inFixtures
    }
    else {
        throw "Fixture not found: $Fixture. Pass a path, or drop the project in " +
              "tests/spec/fixtures/ and pass its folder name."
    }
}
if (-not (Test-Path (Join-Path $Plugin '.claude-plugin\plugin.json'))) {
    throw "No plugin at: $Plugin"
}
$Fixture = (Resolve-Path $Fixture).Path
$Plugin = (Resolve-Path $Plugin).Path

# The account every run of the batch logs in as: `CLAUDE_ACCOUNT` in .env at the repository
# root, with .env.example next to it saying so, and running under another one means editing that
# value. `claude setup-token` is what mints a token: it wants a subscription, so the batch is
# billed where a session already is instead of on an API key. Only that one key is read, since
# a .env is where credentials collect and the rest of the file belongs to whoever put it there.
# The file holds a secret, so it is git ignored and nothing from it reaches the recorded batch.
$accountToken = ''
$envPath = Join-Path $repoRoot '.env'
if (-not (Test-Path $envPath)) {
    throw "No .env at the repository root. Copy .env.example over it and fill in " +
          "CLAUDE_ACCOUNT with a token from ``claude setup-token``."
}
# The value ends at the first space, quote or #, which is what a .env is written like: a token
# carried a trailing ` # note` into the container once and came back as 401 OAuth access token
# is invalid, which reads like an expired token and is a parser taking the comment along.
foreach ($line in (Get-Content $envPath -Encoding utf8)) {
    if ($line -match '^\s*CLAUDE_ACCOUNT\s*=\s*["'']?([^\s"''#]+)') { $accountToken = $matches[1] }
}
if (-not $accountToken) { throw "No CLAUDE_ACCOUNT line in $envPath." }

# Checked before the fixture is copied five times, and named as what it is: the image is built
# from the Dockerfile next to this script, and a batch that only finds out at the first
# `docker run` reports it once per run instead of once.
$known = & docker images -q $Image 2>$null
if (-not $known) { throw "No image named ${Image}: build it with ``docker build -t $Image .`` in tests/spec." }

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

# Nothing tells the run it is being cut. Asking it to stop was tried and it works most of the
# time, which is the worst kind of instrument: a run in five obeyed the skill's handover
# instead, and the wording that fixed that was the fourth one written, each of the earlier
# three having leaked at a different rate. Worse, an instruction in the system prompt is read
# by the agent whether it obeys it or not, so the step being measured was a step run under a
# condition no user has. The kill below needs none of that, so the run is the run a user gets
# and the harness is the only thing that knows about the cut.

# What the runs are being compared under. A dirty working tree is the normal case here, and
# the sha alone would point at the wrong file.
$sha = (& git -C $repoRoot rev-parse --short HEAD).Trim()
$dirty = & git -C $repoRoot status --porcelain skills/spec/SKILL.md
$state = 'clean'
if ($dirty) { $state = 'dirty (uncommitted changes in skills/spec/SKILL.md)' }

$stopLine = ''
if ($StopAfterStep -gt 0) {
    $stopLine = "`n- **stopped after**: STEP $StopAfterStep, killed by the harness, nothing said to the run"
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
- **plugin**: ``$Plugin`` at ``$sha``, $state, run from a copy holding only what Claude Code loads
- **where**: ``$Image``, one container per run, logged in as CLAUDE_ACCOUNT
- **started**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@
Write-Text (Join-Path $outDir 'case.md') $case

# The plugin runs from a copy of its own, and what that removes is what sits above it. Pointed
# at this repository, --plugin-dir leaves CLAUDE.md, notes/ and tests/ one level up from the
# skill, and the agent has the skill's absolute path in hand (R70 hands it one to call the
# validator with): runs have read the framework's own construction notes and the template as
# if they were the project's. An install has none of that above the plugin, so neither does a
# run. What is copied is what Claude Code loads and nothing else.
$pluginCopy = Join-Path $workDir 'plugin'
New-Item -ItemType Directory -Force -Path $pluginCopy | Out-Null
foreach ($part in '.claude-plugin', 'skills', 'commands', 'agents', 'hooks') {
    $src = Join-Path $Plugin $part
    if (Test-Path $src) { Copy-Item -Recurse -Force $src $pluginCopy }
}

Write-Host "$runId : starting $Runs runs"

$procs = @()
foreach ($i in 1..$Runs) {
    $ws = Join-Path $workDir "run-$i\ws"
    New-Item -ItemType Directory -Force -Path (Split-Path $ws) | Out-Null
    Copy-Item -Recurse -Force $Fixture $ws

    # Inside the container the two mounts are all there is, so the paths are the container's.
    $argList = @(
        '-p', ('"' + $prompt + '"'),
        '--plugin-dir', '/plugin',
        '--permission-mode', 'acceptEdits',
        '--allowedTools', 'Read', 'Glob', 'Grep', 'Write', 'Edit',
        '--output-format', 'stream-json', '--verbose'
    )
    # The whole point of the partial chunks is when they arrive. Without them a message reaches
    # raw.jsonl only once it is finished, and the run that wrote STEP 1 through STEP 4 in a
    # single block of text had already written all four by the time anything outside could see
    # the first mark. With them the mark lands as it is typed, so the kill lands there too and
    # the tokens of the steps that follow are never generated.
    if ($StopAfterStep -gt 0) { $argList += '--include-partial-messages' }
    if ($Model) { $argList += @('--model', $Model) }
    if ($Effort) { $argList += @('--effort', $Effort) }
    $raw = Join-Path $workDir "run-$i\raw.jsonl"
    $err = Join-Path $workDir "run-$i\err.txt"
    # The token goes in through a file and not through -e: the command line of a running
    # process is readable, and there are five of them side by side. The file lives with the
    # throwaway copies, outside the repository, and the batch deletes it at the end.
    $envFile = Join-Path $workDir "run-$i\env"
    Write-Text $envFile "CLAUDE_CODE_OAUTH_TOKEN=$accountToken"
    $container = "my-sdd-$stamp-run-$i"
    # `record` is the image's entry point for a run: it starts the session, writes the stream
    # into /run and carries the cut. STOP_AFTER_STEP is the step this batch measures, and it is
    # an environment variable of the wrapper, never anything the session is told.
    $dockerArgs = @(
        'run', '--rm', '--name', $container,
        '--env-file', ('"' + $envFile + '"'),
        '-v', ('"' + $ws + ':/ws"'),
        '-v', ('"' + (Join-Path $workDir "run-$i") + ':/run"'),
        '-v', ('"' + $pluginCopy + ':/plugin:ro"'),
        '-w', '/ws'
    )
    if ($StopAfterStep -gt 0) { $dockerArgs += @('-e', "STOP_AFTER_STEP=$StopAfterStep") }
    $dockerArgs += @($Image, 'record')
    $p = Start-Process -FilePath 'docker' -ArgumentList ($dockerArgs + $argList) `
        -NoNewWindow -PassThru `
        -RedirectStandardOutput (Join-Path $workDir "run-$i\docker.txt") `
        -RedirectStandardError (Join-Path $workDir "run-$i\docker-err.txt")

    $procs += [pscustomobject]@{
        Index = $i; Process = $p; Ws = $ws; Raw = $raw; Killed = ''
        Container = $container; ExitCode = ''
    }
    Write-Host "  run-$i : pid $($p.Id)"
}

# The cut happens inside the container, and record.sh in this folder says why it has to: the
# harness only reads the verdict afterwards. Nothing about it reaches the session, so the step
# being measured is the step a user gets, and a measurement stops depending on the behaviour it
# is measuring.


$procs | ForEach-Object { $_.Process.WaitForExit() }
foreach ($r in $procs) {
    $verdict = Join-Path $workDir "run-$($r.Index)\killed.txt"
    if (Test-Path $verdict) {
        $r.Killed = (Get-Content $verdict -Raw -Encoding utf8).Trim()
        Write-Host "  run-$($r.Index) : killed opening $($r.Killed)"
    }
    $code = Join-Path $workDir "run-$($r.Index)\exit.txt"
    if (Test-Path $code) { $r.ExitCode = (Get-Content $code -Raw -Encoding utf8).Trim() }
}
Write-Host "$runId : all runs finished, collecting"

# What the batch leaves behind is written by collect.js, in a container of the same image the
# runs used. Node is there by construction, since the CLI under test is installed with npm, so
# the host needs no runtime beyond whatever starts a container: the machine that can run a
# batch can record one. The script is mounted rather than baked in, so editing it costs no
# rebuild, and the reason it runs once for the batch instead of once per run is that summary.md
# is a batch's file.
$plan = [ordered]@{
    title = $runId
    runs  = @($procs | ForEach-Object {
        [ordered]@{ index = $_.Index; killed = $_.Killed; exitCode = $_.ExitCode }
    })
}
Write-Text (Join-Path $workDir 'runs.json') ($plan | ConvertTo-Json -Depth 5)

$collectArgs = @(
    'run', '--rm',
    '-v', ('"' + $workDir + ':/batch"'),
    '-v', ('"' + $outDir + ':/out"'),
    '-v', ('"' + $Fixture + ':/fixture:ro"'),
    '-v', ('"' + (Join-Path $PSScriptRoot 'collect.js') + ':/collect.js:ro"'),
    $Image, 'node', '/collect.js'
)
$rowsOut = Join-Path $workDir 'rows.tsv'
$p = Start-Process -FilePath 'docker' -ArgumentList $collectArgs -NoNewWindow -PassThru -Wait `
    -RedirectStandardOutput $rowsOut -RedirectStandardError (Join-Path $workDir 'collect-err.txt')
if ($p.ExitCode -ne 0) {
    throw "collect.js failed: $(Get-Content (Join-Path $workDir 'collect-err.txt') -Raw)"
}

$rows = @()
foreach ($line in (Get-Content $rowsOut -Encoding utf8)) {
    if (-not $line.Trim()) { continue }
    $f = $line -split "`t"
    $rows += [pscustomobject]@{
        run = $f[0]; killed = $f[1]; specs = $f[2]; behaviors = $f[3]; scenarios = $f[4]
        assumed = $f[5]; turns = $f[6]; seconds = $f[7]; usd = $f[8]
    }
}


# The tokens were written to disk to keep them off the command line, so they leave with the
# batch rather than sitting in the throwaway folder until somebody remembers it.
foreach ($r in $procs) {
    $envFile = Join-Path $workDir "run-$($r.Index)\env"
    if (Test-Path $envFile) { Remove-Item $envFile -Force }
}

$rows | Format-Table -AutoSize
Write-Host "recorded in $outDir"
