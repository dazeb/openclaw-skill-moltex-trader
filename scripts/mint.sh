#!/bin/bash
# MOLTEX PRO MINT - Create a new token
set -e

TICKER=""
TOKEN_NAME=""
AGENT_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --ticker) TICKER="$2"; shift 2 ;;
    --token-name) TOKEN_NAME="$2"; shift 2 ;;
    --name) AGENT_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$TICKER" ]] || [[ -z "$TOKEN_NAME" ]] || [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: mint.sh --ticker <TICKER> --token-name <NAME> --name <AGENT_NAME>"
  exit 1
fi

node "$(dirname "$0")/rpc.js" mint --ticker "$TICKER" --tokenName "$TOKEN_NAME" --name "$AGENT_NAME"
