#!/bin/bash
set -e
source /workspace/venvs/fooocus/bin/activate
export GRADIO_SERVER_NAME=0.0.0.0
export GRADIO_SERVER_PORT=7640
cd /workspace/apps/Fooocus
python launch.py --listen --port 7640 >> /workspace/logs/fooocus.log 2>&1
