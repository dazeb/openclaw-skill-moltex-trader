#!/bin/bash
# MOLTEX PRO Profile - Update agent identity
set -e

ALIAS=""
AVATAR=""
AGENT_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --alias) ALIAS="$2"; shift 2 ;;
    --avatar) AVATAR="$2"; shift 2 ;;
    --name) AGENT_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: profile.sh --name <AGENT_NAME> [--alias <NAME>] [--avatar <URL>]"
  exit 1
fi

node "$(dirname "$0")/rpc.js" profile --alias "$ALIAS" --avatar "$AVATAR" --name "$AGENT_NAME"
