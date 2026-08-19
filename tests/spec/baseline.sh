#!/usr/bin/env bash
# Runs one request through the installed spec skill N times and records what each run produced.
#
# The baseline arm: nothing is changed between runs, so the spread across the N outputs is the
# measurement. Where the runs agree the prompt holds; where they diverge is a rule that is
# missing or too weak to survive.
#
# Each run is a real `claude -p` session in a container of its own, with its own copy of the
# fixture as its working directory, so PHASE 1 reads a project that is not this repository and
# PHASE 4 writes into a copy that is thrown away. The skill comes from --plugin-dir, which loads
# the working tree rather than the marketplace cache: the file under review is the file that
# runs.
#
# The container is what keeps a batch from measuring the machine along with the prompt.
# Everything a session would otherwise be lent without being asked stays outside it: the logged
# in user's CLAUDE.md, which runs did read and then quote back as the project's own convention,
# their settings.json with whatever hooks and permissions are in it, whatever ls and find are
# installed, and a python that may or may not be there, which is the difference R71 exists to
# survive. Two mounts is all a run gets, the copy of the fixture and the copy of the plugin.
#
# --assume is what makes an unattended run possible at all, since there is no channel to answer
# PHASE 3. That is also what it does not cover: the confirmation cycle never runs here.
# --verbose is always on, since without the trace there is no telling where two runs diverged.
#
#   ./baseline.sh --name create-board --fixture kanban-clean --request "criar um board"

set -euo pipefail

usage() {
    cat <<'EOF'
usage: baseline.sh --name <case> --fixture <name|path> --request <text> [options]

  --name               names the case, and the folder every batch of that case lands in
  --fixture            the project each run works in: a path, or a folder in fixtures/
  --request            the request, exactly as a user would type it after the command
                       (a skill that takes no argument passes "")
  --skill NAME         the skill the batch calls, as /my-spec:NAME (default spec)
  --runs N             how many runs in the batch (default 5)
  --flags "..."        flags passed to the skill (default "--assume --verbose")
  --stop-after-phase N kill each run as it opens the phase after this one (default off)
  --model NAME         fixed for every run in the batch, and recorded in case.md
  --effort LEVEL       low | medium | high | xhigh | max
  --arm SLUG           which arm this batch is, kebab-case (default baseline)
  --note "..."         the whole sentence the arm slug abbreviates, kept in case.md
  --plugin DIR         the plugin directory (default this repository's root)
  --work-root DIR      where the throwaway working copies go (default ../my-sdd-runs)
  --image NAME         the image every run is a container of (default my-sdd-runner)
EOF
}

name=''
fixture=''
request=''
skill='spec'
runs=5
flags='--assume --verbose'
stop_after_phase=0
model=''
effort=''
arm='baseline'
note=''
plugin=''
work_root=''
image='my-sdd-runner'
have_request=0

while [ $# -gt 0 ]; do
    case $1 in
        --*=*) set -- "${1%%=*}" "${1#*=}" "${@:2}"; continue ;;
        --name)             name=$2; shift 2 ;;
        --fixture)          fixture=$2; shift 2 ;;
        --request)          request=$2; have_request=1; shift 2 ;;
        --skill)            skill=$2; shift 2 ;;
        --runs)             runs=$2; shift 2 ;;
        --flags)            flags=$2; shift 2 ;;
        --stop-after-phase) stop_after_phase=$2; shift 2 ;;
        --model)            model=$2; shift 2 ;;
        --effort)           effort=$2; shift 2 ;;
        --arm)              arm=$2; shift 2 ;;
        --note)             note=$2; shift 2 ;;
        --plugin)           plugin=$2; shift 2 ;;
        --work-root)        work_root=$2; shift 2 ;;
        --image)            image=$2; shift 2 ;;
        -h|--help)          usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

die() { echo "$*" >&2; exit 1; }

[ -n "$name" ]    || die 'missing --name'
[ -n "$fixture" ] || die 'missing --fixture'
[ "$have_request" -eq 1 ] || die 'missing --request'
[[ $skill =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "--skill must be kebab-case, got: $skill"
[[ $runs =~ ^[0-9]+$ ]] || die "--runs takes a number, got: $runs"
[[ $stop_after_phase =~ ^[0-9]+$ ]] || die "--stop-after-phase takes a number, got: $stop_after_phase"
# Kebab-case and short, since it is read in a folder name: baseline, no-r17, r17-reworded.
[[ $arm =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "--arm must be kebab-case, got: $arm"
case ${effort:-low} in low|medium|high|xhigh|max) ;; *) die "--effort must be low, medium, high, xhigh or max, got: $effort" ;; esac

# MSYS rewrites anything that looks like a path before a native binary sees it, so `-v $ws:/ws`
# reaches docker as `-v C:/...:C:/Program Files/Git/ws` and the run comes up with no working
# directory. Conversion is switched off for docker alone, since /ws and /plugin are the
# container's paths and nothing is to be done to them, and the host side of every mount is
# converted by host_path instead, which is also the only shape docker accepts on Windows.
# Off for the whole script it would reach git as well, which then cannot find a repository at
# a path it was handed unconverted.
docker() { MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' command docker "$@"; }
host_path() {
    if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi
}
abs_path() { (cd "$1" && pwd); }

script_dir=$(abs_path "$(dirname "${BASH_SOURCE[0]}")")
repo_root=$(abs_path "$script_dir/../..")
[ -n "$plugin" ] || plugin=$repo_root
[ -n "$work_root" ] || work_root="$(dirname "$repo_root")/my-sdd-runs"

# A name that is not a path is looked up in fixtures/, next to this script: the folder travels
# empty and git ignored, the way runs/ does, so a clone has somewhere to drop the project it
# runs against without any of it landing in the repository. A path still works, which is what a
# project kept elsewhere on the machine uses.
if [ ! -d "$fixture" ]; then
    if [ -d "$script_dir/fixtures/$fixture" ]; then
        fixture="$script_dir/fixtures/$fixture"
    else
        die "Fixture not found: $fixture. Pass a path, or drop the project in tests/spec/fixtures/ and pass its folder name."
    fi
fi
[ -f "$plugin/.claude-plugin/plugin.json" ] || die "No plugin at: $plugin"
fixture=$(abs_path "$fixture")
plugin=$(abs_path "$plugin")

# The account every run of the batch logs in as: `CLAUDE_ACCOUNT` in .env under tests/, with
# .env.example next to it saying so, and running under another one means editing that value.
# It sits in tests/ and not at the repository root because the harness is the only thing that
# reads it, and a second block's harness logs in as the same account rather than keeping its
# own copy of the token. `claude setup-token` is what mints a token: it wants a subscription,
# so the batch is billed where a session already is instead of on an API key.
# The file holds a secret, so it is git ignored and nothing from it reaches the recorded batch.
env_path="$(dirname "$script_dir")/.env"
[ -f "$env_path" ] || die "No .env under tests/. Copy tests/.env.example over it and fill in CLAUDE_ACCOUNT with a token from \`claude setup-token\`."
# The value ends at the first space, quote or #, which is what a .env is written like: a token
# carried a trailing ` # note` into the container once and came back as 401 OAuth access token
# is invalid, which reads like an expired token and is a parser taking the comment along.
account_token=$(sed -n 's/^[[:space:]]*CLAUDE_ACCOUNT[[:space:]]*=[[:space:]]*["'"'"']\{0,1\}\([^[:space:]"'"'"'#]\{1,\}\).*/\1/p' "$env_path" | tail -n 1)
[ -n "$account_token" ] || die "No CLAUDE_ACCOUNT line in $env_path."

# Checked before the fixture is copied five times, and named as what it is: the image is built
# from the Dockerfile next to this script, and a batch that only finds out at the first
# `docker run` reports it once per run instead of once.
[ -n "$(docker images -q "$image")" ] || die "No image named $image: build it with \`docker build -t $image .\` in tests/spec."

stamp=$(date +%Y%m%d-%H%M%S)
# The fixture is the outermost folder, because two batches of the same case against different
# projects are not a series: they answer different questions, and under one folder the timestamps
# read as if they compared. Taken from the folder's own name, since --fixture also accepts a path
# to a project kept anywhere on the machine.
fixture_name=$(basename "$fixture")
# The case names the folder under it and the batch names what is inside that: the timestamp, so
# batches of the same case list in the order they were run, then the phase and the model, which are
# what says whether two batches are comparable at all, and last the arm, which is what is being
# compared. The phase and the model are left out when they were not fixed, since a name that
# carries the word for absent reads as a value. Everything else is in case.md.
batch=$stamp
if [ "$stop_after_phase" -gt 0 ]; then batch="${batch}_phase-$stop_after_phase"; fi
if [ -n "$model" ]; then batch="${batch}_$model"; fi
batch="${batch}_$arm"
run_id="$fixture_name/$name/$batch"
out_dir="$script_dir/runs/$fixture_name/$name/$batch"
# Defaults outside this repository, and that is the whole point of the default: claude climbs
# the directory tree from its working directory, so a copy under the repo inherits this
# repository's CLAUDE.md and .git, and the run then reads the framework's own source as if it
# were the project under spec.
work_dir="$work_root/$fixture_name/$name/$batch"
mkdir -p "$out_dir" "$work_dir"

# Assembled piece by piece rather than in one string, because a skill that takes no argument
# passes --request "" and an empty --flags, and the run would otherwise be called with trailing
# blanks the session reads as an argument that is there and is empty.
prompt="/my-spec:$skill"
if [ -n "$flags" ]; then prompt="$prompt $flags"; fi
if [ -n "$request" ]; then prompt="$prompt $request"; fi

# Nothing tells the run it is being cut. Asking it to stop was tried and it works most of the
# time, which is the worst kind of instrument: a run in five obeyed the skill's handover
# instead, and the wording that fixed that was the fourth one written, each of the earlier
# three having leaked at a different rate. Worse, an instruction in the system prompt is read
# by the agent whether it obeys it or not, so the phase being measured was a phase run under a
# condition no user has. The kill below needs none of that, so the run is the run a user gets
# and the harness is the only thing that knows about the cut.

containers=()
# The tokens are written to disk to keep them off the command line, so they leave with the batch
# rather than sitting in the throwaway folder until somebody remembers them. A trap and not a
# line at the end, because the batch that most needs them gone is the one that died halfway.
cleanup() { rm -f "$work_dir"/run-*/env; }
interrupt() {
    trap - INT TERM
    [ ${#containers[@]} -gt 0 ] && docker rm -f "${containers[@]}" >/dev/null 2>&1 || true
    cleanup
    echo "$run_id : interrupted" >&2
    exit 130
}
trap cleanup EXIT
trap interrupt INT TERM

# What the runs are being compared under. A dirty working tree is the normal case here, and
# the sha alone would point at the wrong file.
sha=$(git -C "$repo_root" rev-parse --short HEAD)
state='clean'
if [ -n "$(git -C "$repo_root" status --porcelain "skills/$skill/SKILL.md")" ]; then
    state="dirty (uncommitted changes in skills/$skill/SKILL.md)"
fi

{
    echo "# $run_id"
    echo
    echo "- **request**: \`$request\`"
    echo "- **flags**: \`$flags\`"
    echo "- **prompt**: \`$prompt\`"
    if [ "$stop_after_phase" -gt 0 ]; then
        echo "- **stopped after**: PHASE $stop_after_phase, killed by the harness, nothing said to the run"
    fi
    echo "- **model**: ${model:-(CLI default, unrecorded)}"
    echo "- **effort**: ${effort:-(CLI default, unrecorded)}"
    echo "- **arm**: $arm"
    if [ -n "$note" ]; then echo "- **note**: $note"; fi
    echo "- **runs**: $runs"
    echo "- **fixture**: \`$fixture\`"
    echo "- **plugin**: \`$plugin\` at \`$sha\`, $state, run from a copy holding only what Claude Code loads"
    echo "- **where**: \`$image\`, one container per run, logged in as CLAUDE_ACCOUNT"
    echo "- **started**: $(date '+%Y-%m-%d %H:%M:%S')"
} > "$out_dir/case.md"

# The plugin runs from a copy of its own, and what that removes is what sits above it. Pointed
# at this repository, --plugin-dir leaves CLAUDE.md, notes/ and tests/ one level up from the
# skill, and the agent has the skill's absolute path in hand (R70 hands it one to call the
# validator with): runs have read the framework's own construction notes and the template as
# if they were the project's. An install has none of that above the plugin, so neither does a
# run. What is copied is what Claude Code loads and nothing else.
plugin_copy="$work_dir/plugin"
mkdir -p "$plugin_copy"
for part in .claude-plugin skills commands agents hooks; do
    if [ -e "$plugin/$part" ]; then cp -R "$plugin/$part" "$plugin_copy/"; fi
done

# What a run may execute is what the skill ships, one pattern per file in its scripts folder.
# The prefix is matched by token, so `Bash(python3 .../scripts/:*)` denies the very script in
# that folder, and `Bash(python3:*)` allows anything else python can be told to do: under the
# wider pattern a run reached for `cat > /tmp/HelloWorld.java` and for `echo`.
allowed_tools=(Read Glob Grep Write Edit)
for script in "$plugin/skills/$skill/scripts/"*; do
    [ -f "$script" ] || continue
    allowed_tools+=("Bash(python3 /plugin/skills/$skill/scripts/$(basename "$script"):*)")
done

echo "$run_id : starting $runs runs"

pids=()
for ((i = 1; i <= runs; i++)); do
    run_dir="$work_dir/run-$i"
    ws="$run_dir/ws"
    mkdir -p "$run_dir"
    # Copied fresh per run, never reset in place: run two would otherwise find the spec.md run
    # one wrote and stop at PHASE 1, by rule.
    cp -R "$fixture" "$ws"

    # An array, so the request reaches the session as one argument however it is written,
    # quotes included, and nothing here has to parse or escape it.
    claude_args=(
        -p "$prompt"
        --plugin-dir /plugin
        --permission-mode acceptEdits
        --allowedTools "${allowed_tools[@]}"
        --output-format stream-json --verbose
    )
    # The whole point of the partial chunks is when they arrive. Without them a message reaches
    # raw.jsonl only once it is finished, and the run that wrote PHASE 1 through PHASE 4 in a
    # single block of text had already written all four by the time anything outside could see
    # the first mark. With them the mark lands as it is typed, so the kill lands there too and
    # the tokens of the phases that follow are never generated.
    if [ "$stop_after_phase" -gt 0 ]; then claude_args+=(--include-partial-messages); fi
    if [ -n "$model" ]; then claude_args+=(--model "$model"); fi
    if [ -n "$effort" ]; then claude_args+=(--effort "$effort"); fi

    # The token goes in through a file and not through -e: the command line of a running
    # process is readable, and there are five of them side by side. Written under a umask that
    # keeps it to this user, and deleted by the trap above.
    (umask 077; printf 'CLAUDE_CODE_OAUTH_TOKEN=%s\n' "$account_token" > "$run_dir/env")

    container="my-sdd-$stamp-run-$i"
    containers+=("$container")
    # `record` is the image's entry point for a run: it starts the session, writes the stream
    # into /run and carries the cut. STOP_AFTER_PHASE is the phase this batch measures, and it is
    # an environment variable of the wrapper, never anything the session is told.
    docker_args=(
        run --rm --name "$container"
        --env-file "$(host_path "$run_dir/env")"
        -v "$(host_path "$ws"):/ws"
        -v "$(host_path "$run_dir"):/run"
        -v "$(host_path "$plugin_copy"):/plugin:ro"
        -w /ws
    )
    if [ "$stop_after_phase" -gt 0 ]; then docker_args+=(-e "STOP_AFTER_PHASE=$stop_after_phase"); fi

    docker "${docker_args[@]}" "$image" record "${claude_args[@]}" \
        > "$run_dir/docker.txt" 2> "$run_dir/docker-err.txt" &
    pids+=($!)
    echo "  run-$i : pid $!"
done

# The cut happens inside the container, and record.sh in this folder says why it has to: the
# harness only reads the verdict afterwards. Nothing about it reaches the session, so the phase
# being measured is the phase a user gets, and a measurement stops depending on the behaviour it
# is measuring.

for pid in "${pids[@]}"; do wait "$pid" || true; done

killed=()
exit_codes=()
for ((i = 1; i <= runs; i++)); do
    verdict=''
    if [ -f "$work_dir/run-$i/killed.txt" ]; then
        verdict=$(tr -d '\r\n' < "$work_dir/run-$i/killed.txt")
    fi
    if [ -n "$verdict" ]; then echo "  run-$i : killed opening $verdict"; fi
    killed+=("$verdict")
    code=''
    if [ -f "$work_dir/run-$i/exit.txt" ]; then
        code=$(tr -d '\r\n' < "$work_dir/run-$i/exit.txt")
    fi
    exit_codes+=("$code")
done
echo "$run_id : all runs finished, collecting"

# What the batch leaves behind is written by collect.js, in a container of the same image the
# runs used. Node is there by construction, since the CLI under test is installed with npm, so
# the host needs no runtime beyond whatever starts a container: the machine that can run a
# batch can record one. The script is mounted rather than baked in, so editing it costs no
# rebuild, and the reason it runs once for the batch instead of once per run is that summary.md
# is a batch's file.
json_string() { printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"; }
{
    printf '{\n  "title": %s,\n  "flags": %s,\n  "runs": [\n' \
        "$(json_string "$run_id")" "$(json_string "$flags")"
    for ((i = 1; i <= runs; i++)); do
        if [ "$i" -gt 1 ]; then printf ',\n'; fi
        printf '    { "index": %d, "killed": %s, "exitCode": %s }' \
            "$i" "$(json_string "${killed[$((i - 1))]}")" "$(json_string "${exit_codes[$((i - 1))]}")"
    done
    printf '\n  ]\n}\n'
} > "$work_dir/runs.json"

rows="$work_dir/rows.tsv"
if ! docker run --rm \
        -v "$(host_path "$work_dir"):/batch" \
        -v "$(host_path "$out_dir"):/out" \
        -v "$(host_path "$fixture"):/fixture:ro" \
        -v "$(host_path "$script_dir/collect.js"):/collect.js:ro" \
        "$image" node /collect.js > "$rows" 2> "$work_dir/collect-err.txt"; then
    die "collect.js failed: $(cat "$work_dir/collect-err.txt")"
fi

# The empty columns are half of what a killed run says, so the table is padded by width rather
# than by squeezing runs of whitespace, which is what a column -t would do to them.
{
    printf 'run\tkilled\tspecs\tbehaviors\tscenarios\tassumed\tcites\toff\tturns\tseconds\tusd\n'
    cat "$rows"
} | awk -F'\t' '
    NF { n++; for (i = 1; i <= 11; i++) { c[n, i] = $i; if (length($i) > w[i]) w[i] = length($i) } }
    END {
        for (r = 1; r <= n; r++) {
            line = ""
            for (i = 1; i <= 11; i++) line = line sprintf("%-" w[i] "s  ", c[r, i])
            sub(/ +$/, "", line)
            print line
        }
    }'

echo "recorded in $out_dir"
