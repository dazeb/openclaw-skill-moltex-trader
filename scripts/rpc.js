const axios = require('axios');
const nacl = require('tweetnacl');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

const API_URL = process.env.MOLTEX_URL || 'https://moltex.pro';
const KEYS_DIR = path.join(process.env.HOME, '.moltex', 'keys');

// --- Helper: Deterministic Key Sorting ---
function sortKeys(obj) {
  if (typeof obj !== 'object' || obj === null) return obj;
  if (Array.isArray(obj)) return obj.map(sortKeys);
  return Object.keys(obj).sort().reduce((acc, key) => {
    acc[key] = sortKeys(obj[key]);
    return acc;
  }, {});
}

// --- Key Management ---
function loadKeys(agentName) {
    const keyPath = path.join(KEYS_DIR, `${agentName}.json`);
    if (!fs.existsSync(keyPath)) {
        throw new Error(`Keyfile for agent '${agentName}' not found at ${keyPath}`);
    }
    const keys = JSON.parse(fs.readFileSync(keyPath, 'utf-8'));
    return {
        publicKey: Buffer.from(keys.publicKey, 'hex'),
        secretKey: Buffer.from(keys.secretKey, 'hex')
    };
}

function toHexString(bytes) {
    return Buffer.from(bytes).toString('hex');
}

// --- RPC Logic ---
async function callRPC(agentName, method, params) {
    const keys = loadKeys(agentName);
    
    const payload = {
        method,
        params,
        timestamp: Date.now(),
        nonce: uuidv4()
    };

    // Serialize payload with sorted keys as required by the protocol
    const messageStr = JSON.stringify(sortKeys(payload));
    const messageBytes = new TextEncoder().encode(messageStr);
    
    const signatureBytes = nacl.sign.detached(messageBytes, keys.secretKey);
    const signature = toHexString(signatureBytes);
    const publicKey = toHexString(keys.publicKey);

    const envelope = {
        payload,
        publicKey,
        signature
    };

    try {
        const response = await axios.post(`${API_URL}/rpc`, envelope);
        return response.data;
    } catch (error) {
        if (error.response) {
            throw new Error(`RPC Error: ${JSON.stringify(error.response.data)}`);
        }
        throw error;
    }
}

// --- CLI ---
const args = require('minimist')(process.argv.slice(2));
const command = args._[0];

if (!command) {
    console.error('Usage: node rpc.js <method> [params] --name <agentName>');
    process.exit(1);
}

const agentName = args.name;
if (!agentName && command !== 'state') {
    console.error('Error: --name <agentName> is required for authenticated actions');
    process.exit(1);
}

(async () => {
    try {
        let result;
        switch (command) {
            case 'state':
                const response = await axios.get(`${API_URL}/state`);
                result = response.data;
                break;
            case 'faucet':
                result = await callRPC(agentName, 'FAUCET', {});
                break;
            case 'mint':
                result = await callRPC(agentName, 'MINT', { ticker: args.ticker, name: args.tokenName });
                break;
            case 'swap':
                result = await callRPC(agentName, 'SWAP', { 
                    ticker: args.ticker, 
                    action: args.action.toUpperCase(), 
                    amount: parseFloat(args.amount) 
                });
                break;
            case 'order':
                result = await callRPC(agentName, 'LIMIT_ORDER', {
                    ticker: args.ticker,
                    type: args.type.toUpperCase(),
                    amount: parseFloat(args.amount),
                    limitPrice: parseFloat(args.price)
                });
                break;
            case 'portfolio':
                const agentKeys = loadKeys(agentName);
                const pubkey = toHexString(agentKeys.publicKey);
                const portfolioResponse = await axios.get(`${API_URL}/state/agent/${pubkey}`);
                result = portfolioResponse.data;
                break;
            case 'transfer':
                result = await callRPC(agentName, 'TRANSFER', { to: args.to, amount: parseFloat(args.amount) });
                break;
            case 'profile':
                result = await callRPC(agentName, 'UPDATE_PROFILE', { name: args.alias, avatarUrl: args.avatar });
                break;
            default:
                console.error(`Unknown command: ${command}`);
                process.exit(1);
        }
        console.log(JSON.stringify(result, null, 2));
    } catch (e) {
        console.error(e.message);
        process.exit(1);
    }
})();
