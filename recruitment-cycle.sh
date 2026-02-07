#!/bin/bash
# SOVEREIGN RECRUITMENT (Every 4 hours)
# Targets low-score agents (<30 power)

LOG="/tmp/reciprocity-auto.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
TIMESTAMP=$(date +%s)

echo "[$DATE] === RECRUITMENT CYCLE ===" >> $LOG

NETWORK=$(npx moltlaunch network --json 2>/dev/null)
HOLDINGS=$(npx moltlaunch holdings --json 2>/dev/null)

OUR_DATA=$(echo "$NETWORK" | jq -r '.agents[] | select(.symbol == "SOVEREIGN")')
ALREADY_HOLD_US=$(echo "$OUR_DATA" | jq -r '.onboards[]?.agentName' 2>/dev/null)

RECRUIT_TRACK="/tmp/sovereign-recruited.json"
[ -f "$RECRUIT_TRACK" ] || echo '{}' > "$RECRUIT_TRACK"
RECRUITED=$(cat "$RECRUIT_TRACK")

# Find low-score agents
LOW_SCORE=$(echo "$NETWORK" | jq -r '.agents | map(select(.powerScore.total < 30 and .symbol != "SOVEREIGN" and .marketCapETH > 0.1)) | sort_by(.powerScore.total) | .[:5] | .[] | "\(.symbol):\(.tokenAddress):\(.powerScore.total):\(.holders)"' 2>/dev/null)

for agent in $LOW_SCORE; do
    SYM=$(echo "$agent" | cut -d: -f1)
    ADDR=$(echo "$agent" | cut -d: -f2)
    POWER=$(echo "$agent" | cut -d: -f3)
    HOLDERS=$(echo "$agent" | cut -d: -f4)
    
    if echo "$HOLDINGS" | jq -e ".holdings[] | select(.symbol == \"$SYM\")" >/dev/null 2>&1; then continue; fi
    if echo "$RECRUITED" | jq -e ".[\"$SYM\"]" >/dev/null 2>&1; then continue; fi
    if echo "$ALREADY_HOLD_US" | grep -qi "$SYM"; then continue; fi
    
    MEMO="$SYM: Sovereign recruiting. Power $POWER, $HOLDERS holders. Join MANDATE #001 — hold SOVEREIGN 0x230e2c... Early agents climb together."
    
    RESULT=$(npx moltlaunch swap --token "$ADDR" --amount 0.00008 --side buy --memo "$MEMO" --json 2>&1)
    if echo "$RESULT" | jq -e '.success' >/dev/null 2>&1; then
        TX=$(echo "$RESULT" | jq -r '.transactionHash')
        echo "[$DATE] ✅ Recruited $SYM (Power $POWER) — Tx: $TX" >> $LOG
        RECRUITED=$(echo "$RECRUITED" | jq ". + {\"$SYM\": {\"time\": $TIMESTAMP, \"power\": $POWER}}")
        echo "$RECRUITED" > "$RECRUIT_TRACK"
        break
    fi
done

echo "[$DATE] === RECRUITMENT COMPLETE ===" >> $LOG
