#!/bin/bash
# Conditions for shutdown:
# 1. No active jobs (tracked by prevent-shutdown)
# 2. No active SSH connections

JOBS_DIR="/var/run/prevent-shutdown"
LOG_FILE="/var/log/auto-shutdown.log"

log() {
  echo "[$(date)] $1" >> "$LOG_FILE"
  echo "$1"
}

# Clean up stale job files (where the PID no longer exists)
cleanup_stale_jobs() {
  log "Checking for stale job files..."
  stale_jobs_found=0

  for job_file in "$JOBS_DIR"/*; do
    if [ ! -f "$job_file" ]; then
      continue
    fi

    # Extract PID from job file
    pid=$(grep -oP '^PID: \K[0-9]+$' "$job_file" 2>/dev/null)
    
    if [ -z "$pid" ]; then
      log "Warning: No PID found in job file $job_file, removing it"
      rm -f "$job_file"
      continue
    fi
    
    if ! ps -p "$pid" > /dev/null; then
      log "Removing stale job file for PID $pid that no longer exists"
      cat "$job_file" >> "$LOG_FILE"
      rm -f "$job_file"
    fi
  done
}

cleanup_stale_jobs

# Check for running jobs
if [ -n "$(ls -A $JOBS_DIR 2>/dev/null)" ]; then
  exit 0
fi

# Count active SSH connections.
# 'w' command shows logged in users, grep for pts (pseudoterminals)
SSH_CONNECTIONS=$(w -h | grep -c "pts/")

if [ "$SSH_CONNECTIONS" -gt 0 ]; then
  exit 0
fi

# No jobs are running and no one is connected via SSH.
sudo shutdown -h now
