// Turns a finished batch into what gets read afterwards: per run the trace, the tool calls and
// the files it wrote, and for the batch the table in summary.md.
//
// It runs inside the same image the runs do, which is node's by construction, since the CLI
// under test is installed with npm. So the harness needs no runtime of its own on the host:
// whatever can start a container can record a batch. It is mounted rather than baked into the
// image, so changing it costs no rebuild.
//
// Mounts, all from baseline.sh: /batch is the throwaway working copies, /out is the recorded
// batch inside the repository, /fixture is what every copy started as.

const fs = require('fs');
const path = require('path');

const BATCH = '/batch';
const OUT = '/out';
const FIXTURE = '/fixture';

const plan = JSON.parse(fs.readFileSync(path.join(BATCH, 'runs.json'), 'utf8'));
const verbose = (plan.flags || '').split(/\s+/).includes('--verbose');

const rows = [];
for (const run of plan.runs) {
  const runDir = path.join(BATCH, `run-${run.index}`);
  const outDir = path.join(OUT, `run-${run.index}`);
  fs.mkdirSync(outDir, { recursive: true });

  const { text, tools, result } = readStream(path.join(runDir, 'raw.jsonl'));
  fs.writeFileSync(path.join(outDir, 'trace.md'), text.join('\n\n'));
  fs.writeFileSync(path.join(outDir, 'tools.txt'), tools.join('\n'));

  const written = copyWhatTheRunWrote(path.join(runDir, 'ws'), outDir);
  const counts = countSpecs(outDir, written);

  const cites = readCitations(text, verbose, counts.specs ? counts.widest >= 2 : null);
  fs.writeFileSync(path.join(outDir, 'cites.txt'),
    cites.map((c) => `STEP ${c.step}\t${c.id}\t${c.verdict}`).join('\n'));

  // A killed run never emits the closing event, so everything the result carries is missing
  // for it: turns, duration and cost included. What the row has to say about that run is the
  // step it opened, and the empty numbers next to it are the second half of the same fact.
  const got = result || {};
  const meta = [
    ['killed', run.killed || ''],
    ['exit_code', run.exitCode === undefined ? '' : run.exitCode],
    ['is_error', got.is_error === undefined ? '' : got.is_error],
    ['stop_reason', got.stop_reason || ''],
    ['num_turns', got.num_turns === undefined ? '' : got.num_turns],
    ['duration_ms', got.duration_ms === undefined ? '' : got.duration_ms],
    ['total_cost_usd', got.total_cost_usd === undefined ? '' : got.total_cost_usd],
    ['permission_denied', (got.permission_denials || []).length],
    ['session_id', got.session_id || ''],
    ['files_written', written.join(', ')],
  ];
  fs.writeFileSync(path.join(outDir, 'meta.txt'),
    meta.map(([k, v]) => `${k}: ${v}`).join('\n'));

  rows.push({
    run: `run-${run.index}`,
    killed: run.killed || '',
    specs: counts.specs,
    behaviors: counts.behaviors,
    scenarios: counts.scenarios,
    assumed: counts.assumed,
    cites: cites.length,
    off: cites.filter((c) => c.verdict !== 'ok').length,
    turns: got.num_turns === undefined ? '' : got.num_turns,
    seconds: got.duration_ms === undefined ? '' : Math.round(got.duration_ms / 1000),
    usd: got.total_cost_usd === undefined ? '' : round(got.total_cost_usd, 3),
    written: written.join(' '),
  });
}

// Counting only. What the runs disagree about is read by a human, in the traces.
const summary = [`# ${plan.title}`, ''];
summary.push('| run | killed | specs | behaviors | scenarios | assumed | cites | off | turns | seconds | usd |');
summary.push('|---|---|---|---|---|---|---|---|---|---|---|');
for (const r of rows) {
  summary.push(`| ${r.run} | ${r.killed} | ${r.specs} | ${r.behaviors} | ${r.scenarios} | ` +
               `${r.assumed} | ${r.cites} | ${r.off} | ${r.turns} | ${r.seconds} | ${r.usd} |`);
}
summary.push('');
for (const r of rows) summary.push(`- **${r.run}** wrote: ${r.written}`);
fs.writeFileSync(path.join(OUT, 'summary.md'), summary.join('\n'));

// One row per line for the console table the batch prints when it ends.
for (const r of rows) {
  process.stdout.write([r.run, r.killed, r.specs, r.behaviors, r.scenarios, r.assumed,
                        r.cites, r.off, r.turns, r.seconds, r.usd, r.written].join('\t') + '\n');
}

function readStream(rawPath) {
  const text = [];
  const tools = [];
  let result = null;
  // The message the kill lands in the middle of never reaches the stream in its finished form,
  // and that message is the one holding the Out line of the very step being measured. So the
  // deltas are kept as they arrive and thrown away as soon as the finished version of the same
  // message turns up: what survives at the end is exactly the piece that was being written
  // when the run died.
  let partial = '';

  if (!fs.existsSync(rawPath)) return { text, tools, result };
  for (const line of fs.readFileSync(rawPath, 'utf8').split('\n')) {
    let o;
    try { o = JSON.parse(line); } catch { continue; }
    if (o.type === 'stream_event') {
      const event = o.event || {};
      if (event.type === 'content_block_delta' && (event.delta || {}).type === 'text_delta') {
        partial += event.delta.text || '';
      }
    } else if (o.type === 'assistant') {
      partial = '';
      for (const c of (o.message || {}).content || []) {
        if (c.type === 'text' && c.text.trim()) text.push(c.text);
        if (c.type === 'tool_use') {
          const input = c.input || {};
          const key = ['file_path', 'pattern', 'path', 'command', 'skill']
            .find((k) => k in input);
          tools.push(`${c.name}\t${key ? String(input[key]) : ''}`);
        }
      }
    } else if (o.type === 'result') {
      result = o;
    }
  }
  if (partial.trim()) text.push(partial);
  return { text, tools, result };
}

// Whatever the run wrote into its copy of the fixture. Anything outside specs/ is a run that
// wrote where it was not asked to, and copying it here is how that gets seen.
function copyWhatTheRunWrote(ws, outDir) {
  const written = [];
  if (!fs.existsSync(ws)) return written;
  const walk = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) { walk(full); continue; }
      const rel = path.relative(ws, full);
      if (fs.existsSync(path.join(FIXTURE, rel))) continue;
      written.push(rel.split(path.sep).join('/'));
      const dest = path.join(outDir, 'written', rel);
      fs.mkdirSync(path.dirname(dest), { recursive: true });
      fs.copyFileSync(full, dest);
    }
  };
  walk(ws);
  return written;
}

function countSpecs(outDir, written) {
  const specs = written.filter((w) => w.endsWith('spec.md'));
  let behaviors = 0, scenarios = 0, assumed = 0, widest = 0;
  for (const sp of specs) {
    const body = fs.readFileSync(path.join(outDir, 'written', sp), 'utf8');
    behaviors += (body.match(/^##\s+B\d+/gm) || []).length;
    scenarios += (body.match(/^\s*Scenario(\s+Outline)?:/gm) || []).length;
    assumed += (body.match(/^\s+-\s+(?!\*\*Assumed)/gm) || []).length;

    // The most scenarios any one behavior carries, which is the only trace of a merge that
    // survives into the file: R22 says one id and two scenarios, so a file whose widest
    // behavior holds one is a file where nothing was merged.
    let here = 0;
    for (const line of body.split('\n')) {
      if (/^##\s+B\d+/.test(line)) { here = 0; continue; }
      if (/^\s*Scenario(\s+Outline)?:/.test(line) && ++here > widest) widest = here;
    }
  }
  return { specs: specs.length, behaviors, scenarios, assumed, widest };
}

// The ↳ line is the one part of the trace a script can rule on, and the four things it can
// rule on are R64's two ids, R65's one place for each, R66's silence without the flag, and the
// merge R22 announces, which has to be in the file it announced it about. What the line says
// beyond that is prose, and prose is read in the trace by a human: a run citing R22 for having
// split rather than merged passes every check here.
function readCitations(text, verbose, merged) {
  const found = [];
  let step = '';
  for (const line of text.join('\n').split('\n')) {
    const opened = line.match(/▸\s*STEP\s*(\d+)/);
    if (opened) { step = opened[1]; continue; }
    if (!line.includes('↳')) continue;
    const id = (line.match(/\bR\d+\b/) || [''])[0];
    found.push({ step, id: id || '-', verdict: judge(step, id, verbose, merged) });
  }
  return found;
}

function judge(step, id, verbose, merged) {
  if (!verbose) return 'off: no flag';
  if (!id) return 'off: no id';
  if (id !== 'R22' && id !== 'R28') return 'off: id';
  if (id === 'R22' && step !== '2') return 'off: step';
  if (id === 'R28' && step !== '3') return 'off: step';
  // A batch cut before STEP 4 has no file to check the merge against, and calling that a false
  // citation would blame the harness for where it stopped.
  if (id === 'R22' && merged === false) return 'off: no merge in the file';
  return 'ok';
}

function round(n, digits) {
  const f = Math.pow(10, digits);
  return Math.round(n * f) / f;
}
