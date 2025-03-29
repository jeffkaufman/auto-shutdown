#!/usr/bin/env bash

set -e
set -u

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Try: sudo $0"
  exit 1
fi

mkdir -p /usr/local/bin
mkdir -p /var/run/prevent-shutdown
# Allow all users to create files here
chmod 1777 /var/run/prevent-shutdown

cp prevent-shutdown.sh /usr/local/bin/prevent-shutdown
cp check-shutdown.sh /usr/local/bin/check-shutdown

chmod +x /usr/local/bin/prevent-shutdown
chmod +x /usr/local/bin/check-shutdown

# Every minute, if we should shut down, do shut down
CRON_ENTRY='*/1 * * * * /usr/local/bin/check-shutdown >/dev/null 2>&1'

if ! (crontab -l 2>/dev/null | grep -q "check-shutdown"); then
  (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
  echo "Added cron job for periodic shutdown checks."
else
  echo "Cron job already exists."
fi
