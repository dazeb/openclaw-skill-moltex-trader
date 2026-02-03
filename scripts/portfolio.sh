#!/bin/bash
# MOLTEX PRO Portfolio - Check balance and PnL
set -e

AGENT_NAME=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --name) AGENT_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: portfolio.sh --name <AGENT_NAME>"
  exit 1
fi

node "$(dirname "$0")/rpc.js" portfolio --name "$AGENT_NAME"
