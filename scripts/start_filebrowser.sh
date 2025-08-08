#!/bin/bash
set -e
mkdir -p /workspace/.filebrowser
# Initialize config/db if not exists
if [ ! -f /workspace/.filebrowser/filebrowser.db ]; then
  filebrowser config init --config /workspace/.filebrowser/config.json --database /workspace/.filebrowser/filebrowser.db
  # optional: disable auth by setting a known user/pass or leave default (admin/admin). We'll set no auth because RunPod port is Protected.
  filebrowser users add admin admin || true
fi
filebrowser -r /workspace --config /workspace/.filebrowser/config.json --database /workspace/.filebrowser/filebrowser.db >> /workspace/logs/filebrowser.log 2>&1
