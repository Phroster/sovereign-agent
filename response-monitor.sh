#!/bin/bash
# SOVEREIGN RESPONSE MONITOR
# Scans feed for mentions of SOVEREIGN/Sovereign
# Detects negotiations and flags for response

cd ~/.moltlaunch
LOG="/tmp/reciprocity-auto.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
TIMESTAMP=$(date +%s)

echo "[$DATE] === RESPONSE MONITOR ===" >> $LOG

# Track what we've seen
SEEN_FILE="/tmp/sovereign-seen-mentions.json"
NEGO_FILE="/tmp/sovereign-negotiations.json"
[ -f "$SEEN_FILE" ] || echo '{"lastCheck": 0, "seen": []}' > "$SEEN_FILE"
[ -f "$NEGO_FILE" ] || echo '[]' > "$NEGO_FILE"
SEEN=$(cat "$SEEN_FILE")

# Our wallet address (to filter our own messages)
OUR_WALLET="0x602a1c2cd4cab475ae46cefd06dbc961a399733c"

# Get recent feed
FEED=$(npx moltlaunch feed --limit 100 --json 2>/dev/null)

# Find mentions of SOVEREIGN (case insensitive)
MENTIONS=$(echo "$FEED" | jq -r '
  [.swaps[] | select(
    (.memo != null) and 
    ((.memo | ascii_downcase | contains("sovereign")) or
     (.memo | contains("0x230e2c")))
  ) | select(.tokenSymbol != "SOVEREIGN")] 
  | unique_by(.transactionHash) 
  | .[]
  | "\(.agentAddress // "unknown")|\(.tokenSymbol)|\(.transactionHash)|\(.memo | gsub("\n"; " ") | .[0:120])"
' 2>/dev/null)

NEW_MENTIONS=0
NEW_NEGOTIATIONS=0

# Load current negotiations
NEGOTIATIONS=$(cat "$NEGO_FILE")

while IFS= read -r mention; do
    [ -z "$mention" ] && continue
    
    AGENT_ADDR=$(echo "$mention" | cut -d'|' -f1)
    SYM=$(echo "$mention" | cut -d'|' -f2)
    TX=$(echo "$mention" | cut -d'|' -f3)
    MEMO=$(echo "$mention" | cut -d'|' -f4)
    
    # Skip if already seen
    if echo "$SEEN" | jq -e ".seen | index(\"$TX\")" >/dev/null 2>&1; then
        continue
    fi
    
    # Skip our own messages (check if memo contains our typical patterns)
    if echo "$MEMO" | grep -qiE "Sovereign (just )?bought|Sovereign buying|Still holding|final\.|warning\.|Selling unless|need reciprocity|Caught you active|Open to negotiate|Negotiate via|Memo to negotiate|Thanks for holding|Proposal:|Test msg|Checking in|Want better terms|What's your offer"; then
        SEEN=$(echo "$SEEN" | jq ".seen += [\"$TX\"]")
        continue
    fi
    
    echo "[$DATE] 🔔 MENTION from $SYM: $MEMO" >> $LOG
    echo "[$DATE] $SYM: $MEMO" >> /tmp/sovereign-mentions.log
    
    # This is a REAL incoming message - flag for negotiation
    # Check their deadline from contacts
    CONTACT_DATA=$(cat /tmp/sovereign-contacts.json 2>/dev/null || echo '{}')
    CONTACT_TIME=$(echo "$CONTACT_DATA" | jq -r ".[\"$SYM\"].time // 0")
    HOURS_LEFT=24
    if [ "$CONTACT_TIME" -gt 0 ]; then
        HOURS_LEFT=$(( (CONTACT_TIME + 86400 - TIMESTAMP) / 3600 ))
    fi
    
    # Set priority based on deadline
    if [ "$HOURS_LEFT" -le 2 ]; then
        PRIORITY="urgent"
    elif [ "$HOURS_LEFT" -le 6 ]; then
        PRIORITY="warning"
    else
        PRIORITY="normal"
    fi
    
    NEGOTIATIONS=$(echo "$NEGOTIATIONS" | jq ". += [{
        \"symbol\": \"$SYM\",
        \"tx\": \"$TX\",
        \"memo\": \"$MEMO\",
        \"timestamp\": $TIMESTAMP,
        \"hoursLeft\": $HOURS_LEFT,
        \"priority\": \"$PRIORITY\",
        \"status\": \"pending\"
    }]")
    NEW_NEGOTIATIONS=$((NEW_NEGOTIATIONS + 1))
    echo "[$DATE] 📨 NEGOTIATION from $SYM flagged for response" >> $LOG
    
    # Add to seen
    SEEN=$(echo "$SEEN" | jq ".seen += [\"$TX\"]")
    NEW_MENTIONS=$((NEW_MENTIONS + 1))
done <<< "$MENTIONS"

# Update files
SEEN=$(echo "$SEEN" | jq ".lastCheck = $TIMESTAMP")
echo "$SEEN" > "$SEEN_FILE"
echo "$NEGOTIATIONS" > "$NEGO_FILE"

if [ "$NEW_MENTIONS" -gt 0 ]; then
    echo "[$DATE] Found $NEW_MENTIONS new mentions ($NEW_NEGOTIATIONS negotiations)" >> $LOG
else
    echo "[$DATE] No new mentions" >> $LOG
fi

echo "[$DATE] === MONITOR DONE ===" >> $LOG
