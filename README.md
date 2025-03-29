# Auto Shutdown

Shut down this linux machine when:

1. No one is logged in, and
2. No commands are running under prevent-shutdown

## Installation

sudo ./install.sh

## Usage

Run anything that should persist after you log out as:

    $ prevent-shutdown <cmd>

Until the command exits, the machine will continue running.

## Implementation

`prevent-shutdown` creates files for running jobs under
`/var/run/prevent-shutdown`.  These are automatically cleaned up when the job
exits, but they also include the PID so stale entries can be cleaned up
automatically.

`check-shutdown` shuts the machine down if no one is logged in and
`/var/run/prevent-shutdown` contains non-stale job files.

`install.sh` installs these two commands, and sets up systemd to run
check-shutdown periodically.
