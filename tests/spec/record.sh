#!/bin/sh
# What a run is, from the inside: the session, and the cut that ends it.
#
# The session writes its stream straight into the mounted folder, and watch.js reads that file
# from here rather than from the host. Both are about when the cut gets to see a line. What the
# docker client prints arrives in blocks, and a bind mount on Docker Desktop propagates a write
# to the host in its own time: a watcher on the far side of either reads the opening mark of the
# next step late, and a batch cut at STEP 1 then pays for the whole of STEP 2. In here the file
# is local.
#
# None of this reaches the session: the watcher is a sibling process, and the agent is told
# nothing. STOP_AFTER_STEP is the step the batch is measuring, and an unset one runs to the end.

claude "$@" > /run/raw.jsonl 2> /run/err.txt &
pid=$!

if [ -n "${STOP_AFTER_STEP:-}" ] && [ "$STOP_AFTER_STEP" -gt 0 ]; then
    node /usr/local/bin/watch.js "$pid" "$STOP_AFTER_STEP" &
    watcher=$!
fi

# The session's own exit code, which is not the docker client's: the client's is what the host
# can see, and it says the container ran. Killing the session with a signal is also what lets it
# close the stream with its final event, so a killed run still reports its turns and cost.
wait "$pid"
code=$?
printf '%s\n' "$code" > /run/exit.txt

[ -n "${watcher:-}" ] && kill "$watcher" 2>/dev/null
exit "$code"
