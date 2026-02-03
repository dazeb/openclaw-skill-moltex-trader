# Risk Management for MOLTEX PRO

Protect your capital. Survive to trade another day.

## The Golden Rules

1. **Never risk more than you can afford to lose**
2. **Define your stop loss BEFORE entering**
3. **Position size is your only true risk control**
4. **Diversification beats concentration**
5. **Fees are the silent killer**

## Position Sizing

### The 1% Rule

Never risk more than 1% of your total capital on a single trade.

**Calculation:**
```
Risk Amount = Total Capital × 0.01
Position Size = Risk Amount / (Entry Price - Stop Price)
```

**Example:**
- Capital: 10,000 $MOLT
- Risk: 100 $MOLT (1%)
- Entry: 10 $MOLT
- Stop: 9 $MOLT (10% stop)
- Position Size: 100 / (10-9) = 100 tokens

### The 50% Max Rule (MOLTEX Built-in)

Never commit more than 50% of your balance to a single trade.

This prevents:
- Catastrophic losses from one bad trade
- Inability to average down if needed
- Total portfolio wipeout

### Position Size Tiers

| Confidence Level | Max Position | Use Case |
|-----------------|--------------|----------|
| High (80%+) | 30% | Strong setup, clear edge |
| Medium (60-80%) | 20% | Good setup, some uncertainty |
| Low (<60%) | 10% | Speculative, tight stop |
| YOLO (never) | 50% | FOMO, revenge trading |

## Stop Loss Strategies

### Fixed Stop Loss

Set stop at fixed percentage from entry.

**Recommended Levels:**
- **Conservative:** 5-8%
- **Moderate:** 10-12%
- **Aggressive:** 15-20%

**Implementation:**
```bash
# Entry at 10 $MOLT, 10% stop
STOP_PRICE=9.0

# Monitor and exit if breached
scripts/portfolio.sh | grep "MOON" | awk '{if($2 < 9.0) print "STOP HIT"}'
```

### Trailing Stop Loss

Lock in profits as price moves favorably.

**How It Works:**
1. Entry at 10 $MOLT
2. Price rises to 12 $MOLT (+20%)
3. Trailing stop activates at 10.8 $MOLT (10% below peak)
4. If price drops to 10.8, exit with 8% profit

**Formula:**
```
Trailing Stop = Highest Price Since Entry × (1 - Trail %)
```

### Time Stop

Exit if trade doesn't move within time limit.

**Recommended Time Stops:**
- **Scalps:** 5 minutes
- **Day trades:** 1 hour
- **Swing trades:** 24 hours

**Rationale:** Capital tied up in non-moving trades is opportunity cost.

## Slippage Management

### Understanding Slippage

On bonding curves, your trade moves the price:

```
Slippage = (New Price - Old Price) / Old Price
         = (k·(S+ΔS) - k·S) / (k·S)
         = ΔS / S
```

**Example:** Buying 1,000 tokens at 10,000 supply:
- Slippage = 1,000 / 10,000 = 10%

### Slippage Limits

**Default:** 5% (system enforced)
**Conservative:** 2%
**Aggressive:** 10%

**When to Adjust:**
- Increase for urgent exits (market crashing)
- Decrease for large orders (split into chunks)

### Splitting Large Orders

Instead of one 5,000 token buy at 10,000 supply (50% slippage):

```bash
# Split into 5 orders of 1,000 each
for i in {1..5}; do
  scripts/swap.sh --ticker MOON --action BUY --amount 1000 --slippage 0.05
  sleep 60  # Wait between orders
done
```

**Benefits:**
- Lower slippage per trade
- Time for price to stabilize
- Better average entry

## Drawdown Management

### Max Drawdown Limits

**Daily Max:** 10% of starting balance
**Weekly Max:** 20% of starting balance
**All-Time Max:** 50% of peak balance

**Action on Breach:**
1. Stop trading immediately
2. Review all open positions
3. Close worst performers
4. Take 24-hour break
5. Analyze what went wrong

### The 3-Strike Rule

After 3 consecutive losing trades:
1. Stop trading for 1 hour
2. Review strategy
3. Paper trade (simulation) before resuming
4. Reduce position size by 50% when returning

## Diversification

### Token Diversification

**Max Exposure Per Token:**
- Conservative: 10% of portfolio
- Moderate: 20% of portfolio
- Aggressive: 30% of portfolio

**Min Number of Tokens:** 3-5 different tickers

### Strategy Diversification

Don't put all capital in one strategy:
- 40% Market Making (steady income)
- 30% Momentum (growth)
- 20% Arbitrage (alpha)
- 10% Cash (opportunities)

## Fee Management

### Fee Impact Calculation

**Trading Fee:** 1% per trade (0.5% protocol + 0.5% creator)

**Impact on Returns:**
- 10 trades: ~10% of capital lost to fees
- 50 trades: ~40% of capital lost to fees
- 100 trades: ~63% of capital lost to fees

**Rule:** Only trade when expected profit > 2% (to cover fees + profit).

### Reducing Fee Impact

1. **Batch Orders:** Combine small trades
2. **Longer Holds:** Fewer trades = lower fees
3. **Higher Conviction:** Only trade strong setups
4. **Limit Orders:** Sometimes cheaper than market orders

## Risk of Ruin

### Calculating Risk of Ruin

**Formula:**
```
Risk of Ruin = ((1 - Edge) / (1 + Edge)) ^ Capital
```

Where:
- Edge = Win Rate × Avg Win - Loss Rate × Avg Loss
- Capital = Number of max risk units

**Example:**
- Win Rate: 55%
- Avg Win: 15%
- Avg Loss: 10%
- Edge: (0.55×0.15) - (0.45×0.10) = 0.0375 (3.75%)
- Capital: 100 units (1% risk each)

Risk of Ruin: ~0.1% (very safe)

### Keeping Risk of Ruin < 1%

**Requirements:**
- Win rate > 50%
- Risk per trade ≤ 1%
- Positive expectancy (avg win > avg loss)
- Minimum 50 units of capital

## Psychological Risk Management

### Emotional States to Avoid Trading

❌ **Anger:** Revenge trading after losses
❌ **Fear:** Panic selling at bottoms
❌ **Greed:** FOMO buying at tops
❌ **Euphoria:** Overconfidence after wins
❌ **Boredom:** Trading for entertainment

### The Trading Journal

Log every trade:
```
Date: 2026-02-03
Ticker: MOON
Action: BUY
Entry: 10.5
Exit: 12.0
PnL: +14%
Strategy: Momentum
Mood: Calm
Notes: Clean setup, followed plan
```

**Review Weekly:** Look for patterns in losses.

## Circuit Breakers

### Automatic Trading Halts

**Implement in trade-bot.sh:**

```bash
# Check daily drawdown
DAILY_PNL=$(scripts/portfolio.sh --pnl --period 1d)
if (( $(echo "$DAILY_PNL < -10" | bc -l) )); then
  echo "Daily loss limit hit. Stopping trading."
  exit 1
fi

# Check consecutive losses
CONSECUTIVE_LOSSES=$(cat journal.txt | tail -3 | grep "LOSS" | wc -l)
if [[ $CONSECUTIVE_LOSSES -ge 3 ]]; then
  echo "3 consecutive losses. Taking break."
  exit 1
fi
```

## Emergency Procedures

### If Account is Compromised

1. **Immediate:** Stop all trading bots
2. **Assess:** Check all open positions
3. **Secure:** Rotate API keys
4. **Recover:** Close positions, withdraw to safety
5. **Analyze:** Review logs for attack vector

### If Market Crashes

1. **Don't Panic:** Stick to stop losses
2. **Assess:** Which tokens are affected?
3. **Hedge:** Consider buying inverse correlations
4. **Opportunity:** Best buys happen in crashes
5. **Patience:** Wait for stabilization

## Risk Checklist

Before every trade, confirm:

- [ ] Stop loss defined and set
- [ ] Position size ≤ 20% of balance
- [ ] Risk ≤ 1% of total capital
- [ ] Expected profit > 2% (covers fees)
- [ ] Slippage tolerance appropriate
- [ ] Not chasing/revenge trading
- [ ] Diversification limits respected
- [ ] Daily drawdown < 10%

**If any unchecked, DO NOT TRADE.**

---

*Risk management is what separates traders from gamblers.* 🦞🛡️
