import re
import sys

USAGE = """Checks a list of business rules against the shapes the phase declares.

    python3 validate-rules.py --request "issue an invoice" < rules.txt
    python3 validate-rules.py --request "issue an invoice" rules.txt

One numbered line per rule, `ok` or what it breaks, and exit code 1 if any rule broke one. A
rule that only warns leaves the exit code alone, so the cycle can come clean."""


MODALS = ['can', 'could', 'may', 'might', 'must', 'shall', 'should', 'will', 'would',
          'pode', 'podem', 'poderá', 'poderia', 'deve', 'devem', 'deverá', 'deveria']
NEGATIONS = ['cannot', "can't", 'must not', 'does not', 'do not', 'never',
             'não pode', 'não deve', 'nunca']
FIELD_VERBS = ['has', 'have', 'contains', 'contain', 'includes', 'include',
               'belongs to', 'belong to', 'is composed of', 'consists of',
               'tem', 'têm', 'possui', 'possuem', 'contém', 'inclui',
               'pertence a', 'pertencem a', 'é composto de', 'é composta de']
# A rule is what two or more scenarios illustrate. A line naming one case is one of those
# scenarios: an outcome, or a condition narrowing the line to a single run of the system.
SINGLE_CASE = ['is rejected', 'is refused', 'is accepted', 'is denied', 'is ignored',
               'if', 'when', 'without', 'with no',
               'é recusad', 'é rejeitad', 'é aceit', 'é negad', 'é ignorad',
               'se', 'quando', 'sem']
NON_SUBJECTS = ['system', 'application', 'service', 'api', 'user', 'users',
                'sistema', 'aplicação', 'serviço', 'usuário', 'usuários']
IMPERATIVES = ['create', 'manage', 'delete', 'update', 'list', 'handle', 'support', 'allow',
               'enable', 'ensure', 'provide', 'store', 'maintain',
               'criar', 'gerenciar', 'apagar', 'listar', 'permitir', 'garantir', 'manter']
VAGUE = ['valid', 'invalid', 'proper', 'appropriate', 'adequate', 'correct', 'fast', 'quick',
         'slow', 'efficient', 'reasonable', 'robust', 'user-friendly',
         'válido', 'inválido', 'adequado', 'correto', 'rápido', 'lento', 'eficiente',
         'razoável', 'amigável']
IMPLEMENTATION = ['table', 'index', 'endpoint', 'database', 'json', 'http', 'rest', 'dto',
                  'repository', 'schema', 'migration', 'cache', 'primary key', 'foreign key',
                  '200', '201', '400', '404', '409',
                  'tabela', 'índice', 'banco de dados', 'classe', 'repositório', 'esquema']
ARTICLES = ['the', 'a', 'an', 'o', 'os', 'as', 'um', 'uma']
DETERMINERS = ARTICLES + ['this', 'that', 'these', 'those', 'every', 'each', 'any',
                          'este', 'esta', 'esse', 'essa', 'todo', 'toda', 'cada', 'qualquer']
STOPWORDS = ARTICLES + ['of', 'with', 'in', 'on', 'no', 'not', 'de', 'do', 'da', 'com', 'em',
                        'sem', 'que']

BULLET = re.compile(r'^\s*(?:\d+[.)]|[-*•])\s*')
BOLD = re.compile(r'\*\*|__|`')


def found(text, terms):
    for term in terms:
        if re.search(r'(?<!\w)' + re.escape(term) + r'(?!\w)', text):
            return term
    return None


def stem(word):
    word = re.sub(r'[^\w-]', '', word.lower())
    return re.sub(r'(es|s)$', '', word)


def subject_window(text):
    words = text.split()
    if words and words[0].lower() in ARTICLES:
        words = words[1:]
    return [word for word in words[:3] if word.lower() not in STOPWORDS]


def akin(word, stems):
    root = stem(word)
    return any(root == other or (len(root) > 3 and other.startswith(root[:4])) for other in stems)


def names_the_act(rule, request_stems):
    words = [word for word in rule.split() if word.lower() not in STOPWORDS]
    return bool(words) and all(akin(word, request_stems) for word in words)


def verb_first(word):
    # English gerund or one of the plain forms, Portuguese infinitive. The first word decides,
    # since an act names what is done and a noun phrase names the doing of it.
    return word.endswith('ing') or word.endswith(('ar', 'er', 'ir')) or word in IMPERATIVES


def check(rule, request_stems):
    breaks = []
    warnings = []
    low = rule.lower()
    words = rule.split()
    first = words[0].lower().strip(',.:;') if words else ''

    if first and not verb_first(first):
        breaks.append('does not open with a verb: an act is `issuing an invoice`, never `Invoice creation`')

    implementation = found(low, IMPLEMENTATION)
    if implementation:
        warnings.append(f'"{implementation}" is implementation unless it is the word of this domain')

    return breaks, warnings


def rules_from(lines):
    rules = []
    for raw in lines:
        text = BOLD.sub('', BULLET.sub('', raw)).strip().rstrip('.')
        if text:
            rules.append(text)
    return rules


def main(arguments):
    request = ''
    paths = []
    while arguments:
        argument = arguments.pop(0)
        if argument == '--request':
            request = arguments.pop(0) if arguments else ''
        elif argument.startswith('--request='):
            request = argument.split('=', 1)[1]
        elif argument in ('-h', '--help'):
            print(USAGE)
            return 2
        else:
            paths.append(argument)

    lines = []
    if paths:
        for path in paths:
            with open(path, encoding='utf-8') as handle:
                lines.extend(handle.read().splitlines())
    else:
        lines = sys.stdin.read().splitlines()

    rules = rules_from(lines)
    if not rules:
        print('no business rules on the input')
        return 2

    request_stems = {stem(word) for word in request.split() if stem(word)}
    broke = 0
    warned = 0
    for index, rule in enumerate(rules, start=1):
        breaks, warnings = check(rule, request_stems)
        if breaks:
            broke += 1
        if warnings:
            warned += 1
        verdict = '; '.join(breaks + [f'({warning})' for warning in warnings]) or 'ok'
        print(f'{index:02d} · {rule}\n     {verdict}')

    print(f'\n{len(rules)} rules, {broke} broke a rule, {warned} to check')
    # Three acts is the ordinary shape of a request that can fail: the act, and a refusal
    # for each way it is turned down. One line is a list whose refusals were never written.
    if len(rules) == 1:
        print('one rule alone: where the act can be refused, each refusal is an act of its own')
    return 1 if broke else 0


if __name__ == '__main__':
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main(sys.argv[1:]))
