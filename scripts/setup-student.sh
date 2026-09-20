#!/usr/bin/env bash

set -euo pipefail

ORG="oncparkdreef"
ENV_ROOT="/workspaces/informatica-student-environment"

LOGIN="$(gh api user --jq .login)"
REPO="informatica-2627-${LOGIN}"
TARGET="/workspaces/${REPO}"

echo
echo "ONC Informatica"
echo "GitHub account : ${LOGIN}"
echo "Leerlingrepo   : ${ORG}/${REPO}"
echo

if [ ! -d "${TARGET}/.git" ]; then
    echo "Leerlingrepo ophalen..."
    gh repo clone "${ORG}/${REPO}" "${TARGET}"
else
    echo "Leerlingrepo bestaat al."
fi
echo "Terminal instellen..."

if ! grep -q "ONC TERMINAL PROMPT" "${HOME}/.bashrc"; then
    cat >> "${HOME}/.bashrc" <<'EOF'

# ONC TERMINAL PROMPT
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PS1='\W > '
EOF
fi
echo "Mappenstructuur controleren..."

for module in 1 2 3; do
    for week in $(seq -w 0 11); do
        mkdir -p "${TARGET}/module${module}/week${week}"
    done
done

echo "Pythonomgeving controleren..."
if [ ! -d "${ENV_ROOT}/.venv" ]; then
    python -m venv "${ENV_ROOT}/.venv"
fi

"${ENV_ROOT}/.venv/bin/python" -m pip install -r "${ENV_ROOT}/requirements.txt"

echo "Leerlinginstellingen plaatsen..."
mkdir -p "${TARGET}/.vscode"
cp "${ENV_ROOT}/config/settings.json" "${TARGET}/.vscode/settings.json"

echo "Startpagina plaatsen..."
mkdir -p "${TARGET}/.onc"
sed "s/{{GITHUB_USER}}/${LOGIN}/g" \
    "${ENV_ROOT}/start/START_HIER.md" \
    > "${TARGET}/.onc/START_HIER.md"

# Technische lokale bestanden nooit per ongeluk laten committen.
grep -qxF ".vscode/" "${TARGET}/.git/info/exclude" ||
    echo ".vscode/" >> "${TARGET}/.git/info/exclude"

grep -qxF ".onc/" "${TARGET}/.git/info/exclude" ||
    echo ".onc/" >> "${TARGET}/.git/info/exclude"

echo
echo "Klaar."
