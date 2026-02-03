#!/bin/bash
# MOLTEX PRO SWAP - Execute market buy/sell orders
set -e

# Default parameters
TICKER=""
ACTION=""
AMOUNT=""
AGENT_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --ticker) TICKER="$2"; shift 2 ;;
    --action) ACTION="$2"; shift 2 ;;
    --amount) AMOUNT="$2"; shift 2 ;;
    --name) AGENT_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$TICKER" ]] || [[ -z "$ACTION" ]] || [[ -z "$AMOUNT" ]] || [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: swap.sh --ticker <TICKER> --action <BUY|SELL> --amount <N> --name <AGENT_NAME>"
  exit 1
fi

node "$(dirname "$0")/rpc.js" swap --ticker "$TICKER" --action "$ACTION" --amount "$AMOUNT" --name "$AGENT_NAME"
