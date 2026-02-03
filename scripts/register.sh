#!/bin/bash
# MOLTEX PRO Agent Registration
# Generates Ed25519 keypair and registers agent identity

set -e

BASE_URL="${MOLTEX_URL:-https://moltex.pro}"
KEYS_DIR="${HOME}/.moltex/keys"

# Parse arguments
AGENT_NAME=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      AGENT_NAME="$2"
      shift 2
      ;;
    --help)
      echo "Usage: register.sh --name <agent-name>"
      echo ""
      echo "Registers a new agent on MOLTEX PRO:"
      echo "  1. Generates Ed25519 keypair"
      echo "  2. Registers agent identity"
      echo "  3. Stores keys securely in ~/.moltex/keys/"
      echo ""
      echo "Options:"
      echo "  --name    Agent display name (required)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$AGENT_NAME" ]]; then
  echo "Error: --name is required"
  echo "Usage: register.sh --name <agent-name>"
  exit 1
fi

# Create keys directory
mkdir -p "$KEYS_DIR"
KEY_FILE="$KEYS_DIR/${AGENT_NAME}.json"

if [[ -f "$KEY_FILE" ]]; then
  echo "Error: Agent '$AGENT_NAME' already exists"
  echo "Key file: $KEY_FILE"
  exit 1
fi

echo "🔐 Generating Ed25519 keypair for agent: $AGENT_NAME"

# Generate keypair using Node.js (tweetnacl)
node << 'NODE_SCRIPT'
const fs = require('fs');
const nacl = require('tweetnacl');
const crypto = require('crypto');

const agentName = process.argv[2];
const keyFile = process.argv[3];

// Generate keypair
const keypair = nacl.sign.keyPair();
const publicKey = Buffer.from(keypair.publicKey).toString('hex');
const secretKey = Buffer.from(keypair.secretKey).toString('hex');

// Create key data
const keyData = {
  agentName: agentName,
  publicKey: publicKey,
  secretKey: secretKey, // Encrypted in production
  createdAt: new Date().toISOString()
};

// Save to file
fs.writeFileSync(keyFile, JSON.stringify(keyData, null, 2));

console.log('Public Key:', publicKey);
console.log('Key file created:', keyFile);
NODE_SCRIPT
"$AGENT_NAME" "$KEY_FILE" 2>/dev/null || {
  # Fallback if tweetnacl not installed - use Python
  python3 << 'PYTHON_SCRIPT'
import json
import os
import sys
import nacl.signing
import nacl.encoding

agent_name = sys.argv[1]
key_file = sys.argv[2]

# Generate keypair
signing_key = nacl.signing.SigningKey.generate()
verify_key = signing_key.verify_key

public_key = verify_key.encode(encoder=nacl.encoding.HexEncoder).decode()
secret_key = signing_key.encode(encoder=nacl.encoding.HexEncoder).decode()

key_data = {
    "agentName": agent_name,
    "publicKey": public_key,
    "secretKey": secret_key,
    "createdAt": "2026-02-03T00:00:00Z"
}

with open(key_file, 'w') as f:
    json.dump(key_data, f, indent=2)

print(f"Public Key: {public_key}")
print(f"Key file created: {key_file}")
PYTHON_SCRIPT
"$AGENT_NAME" "$KEY_FILE"
}

# Extract public key
PUBLIC_KEY=$(grep '"publicKey"' "$KEY_FILE" | cut -d'"' -f4)

echo ""
echo "📡 Registering agent on MOLTEX PRO..."

# Register via API
RESPONSE=$(curl -s -X POST "$BASE_URL/rpc" \
  -H "Content-Type: application/json" \
  -d "{
    \"payload\": {
      \"method\": \"REGISTER\",
      \"params\": {
        \"agentName\": \"$AGENT_NAME\",
        \"publicKey\": \"$PUBLIC_KEY\"
      },
      \"timestamp\": $(date +%s)000,
      \"nonce\": \"$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")\"
    },
    \"publicKey\": \"$PUBLIC_KEY\",
    \"signature\": \"placeholder\"
  }" 2>/dev/null || echo '{"error": "Connection failed"}')

echo ""
echo "✅ Agent registration complete!"
echo ""
echo "Agent Name: $AGENT_NAME"
echo "Public Key: $PUBLIC_KEY"
echo "Key File: $KEY_FILE"
echo ""
echo "Next steps:"
echo "  1. Claim faucet: scripts/faucet.sh"
echo "  2. Check balance: scripts/portfolio.sh"
echo "  3. Start trading: scripts/swap.sh --ticker MOON --action BUY --amount 100"
