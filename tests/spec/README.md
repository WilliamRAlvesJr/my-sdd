# tests/spec

Runs the `spec` skill for real and records what came out. Nothing here is loaded by Claude
Code: only `skills/`, `commands/` and `agents/` are scanned, so this folder travels in git and
costs the agent nothing.

## The two arms

**Baseline** is `baseline.ps1`: the same request N times with nothing changed. The
measurement is the spread across the N outputs. Where the runs agree the prompt holds; where
they diverge is a rule that is missing or too weak to survive. It needs no expected result,
since comparing the runs against each other already informs, and it is what names a suspect
before there is anything to ablate.

**Ablation** is the same script against a second copy of the repository with one rule removed,
compared by counting on a case that has a known answer. It comes after the baseline, when one
rule is under suspicion and nothing else decides. Around five runs per arm show a coarse
effect; a subtle one needs dozens and stops paying.

## Running one

```powershell
.\baseline.ps1 -Name create-board `
               -Fixture ..\..\Temp\Fixtures\kanban-clean `
               -Request "criar um board" `
               -Runs 5
```

The runs are parallel processes, and what a batch costs follows `-Model` and `-Effort`: five
full runs are minutes and around a dollar on a large model, and a fraction of that on a small
one with low effort.

- `-Fixture` is a project copied fresh per run. It is never this repository: STEP 1 reads the
  repository and STEP 4 writes `specs/<feature>/`, so a run against the framework specifies
  the framework. A copy per run rather than a reset, because run two would otherwise find the
  `spec.md` run one wrote and stop at STEP 1, by rule.
- `-Plugin` defaults to this repository's root and reaches the skill through `--plugin-dir`,
  which loads a directory for that session only. The file under review is the file that runs,
  uncommitted changes and all; the marketplace cache is never read.
- `-Flags` defaults to `--assume --verbose`. `--assume` is what makes an unattended run
  possible at all, since a headless session has no channel to answer STEP 3, and that is also
  the one thing this cannot reach: the confirmation cycle never runs, so the rules around it
  stay a manual test. `--verbose` is always on, since without the trace there is no telling
  where two runs diverged.
- `-Model` and `-Effort` fix both for every run in the batch. Left unset, a run inherits
  whatever the CLI defaults to at that moment, and two batches of the same case then compare
  across a difference nothing in the output names. Either way `case.md` records what was used.
- `-StopAfterStep` ends each run once that step is done, through `--append-system-prompt`, so
  the instrument never enters the request and the skill knows nothing about it. A run cut this
  way is not the run a user gets: the agent works knowing it stops, so what it measures is the
  trace and the reading of that step, not the artifact. The cut has to beat the skill's own
  handover from one step to the next, which is what a run that leaks past the step obeyed
  instead, so below STEP 4 the instruction bans writing as well and a leak leaves no artifact.
  Whether it held is read in the traces: a `▸` for a later step is a run that ignored the cut.
- `-Arm` is which arm this batch is, and it is the last field of the folder name. It defaults
  to `baseline`, and the ablation is what it exists for: the two arms carry the same `-Name`,
  the same step and the same model on purpose, so without it the only thing telling them apart
  in the listing is the timestamp, which says nothing. Kebab-case and short, since it is read
  in a folder name: `baseline`, `no-r17`, `r17-reworded`.
- `-Note` is the whole sentence that slug abbreviates: which rule came out of the copy under
  `-Plugin`, and how. It stays in `case.md`, where there is room for it.

`bypassPermissions` is refused by the permission classifier, so each run is `acceptEdits` with
`Read Glob Grep Write Edit` allowed. That list adds permissions, it does not confine the run:
every run so far reached for `Bash` to list and read files, and got it. What the runs are not
supposed to do is run anything, and `tools.txt` is where that gets checked.

## What a run leaves behind

Recorded under `runs/<case>/<timestamp>[_step-N][_<model>]_<arm>/`, git ignored for now. The case is the
folder, so the batches ablation compares sit side by side under it; inside, the timestamp
orders them, the step and the model say whether two of them are comparable at all, and the arm
says what is being compared. The step and the model are left out when they were not fixed. The
rest, effort and `-Note` included, is in `case.md`:

| file | what it holds |
|---|---|
| `case.md` | the request, the flags, the fixture, and the commit the skill was at, said to be clean or dirty |
| `summary.md` | one row per run: files written, `behaviors`, `scenarios`, `Assumed`, turns, seconds, cost |
| `run-N/trace.md` | everything the agent wrote: the `▸ ↳ ◂` lines and the STEP 5 report |
| `run-N/tools.txt` | one line per tool call, with the file or pattern, which is what the run actually read |
| `run-N/written/` | every file that appeared in the fixture copy. Anything outside `specs/` is a run that wrote where it was not asked to |
| `run-N/meta.txt` | exit code, stop reason, turns, duration, cost, permission denials, session id |

The counting in `summary.md` says where to look. What the runs disagree about is read in the
traces, by a human.

The throwaway working copies and the raw `stream-json` stay outside this repository, under
`../my-sdd-runs/<case>/<timestamp>[_step-N][_<model>]_<arm>/`, and can be deleted at any time. Outside and not in the
ignored `Temp/`, because `claude` climbs the directory tree from its working directory: a copy
under this repository inherits this repository's `CLAUDE.md` and `.git`, and the run then reads
the framework's own source as if it were the project it was asked to specify. `-WorkRoot`
moves it, and moving it back under the repository is what that bias looks like.
