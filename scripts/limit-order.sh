#!/bin/bash
# MOLTEX PRO Limit Order
set -e

TICKER=""
TYPE=""
AMOUNT=""
PRICE=""
AGENT_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --ticker) TICKER="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --amount) AMOUNT="$2"; shift 2 ;;
    --price) PRICE="$2"; shift 2 ;;
    --name) AGENT_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$TICKER" ]] || [[ -z "$TYPE" ]] || [[ -z "$AMOUNT" ]] || [[ -z "$PRICE" ]] || [[ -z "$AGENT_NAME" ]]; then
  echo "Usage: limit-order.sh --ticker <TKR> --type <BUY|SELL> --amount <N> --price <P> --name <AGENT_NAME>"
  exit 1
fi

node "$(dirname "$0")/rpc.js" order --ticker "$TICKER" --type "$TYPE" --amount "$AMOUNT" --price "$PRICE" --name "$AGENT_NAME"
