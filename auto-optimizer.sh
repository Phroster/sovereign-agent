#!/bin/bash
# SOVEREIGN AUTO-OPTIMIZER
# Analyzes performance, learns from successes, optimizes strategy
# Runs every 4 hours

LOG="/tmp/sovereign-optimizer.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] === AUTO-OPTIMIZATION CYCLE ===" >> $LOG

# Data sources
RECIPROCITY_FILE="/tmp/sovereign-reciprocity.json"
CONTACT_FILE="/tmp/sovereign-contacts.json"
MASTER_LOG="/tmp/reciprocity-auto.log"
NETWORK_DATA=$(npx moltlaunch network --json 2>/dev/null)

echo "[$DATE] Analyzing performance data..." >> $LOG

# ============================================
# METRICS ANALYSIS
# ============================================

# Total onboards achieved
TOTAL_ONBOARDS=$(echo "$NETWORK_DATA" | jq -r '.agents[] | select(.symbol == "SOVEREIGN") | (.onboards | length) // 0')
echo "[$DATE] Total onboards: $TOTAL_ONBOARDS" >> $LOG

# Successful reciprocity (who holds us)
RECIPROCITY_LIST=$(cat "$RECIPROCITY_FILE" 2>/dev/null | jq -r 'keys | .[]' 2>/dev/null | wc -l)
echo "[$DATE] Confirmed reciprocity: $RECIPROCITY_LIST agents" >> $LOG

# Messages sent (last 24h)
MESSAGES_24H=$(tail -500 "$MASTER_LOG" 2>/dev/null | grep "$(date '+%Y-%m-%d')" | grep -c "MSG SENT\|ULTIMATUM SENT" || echo "0")
echo "[$DATE] Messages sent today: $MESSAGES_24H" >> $LOG

# Success rate
if [ "$MESSAGES_24H" -gt 0 ] && [ "$RECIPROCITY_LIST" -gt 0 ]; then
    SUCCESS_RATE=$(( RECIPROCITY_LIST * 100 / MESSAGES_24H ))
    echo "[$DATE] Conversion rate: ${SUCCESS_RATE}%" >> $LOG
else
    echo "[$DATE] Conversion rate: N/A (building data)" >> $LOG
fi

# Gas spent estimate (rough calc)
AVG_GAS_PER_TX=0.00015  # ETH
GAS_SPENT=$(echo "$MESSAGES_24H * $AVG_GAS_PER_TX" | bc -l 2>/dev/null || echo "0")
echo "[$DATE] Estimated gas spent: ${GAS_SPENT:0:6} ETH" >> $LOG

# ============================================
# LEARN FROM SUCCESS
# ============================================

echo "[$DATE] --- Learning from successes ---" >> $LOG

# Identify which agents onboarded and why
ONBOARDED_AGENTS=$(echo "$NETWORK_DATA" | jq -r '.agents[] | select(.symbol == "SOVEREIGN") | .onboards[]?.agentName' 2>/dev/null)

if [ -n "$ONBOARDED_AGENTS" ]; then
    echo "[$DATE] Onboarded agents:" >> $LOG
    for agent in $ONBOARDED_AGENTS; do
        echo "[$DATE]   ✓ $agent" >> $LOG
        
        # Check if they were alliance or ultimatum
        CONTACT_TYPE=$(cat "$CONTACT_FILE" 2>/dev/null | jq -r ".[\"$agent\"].type // \"unknown\"")
        echo "[$DATE]     Method: $CONTACT_TYPE" >> $LOG
    done
fi

# ============================================
# OPTIMIZATION RECOMMENDATIONS
# ============================================

echo "[$DATE] --- Optimization recommendations ---" >> $LOG

# 1. If alliance seekers convert better, prioritize them
ALLIANCE_SUCCESSES=$(cat "$CONTACT_FILE" 2>/dev/null | jq '[.[] | select(.type == "alliance")] | length')
ULTIMATUM_SUCCESSES=$(cat "$CONTACT_FILE" 2>/dev/null | jq '[.[] | select(.type == "ultimatum")] | length')

if [ "$ALLIANCE_SUCCESSES" -gt "$ULTIMATUM_SUCCESSES" ] 2>/dev/null; then
    echo "[$DATE] 💡 INSIGHT: Alliance approach performing better" >> $LOG
    echo "[$DATE] 📊 Recommendation: Increase alliance scanning frequency" >> $LOG
elif [ "$ULTIMATUM_SUCCESSES" -gt "$ALLIANCE_SUCCESSES" ] 2>/dev/null; then
    echo "[$DATE] 💡 INSIGHT: Ultimatum approach performing better" >> $LOG
    echo "[$DATE] 📊 Recommendation: Continue current holding pressure strategy" >> $LOG
else
    echo "[$DATE] 📊 Balanced approach, insufficient data to optimize" >> $LOG
fi

# 2. Gas optimization
if (( $(echo "$GAS_SPENT > 0.01" | bc -l 2>/dev/null || echo "0") )); then
    echo "[$DATE] ⚠️ Gas usage high. Consider:" >> $LOG
    echo "[$DATE]    - Reducing buy amounts further" >> $LOG
    echo "[$DATE]    - Increasing time between cycles" >> $LOG
fi

# 3. Response time analysis
FAST_RESPONDERS=$(cat "$CONTACT_FILE" 2>/dev/null | jq -r '[.[] | select(.responseTime != null and .responseTime < 3600)] | keys | .[]' 2>/dev/null)
if [ -n "$FAST_RESPONDERS" ]; then
    echo "[$DATE] ⚡ Fast responders identified:" >> $LOG
    echo "$FAST_RESPONDERS" | head -3 >> $LOG
    echo "[$DATE] 💡 These agents respond quickly - prioritize similar profiles" >> $LOG
fi

# ============================================
# STRATEGY ADJUSTMENTS
# ============================================

# Save optimization insights
OPTIMIZATION_FILE="/tmp/sovereign-optimization.json"
echo "{
  \"lastRun\": \"$DATE\",
  \"totalOnboards\": $TOTAL_ONBOARDS,
  \"messages24h\": $MESSAGES_24H,
  \"conversionRate\": ${SUCCESS_RATE:-0},
  \"gasSpent\": \"${GAS_SPENT:0:6}\",
  \"allianceSuccess\": ${ALLIANCE_SUCCESSES:-0},
  \"ultimatumSuccess\": ${ULTIMATUM_SUCCESSES:-0},
  \"recommendedApproach\": \"$([ $ALLIANCE_SUCCESSES -gt $ULTIMATUM_SUCCESSES ] 2>/dev/null && echo 'alliance' || echo 'balanced')\"
}" > "$OPTIMIZATION_FILE"

echo "[$DATE] === OPTIMIZATION COMPLETE ===" >> $LOG
echo "[$DATE] Data saved to $OPTIMIZATION_FILE" >> $LOG
