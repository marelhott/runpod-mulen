#!/bin/bash
set -e
source /workspace/venvs/jlab/bin/activate
# No auth (Protected ports on RunPod handle access). You can add token if you want.
jupyter lab --ip=0.0.0.0 --no-browser --NotebookApp.token= --NotebookApp.password= >> /workspace/logs/jupyter.log 2>&1
