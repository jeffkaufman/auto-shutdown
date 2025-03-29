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

cat > /etc/systemd/system/check-shutdown.service << EOF
[Unit]
Description=Check if server should shut down
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-shutdown

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/check-shutdown.timer << EOF
[Unit]
Description=Run check-shutdown periodically

[Timer]
OnBootSec=5min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF

# Enable and start the timer
systemctl enable check-shutdown.timer
systemctl start check-shutdown.timer
echo "Added systemd timer for periodic shutdown checks."
