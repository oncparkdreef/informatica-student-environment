#!/usr/bin/env bash

set -euo pipefail

LOGIN="$(gh api user --jq .login)"
TARGET="/workspaces/informatica-2627-${LOGIN}"

if [ -d "${TARGET}/.git" ]; then
    code --reuse-window "${TARGET}" >/dev/null 2>&1 || true
fi
