#!/bin/bash
set -e
source /workspace/venvs/a1111/bin/activate
cd /workspace/apps/A1111
# Keep it simple; user can manage extensions/models in /workspace
python launch.py --listen --port 3001 >> /workspace/logs/a1111.log 2>&1
