# The environment a run gets, pinned. Outside a container a run inherits the machine: the
# CLAUDE.md and the settings of whoever is logged in, whatever ls and find happen to be there,
# and a python that may or may not exist, which is the difference R71 exists to survive. Here
# all of that is declared, so two batches on two machines differ by the prompt and nothing else.
#
# Nothing of the framework is baked in. The skill comes in on --plugin-dir and the project on
# the working directory, both mounted at run time, so the image survives every change to both.
FROM node:22-bookworm-slim

# git because a project under spec normally is a repository, and python3 because that is what
# R70 calls the validator with.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates git python3 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

# What a run is from the inside, session and cut both, and record.sh says why it is in here
# rather than on the host. It is the image's entry point for a run: baseline.ps1 calls `record`
# and passes it the claude arguments.
COPY record.sh /usr/local/bin/record
COPY watch.js /usr/local/bin/watch.js
RUN chmod +x /usr/local/bin/record

# Not root: a run writing into a mounted project would leave files nobody on the host owns.
RUN useradd --create-home --shell /bin/bash runner
USER runner
WORKDIR /ws
