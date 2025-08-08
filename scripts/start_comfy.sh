#!/bin/bash
set -e
source /workspace/venvs/comfy/bin/activate
python /workspace/apps/ComfyUI/main.py --listen 0.0.0.0 --port 3021 >> /workspace/logs/comfy.log 2>&1
