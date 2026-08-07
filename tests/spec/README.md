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

Every run is a container, so a batch needs the image built once and an account to log in as:

```powershell
docker build -t my-sdd-runner .
Copy-Item ..\..\.env.example ..\..\.env    # then put a `claude setup-token` token in it
```

```powershell
.\baseline.ps1 -Name create-board `
               -Fixture kanban-clean `
               -Request "criar um board" `
               -Runs 5
```

What the container is for is everything the machine lends a run without being asked: the
logged in user's `CLAUDE.md`, which runs did read and quote back as the project's convention,
their `settings.json` with whatever hooks and permissions are in it, whatever `ls` and `find`
are installed, and a `python` that may or may not be there, which is the difference R71 exists
to survive. Inside, all of it is declared, and a batch on another machine differs by the prompt
and nothing else. Only two things are mounted: the copy of the fixture as the working
directory, and the copy of the plugin, read only.

Authentication is a token from `claude setup-token`, which wants a subscription, so a batch is
billed where a session already is instead of on an API key. It lives in `CLAUDE_ACCOUNT` in
`.env` at the repository root, git ignored, with `.env.example` next to it as the form to copy:

```
CLAUDE_ACCOUNT=sk-ant-oat01-...
```

It is the account every run of the batch logs in as, and running under another one means
editing that value. Only that key is read, so the file stays usable for whatever other
credential the repository comes to need. The token reaches the container in a file rather than
on the command line, since the command line of a running process is readable and there are five
of them side by side; the file goes with the throwaway copies and the batch deletes it at the
end, and nothing from it reaches the recorded batch.

The runs are parallel containers, and what a batch costs follows `-Model` and `-Effort`: five
full runs are minutes and around a dollar on a large model, and a fraction of that on a small
one with low effort.

- `-Fixture` is a project copied fresh per run, given as a path or as the name of a folder in
  `fixtures/`, which is where a clone drops the project it wants to run against: the folder
  travels empty and git ignored, so no fixture ever lands in the repository. It is never this
  repository: STEP 1 reads the repository and STEP 4 writes `specs/<feature>/`, so a run
  against the framework specifies the framework. A copy per run rather than a reset, because
  run two would otherwise find the `spec.md` run one wrote and stop at STEP 1, by rule.
- `-Plugin` defaults to this repository's root and reaches the skill through `--plugin-dir`,
  which loads a directory for that session only. The file under review is the file that runs,
  uncommitted changes and all; the marketplace cache is never read. What runs is a copy of it,
  holding only what Claude Code loads, because what matters is what sits above the skill:
  pointed at the repository, `--plugin-dir` leaves `CLAUDE.md`, `notes/` and `tests/` one level
  up, and the agent has the skill's absolute path in hand. Runs did read the framework's own
  construction notes that way. An install has none of that above the plugin, so neither does a
  run, and a reading outside the project is then the skill's defect rather than the harness's.
- `-Flags` defaults to `--assume --verbose`. `--assume` is what makes an unattended run
  possible at all, since a headless session has no channel to answer STEP 3, and that is also
  the one thing this cannot reach: the confirmation cycle never runs, so the rules around it
  stay a manual test. `--verbose` is always on, since without the trace there is no telling
  where two runs diverged.
- `-Model` and `-Effort` fix both for every run in the batch. Left unset, a run inherits
  whatever the CLI defaults to at that moment, and two batches of the same case then compare
  across a difference nothing in the output names. Either way `case.md` records what was used.
- `-StopAfterStep` kills each run the moment it opens the step after this one, so a batch
  measuring STEP 1 pays for STEP 1. Nothing is said to the run: asking it to stop was tried,
  and it works most of the time, which is the worst a measurement can be. A run in five obeyed
  the skill's handover from one step to the next instead, and the wording that finally held was
  the fourth one written. The mark is what triggers the kill, never the step's number on its
  own, which turns up in ordinary prose; below STEP 4 an announced `Write` triggers it too, for
  the run that skips the mark. A killed run says so in `summary.md` and in `meta.txt`, and the
  numbers the closing event would have carried are empty for it. What a batch cut this way
  measures is the trace and the reading of that step, not the artifact.
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
| `summary.md` | one row per run: the step it was killed at if it was, files written, `behaviors`, `scenarios`, `Assumed`, turns, seconds, cost |
| `run-N/trace.md` | everything the agent wrote: the `▸ ↳ ◂` lines and the STEP 5 report |
| `run-N/tools.txt` | one line per tool call, with the file or pattern, which is what the run actually read |
| `run-N/written/` | every file that appeared in the fixture copy. Anything outside `specs/` is a run that wrote where it was not asked to |
| `run-N/meta.txt` | the step the harness killed it at, exit code, stop reason, turns, duration, cost, permission denials, session id |

The counting in `summary.md` says where to look. What the runs disagree about is read in the
traces, by a human.

The throwaway working copies and the raw `stream-json` stay outside this repository, under
`../my-sdd-runs/<case>/<timestamp>[_step-N][_<model>]_<arm>/`, and can be deleted at any time. Outside and not in the
ignored `Temp/`, because `claude` climbs the directory tree from its working directory: a copy
under this repository inherits this repository's `CLAUDE.md` and `.git`, and the run then reads
the framework's own source as if it were the project it was asked to specify. `-WorkRoot`
moves it, and moving it back under the repository is what that bias looks like.
