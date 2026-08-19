#!/usr/bin/env bash
# Writes the index of the spec skill's rules, and checks it against the cases both ways.
#
# The index is rules.md, one line per rule, generated and never edited by hand. It is what makes
# a grown SKILL.md reviewable: what shows up in the diff is the new R, and that is where the
# decision to read the paragraph gets made.
#
# The check is the other half, and it exists because rereading never caught either side. A rule
# no case cites is the defect already written for this block, a rule nothing exercises; a case
# citing an id the skill no longer has is the citation left behind by a rewrite, and keeping
# those in order by hand is what ate the session the prompt was open in. Both are set difference,
# so a script rules on them and a person stops trying to.
#
# A citation is any R followed by digits anywhere in test-cases.md, which is deliberately loose:
# a case naming a rule in its prose is exercising it as much as one naming it in a field, and a
# format the script polices is a format that gets fought.
#
# Only the spec block is known here. This grows an argument for the block's name and moves up to
# tests/ when a second block has cases, and not before.

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
skill="$here/../../skills/spec/SKILL.md"
index="$here/rules.md"
cases="$here/test-cases.md"

[ -f "$skill" ] || { echo "No skill at: $skill" >&2; exit 1; }

extract() {
    awk '
        function flush(   rest, shut, text, body) {
            if (buf == "") return
            rest = substr(buf, 3)
            shut = index(rest, "**")
            if (shut == 0) {
                print "unterminated bold: " substr(rest, 1, 40) > "/dev/stderr"
                shut = length(rest) + 1
            }
            text = substr(rest, 1, shut - 1)
            sub(/[ \t]+$/, "", text)
            if (text ~ /^R[0-9]+ ·$/) {
                body = substr(rest, shut + 2)
                gsub(/\*\*/, "", body)
                sub(/^ +/, "", body)
                if (match(body, /\. /)) body = substr(body, 1, RSTART)
                text = text " " body
            }
            sub(/[ \t]+$/, "", text)
            print section "\t" text
            buf = ""
        }
        /^## / { flush(); section = substr($0, 4); sub(/:.*/, "", section); next }
        /^\*\*R[0-9]+ ·/ { flush(); buf = $0; next }
        /^$/ { flush(); next }
        buf != "" { buf = buf " " $0 }
        END { flush() }
    ' "$skill"
}

rules=$(extract)
[ -n "$rules" ] || { echo "No rules found in: $skill" >&2; exit 1; }

# A rule the parser walks past is worse than one it mangles, so the count is checked against the
# file rather than trusted: three rules opened `**R41 ·**`, with the sentence outside the bold,
# and the first version of this script dropped all three without a word.
declared=$(grep -cE '^\*\*R[0-9]+ ·' "$skill")
parsed=$(printf '%s\n' "$rules" | wc -l | tr -d ' ')
[ "$declared" -eq "$parsed" ] || { echo "$skill declares $declared rules and $parsed parsed" >&2; exit 1; }

{
    echo "# spec: the rules"
    echo
    echo "Generated from \`skills/spec/SKILL.md\` by \`rules.sh\`. Do not edit."
    echo
    printf '%s\n' "$rules" | awk -F'\t' '
        {
            id = $2
            sub(/ ·.*/, "", id)
            rule = $2
            sub(/^R[0-9]+ · /, "", rule)
            n = substr(id, 2) + 0
            if (seen[n]) print "duplicate " id > "/dev/stderr"
            line[n] = "- **" id "** · " $1 " · " rule
            if (n > max) max = n
            seen[n] = 1
        }
        END { for (i = 1; i <= max; i++) if (seen[i]) print line[i] }
    '
} > "$index"

ids=$(printf '%s\n' "$rules" | awk -F'\t' '{ id = $2; sub(/ ·.*/, "", id); print id }' | sort -u)
total=$(printf '%s\n' "$ids" | wc -l | tr -d ' ')
echo "$index : $total rules"

if [ ! -f "$cases" ]; then
    echo "No cases at: $cases, coverage unchecked"
    exit 0
fi

cited=$(grep -oE '\bR[0-9]+\b' "$cases" | sort -u || true)
uncovered=$(comm -23 <(printf '%s\n' "$ids" | sort) <(printf '%s\n' "$cited" | sort))
unknown=$(comm -13 <(printf '%s\n' "$ids" | sort) <(printf '%s\n' "$cited" | sort))

fail=0
if [ -n "$uncovered" ]; then
    echo "no case cites: $(printf '%s\n' "$uncovered" | sort -V | tr '\n' ' ')"
    fail=1
fi
if [ -n "$unknown" ]; then
    echo "cited and gone: $(printf '%s\n' "$unknown" | sort -V | tr '\n' ' ')"
    fail=1
fi
if [ "$fail" -eq 0 ]; then echo "$cases : every rule cited, no citation left behind"; fi

exit "$fail"
