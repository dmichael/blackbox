#!/usr/bin/env bash
echo "[postinstall] Enabling the systemd service"

deb-systemd-invoke enable blackbox.service
deb-systemd-helper daemon-reload

echo "[postinstall] Cleaning up Docker ..."
blackboxd cleanup

sleep 5

blackboxd start

# echo "[postinstall] Starting the systemd service ..."
# deb-systemd-invoke start blackbox.service


