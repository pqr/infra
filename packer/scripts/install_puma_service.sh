#!/bin/bash
set -e

mv /home/appuser/puma.service /etc/systemd/system/puma.service
systemctl enable puma.service
