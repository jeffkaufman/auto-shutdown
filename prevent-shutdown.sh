#!/usr/bin/env bash

set -e
set -u

JOBS_DIR="/var/run/prevent-shutdown"

if [[ ! -d "$JOBS_DIR" ]]; then
    echo "$JOBS_DIR doesn't exist; did you run install.sh?"
    exit 1
fi

JOB_FILE="$JOBS_DIR/$(uuidgen)"

# This makes it more efficient, but check-shutdown cleans up stale jobs and so
# if this code doesn't run our job file will still eventually be deleted.
cleanup() {
  rm -f "$JOB_FILE"
}
trap cleanup EXIT TERM INT HUP

# Pull parent process info
PPID_CMD=$(ps -o cmd= -p $PPID)

# Create job file with command info
echo "Command: $*" > "$JOB_FILE"
echo "ParentCmd: $PPID_CMD" >> "$JOB_FILE"
echo "Started: $(date)" >> "$JOB_FILE"
echo "PID: $$" >> "$JOB_FILE"
echo "PPID: $PPID" >> "$JOB_FILE"

# Run the actual command
echo "Running command: $*"
"$@"

# Exit with the same code as the command
exit $?
