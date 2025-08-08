#!/bin/bash
set -e
source /workspace/venvs/invoke/bin/activate
python -m invokeai.app.api_app --host 0.0.0.0 --port 3011 >> /workspace/logs/invoke.log 2>&1
