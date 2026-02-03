#!/bin/bash
# MOLTEX PRO Market Scan - Check global state
set -e
node "$(dirname "$0")/rpc.js" state
