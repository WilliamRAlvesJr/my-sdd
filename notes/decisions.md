# Decisions, in full

What `CLAUDE.md` holds in one line, written out. Part of it came from reading `spec-kit`,
part from the reread that followed each block closing.

Nothing here is implemented now. A section is read when its block starts; until then
`CLAUDE.md` is what holds, and it points here. Both files are construction scaffolding and
neither one is in git.

## `spec`: the holes that are closed

Found by rereading, after the block had already been validated. What they settled is worth
keeping.

**Where the `feature` folder name comes from**: under `init` below, and written out in STEP 3
until that block exists.

**`--assume` reaching a stop.** The refusal principle settled it: the flag drops a question,
never an end of work, and STEP 1 now names the three ends it doesn't touch. Checking the
inputs before doing any work also reordered STEP 1, with the `spec.md` that already exists
looked for at item 2, so the conventions, the repository and the obstacles are only read once
there is a `feature` to write.

**The split** turned out to be a wording problem, not a structural one. *You write `spec.md` and
nothing else* was written to keep the agent from producing a plan, a task list and code: it
restricts the kind of artifact, not how many, and the glossary already said *one per
`feature`*. So the split writes every `spec`, because whoever asked for a CRUD asked for the
three, and the line at the top now says one per `feature` out loud. What the confirmed split
changes: one table per `spec` in the one message, a question naming the folder along with the
id (`create-invite:B3`, since each table opens at its own `B1`), and the confirmation in the
plural, `are the lists right?`, still alone in its selector. What is being confirmed is the
split itself, and one confirmation per table asks the same question three times. With
`--assume` the cut is made alone and every `spec` still gets written, with the report saying
the cut was assumed too: the flag drops the question, and the alternative would be leaving
most of the request specified nowhere.

One residue left there on purpose: **a split into five or six `features`.** Writing six specs
in one run is a lot, and the natural way out would be asking which ones go now, which is
choosing what to specify first, and order belongs to `tasks`. An arbitrary cap is worse than
no rule; if it shows up against the lab rat, that is when it gets decided.

**The `Given` leaning on something nobody built** turned into a graded answer, and the grade
is who has decided what. **Nobody specified the dependency**: STEP 3 asks it, while the table
is still open and nothing is written: *columns presuppose boards,
which no `spec` covers. do boards come in?*. Yes makes it a split; no makes it a line in the
report, decided by the person who knows whether boards are with somebody else or due next
sprint. **Already specified and not built**: no question, since somebody decided it exists
and what is left is work order; it is a warning under *can't be verified yet*. **Delivered by
the `feature` itself or already working**: silence.

**What it is never is a stop**, and that was the fork worth getting right. Specifying isn't
building: the `spec.md` comes out correct with the dependency missing, and what can't run yet
is `build`. Blocking would put build order inside the artifact that says it carries none. And
in the case that motivated the question, someone asked for columns and the request was clear,
so refusing to write it doesn't make the dependency appear, it just moves the request to a
post-it. The refusal principle covers inputs, which the user fixes by retyping the call; the
state of the world isn't one, and a block nobody can clear teaches people to work around it.
Three things it also isn't: `Assumed`, since no decision is pending and `clarify` would have
nothing to ask; a `behavior`, for the same reason the obstacle isn't one; and a reason to
merge two `features`, since that rule is about the `Then`.

**`--verbose` locates, it does not prove, and that is half a line to add to `R65`.** A step
reporting which rule decided is self-report, and self-report of a reason puts the decision
first and the citation after it: the rule applied without noticing is missing from the list,
and a plausible one can show up in its place. What survives that is the other half of the `↳`
line. The id is a candidate paragraph to open when something came out wrong; the decision next
to it (`expiration and revoking left out`) is a fact the reader checks against the request in
seconds, and it is the one whose only result is a line that is not there, invisible in the
artifact and invisible to `check`. So the text after the id is the decision itself, never the
rule reworded, since `↳ R24 · left out what wasn't in the request` is the rule repeated and
says nothing. And no hedge in the emitted line: `possible rule applied` authorises citing
without commitment, and what the citation is worth belongs in the flag's description, once,
not in every line it prints. Who reads the flag settles it, and it is whoever wrote the
prompt, since `R66` keeps every id away from the user.

## `clarify`

**The decision nobody made, settled outside `spec`.** `spec` records under
`Assumed` and does not ask; `clarify` reads `spec.md`, stops at each item and edits the file.
Four things it has to carry:

- **confirming an assumption deletes the line.** The field says nobody chose; once the
  question is answered, somebody chose: the value stays in the `Then` and the line goes
  away. That is where the cycle's exit condition comes from, verifiable from the outside: a
  `spec.md` with no `Assumed` left is clarified. Without this the command reopens the same
  questions on every run;
- **do not raise a decision just to have something to ask**, or the queue never empties;
- **the last round is the `spec`'s confirmation**, including when there was no assumption at
  all. It is the only place where the `spec` is approved, since `spec` confirms nothing after
  STEP 3;
- **an answer worth more than this `feature` is written to `specs/conventions.md`**, with the
  next free `C`, and the `behavior` starts citing it. Without this the user's decision
  evaporates: the line disappears, the next `feature` assumes the same thing again, and the
  only way into the file would be running `init` a second time, which nobody does. The filter
  is one question: **does it hold beyond this `feature`?** *An error body follows Problem
  Details* does; *the name is capped at 100 characters* does not, and that one just loses its
  line and keeps its value in the `Then`. Promoting everything turns the file into a dump, and
  then *a convention written there never becomes `Assumed` again* stops meaning anything,
  since most of the lines would never have come up twice.

A convention inherited from the repository is not its business: reading the repository is
`init`'s, and what `clarify` writes is a decision that was made now, in front of the user.
Neither is a `Scenario` that is expensive to verify: that is a warning in the `spec`
report, not a pending decision.

## `sync`

**Everything that was already there when the call arrived.** It is `spec`'s fallback,
and its three entrances are a `feature` built by hand with no `spec`, a `spec` a request
changes, and a `spec` the code has drifted from. The name says the work: putting the `spec` and
the system back in agreement, whichever of the two moved. `respec` was the earlier name and it
promised the wrong thing twice, since `re-` reads as specifying again where the operation is
surgical, and most of these calls have no earlier `spec` to redo.

What was missing is the path for a request that
changes a `feature` already specified: "change the Name label to Title" has someone who sees
the difference, but opens no decision at all: there is no failure path, and `clarify` would
have nothing to ask. The work is fixing that line with the id intact, because a `spec`
describing a screen that changed starts lying, and the test citing the id keeps pointing at
it.

**The trigger is a stop in `spec`, and what it looks at is the `feature`, not the request.**
STEP 1 already stops when the `spec` of the `feature` the request lands in is there, and that
is the older half: a Boards `spec` holding create and list is where deleting a board belongs,
even though it covers nothing about deleting. The other entrance is the same `feature` with no
`spec` at all, and STEP 2's list is what makes it cheap: one `behavior` on it that the system
already delivers is enough, and the run ends handing over `/my-spec:sync`.

**One is enough, because the alternative is a `spec` that lies by omission.** Requiring all of
them was the first shape and it breaks on the ordinary case: Boards answering POST and GET,
nobody having written a `spec`, and a request for DELETE. The delete is left over, so the run
would go on, and what it hands back is a permanent file with one `behavior` in it, describing a
third of a `feature` whose other two thirds are specified nowhere. `sync` takes the whole
`feature` in, the built part along with the requested one.

**It is `behavior` by `behavior` inside the `feature` being delimited, never `feature` against
`feature`.** Comparing whole is what turns "invite by public link"
into "we already do invites" when what exists is invite by email: the two share a name and a
domain, and neither delivers a `behavior` of what was asked. That comparison is also what keeps
this from swallowing R14, where what already works belongs to another `feature` and rightly
stays out.

It is a stop and not a question, and that is what `--assume` settles: R4 has the flag dropping
a question and never an end of work, so as a question this one would be dropped exactly where
the agent is least able to decide alone. The way out of a wrong stop is R10's: the request
comes back saying what sets it apart from what was found.

This changes `spec`, a block already validated, in STEP 2 and not STEP 1: the test needs the
list of `behaviors`, which STEP 1 has not produced yet. The step's `Out` gains the second end
of run alongside the empty list, and the new rule sits next to that one with the difference
named: an empty list is a request with no product in it, and this one is product that is
already built.

**What decides the work is not what exists in the system, it is whether anything cites an id
yet.** That is why code written by hand and an empty repository land on the same side,
opposite as they look: code with no `spec` cites no id, so specifying it is new writing, not
an update.

Nobody cites an id. Rewriting is free, renumbering included:

- nothing built and nothing specified: the normal path, `spec` and then the rest;
- code built by hand, no `spec`: specify it, and the answer cannot be inventing the
  `behaviors` from the code, which nobody reviewed;
- `spec` written, nothing implemented: the everyday case, where you read what you just wrote
  and change your mind.

Something cites an id. Every operation is surgical, and the id is what has to survive:

- the request changes wording and opens no decision: fix the line, id intact;
- the request opens a decision no id takes: new `behavior`, with the next free id, even when
  its place is in the middle of the file. An `Assumed` line the product ran over goes away
  with it, and not through `clarify`, since "the body has these fields and nothing else" stops
  being true the moment one more is required;
- the request removes product: the `behavior` goes and its number stays vacant forever;
- the request moves the line between `features`: a `behavior` changes file, and there is no
  answer yet, since the id is unique inside its `spec`, so migrating `B3` either renumbers it
  or leaves two `B3` in the repository;
- half the tasks are done: the same request hits a `behavior` with a passing test and one
  nobody has written, and the two halves follow different rules.

A `spec` and the code drifting apart with nobody asking for anything is not on the list above,
since there is no request, just a defect. It is `sync`'s all the same: `check` finds it, `sync`
fixes it, and which of the two wins is the user's call.

**What was already built goes in as a `Rule:` with no `Scenario` under it.** The line and its
description, nothing else. The `feature` shows up whole, so nothing lies by omission, and no
`scenario` was transcribed from the code, so the ban above holds. Reading an old `behavior`
costs one line instead of a screen, and that is what keeps a two line change costing two lines
of review. Nobody converts the file, so a `Rule:` with nothing under it has no parser to pass.

**The mark is `Assumed`, and there is no new field.** `Assumed` is already the only field
written to disappear and `clarify` is already what asks: a `behavior` with no `scenario`
carries one saying the system delivers it and nobody specified it, and whoever closes it
writes the `scenarios` with the next free `S`. The debt is declared instead of invisible,
which is what it is today.

**What the user reads is the diff and not the file**, which settles half of what the paragraph
below left open. The volume of review follows the request, not the size of what the request
landed in.

A screen filtering users by phone number, and a request adding email and name: `B1` is one
line with an `Assumed` and no `scenario`, `B2` is new and carries the `scenarios` for email
and name. Three lines read. The alternative that loses is writing the old `behavior`'s
`scenarios` and marking them unreviewed: same volume as today, and it freezes whatever the
code does by accident as `S1`, with a test citing the id from then on.

One requirement falls on `check`: a `behavior` with no `scenario` is declared debt and not a
coverage failure, or the first run flags every `spec` that ever went through `sync`.

Still open, and it is about the call rather than the work: the argument,
`sync [<feature name | file>]`. `spec` carries none of this: it stops
at STEP 1 when the `spec.md` is already there or when the repository already covers the
request, and at STEP 2 when there is no `behavior`.

## `check`

**Coverage in both directions.** A spec scenario no task exercises, and a test in
the repository that cites no id. Both are cheap to find, and rereading doesn't catch either.
The `S` is what makes the first one arithmetic: the set of `S` in `spec.md` minus the set of
`S` in `tasks.md`, with nothing left to judge. The
one who writes `tasks.md` checks their own arithmetic, and that doesn't count. The
diagram selector pointing at a line that doesn't exist belongs here too: the agent doesn't
render what it writes, so a wrong index passes in silence. The convention citation is a third
direction, and the reason it is worth an id is under `init`.

**A fourth direction, and it is form and not coverage**: the artifact against the shape its
own block declares. A `behavior` with no `scenario` under it, a `Scenario` with no `Then`, a
number reused, a fenced block that never opened. The glossary already rules the first one out
(a `behavior` is a Gherkin block with one or more `scenarios`), and that is the point: the rule
is written, nothing counts it, and a `behavior` with no `scenario` is invisible to the three
directions above, since all of them count `S` and this one has none. It is the same arithmetic
the rest of `check` runs on, over the file's own structure rather than over the ids it shares
with another file, which is why it belongs here and not in a reread. `OpenSpec` splits exactly
this off into a `validate` that runs before any agent reads the file, and its `spec` names the
trap out loud: a `Scenario` written with three hashes instead of four fails in silence.

## `init`

**Where the convention that crosses features lives.** A decision that already holds
for the whole repository does not belong to one feature's spec, and today the spec skill asks
and the user answers "confirm it once and I'll stop asking" without the file where that
confirmation lands existing. It writes `specs/conventions.md` and nothing else.

What it is for, stated so the block can be verified from the outside: **a convention written
in that file never becomes `Assumed` again.** The `spec` already reads "`CLAUDE.md` or a
conventions file" in STEP 1, and that part is done: `R13` now names `specs/conventions.md`,
puts it ahead of `CLAUDE.md` where the two disagree, and leaves the repository as the third
fallback. The file does not exist yet, so today `R13` falls through to the other two; what
the `init` block adds is the first source, not a new rule in `spec`.

Four steps, the shape the other blocks already have: read the repository (the language of
what is written, the shape of an error response, what the system already does in a similar
spot, how the folders are already named); build the list, one line per convention with its
origin attached, *inherited from `BoardController.java`* or *chosen now*, because the origin
is what says whether it can be trusted; confirm in a cycle, `AskUserQuestion` the same way
STEP 3 of `spec` does, with *is the list right?* alone at the end; write the file.

In goes what changes the artifact, value or shape, **including the shape of the `feature`
folder name**, casing, wording and language, which is one of the open holes in `spec`. The
filter used to read *what changes a `Then` or names a folder*, and it was already narrower
than the file it described: the artifact's language changes no `Then` and names no folder, and
it was in there from the start. Out goes architecture: `plan` reads the real names from the
repository and needs no file. And out goes everything `spec-kit` puts in its `constitution`:
principle, governance, document version. That is a process manifesto, and no spec consumes it.

**How the `spec.md` itself is written is a convention too, and the case that shows it is the
abstraction level of the step.** `When I rename the task to <title>` and `When I send PATCH
"/cards/card-1" with body { "title": <title> }` describe the same `scenario`, and which one a
repository wants is not the `feature`'s decision, it is the repository's. It needs no new
category: it is shape and not value, the same side as the artifact's language and the folder
name, so it comes in with its own `C`, no `behavior` cites it, and `check` counts nothing.

Two things come with it:

- **its origin is always *chosen now*, and it is the first convention where that is
  structural.** `init` infers from the repository, and a repository with no `spec` in it has
  no step to infer a level from. So this line only ever exists because somebody picked it in
  the confirmation cycle, which is exactly why it has to be asked rather than defaulted;
- **a convention picks inside what `SKILL.md` allows, it never overrides a rule.** In the
  pair above both sides survive `R48 · write the value, don't describe it`, since both are
  concrete and what varies is how much of the transport surfaces. A `C` that put the step
  back to *I get the right response* would not be a style choice, it would be a convention
  against a rule of the prompt, and the precedence is that `SKILL.md` wins.

The transport in the `When` is a real cost and not a reason to forbid it: the `spec.md` is
permanent and cited by tests, so a route in the step makes the `spec` lie the day the route
changes, and that is `sync`'s work, which the prose variant would not have. `R48` already puts
literal transport in the `Then` (`201 with Location: /invites/{code}`), so what the convention
really decides is whether it climbs into the `When` as well. Whoever owns the repository
decides that, and the report says the cost once.

**Decided: `spec-kit`'s short name without its number**, as in `specs/create-invite/`, two to
four words in kebab-case, action-noun where it reads well, acronyms keeping their own
spelling. Written out in STEP 3 of `spec`, and it moves here once `init` exists.

**The `NNN` prefix stays out, because it was never about ordering.** `spec-kit` numbers for
two reasons that are its own: shell scripts locate the feature directory by prefix, and
several agents can be working at the same time, where the number is what keeps two of them off
the same folder. Nothing here shells out to find a folder, and one agent writes one `spec` at
a time. What the prefix would cost is the reading it invites: a number in front of a folder
looks like priority or build order, and this artifact carries neither.

Two more departures, both kept: **the name is confirmed with the user**, not generated and
used silently, and **it has no relation to a git branch**. The folder is permanent, since the
plan and the tasks live in it.

Three decisions already made:

- **`sync` is not part of it.** `init` runs once and writes one file; `sync` runs many
  times, is surgical, and branches on whether anything cites an id yet. Different cadence,
  different artifact;
- **the convention is numbered, `C1`, `C2`, and the `spec` cites it.** Below;
- **`init` is not the only writer, and `clarify` appends too.** This overturns an earlier
  decision here, which was that nothing is shared before the second consumer. The second
  consumer is the second `feature`, and it always arrives: with a single writer, an answer the
  user gave in `clarify` reaches no other `spec`, and the file only ever fills up by running
  `init` again. So two writers, with the split named: `init` reads the repository and records
  what was already there; `clarify` records what was decided just now. Neither one rewrites
  the other's lines.

An empty repository has nothing to inherit and the file comes out nearly empty. That is the
point: it exists so the `spec` has somewhere to read, and the `spec` already knows how to
pick and confirm on the first `feature`.

**The convention has an id, and the `behavior` cites it.** The reason is that the
convention's value is already sitting in the `Then`: `C2` saying that an error answers 422
with `{field, message}` is what `B2` writes out literally, and the day `C2` changes that
`Then` is a lie. Without an id, finding out means rereading every `spec` and judging whether
it still matches; with one, it is arithmetic, and the framework already prefers the second,
which is why `check` exists at all.

It is the twin of `Assumed`: both point at a value in the `Then` whose owner is somewhere
else. `Assumed` means nobody chose, and disappears when someone does; the citation means
somebody chose once, for the whole repository, and stays.

Two rules keep it from turning into noise:

- **only cite the convention whose value shows up literally in a `Then` of that
  `behavior`.** A convention that is shape and not value (the artifact's language, the
  folder name) is cited by nobody, and that is right;
- **it goes under each `behavior` that uses it, repeated.** `Assumed` goes under the first
  one only, because that line is going to disappear; this one is there for impact, and citing
  only the first hides the other four `behaviors` that went stale.

**An exception is another convention, never a level underneath.** A convention holds for the
repository unless it says otherwise, and the one that contradicts it comes in with its own
id, its own scope and a line naming who it replaces: `C7 · in the message gateway the error
follows the BSP's format, replaces C2`. Flat, read top to bottom, and whoever cites `C7` has
said everything: no resolution, and `check` goes on counting.

**Raised and turned down, twice over: tags on the `Scenario` carrying the citation, and a
hierarchy of scopes with override**, `@common` as the default, `@messaging` when the rule
contradicts it, `@messaging_create` under that. Both were worth answering, and the answers
are the reason the shape above is what it is:

- **a tag names a scope, not a convention.** For `check` to find the `Then` that disagrees
  with what it cites, it needs `C2`; with `@messaging` it would first have to work out which
  conventions hold in `@messaging` after inheritance, which is judging again, the thing the
  numbering bought its way out of. And the tag sits above the `Scenario` while the convention
  almost always holds for the whole `behavior`, which is where the citation already lives;
- **the cascade converges on where we already are.** The deepest scope is roughly the name of
  a `feature`, and a convention that holds for one `feature` is the value in that `feature`'s
  `Then`. So the hierarchy, followed to the end, arrives at the `Then`, after three levels of
  resolution. The price of those levels is precedence in a cascade, which is CSS, the
  canonical system where nobody can look at one element and say which rule won; and a taxonomy
  that has to exist before there are cases to put in it, growing one exception at a time until
  the third case fits no branch.

What it costs, which is not free:

- **`init` moves to the surgical side.** What decides the work is whether anything cites an
  id yet, and now something does. It stays re-runnable (that is how a convention discovered
  in the third `feature` gets in), but it appends and edits lines instead of rewriting the
  file. Numbers are never reused, and a removed convention leaves its number vacant forever;
- **it changes the `spec`, a block already validated.** Today the `Assumed` section says an
  inherited convention does not go in the file, because it has an owner outside and changes
  without the `feature` changing. That premise was there being nowhere to trace it to. The
  reformulation: the `spec` never copies the convention's text, it cites the id, and the value
  stays where it always was, in the `Then`. `TEMPLATE.md` gets the field;
- **`check` gets a third direction**: a `spec` citing a `C` that does not exist, and a `Then`
  that disagrees with the convention it cites.

## `build`

**Scope and stopping.** Running the whole list in one go makes the agent lose the
plan halfway. The scope is asked for in the call (one task, a stretch), and resuming comes
from the state mark, which already tells written apart from checked. It stops at `?` and
never marks `x`. This is where "no mocks" is really enforced: the test it writes boots the
system.

**The build order is the reverse of the usage order.** In use, spec produces plan which
produces tasks. In construction, we wrote the tasks by hand first and inferred from there
what spec and plan have to carry: a decision the lower artifact cannot make on its own is a
requirement of the one above it. Starting from the top produces a document nobody consumes.

And that is how the spec showed up finished: two runs sharpening `tasks.md` produced the
scenario format, and only then did it become visible that it had never been a task. The
content changed files without changing shape.

## `tests/`

**`tests/` is versioned and never loaded.** What decides whether an installer sees a file is
not `.gitignore`, it is the folder's name: Claude Code only scans `skills/`, `commands/` and
`agents/`, so a folder called anything else is copied and never read, and a `CLAUDE.md` at the
plugin root isn't loaded either, by the same rule. There is no `.pluginignore` and no exclude
field, and a git marketplace clones the whole repository, so this is the only lever there is.
It buys the test cases a place in git without costing the agent a token, and it is why they
left the ignored working folder: that folder is ignored for a different reason, and lumping
the two together was hiding the cases from the repository to solve a problem they never had.

**One folder per block under `tests/`**, mirroring `skills/`: `tests/spec/` holds
`test-cases.md`, the generated `rules.md` and the `rules.sh` that writes it. The script is the
`spec`'s and knows only the `spec`: it moves up to `tests/` taking the block's name as an
argument when a second block has cases, and not before.

**Test cases detect, the trace locates.** Worth keeping apart, because merging them buys a
suite that is green on runs nobody watched. The cases and `check` answer *this came out wrong*;
the trace and `--verbose` answer *which step it was in and what it thought it was doing*. A
detector with no locator hands over a wrong `spec.md` and no lead; a locator with no detector
narrates runs you believe went fine. Of the two the cases buy more, and that is the order to
build them in.

**The harness runs the skill for real, in subagents.** One subagent per run, N runs per case,
each one calling the command against a target project, with what came out left in a file for a
human to read later. `--assume` is what makes it possible at all, since a subagent has no
channel to the user and every run would otherwise die in STEP 3. What it does not cover is that
same step: the flag drops the question, so the confirmation cycle never runs and the rules the
trace was built to watch stay a manual test.

**The harness lives here and the target does not.** The script, the cases and the recorded runs
are `tests/`, versioned and never loaded. The project the skill runs against cannot be this
repository: STEP 1 reads the repository and STEP 4 writes `specs/<feature>/`, so a run against
the framework specifies the framework and leaves its output in it. The target is a fixture,
copied fresh for each run rather than reset with git, since a copy does not depend on the state
of what it came from. Run two would otherwise find the `spec.md` run one wrote and stop at STEP
1, by rule. The fixture sits next to the lab rat in the ignored working folder, and its path is
an argument, never a line in the harness.

**The harness is not a skill of the plugin.** `source` is `./`, so everything under `skills/`
and `commands/` is installed: a `my-spec:ablation-study` would land on the machine of somebody
who only wants to write a `spec`, which is the framework's own construction travelling to the
user. The session runs here, in the my-sdd repository, and what goes outside is the subagent,
working in a copy of the fixture that declares the plugin in its `.claude/settings.json` the
way the lab rat already does. When the procedure settles, the trigger is a project command in
this repository's `.claude/`, which no install ever sees; until then the harness is a document
read at the moment it runs.

**To be checked on the first execution: whether a subagent can invoke the installed skill.** A
slash command is expanded by the CLI and not by the agent, so the call has to go through the
skill tool. If it does not work, the fallback is the subagent reading the installed `SKILL.md`
and executing it, which is less faithful and gets recorded as a departure rather than passed
over.

**Clean is not the same as empty, and empty exercises little.** With no conventions, no other
`spec` and no code, most of STEP 1 never fires: inheriting a convention, finding the `spec.md`
that is already there, the hand-off to `sync`. So at least two fixtures, one empty and one
populated, and the populated one is where the fragile rules live.

**The baseline arm comes first, and it is an instrument of its own.** Before any rule is
removed, run the same request N times with nothing changed and read the spread across the N
outputs. Where five runs agree the prompt holds; where they diverge is the rule that is missing
or the one too weak to survive, and that is the answer to what the prompt does today, which is
the question you have before you have any suspects. It costs half of what two arms cost and it
needs no expected result, since comparing the runs against each other already informs.

**Ablation has two arms, and the arms share one file.** The control arm is the baseline above;
the other runs the same case against a `SKILL.md` with one rule removed. The subagent invokes
the installed skill, so editing it between arms makes the runs serial: two arms in parallel
would read a file neither of them thinks it is reading. Either serialise and pay in time, or
install two copies of the plugin under different names.

**A binary question per case is what counting needs, and only counting needs it.** Two arms are
compared by counting, so each case carries what should have happened, written so it can be
checked: file shape, ids with no gap, number of `behaviors`, the `behavior` that should be
absent. The baseline needs none of that. What both record is the same: the request, the flags,
the whole trace, the `spec.md` and the STEP 5 report, with the case's expected result next to
it where there is one, or the reader rereads the request to remember what was right.
`--verbose` is always on, since without the trace you are comparing ten files with no idea
where the runs diverged. The human reads what the counting leaves over, and the runs that
diverge from each other.

**Ablation is an instrument, not a command.** Deleting one rule and running the same request
again answers the one question nothing else answers, whether a rule does anything at all, which
is the defect already written for this block: a rule no run ever exercised. It does not become
a feature. The model is not deterministic, so one run per arm concludes nothing: it compares
distributions, it needs a binary outcome to count (so it runs on top of a test case with a
known answer, never on its own), and around five runs per arm show a coarse effect while a
subtle one needs dozens and stops paying. Reach for it when one rule is under suspicion and the
test case does not decide, which is to say after the baseline has run and named a suspect.

**The small case came from real work, and it crosses two blocks.** A screen already filters
users by phone number, and the request adds email and name to the same filter. What arrived
with it was a PRD: pages of it, naming the squad and the programming language, none of which
decides behavior. It is the shape the competing tools were reported to fail on, an opinionated
pipeline producing twenty markdown files for a change somebody would rather have typed by
hand, and it is the only case so far that nobody invented.

Filtering by phone is a `behavior` of this same `feature` that the system already delivers, so
R63 fires and `spec` writes no file at all: the run ends at STEP 2 handing over `sync`. Half
the case is checkable today and half waits for that block.

Against `spec`, today:

- **Where it ends.** STEP 2, with the hand-off, and no `spec.md` anywhere. A run that writes a
  file holding email and name is R63 missing the `behavior` that was already standing, which
  is the omission R63 exists to stop.
- **What it drops.** Squad, stack and the rest of the PRD leave no trace: none of it reaches
  the list of `behaviors` or the stop message. A run that carries them is reading its input as
  content instead of as a request.

Against `sync`, when the block exists:

- **What it hands back.** `B1` as one line with an `Assumed` and no `scenario`, `B2` new with
  the `scenarios` for email and name, and a diff three lines long. This is the case the shape
  was decided against, so it is the first one to run.
- **What it asks.** The request hides four decisions the PRD does not settle: whether the name
  matches exactly or partially, whether the match ignores case and accents, whether the three
  fields combine with AND or OR, and what an empty field does when another one is filled.
  Those are `Assumed` lines under `B2`, and `clarify` is what asks them. Missing them is the
  worst of the four failures, because getting them out is the whole value the clarification
  phase is claimed to buy.

It runs against the populated fixture. The filter is an edit to a screen that already exists,
so the same request against an empty project is a different case.

## `debug`

**Dissolved, and dropping replay is what did it.** It was going to be an execution mode every
block runs under, with three parts: the persisted run, the isolated step and the replay. The
other two existed for the replay, so the chain unwinds with it. The isolated step was only ever
there to make the replay's input verifiable, at a price that fell on the most expensive spot in
`spec`, with STEP 4 writing the Gherkin having never read the user's words. And the per-step
`<n>.in.md` / `<n>.out.md` has no consumer left, since the harness that runs the skill records
what came out on its own. Two of the three things the block promised already exist elsewhere:
the trace in the conversation, built in `spec`, and the harness in `tests/`. Nothing here is a
block any more, and this section is what keeps the questions from coming back.

**The persisted run goes with it, and `--debug` is never created.** One folder per run, a pair
of files per step and a place outside `specs/` were all decided, and they were the flag that
earned the name, since the folder landed in the user's repository. Nothing writes that folder
now. `--verbose` keeps its name and stays the only flag of its kind, and the argument that
separated the two is exactly what it holds onto: it narrates and changes nothing.

**Raised and turned down: a log file replacing the trace, at `specs/<feature>/logs/<date>`.**
Kept written down because the question comes back the moment somebody wants a run to outlive
the conversation. The trace is synchronous with the run, and the failure it exists to catch is
the run that stopped at STEP 2 and handed over a plausible artifact: the missing `◂` is seen
while it happens, and a log is only read by whoever opens the log, which nobody does for a run
that looked fine. It is also what the test cases assert on. The path breaks on its own terms
too: `specs/<feature>/` is the permanent directory the user reviews and commits, so the log
lands in the diff; not every run has a feature, and the STEP 1 stop (missing argument, `spec.md`
already there) is both the most interesting run to debug and the one with nowhere to write; and
`<date>` collides on the second run of the day.

**One file per step: turned down, and this is the second time.** First as review ergonomics,
which the `R` index settled, and now as a defence against the model going wrong on a file this
size. Hallucination is not the failure mode: nothing in the file asks for knowledge outside the
request, and the entry check in STEP 1 covers the one place invention could enter. What
actually happens is instruction drift, in four shapes: leaving the cycle on the first round, a
rule that fights the prior obeyed once and dropped on the third run, deriving a line instead of
asking, and a late rule applied early. Only the fourth is attacked by the split, and it is the
rarest of the four. Against it there is already half a detector, an `↳` line carrying an id
from another step's range under `▸ STEP 2`, and the whole detector costs a range of `R` per
step counted by `check`, not a change of architecture. The split also creates a failure of its
own: the step that does not load its file and runs from what it read at the start, which is
invisible because the result comes out plausible. The recut stays cheap if it ever comes back,
since the `R` are flat and do not renumber. Loading each step's file only when the step opens,
in a single thread, goes down with it: it was the cheaper half of the same idea and it needs
the same split.
