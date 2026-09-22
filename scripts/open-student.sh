#!/usr/bin/env bash

set -euo pipefail

ENV_ROOT="/workspaces/informatica-student-environment"

LOGIN="$(gh api user --jq .login)"
TARGET="/workspaces/informatica-2627-${LOGIN}"
START_PAGE="${TARGET}/.onc/START_HIER.md"

if [ -d "${TARGET}/.git" ]; then
    code --add "${TARGET}" >/dev/null 2>&1 || true

    sleep 1

    if [ -f "${START_PAGE}" ]; then
        code --reuse-window "${START_PAGE}" >/dev/null 2>&1 || true
    fi

    code --remove "${ENV_ROOT}" >/dev/null 2>&1 || true
fi