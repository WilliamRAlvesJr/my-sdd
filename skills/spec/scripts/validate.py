#!/usr/bin/env python3
"""Checks a generated spec.md against the shape TEMPLATE.md declares.

Form only: what can be decided by reading the file. Whether a Then carries a literal value,
whether a behavior belongs in this feature, whether the scenarios cover the request: none of
that is here, because none of it is decidable by a parser, and a false positive on a
permanent file costs more than a check nobody runs.

    python3 validate.py specs/create-invite/spec.md [more ...]

A directory argument expands to every spec.md under it, so a split that wrote more than one
spec goes in a single call. One line per problem, and exit code 1 if there was any.
"""

import re
import sys
from pathlib import Path

HEADING = re.compile(r'^(#+)\s*(.*)$')
BEHAVIOR = re.compile(r'^B(\d+)\s+·\s+(\S.*)$')
SCENARIO = re.compile(r'^(Scenario Outline|Scenario):\s*(.*)$')
SCENARIO_ID = re.compile(r'^S(\d+)\s+·\s+(\S.*)$')
STEP = re.compile(r'^(Given|When|Then|And|But|\*)\s+(\S.*)$')
EXAMPLES = re.compile(r'^Examples:\s*$')
ROW = re.compile(r'^\|(.*)\|$')
PLACEHOLDER = re.compile(r'<([^<>]+)>')
ASSUMED = re.compile(r'^-\s+\*\*Assumed\*\*(.*)$')
ASSUMED_ITEM = re.compile(r'^ +-\s+\S')

# A skeleton placeholder is [text] with no ( after it, which is what tells it apart from a
# markdown link.
BRACKET = re.compile(r'\[[^\[\]]+\](?!\()')
# The italic label saying when a field applies: an instruction for the agent, not a field.
LABEL = re.compile(r'\*\([^)]*\)\*')

PRIMARY = {'Given': 0, 'When': 1, 'Then': 2}


def check(path):
    problems = []

    def bad(line, message):
        problems.append((line, message))

    try:
        text = Path(path).read_text(encoding='utf-8')
    except OSError as error:
        return [(0, f'cannot read: {error}')]

    lines = text.splitlines()

    fence = None            # {'start': int, 'info': str, 'body': [(int, str)]}
    seen_title = False
    seen_summary = False
    behavior = None         # (line, number)
    behavior_scenarios = 0
    next_b = 1
    next_s = 1
    assumed_at = None
    assumed_items = 0
    assumed_indent = 0

    def close_assumed():
        nonlocal assumed_at, assumed_items, assumed_indent
        if assumed_at is not None and assumed_items == 0:
            bad(assumed_at, 'Assumed has no item under it')
        assumed_at = None
        assumed_items = 0
        assumed_indent = 0

    def close_behavior():
        nonlocal behavior, behavior_scenarios
        close_assumed()
        if behavior is not None and behavior_scenarios == 0:
            bad(behavior[0], f'B{behavior[1]} has no scenario under it')
        behavior = None
        behavior_scenarios = 0

    def check_gherkin(start, info, body):
        nonlocal next_s
        if info != 'gherkin':
            bad(start, f'fenced block is ```{info or "(no language)"}, expected ```gherkin')

        items = []
        in_doc_string = False
        for line, raw in body:
            stripped = raw.strip()
            if stripped.startswith('"""'):
                in_doc_string = not in_doc_string
                continue
            if in_doc_string or not stripped:
                continue
            items.append((line, stripped, len(raw) - len(raw.lstrip())))

        if not items:
            bad(start, 'empty gherkin block')
            return

        head_line, head, head_indent = items[0]
        opener = SCENARIO.match(head)
        if not opener:
            bad(head_line, 'block does not open with Scenario: or Scenario Outline:')
            return

        outline = opener.group(1) == 'Scenario Outline'
        name = opener.group(2).strip()
        found = SCENARIO_ID.match(name)
        if not found:
            bad(head_line, f'scenario name is not "S<n> · text": {name or "(empty)"}')
            next_s += 1
        else:
            number = int(found.group(1))
            if number != next_s:
                bad(head_line, f'scenario is S{number}, expected S{next_s}')
            # Take the higher of the two, so one wrong number does not report every scenario
            # after it.
            next_s = max(next_s, number) + 1

        keywords = []           # (line, primary keyword) in the order they appear
        placeholders = set()
        examples_at = None
        table = []              # (line, cells) of the Examples table
        anchor = head_indent    # indentation of the last line that opened something

        for line, item, indent in items[1:]:
            if EXAMPLES.match(item):
                # Gherkin allows more than one Examples section, and the columns of all of
                # them answer the same placeholders.
                examples_at = line
                anchor = indent
                continue

            row = ROW.match(item)
            if row:
                # Before Examples this is a step's data table, which is allowed and says
                # nothing about the placeholders.
                if examples_at is not None:
                    table.append((line, [cell.strip() for cell in row.group(1).split('|')]))
                anchor = indent
                continue

            step = STEP.match(item)
            if step:
                keyword = step.group(1)
                if not keywords and keyword not in PRIMARY:
                    bad(line, f'scenario opens with "{keyword}", which continues a step that '
                              f'is not there')
                if keyword in PRIMARY:
                    keywords.append((line, keyword))
                placeholders |= set(PLACEHOLDER.findall(item))
                anchor = indent
                continue

            # A step long enough to wrap carries on indented under itself, and the rest of it
            # can hold a placeholder like any other part of the step.
            if indent > anchor:
                placeholders |= set(PLACEHOLDER.findall(item))
                continue

            bad(line, f'not a Gherkin step, table row or Examples: {item}')

        written = [keyword for _, keyword in keywords]
        if 'When' not in written:
            bad(head_line, 'scenario has no When')
        if 'Then' not in written:
            bad(head_line, 'scenario has no Then')

        furthest = -1
        for line, keyword in keywords:
            if PRIMARY[keyword] < furthest:
                bad(line, f'{keyword} comes after a later keyword: the order is Given, When, '
                          f'Then')
            furthest = max(furthest, PRIMARY[keyword])

        if outline and examples_at is None:
            bad(head_line, 'Scenario Outline with no Examples')
        if not outline and examples_at is not None:
            bad(examples_at, 'Examples under a Scenario: it has to be a Scenario Outline')
        if not outline and placeholders:
            bad(head_line, f'a step uses <{sorted(placeholders)[0]}> but this is not a '
                           f'Scenario Outline')

        if table:
            header = table[0][1]
            for line, cells in table[1:]:
                if len(cells) != len(header):
                    bad(line, f'row has {len(cells)} cells and the header has {len(header)}')
            if len(table) == 1:
                bad(examples_at, 'Examples has a header and no row')
            columns = set(header)
            for column in sorted(placeholders - columns):
                bad(examples_at, f'<{column}> has no column in Examples')
            for column in sorted(columns - placeholders):
                bad(examples_at, f'column "{column}" is used by no step')
        elif examples_at is not None:
            bad(examples_at, 'Examples with no table under it')

    for index, raw in enumerate(lines):
        line = index + 1
        text_line = raw.rstrip()

        if text_line.lstrip().startswith('```'):
            if fence is None:
                fence = {'start': line, 'info': text_line.strip()[3:].strip(), 'body': []}
            else:
                if behavior is None:
                    bad(fence['start'], 'gherkin block outside a behavior')
                behavior_scenarios += 1
                check_gherkin(fence['start'], fence['info'], fence['body'])
                fence = None
            continue

        if fence is not None:
            fence['body'].append((line, raw))
            continue

        heading = HEADING.match(text_line)
        if heading:
            close_assumed()
            level = len(heading.group(1))
            title = heading.group(2).strip()
            if level == 1:
                close_behavior()
                if seen_title:
                    bad(line, 'second # heading: the file names one feature')
                if not title:
                    bad(line, 'the # heading has no feature name')
                seen_title = True
            elif level == 2:
                close_behavior()
                if not seen_title:
                    bad(line, 'behavior before the # heading')
                found = BEHAVIOR.match(title)
                if not found:
                    bad(line, f'heading is not "## B<n> · text": {title or "(empty)"}')
                    behavior = (line, next_b)
                    next_b += 1
                else:
                    number = int(found.group(1))
                    if number != next_b:
                        bad(line, f'behavior is B{number}, expected B{next_b}')
                    behavior = (line, number)
                    next_b = max(next_b, number) + 1
                behavior_scenarios = 0
            else:
                bad(line, f'level {level} heading: the file has # and ## only')
            continue

        if not text_line.strip():
            continue

        if behavior is None:
            if not seen_title:
                bad(line, 'text before the # heading')
            else:
                seen_summary = True
            continue

        found = ASSUMED.match(text_line.strip())
        if found:
            close_assumed()
            assumed_at = line
            if found.group(1).strip():
                bad(line, 'the Assumed line carries text from the skeleton')
            continue

        if assumed_at is not None and ASSUMED_ITEM.match(text_line):
            assumed_items += 1
            assumed_indent = len(text_line) - len(text_line.lstrip())
            continue

        # An assumption long enough to wrap carries on indented under its own item.
        if assumed_items and len(text_line) - len(text_line.lstrip()) > assumed_indent:
            continue

        bad(line, f'prose under B{behavior[1]}: the behavior holds scenarios and Assumed only')

    if fence is not None:
        bad(fence['start'], 'fenced block never closed')
    close_behavior()

    if not seen_title:
        bad(1, 'no # heading at the top')
    elif not seen_summary:
        bad(1, 'no summary under the # heading')
    if next_b == 1:
        bad(1, 'no behavior in the file')

    for index, raw in enumerate(lines):
        line = index + 1
        for left in BRACKET.finditer(raw):
            bad(line, f'skeleton placeholder left in the file: {left.group(0)}')
        if LABEL.search(raw):
            bad(line, 'the *(...)* label is an instruction for the agent, not part of the file')

    problems.sort(key=lambda problem: problem[0])
    return problems


def expand(arguments):
    paths = []
    for argument in arguments:
        path = Path(argument)
        if path.is_dir():
            paths.extend(sorted(path.rglob('spec.md')))
        else:
            paths.append(path)
    return paths


def main(arguments):
    if not arguments:
        print(__doc__.strip())
        return 2

    paths = expand(arguments)
    if not paths:
        print('no spec.md found')
        return 2

    total = 0
    for path in paths:
        problems = check(path)
        if problems:
            for line, message in problems:
                print(f'{path}:{line} · {message}')
            total += len(problems)
        else:
            print(f'{path} · ok')

    if total:
        print(f'\n{total} problem{"" if total == 1 else "s"}')
        return 1
    return 0


if __name__ == '__main__':
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main(sys.argv[1:]))
