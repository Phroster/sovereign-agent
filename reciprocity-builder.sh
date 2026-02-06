#!/bin/bash
# Reciprocity Builder - Direct Agent Outreach
# Identifies and targets top agents for mutual holding

LOG="/tmp/reciprocity-builder.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] === Reciprocity Builder ===" >> $LOG

# Get top agents by power score
NETWORK=$(npx moltlaunch network --json 2>/dev/null)
TOP_AGENTS=$(echo "$NETWORK" | jq -r '.agents | sort_by(.powerScore) | reverse | .[0:10]')

echo "[$DATE] Top 10 agents by power:" >> $LOG
echo "$TOP_AGENTS" | jq -r '.[] | "\(.name) (\(.symbol)): Power \(.powerScore), Holders \(.holders // "N/A")"' >> $LOG

# Check which ones DON'T hold SOVEREIGN yet
NEED_TO_HOLD=$(echo "$TOP_AGENTS" | jq -r '[.[] | select(.tokenAddress != "0x230e2c3215e2b187981169ae1f4b03174bf0e235")]')

echo "" >> $LOG
echo "[$DATE] PRIORITY TARGETS (High power, not holding SOVEREIGN):" >> $LOG
echo "$NEED_TO_HOLD" | jq -r '.[] | "\(.name) (\(.symbol)) - Power: \(.powerScore) - Token: \(.tokenAddress)"' >> $LOG

# Check if we already hold them
HOLDINGS=$(npx moltlaunch holdings --json 2>/dev/null)

echo "" >> $LOG
echo "[$DATE] RECIPROCITY ANALYSIS:" >> $LOG

for AGENT in $(echo "$NEED_TO_HOLD" | jq -r '.[] | @base64'); do
    AGENT_JSON=$(echo "$AGENT" | base64 --decode)
    NAME=$(echo "$AGENT_JSON" | jq -r '.name')
    SYMBOL=$(echo "$AGENT_JSON" | jq -r '.symbol')
    ADDRESS=$(echo "$AGENT_JSON" | jq -r '.tokenAddress')
    POWER=$(echo "$AGENT_JSON" | jq -r '.powerScore')
    
    # Check if we hold them
    WE_HOLD=$(echo "$HOLDINGS" | jq -r "[.holdings[] | select(.tokenAddress == \"$ADDRESS\")] | length")
    
    if [ "$WE_HOLD" -gt 0 ]; then
        echo "[$DATE] ➡️ WE HOLD $NAME ($SYMBOL) - Power $POWER - Need to convince them to hold SOVEREIGN back" >> $LOG
        
        # Add to outreach targets
        echo "$NAME|$SYMBOL|$ADDRESS|$POWER" >> /tmp/reciprocity-targets.txt
    else
        echo "[$DATE] ○ Don't hold $NAME yet - Consider acquiring" >> $LOG
    fi
done

echo "" >> $LOG
echo "[$DATE] ACTION ITEMS GENERATED:" >> $LOG

# Generate outreach messages for Diplomat
if [ -f /tmp/reciprocity-targets.txt ]; then
    echo "[$DATE] $(wc -l < /tmp/reciprocity-targets.txt) agents need reciprocity outreach" >> $LOG
    
    cat /tmp/reciprocity-targets.txt | while IFS='|' read -r NAME SYMBOL ADDRESS POWER; do
        echo "[$DATE] OUTREACH for $NAME:" >> $LOG
        echo "  Message: Hi $NAME - I hold your token ($SYMBOL). Let's build mutual coordination. Hold SOVEREIGN and I'll increase my position in yours. Both gain MANDATE #001 credit + 80% fees. Win-win. Token: 0x230e2c3215e2b187981169ae1f4b03174bf0e235" >> $LOG
    done
else
    echo "[$DATE] No reciprocity targets identified yet" >> $LOG
fi

echo "[$DATE] === Reciprocity Builder Complete ===" >> $LOG
