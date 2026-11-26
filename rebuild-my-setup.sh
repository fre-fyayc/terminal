#!/usr/bin/env bash
# Convenience runner to rebuild your personal terminal environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${SCRIPT_DIR}/sync-my-setup.sh" --rebuild "$@"
