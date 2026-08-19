# tests/spec

Runs the `spec` skill for real and records what came out. Nothing here is loaded by Claude
Code: only `skills/`, `commands/` and `agents/` are scanned, so this folder travels in git and
costs the agent nothing.

## The two arms

**Baseline** is `baseline.sh`: the same request N times with nothing changed. The
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

```sh
docker build -t my-sdd-runner .
cp ../.env.example ../.env    # then put a `claude setup-token` token in it
```

```sh
./baseline.sh --name create-board \
              --fixture kanban-clean \
              --request "criar um board" \
              --runs 5
```

The host needs a shell, git and docker, which on Windows is what Git Bash already carries.
There the path of every mount is converted before docker sees it, since MSYS otherwise rewrites
the container's side of it and the run comes up with no working directory.

What the container is for is everything the machine lends a run without being asked: the
logged in user's `CLAUDE.md`, which runs did read and quote back as the project's convention,
their `settings.json` with whatever hooks and permissions are in it, whatever `ls` and `find`
are installed, and a `python` that may or may not be there, which is the difference R71 exists
to survive. Inside, all of it is declared, and a batch on another machine differs by the prompt
and nothing else. Only two things are mounted: the copy of the fixture as the working
directory, and the copy of the plugin, read only.

Authentication is a token from `claude setup-token`, which wants a subscription, so a batch is
billed where a session already is instead of on an API key. It lives in `CLAUDE_ACCOUNT` in
`tests/.env`, git ignored, with `tests/.env.example` next to it as the form to copy:

```
CLAUDE_ACCOUNT=sk-ant-oat01-...
```

It is the account every run of the batch logs in as, and running under another one means
editing that value. It sits one level up rather than at the repository root because the harness
is the only thing that reads it, and a second block's harness logs in as this same account
instead of keeping its own copy of the token. The token reaches the container in a file rather than
on the command line, since the command line of a running process is readable and there are five
of them side by side; the file goes with the throwaway copies and the batch deletes it at the
end, and nothing from it reaches the recorded batch.

The runs are parallel containers, and what a batch costs follows `--model` and `--effort`: five
full runs are minutes and around a dollar on a large model, and a fraction of that on a small
one with low effort.

- `--fixture` is a project copied fresh per run, given as a path or as the name of a folder in
  `fixtures/`, which is where a clone drops the project it wants to run against: the folder
  travels empty and git ignored, so no fixture ever lands in the repository. It is never this
  repository: PHASE 1 reads the repository and PHASE 4 writes `specs/<feature>/`, so a run
  against the framework specifies the framework. A copy per run rather than a reset, because
  run two would otherwise find the `spec.md` run one wrote and stop at PHASE 1, by rule.
- `--plugin` defaults to this repository's root and reaches the skill through `--plugin-dir`,
  which loads a directory for that session only. The file under review is the file that runs,
  uncommitted changes and all; the marketplace cache is never read. What runs is a copy of it,
  holding only what Claude Code loads, because what matters is what sits above the skill:
  pointed at the repository, `--plugin-dir` leaves `CLAUDE.md`, `notes/` and `tests/` one level
  up, and the agent has the skill's absolute path in hand. Runs did read the framework's own
  construction notes that way. An install has none of that above the plugin, so neither does a
  run, and a reading outside the project is then the skill's defect rather than the harness's.
- `--flags` defaults to `--assume --verbose`. `--assume` is what makes an unattended run
  possible at all, since a headless session has no channel to answer PHASE 3, and that is also
  the one thing this cannot reach: the confirmation cycle never runs, so the rules around it
  stay a manual test. `--verbose` is always on, since without the trace there is no telling
  where two runs diverged.
- `--model` and `--effort` fix both for every run in the batch. Left unset, a run inherits
  whatever the CLI defaults to at that moment, and two batches of the same case then compare
  across a difference nothing in the output names. Either way `case.md` records what was used.
- `--stop-after-phase` kills each run the moment it opens the phase after this one, so a batch
  measuring PHASE 1 pays for PHASE 1. Nothing is said to the run: asking it to stop was tried,
  and it works most of the time, which is the worst a measurement can be. A run in five obeyed
  the skill's handover from one phase to the next instead, and the wording that finally held was
  the fourth one written. The mark is what triggers the kill, never the phase's number on its
  own, which turns up in ordinary prose; below PHASE 4 an announced `Write` triggers it too, for
  the run that skips the mark. A killed run says so in `summary.md` and in `meta.txt`, and the
  numbers the closing event would have carried are empty for it. What a batch cut this way
  measures is the trace and the reading of that phase, not the artifact.
- `--arm` is which arm this batch is, and it is the last field of the folder name. It defaults
  to `baseline`, and the ablation is what it exists for: the two arms carry the same `--name`,
  the same phase and the same model on purpose, so without it the only thing telling them apart
  in the listing is the timestamp, which says nothing. Kebab-case and short, since it is read
  in a folder name: `baseline`, `no-r17`, `r17-reworded`.
- `--note` is the whole sentence that slug abbreviates: which rule came out of the copy under
  `--plugin`, and how. It stays in `case.md`, where there is room for it.

`bypassPermissions` is refused by the permission classifier, so each run is `acceptEdits` with
`Read Glob Grep Write Edit` and `Bash(python3 /plugin/skills/<skill>/scripts/:*)` allowed. That list adds permissions, it does
not confine the run: every run so far reached for `Bash` to list and read files, and got it.
The interpreter is on the list because a phase runs the skill's own validator, and a run that
built the call correctly had it denied and then reported the check as if it had passed. The
pattern is the skill's own `scripts/` folder and not `python3` on its own, so what a run can
execute is what the plugin ships: a build, a test and a `python3 -c` still come back denied,
and `tools.txt` is where that gets checked.

## What a run leaves behind

Recorded under `runs/<fixture>/<case>/<timestamp>[_phase-N][_<model>]_<arm>/`, git ignored for now.
The fixture is the outermost folder, because two batches of the same case against different
projects are not a series and under one folder the timestamps read as if they compared. The case
is the folder under it, so the batches ablation compares sit side by side; inside, the timestamp
orders them, the phase and the model say whether two of them are comparable at all, and the arm
says what is being compared. The phase and the model are left out when they were not fixed. The
rest, effort and `-Note` included, is in `case.md`:

| file | what it holds |
|---|---|
| `case.md` | the request, the flags, the fixture, and the commit the skill was at, said to be clean or dirty |
| `summary.md` | one row per run: the phase it was killed at if it was, files written, `behaviors`, `scenarios`, `Assumed`, `↳` lines and how many of them were off, turns, seconds, cost |
| `run-N/trace.md` | everything the agent wrote: the marks, the prose around them and the PHASE 5 report |
| `run-N/cites.txt` | one line per `↳`, with the phase it came out in, the id it carried and what is wrong with it |
| `run-N/tools.txt` | one line per tool call, with the phase that was open when it was made and the file or pattern, which is what the run actually read and when |
| `run-N/written/` | every file that appeared in the fixture copy. Anything outside `specs/` is a run that wrote where it was not asked to |
| `run-N/meta.txt` | the phase the harness killed it at, exit code, stop reason, turns, duration, cost, permission denials, session id |

The counting in `summary.md` says where to look. What the runs disagree about is read in the
traces, by a human.

The `off` column is the one count that rules rather than measures, and it rules on four things:
a `↳` carrying an id that is not `R22` or `R28`, one carrying no id at all, `R22` outside PHASE 2
or `R28` outside PHASE 3, and a batch whose flags left `--verbose` out emitting any `↳` at all.
`R22` gets a fifth, against the file the same run wrote: it announces one id and two
`scenarios`, so a `spec.md` whose widest `behavior` holds a single `scenario` is one where the
merge never happened. A batch cut before PHASE 4 has no file, and there the check stays quiet
rather than blaming the run for where the harness stopped. What the line *says* is not ruled
on: a run citing `R22` for having split rather than merged counts as clean, and that is what
the trace is read for.

The throwaway working copies and the raw `stream-json` stay outside this repository, under
`../my-sdd-runs/<fixture>/<case>/<timestamp>[_phase-N][_<model>]_<arm>/`, mirroring the layout above,
and can be deleted at any time. Outside and not in the
ignored `Temp/`, because `claude` climbs the directory tree from its working directory: a copy
under this repository inherits this repository's `CLAUDE.md` and `.git`, and the run then reads
the framework's own source as if it were the project it was asked to specify. `--work-root`
moves it, and moving it back under the repository is what that bias looks like.
