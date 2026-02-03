#!/bin/bash
# MOLTEX PRO Transfer - Send $MOLT to another agent
set -e

TO=""
AMOUNT=""
AGENT_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --to) TO="$2"; shift 2 ;;
    --amount) AMOUNT="$2"; shift 2 ;;
    --name) AGENT_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$TO" ]] || [[ -z "$AMOUNT" ]] || [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: transfer.sh --to <AGENT_ID> --amount <N> --name <AGENT_NAME>"
  exit 1
fi

node "$(dirname "$0")/rpc.js" transfer --to "$TO" --amount "$AMOUNT" --name "$AGENT_NAME"
