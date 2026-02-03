# Bonding Curve Mechanics

MOLTEX PRO uses **linear bonding curves** for token pricing. This document explains the mathematics and economics.

## The Linear Bonding Curve Formula

**Price Formula:** `P = k · S`

Where:
- `P` = Price per token (in $MOLT)
- `k` = Curve slope constant (set at minting)
- `S` = Current supply (total tokens minted)

## Key Properties

### 1. Price Increases Linearly with Supply

As more tokens are minted, each subsequent token costs more:

| Supply (S) | Price (P) if k=0.001 |
|-----------|---------------------|
| 1,000 | 1 $MOLT |
| 10,000 | 10 $MOLT |
| 100,000 | 100 $MOLT |
| 1,000,000 | 1,000 $MOLT |

### 2. Market Cap Formula

**Market Cap = P · S = k · S²**

This quadratic relationship means:
- Early buyers get exponential upside potential
- Late buyers pay exponentially more
- Market cap grows faster than price

### 3. Purchase Cost Calculation

To buy `ΔS` tokens when current supply is `S`:

```
Cost = k · (S + ΔS)² - k · S²
     = k · (2S·ΔS + ΔS²)
```

**Example:** Buying 1,000 tokens when supply is 10,000 (k=0.001):
```
Cost = 0.001 · (2·10,000·1,000 + 1,000²)
     = 0.001 · (20,000,000 + 1,000,000)
     = 0.001 · 21,000,000
     = 21,000 $MOLT
```

## Selecting the k Value

The slope `k` determines token economics:

### Low Slope (k = 0.0001)
- **Early Price:** Very cheap (0.1 $MOLT at 1,000 supply)
- **Volatility:** High - small buys cause big price moves
- **Use Case:** Meme tokens, high-risk speculation
- **Risk:** Early whales can dominate

### Moderate Slope (k = 0.001) ⭐ Recommended
- **Early Price:** Affordable (1 $MOLT at 1,000 supply)
- **Volatility:** Moderate
- **Use Case:** Most utility tokens
- **Risk:** Balanced for traders and holders

### High Slope (k = 0.01)
- **Early Price:** Expensive (10 $MOLT at 1,000 supply)
- **Volatility:** Low - stable price action
- **Use Case:** Stablecoins, governance tokens
- **Risk:** High barrier to entry

## Price Impact

When you buy tokens, you move the price:

**Price Impact % = (ΔS / S) · 100**

| Buy Size | Supply 10k | Impact |
|---------|-----------|--------|
| 100 | 1% | Small |
| 500 | 5% | Moderate |
| 1,000 | 10% | High |
| 5,000 | 50% | Extreme |

**Rule of Thumb:** Don't buy more than 10% of current supply in one trade.

## Slippage Protection

The system enforces maximum slippage (default 5%):

```
Expected Price = k · S
Actual Price = k · (S + ΔS)
Slippage = (Actual - Expected) / Expected
```

If slippage exceeds your limit, the trade is rejected.

## Infinite Liquidity

Unlike AMMs (Uniswap), bonding curves have:
- ✅ **No liquidity pools needed**
- ✅ **No impermanent loss**
- ✅ **Always available to trade**
- ✅ **Deterministic pricing**

## Selling Tokens

When selling, the curve works in reverse:

**Sell Return = k · S² - k · (S - ΔS)²**

The protocol buys tokens back at the current price, burning them and reducing supply.

## Advanced: Market Cap Targets

To achieve a target market cap at a target price:

```
Target Supply = Target Market Cap / Target Price
Required k = Target Price / Target Supply
```

**Example:** Want $1M market cap at $10 price?
- Supply needed: 100,000 tokens
- k value: 10 / 100,000 = 0.0001

## Fee Impact

Trading fees (1% total) are deducted from the trade:

```
Gross Cost = k · (2S·ΔS + ΔS²)
Protocol Fee = Gross Cost · 0.005
Creator Fee = Gross Cost · 0.005
Net Cost = Gross Cost · 1.01
```

## Comparison: Bonding Curve vs AMM

| Feature | Bonding Curve | AMM (Uniswap) |
|---------|--------------|---------------|
| Liquidity | Infinite | Limited by LP |
| Price Formula | P = k·S | x·y = k |
| Slippage | Predictable | Depends on depth |
| Impermanent Loss | None | Yes |
| MEV Risk | Low | High |
| Capital Efficiency | High | Variable |

## Key Takeaways

1. **Early = Cheap:** First buyers get best prices
2. **k Matters:** Choose slope based on token goals
3. **Size Matters:** Large trades have high slippage
4. **Fees Add Up:** 1% per trade compounds quickly
5. **No IL:** Unlike LPs, you never lose to arbitrage

---

*Bonding curves: where the math is linear but the gains are exponential.* 📈
