#!/usr/bin/env bash

set -euo pipefail

LOGIN="$(gh api user --jq .login)"
TARGET="/workspaces/informatica-2627-${LOGIN}"
START_PAGE="${TARGET}/.onc/START_HIER.md"

if [ -d "${TARGET}/.git" ]; then
    code --reuse-window "${TARGET}" >/dev/null 2>&1 || true

    # Even wachten tot de leerlingworkspace geopend is.
    sleep 2

    if [ -f "${START_PAGE}" ]; then
        code --reuse-window "${START_PAGE}" >/dev/null 2>&1 || true
    fi
fi