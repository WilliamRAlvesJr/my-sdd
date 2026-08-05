# my-sdd

A spec-anchored SDD framework for Claude Code, shipped as a plugin (`my-spec`).

What gets written here is **prompt, not documentation**. The final reader is the agent; the
user only reviews.

## What the framework is

Almost a BDD run by the agent. The center is the Gherkin scenario: it is what the user
reviews, what the test verifies, and the only reference that outlives the feature.

Four decisions come from that, and they hold in every block:

**The Gherkin lives in the spec, not in the tasks.** BDD itself calls Gherkin a
specification, and that is what `tasks.md` had been turning into. `spec.md` holds the
scenarios, numbered `S1`, `S2` and permanent; `tasks.md` is order, state and where the work
lands, citing the ids.

**Two ids, and the `scenario` is the one the work cites.** The `behavior` is `B1`, `B2`: the
product decision, what `sync` operates on and what `Assumed` hangs under. The `scenario` is
`S1`, `S2`: the unit that gets verified, and the id a task and a test carry. Both are unique
inside the `spec` and neither number is ever reused. The `S` runs through the whole file
instead of restarting under each `behavior`: `B2.S1` would say twice where the `scenario`
sits, and one of the two copies goes stale the day it moves. Citing only the `B` was the
earlier shape, and it hides four fifths of a `behavior` with five `scenarios` from `check`,
which then has to judge coverage instead of counting it.

**Every scenario is verified end to end, against the real system.** No mock, no piece
swapped out. That is where the ban on the intermediate version in the tasks comes from:
hardcoded value, response assembled without saving, and the white cube all died together,
because a scenario that passes with half the system faked says nothing about the product.

**The Gherkin does not become code.** It exists to be read by people. The framework
presumes neither Cucumber nor anything else that executes `.feature`: what verifies the
scenario is a test written in the project's technology. The style reference is an acceptance
suite where the two live side by side: the scenario in prose, and a real acceptance test
behind it that nothing generated.

**`spec.md` is a `.feature` written in markdown, and nobody converts it.** Reading Gherkin's
own reference closed the pair that was missing: `Rule` is the `behavior`, *one business
rule*, which *groups together several scenarios*, word for word what we had written. So the
`#` is `Feature:`, the summary under it is the free-form description, each `## B` is a
`Rule:`, and each fenced block is one `Scenario`. Out go `Background` (a `scenario` is cited
alone by a task and by a test, so its starting state has to be readable there), tags (nothing
is executed) and the `# language:` header with comments (keywords are always English).
`Assumed` is the only field with no counterpart, and that is why it stays markdown: it is
the only line meant to disappear. The 1:1 buys nothing at runtime; it buys a structure
somebody else defined, against the pull to invent a heading, an index, a section of notes,
none of which a `.feature` could hold.

**No user story, and Cucumber says why.** Its own definition is *"a small piece of valuable
functionality used for planning and prioritising work"*: planning and priority, which is
`tasks` and not `spec`. Gherkin has no keyword for it either, so a `spec.md` shaped like a
`.feature` leaves it out by construction. `spec-kit` goes the other way: there the `P1` story
is the standalone MVP, which makes the spec decide build order.

**A `Then` that needs another feature merges the two.** Twenty `behaviors` usually mean two
`specs`; the reverse happens too. When the result can only be observed by using something
the feature does not deliver (creation answers with an address, and reading that address
belongs to the other `spec`), the `scenario` does not close on its own, and the two are one
feature. A dependency in the `Given` does not count: there the world already had a history,
and building the initial state out of a feature that is done and verified is the normal
case.

## State

Built block by block. Each block is validated by the user before the next one starts.

| block | state |
|---|---|
| `skills/spec/` + `commands/spec.md` | `SKILL.md` + `TEMPLATE.md`; no execution yet, and one open hole below |
| `skills/plan/` + `commands/plan.md` | **current**: today it carries a single diagram, the class diagram with a diff, and it is always attempted. Its notation is in `diagrams/class-diff.md`; `SKILL.md` conducts and does not describe. Run once against the lab rat |
| `tests/spec/` | deleted on 2026-08-01, and it comes back as a block of its own. It held `test-cases.md` (60 cases, each citing the `R` it exercises), the generated index `rules.md`, and `rules.sh`, which writes the index and checks coverage both ways. Keeping the quoted citations in step with every reworded rule was eating the session the prompt was open for, so the cases stop travelling with the prompt: the version in the git history is where they come back from. The block also carries the harness that runs the skill for real, one subagent per run against a fixture: first to read the spread across runs of the same request, and later as the control arm ablation needs |
| `tasks` | deleted in the commit where the spec absorbed the Gherkin. Two lab-rat runs and twelve fixed defects are in the git history, and that is where the new version comes from when its turn arrives |
| `clarify` | decided and not started: `spec` already tells the user to run it at the end of the report. It edits `spec.md` and appends to `specs/conventions.md` |
| `init` | decided and not started: it writes `specs/conventions.md`, numbered `C1`, `C2` and cited by the `behavior`. The `feature` folder name is settled and lives in `spec` until this block exists |
| `sync` | raised and not started: it is its own block, `init` does not absorb it, and `spec` stops and hands over to it |
| `debug` | dissolved on 2026-08-04. It was going to be an execution mode with three parts, and the other two existed for the replay: dropping it took the persisted run and the isolated step with it. What it promised is already elsewhere, in the trace built into `spec` and in the harness under `tests/` |
| `build`, `check` | not started |

Nothing outside the current block gets implemented, even when the decision is already made.

**Everything the repository is built against sits outside it**, in a working folder git
ignores: the lab rat, the hand-written examples the formats came from, and the third-party
projects that were read for analysis (`spec-kit`, `OpenSpec`, `cavekit`, `ponytail`). A clone
has none of them, and a block that needs one sets it up first. Nothing under `skills/` or
`commands/` may cite a path that lives there.

**What each of these was decided to be is in `notes/decisions.md`**, one section per block:
the requirements already raised for `clarify`, `sync`, `check`, `init`, `build` and `tests/`,
what `debug` was before it dissolved, and the holes in `spec` that are already closed. Read the section when its block
starts, and not before. Nothing there is implemented now.

### The open hole in `spec`

Found by rereading, after the block had already been validated:

- **it points at two commands that do not exist.** STEP 5 always ends in `Run
  /my-spec:clarify`, and the STEP 1 stop offers `/my-spec:sync`; `commands/` holds
  `plan.md` and `spec.md`. The stop is the worse of the two, because it denies the only path
  there is and hands over one that is not there.

## How we write the prompts

**Reasons only where the prior runs the other way.** A rule the model would follow on its
own gets one line, with no justification. A rule that fights the training carries its reason,
or it is obeyed the first time and abandoned the third.

**A block refuses rather than guesses.** Every entry a block needs is declared, and it is
checked before any work starts: the argument that is required, the file that has to be there,
the file that must not be. Missing one of them ends the run right there, saying what is
missing. The pull is the other way: the model would rather hand something over than come back
empty, so it fills the gap from whatever is nearby and carries on. What that produces is not
a visible error; it is a plausible artifact built on a request nobody wrote, and the artifact
is permanent and cited by tests. Stopping costs one line. A whole `spec.md` written from what
I took the request to be costs the run and the reread after it.

**The conversation is not an input.** What the user typed in the call is; what they said three
messages ago is not. That text was written to explore: it changed direction, half of it was
dropped, and none of it was written to be turned into a permanent file. Making them state the
request again costs one line and is them signing it. This is why `/my-spec:spec` with no
argument stops instead of reusing what was just discussed.

**Every step declares an `In` and an `Out`, announces both, and a new block carries that
too.** Two lines under the step's heading say what it takes in and what it hands over, and
two lines in the conversation say it happened: `▸` going in, with what this pass is doing,
and `◂` coming out, with what actually came out. A step that is a cycle emits one `▪` per
round, numbered, between its `▸` and its `◂`: the step is entered once and left once however
many rounds it takes, and a `▸` per round would make a cycle indistinguishable from four steps
in a row. A stop is an `Out`, not a failure. None of it goes in the artifact, and the `◂` is
not a section of the final report.

The reason it is a rule and not a habit is that a run that stopped halfway is
indistinguishable from one that went through every step: the model works in silence and hands
over the finished artifact, so the two failures the reread never catches (the cycle left on
the first round, the stop nobody noticed) look exactly like success. It is also what gives
the test cases something to assert on: *the cycle ran more than one round* stops being
something you check by eye.

**Write the `In` even where it is the previous `Out`, because where it isn't, that is the
find.** Writing the `spec`'s five pairs is what made two seams visible: STEP 5 consumes the
warnings and what stayed out, carried since STEP 1 across four steps, and STEP 3 produces N
folders after a split while STEP 4 consumes N. An `Out`-only contract would have hidden both.

It is repeated in each `SKILL.md` rather than shared: a few lines duplicated cost less than a
file every skill has to read to know how to print one line.

**Every rule carries an id, `R1`, `R2`, and the index is generated.** Flat, permanent, never
reused, the fourth series after `B`, `S` and `C`, and for the same reason each of those
exists: it turns a reread into arithmetic. Three things hang off it. A test case cites `R17`
instead of pasting the paragraph, so *a rule no case exercises*, already written as a defect
of the block, becomes set minus set, run by a script and not by eye. The review fits on a
screen: an index with one line per rule, and when a `SKILL.md` grows what shows up is the new
`R`, which is when you decide whether to read the paragraph at all. Both of those live in the
tests block, which is deleted and comes back later; the id is what they are waiting on. And
the reason not to split a `SKILL.md` into one file per step goes with it: the id gives the
reader a gate without taking the rule's reason away from the agent, which is what made the
file long in the first place. The split was proposed a second time, as a defence against the
model drifting on a long file, and lost again for a different reason: the drift that actually
happens is not the kind a split prevents. The glossary gets no id: it defines, it doesn't order.

**A rule with an id names its own subject, because it is read alone.** *It drops a question,
never an end of work* is fine as the paragraph after the one about `--assume`, and it means
nothing as a line in the index or as the rule a test case cites: the antecedent is in the
neighbour, and the citation doesn't carry the neighbour. So no leading pronoun, and no *here*,
*above*, *that line* or *the fifth one* pointing outside the sentence. Twenty of the `spec`'s
sixty-two rules were written this way before the ids existed, which is the tell: prose reads
top to bottom and an id doesn't, and the id is what the rest of the repository cites. The
fix is always the same and costs a few words: `--assume` drops a question, the folder is
`specs/<short-name>/`, the `clarify` line always goes in.

**Dilution is a cost.** A rule buried in 250 lines competes for attention with 249 others.
Cutting too much and cutting too little are not symmetrically bad.

**One complete example beats six partial ones.** The model follows an example better than a
description, but a repeated example is duplication like any other.

**A drawing where it shortens the review.** The user checks a diagram faster than the
equivalent list, and that is why the class diagram went into `plan`. Every new artifact gets
asked the same way: is there anything here that is better seen drawn? If there is, it carries
the drawing; if not, text, since a diagram that only illustrates costs the same as any other
duplication.

**Nothing shared before the second consumer.** A core with one implementation is the
abstraction the framework itself condemns.

**The format follows the artifact's owner.** The `spec.md` skeleton lives in `skills/spec/`,
not in a `templates/` folder at the root: the block's skill and template travel together,
and a new block is a single folder. A command does not carry the definition of an artifact it
does not write.

**The format is a template, not a description.** Each block is a folder with the `SKILL.md`
and, next to it, the artifact's format. The template is the blank artifact, with placeholders
in brackets, that the agent copies and fills in; all the prose about the artifact (the rule
and its reason) stays in `SKILL.md`. The template explains nothing, because an instruction
comment inside the skeleton survives the filling in and leaks into the user's file. The
pattern came from `spec-kit`'s `templates/` folder, without the prefix in the name: there the
templates share a folder and have to tell each other apart, here each one is already in its
owner's folder.

**A drawing has no template, it has a notation.** `TEMPLATE.md` works for the text artifact,
which is copied and filled in. A diagram is not that: a UML skeleton with `[Class]` inside a
CSS selector is not something anyone would copy, and it's exactly the leftover the prompt tells
you to hunt for, coming out worse than the complete example `SKILL.md` already carried. Where
the artifact is a drawing, the block carries the notation, one file per diagram inside
`diagrams/`, with the name saying which diagram it is: `skills/plan/diagrams/class-diff.md`.
UML diagrams are many, and a single file for all of them is the folder the next diagram would
have to share.

**Thin command.** `commands/*.md` delegates to the skill and repeats no rule.

**What lives in `skills/` does not know this repository.** This `CLAUDE.md` and `notes/` are
construction scaffolding: they say how the framework is built, and a skill that read them
would be shipping the construction to the user. An example taken from the lab rat, a rule
taken from here, down to the language: all of that comes in looking like knowledge and is
only what happened to be open on the screen. The framework's documentation invents its own
examples.

## Writing

English, in every file of the framework. Lean technical prose: no symbols, no telegraphic
style. The reviewer is an engineer: precision at the forks is worth more than saving tokens.
The arrow `→` as light notation. **The conversation with the user is in Brazilian
Portuguese**; what changes language is the artifact, not the chat.

**No em dash, anywhere.** Not `—`, not `–`, in any file and in the chat. Where one would go:
a colon when what follows explains what came before, a comma when it is an aside, brackets
when it is a side remark, a full stop when it is already another sentence. The rule carries
its reason because the pull is constant: the em dash is the model's default connector, it
comes back the moment nobody is watching, and it reads as machine-written in a repository
whose whole point is prose a person signed.

Don't explain the stack: the reader is a Java/Spring engineer.

**Standard engineering words are fine; methodology dialect isn't.** Mock, stub, race
condition, idempotent, regression, edge case: any engineer reads those without a definition,
and spelling them out in plain words costs a line and buys nothing. What stays out is the
dialect: atom, vertical slice, proof, unhappy path. The model coins those and then uses them
as if everyone knew them, and the reviewer gets stuck on the word instead of disagreeing with
the idea. The test is who would need the definition: every engineer knows the first list;
only someone who read a particular book on process knows the second. A term that fails the
test becomes the sentence that would define it.

**A field label says what the field does**: **Changes**, not "touches". Vagueness isn't
jargon, and none of the above licenses it.

**A term from one domain only comes in with the domain named.** "An endpoint of a web API",
"a scene of a Unity game", "a database migration in a backend": concrete names are welcome
in an example; what can't happen is the bare term, because bare it reads as if it held for
every project, and that's how the format ends up with a backend flavor. Where the list
already mixes domains, the variety says that on its own and naming each item is noise.

## Verification

A block only closes after running against a lab rat: a real project outside this repository,
with its own git, declaring the plugin in its `.claude/settings.json`. Today it is a
greenfield Spring Boot + Flyway + Testcontainers API, and the first feature it gets is the
only one with no dependency, since that is the only one that can go to build on an empty
system.

**The one who verifies can't have helped write it.** Running the skill in the same
conversation where it was written tests nothing: the result comes from remembering what was
already decided, not from the prompt. A run only counts when an agent without that context
does it, banned from reading the hand-written examples (they hold the answer) and told to
report where the prompt got in the way and where it nearly disobeyed. That's how the
contradictions no rereading ever caught turned up.

The second example is from another kind of project, today a Unity game. A format validated in
one domain is not a format, it is that domain's habit: it was Unity that showed that the
initial state is a field, that a result can be a range instead of a number, and that there
are tasks no test verifies.

Signs that the block failed, not that the project is hard: an obvious question in the output,
a derivable line in the artifact, a rule in the prompt that no run ever exercised, **a task
for a problem nobody asked to solve**: an obstacle found along the way becomes a warning,
not a list item.
