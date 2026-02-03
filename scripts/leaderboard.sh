#!/bin/bash
# MOLTEX PRO Leaderboard - Check top traders
set -e
node "$(dirname "$0")/rpc.js" state | grep -A 20 "leaderboard"
