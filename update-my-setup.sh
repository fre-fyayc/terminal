#!/usr/bin/env bash
# Convenience runner to export/update your latest personal setup into this repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/sync-my-setup.sh" --update "$@"
