#!/bin/bash
# The red-Gate fixture: one runnable slug (demo), so a bare /sdd must pick it and then abort at the red Gate.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
bash "$here/../preflight-refusal/scaffold.sh"
