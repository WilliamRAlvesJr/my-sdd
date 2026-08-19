// Watches a run's stream from inside its own container and kills the session the moment it
// opens a phase past the one the batch is measuring. record.sh starts it; nothing here reaches
// the session, which is told nothing about being cut.
//
// It reads the stream rather than grepping it, and both reasons cost a batch to find out.
// Thinking is not the trace: the model writes the next phase's mark while reasoning about it,
// well before writing the closing line of the phase being measured, and a grep over the file
// killed two runs of five before their own Out line existed. And a delta is not a line: the
// visible text arrives in fragments of arbitrary length, so the mark itself can straddle two
// of them and match neither.
//
// Usage: node watch.js <pid> <stopAfterPhase>

const fs = require('fs');

const RAW = '/run/raw.jsonl';
const VERDICT = '/run/killed.txt';
const pid = Number(process.argv[2]);
const stopAfterPhase = Number(process.argv[3]);

let offset = 0;
let pending = '';   // the tail of the file that is not a whole line yet
let visible = '';   // everything the run has actually written, thinking excluded
let why = '';

const timer = setInterval(tick, 100);

function tick() {
  if (!alive()) return done();
  read();

  for (const m of visible.matchAll(/▸\s*PHASE\s*(\d+)/g)) {
    if (Number(m[1]) > stopAfterPhase) { why = `PHASE ${m[1]}`; break; }
  }
  if (why) return kill();
}

function read() {
  if (!fs.existsSync(RAW)) return;
  const size = fs.statSync(RAW).size;
  if (size <= offset) return;
  const fd = fs.openSync(RAW, 'r');
  const buf = Buffer.alloc(size - offset);
  fs.readSync(fd, buf, 0, buf.length, offset);
  fs.closeSync(fd);
  offset = size;

  const lines = (pending + buf.toString('utf8')).split('\n');
  pending = lines.pop();
  for (const line of lines) {
    let o;
    try { o = JSON.parse(line); } catch { continue; }
    if (o.type === 'stream_event') {
      const event = o.event || {};
      if (event.type === 'content_block_delta' && (event.delta || {}).type === 'text_delta') {
        visible += event.delta.text || '';
      }
      // The tool call that only PHASE 4 makes is the second thing worth killing on, for the run
      // that writes the file without announcing the phase. It fires on the call being announced,
      // before the arguments are even generated, so the file is never written.
      if (event.type === 'content_block_start' && stopAfterPhase < 4) {
        const block = event.content_block || {};
        if (block.type === 'tool_use' && (block.name === 'Write' || block.name === 'Edit')) {
          why = `a ${block.name} call`;
        }
      }
    } else if (o.type === 'assistant') {
      for (const c of (o.message || {}).content || []) {
        if (c.type === 'text') visible += c.text || '';
        if (c.type === 'tool_use' && stopAfterPhase < 4 &&
            (c.name === 'Write' || c.name === 'Edit')) {
          why = `a ${c.name} call`;
        }
      }
    }
  }
}

function kill() {
  fs.writeFileSync(VERDICT, why + '\n');
  try { process.kill(pid, 'SIGTERM'); } catch { /* it beat us to it */ }
  done();
}

function alive() {
  try { process.kill(pid, 0); return true; } catch { return false; }
}

function done() {
  clearInterval(timer);
  process.exit(0);
}
