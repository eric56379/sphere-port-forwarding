#!/usr/bin/env bash
set -euo pipefail

USER_HOME="$HOME"
SSH_DIR="$USER_HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

CONFIG=""
for candidate in \
  "$SCRIPT_DIR/config" \
  "$SCRIPT_DIR/../config"
do
  if [[ -f "$candidate" ]]; then CONFIG="$candidate"; break; fi
done

KEY=""
for candidate in \
  "$SCRIPT_DIR/merge_key" \
  "$SCRIPT_DIR/../merge_key"
do
  if [[ -f "$candidate" ]]; then KEY="$candidate"; break; fi
done

if [[ -z "$CONFIG" ]]; then
  echo "config was not found near the script. Expected at: $SCRIPT_DIR/{config,../config}"
  exit 1
fi

if [[ -z "$KEY" ]]; then
  echo "merge_key was not found near the script. Expected at: $SCRIPT_DIR/{merge_key,../merge_key}"
  exit 1
fi

echo "Ensuring $SSH_DIR exists..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ ! -f "$SSH_DIR/known_hosts" ]]; then
  echo "Creating $SSH_DIR/known_hosts..."
  : > "$SSH_DIR/known_hosts"
  chmod 600 "$SSH_DIR/known_hosts"
fi

echo "Processing SSH config..."
if [[ ! -f "$SSH_CONFIG" ]]; then
  echo "No existing config. Creating $SSH_CONFIG and adding snippet."
  cp "$CONFIG" "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
else
  echo "Config exists. Checking for 'Host mergejump' stanza..."
  if grep -Eq '^[[:space:]]*Host[[:space:]]+mergejump([[:space:]]|$)' "$SSH_CONFIG"; then
    echo "Mergejump entry already present. Skipping append."
  else
    echo -e "\n" >> "$SSH_CONFIG"
    cat "$CONFIG" >> "$SSH_CONFIG"
  fi
fi

echo "Installing merge_key into $SSH_DIR..."
dest_key="$SSH_DIR/merge_key"

cp "$KEY" "$dest_key"
chmod 600 "$dest_key"

echo -e "\nTask completed. You may now delete the zip file after reviewing README.md for XDC access instructions."
