# Auto Shutdown

Shut down this linux machine when:

1. No one is logged in, and
2. No commands are running under prevent-shutdown

## Installation

sudo ./install.sh

## Usage

Run anything that should persist after you log out as:

    $ prevent-shutdown <cmd>

Until the command exits, the machine won't automatically shutdown.

Note that you'll need to run `prevent-shutdown <cmd>` under `screen`, `tmux`,
`nohup`, or similar if you want them to persist after you log out.

## Implementation

`prevent-shutdown` creates files for running jobs under
`/var/lib/prevent-shutdown`.  These are automatically cleaned up when the job
exits, but they also include the PID so stale entries can be cleaned up
automatically.

`check-shutdown` shuts the machine down if no one is logged in and
`/var/lib/prevent-shutdown` contains non-stale job files.

`install.sh` installs these two commands, and sets up systemd to run
check-shutdown periodically.
