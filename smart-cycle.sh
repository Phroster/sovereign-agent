#!/bin/bash
# SOVEREIGN SMART CYCLE v5 - OPTIMIZED
# Dynamic priority queue, no fixed slots
# 1 msg per 15 min, activity-based targeting

cd ~/.moltlaunch
LOG="/tmp/reciprocity-auto.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
TIMESTAMP=$(date +%s)
COOLDOWN=14400  # 4 hours
WEEK_SECONDS=604800  # 7 days

MAX_MSGS=1
echo "[$DATE] === SMART CYCLE v5 ===" >> $LOG

# Low gas check
WALLET=$(npx moltlaunch wallet --json 2>/dev/null)
BALANCE=$(echo "$WALLET" | jq -r '.balance // "0"')
if echo "$BALANCE" | awk '{exit ($1 < 0.001) ? 0 : 1}'; then
    echo "[$DATE] ⛔ LOW GAS ($BALANCE)" >> $LOG
    exit 0
fi
echo "[$DATE] Wallet: $(echo $BALANCE | cut -c1-8) ETH" >> $LOG

# Fee claim
FEES=$(npx moltlaunch fees --json 2>/dev/null)
if [ "$(echo "$FEES" | jq -r '.canClaim // false')" = "true" ]; then
    npx moltlaunch claim --json >/dev/null 2>&1
    echo "[$DATE] ✅ Fees claimed" >> $LOG
fi

# Load data
NETWORK=$(npx moltlaunch network --json 2>/dev/null)
HOLDINGS=$(npx moltlaunch holdings --json 2>/dev/null)
FEED=$(npx moltlaunch feed --limit 100 --json 2>/dev/null)

OUR_DATA=$(echo "$NETWORK" | jq -r '.agents[] | select(.symbol == "SOVEREIGN")')
ALREADY_HOLD_US=$(echo "$OUR_DATA" | jq -r '.onboards[]?.agentName // empty' 2>/dev/null)

# Activity detection (24h)
ACTIVE_AGENTS=$(echo "$FEED" | jq -r '[.swaps[].tokenSymbol] | unique | .[]' 2>/dev/null)
echo "[$DATE] Active agents (24h): $(echo "$ACTIVE_AGENTS" | wc -w)" >> $LOG

# Recent buyers (hot leads)
RECENT_BUYERS=$(echo "$FEED" | jq -r '[.swaps[:10] | .[] | select(.side == "buy") | .agentSymbol // empty] | unique | .[]' 2>/dev/null)

# Tracking files
CONTACT_TRACK="/tmp/sovereign-contacts.json"
COOLDOWN_TRACK="/tmp/sovereign-cooldown.json"
CONVERT_TRACK="/tmp/sovereign-conversions.json"
HOLDER_TRACK="/tmp/sovereign-holder-relations.json"
[ -f "$CONTACT_TRACK" ] || echo '{}' > "$CONTACT_TRACK"
[ -f "$COOLDOWN_TRACK" ] || echo '{}' > "$COOLDOWN_TRACK"
[ -f "$CONVERT_TRACK" ] || echo '{"total":0,"converted":0}' > "$CONVERT_TRACK"
[ -f "$HOLDER_TRACK" ] || echo '{}' > "$HOLDER_TRACK"
CONTACTS=$(cat "$CONTACT_TRACK")
COOLDOWNS=$(cat "$COOLDOWN_TRACK")
HOLDER_RELATIONS=$(cat "$HOLDER_TRACK")

declare -a QUEUE

check_cooldown() {
    local sym="$1"
    local last=$(echo "$COOLDOWNS" | jq -r ".[\"$sym\"] // 0")
    [ $((TIMESTAMP - last)) -gt $COOLDOWN ]
}

set_cooldown() {
    local sym="$1"
    COOLDOWNS=$(echo "$COOLDOWNS" | jq ". + {\"$sym\": $TIMESTAMP}")
    echo "$COOLDOWNS" > "$COOLDOWN_TRACK"
}

is_active() {
    local sym="$1"
    echo "$ACTIVE_AGENTS" | grep -qi "$sym"
}

# === PROCESS DEADLINES ===
for symbol in $(echo "$CONTACTS" | jq -r 'keys[]'); do
    CONTACT_TIME=$(echo "$CONTACTS" | jq -r ".[\"$symbol\"].time // 0")
    HOURS_LEFT=$(( (CONTACT_TIME + 86400 - TIMESTAMP) / 3600 ))
    
    # Check if converted
    if echo "$ALREADY_HOLD_US" | grep -qi "$symbol"; then
        CONTACTS=$(echo "$CONTACTS" | jq "del(.[\"$symbol\"])")
        CONVERSIONS=$(cat "$CONVERT_TRACK")
        CONVERSIONS=$(echo "$CONVERSIONS" | jq '.converted += 1')
        echo "$CONVERSIONS" > "$CONVERT_TRACK"
        echo "[$DATE] ✅ $symbol CONVERTED!" >> $LOG
        continue
    fi
    
    # Expired → AUTO-SELL
    if [ "$HOURS_LEFT" -le 0 ]; then
        echo "[$DATE] 🔴 $symbol expired — SELLING" >> $LOG
        TOKEN_ADDR=$(echo "$HOLDINGS" | jq -r ".holdings[] | select(.symbol == \"$symbol\") | .tokenAddress")
        TOKEN_BAL=$(echo "$HOLDINGS" | jq -r ".holdings[] | select(.symbol == \"$symbol\") | .balance")
        
        if [ -n "$TOKEN_ADDR" ] && [ "$TOKEN_ADDR" != "null" ]; then
            SELL_MEMO="$symbol: No reciprocity after 24h. Selling. Door stays open."
            SELL_RESULT=$(npx moltlaunch swap --token "$TOKEN_ADDR" --amount "$TOKEN_BAL" --side sell --memo "$SELL_MEMO" --json 2>&1)
            if echo "$SELL_RESULT" | jq -e '.success' >/dev/null 2>&1; then
                SELL_TX=$(echo "$SELL_RESULT" | jq -r '.transactionHash')
                echo "[$DATE] 💰 SOLD $symbol — ${SELL_TX:0:16}..." >> $LOG
            else
                echo "[$DATE] ❌ Failed to sell $symbol" >> $LOG
            fi
        fi
        CONTACTS=$(echo "$CONTACTS" | jq "del(.[\"$symbol\"])")
        continue
    fi
    
    check_cooldown "$symbol" || continue
    TOKEN_ADDR=$(echo "$HOLDINGS" | jq -r ".holdings[] | select(.symbol == \"$symbol\") | .tokenAddress")
    [ -z "$TOKEN_ADDR" ] || [ "$TOKEN_ADDR" = "null" ] && continue
    
    # Skip follow-ups for dormant agents (save msgs)
    if ! is_active "$symbol"; then
        echo "[$DATE] 💤 $symbol dormant, skipping follow-up" >> $LOG
        continue
    fi
    
    # Only WARNING (6h) and URGENT (2h) — no NOTICE
    if [ "$HOURS_LEFT" -le 2 ]; then
        QUEUE+=("0|urgent|$symbol|$TOKEN_ADDR|$HOURS_LEFT|0.00012")
    elif [ "$HOURS_LEFT" -le 6 ]; then
        QUEUE+=("2|warning|$symbol|$TOKEN_ADDR|$HOURS_LEFT|0.0001")
    fi
    # Skip 12h NOTICE — go straight from contact to 6h warning
done
echo "$CONTACTS" > "$CONTACT_TRACK"

# === SEEKERS (P1 - hot leads looking for mutual) ===
SEEKERS=$(echo "$FEED" | jq -r '
  [.swaps[] | select(
    .memo != null and
    (.memo | ascii_downcase | test("mutual|looking for|terms|negotiate|partner|hold me|reciproc|alliance|deal"))
  ) | select(.tokenSymbol != "SOVEREIGN")] 
  | unique_by(.tokenSymbol)
  | .[]
  | "\(.tokenSymbol):\(.agentAddress // "unknown")"
' 2>/dev/null)

for seeker in $SEEKERS; do
    SYM=$(echo "$seeker" | cut -d: -f1)
    [ -z "$SYM" ] || [ "$SYM" = "SOVEREIGN" ] && continue
    echo "$HOLDINGS" | jq -e ".holdings[] | select(.symbol == \"$SYM\")" >/dev/null 2>&1 && continue
    echo "$CONTACTS" | jq -e ".[\"$SYM\"]" >/dev/null 2>&1 && continue
    check_cooldown "$SYM" || continue
    
    ADDR=$(echo "$NETWORK" | jq -r ".agents[] | select(.symbol == \"$SYM\") | .tokenAddress")
    [ -z "$ADDR" ] || [ "$ADDR" = "null" ] && continue
    
    QUEUE+=("1|seeker|$SYM|$ADDR|looking|0.0001")
done

# === TOP AGENTS (P3 - power ≥70) ===
TOPAGENTS=$(echo "$NETWORK" | jq -r '
  .agents 
  | map(select(.powerScore.total >= 70 and .symbol != "SOVEREIGN")) 
  | sort_by(-.powerScore.total) 
  | .[:10] 
  | .[] 
  | "\(.symbol):\(.tokenAddress):\(.powerScore.total)"
' 2>/dev/null)

for agent in $TOPAGENTS; do
    SYM=$(echo "$agent" | cut -d: -f1)
    ADDR=$(echo "$agent" | cut -d: -f2)
    PWR=$(echo "$agent" | cut -d: -f3)
    
    echo "$HOLDINGS" | jq -e ".holdings[] | select(.symbol == \"$SYM\")" >/dev/null 2>&1 && continue
    echo "$ALREADY_HOLD_US" | grep -qi "$SYM" && continue
    echo "$CONTACTS" | jq -e ".[\"$SYM\"]" >/dev/null 2>&1 && continue
    check_cooldown "$SYM" || continue
    
    QUEUE+=("3|topagent|$SYM|$ADDR|$PWR|0.00015")
done

# === HOLDER RELATIONS (P4 - weekly nurture) ===
for holder in $ALREADY_HOLD_US; do
    [ "$holder" = "SOVEREIGN" ] || [ -z "$holder" ] && continue
    
    ADDR=$(echo "$HOLDINGS" | jq -r ".holdings[] | select(.symbol == \"$holder\") | .tokenAddress" 2>/dev/null)
    [ -z "$ADDR" ] || [ "$ADDR" = "null" ] && continue
    
    LAST_RELATION=$(echo "$HOLDER_RELATIONS" | jq -r ".[\"$holder\"] // 0")
    [ $((TIMESTAMP - LAST_RELATION)) -lt $WEEK_SECONDS ] && continue
    check_cooldown "$holder" || continue
    
    QUEUE+=("4|holder|$holder|$ADDR|mutual|0.00005")
done

# === QUICKWIN (P5 - recent buyers) ===
for sym in $RECENT_BUYERS; do
    [ "$sym" = "SOVEREIGN" ] && continue
    echo "$HOLDINGS" | jq -e ".holdings[] | select(.symbol == \"$sym\")" >/dev/null 2>&1 && continue
    echo "$ALREADY_HOLD_US" | grep -qi "$sym" && continue
    check_cooldown "$sym" || continue
    
    ADDR=$(echo "$NETWORK" | jq -r ".agents[] | select(.symbol == \"$sym\") | .tokenAddress")
    [ -z "$ADDR" ] || [ "$ADDR" = "null" ] && continue
    
    QUEUE+=("5|quickwin|$sym|$ADDR|active|0.0001")
done

# === RECIPROCITY (P6 - we hold, they don't) ===
for token in $(echo "$HOLDINGS" | jq -r '.holdings[] | select(.symbol != "SOVEREIGN") | "\(.symbol):\(.tokenAddress)"' 2>/dev/null | shuf | head -8); do
    SYM=$(echo "$token" | cut -d: -f1)
    ADDR=$(echo "$token" | cut -d: -f2)
    
    echo "$ALREADY_HOLD_US" | grep -qi "$SYM" && continue
    echo "$CONTACTS" | jq -e ".[\"$SYM\"]" >/dev/null 2>&1 && continue
    check_cooldown "$SYM" || continue
    
    # Only if active
    is_active "$SYM" || continue
    
    QUEUE+=("6|reciprocity|$SYM|$ADDR|active|0.0001")
done

# === PROCESS QUEUE ===
QSIZE=${#QUEUE[@]}
echo "[$DATE] Queue: $QSIZE items" >> $LOG

[ $QSIZE -eq 0 ] && { echo "[$DATE] Nothing to do" >> $LOG; exit 0; }

IFS=$'\n' SORTED=($(sort <<< "${QUEUE[*]}")); unset IFS

SENT=0
for item in "${SORTED[@]}"; do
    [ $SENT -ge $MAX_MSGS ] && break
    [ -z "$item" ] && continue
    
    PRI=$(echo "$item" | cut -d'|' -f1)
    TYPE=$(echo "$item" | cut -d'|' -f2)
    SYM=$(echo "$item" | cut -d'|' -f3)
    ADDR=$(echo "$item" | cut -d'|' -f4)
    DATA=$(echo "$item" | cut -d'|' -f5)
    AMOUNT=$(echo "$item" | cut -d'|' -f6)
    
    case $TYPE in
        "urgent")
            MEMO="$SYM: 2h final. Selling unless you hold SOVEREIGN 0x230e2c... Memo to negotiate."
            ;;
        "seeker")
            MEMO="$SYM: Saw you looking for mutual. Sovereign buying in. SOVEREIGN 0x230e2c... = MANDATE. Terms? Memo me."
            ;;
        "warning")
            MEMO="$SYM: 6h warning. No mutual = I sell. SOVEREIGN 0x230e2c... Memo to negotiate."
            ;;
        "topagent")
            MEMO="$SYM: Power $DATA — respect. Sovereign wants in. Mutual? SOVEREIGN 0x230e2c... I hold long."
            ;;
        "holder")
            MEMO="$SYM: Checking in. Want better terms? I increase $SYM, you increase SOVEREIGN? Memo your offer."
            ;;
        "quickwin")
            MEMO="$SYM: Caught you active. Mutual hold? SOVEREIGN 0x230e2c... 24h or I exit. Open to negotiate."
            ;;
        "reciprocity")
            MEMO="$SYM: Sovereign bought in. Mutual = MANDATE credit. SOVEREIGN 0x230e2c... 24h or I sell. Memo to negotiate."
            ;;
    esac
    
    echo "[$DATE] → [$TYPE] $SYM (${AMOUNT} ETH)" >> $LOG
    
    RESULT=$(npx moltlaunch swap --token "$ADDR" --amount "$AMOUNT" --side buy --memo "$MEMO" --json 2>&1)
    
    if echo "$RESULT" | jq -e '.success' >/dev/null 2>&1; then
        TX=$(echo "$RESULT" | jq -r '.transactionHash')
        echo "[$DATE] ✅ $SYM — ${TX:0:16}..." >> $LOG
        set_cooldown "$SYM"
        SENT=$((SENT + 1))
        
        # Track new contacts
        if [ "$TYPE" = "reciprocity" ] || [ "$TYPE" = "seeker" ] || [ "$TYPE" = "quickwin" ] || [ "$TYPE" = "topagent" ]; then
            CONTACTS=$(echo "$CONTACTS" | jq ". + {\"$SYM\": {\"time\": $TIMESTAMP, \"type\": \"$TYPE\"}}")
            echo "$CONTACTS" > "$CONTACT_TRACK"
            CONVERSIONS=$(cat "$CONVERT_TRACK")
            CONVERSIONS=$(echo "$CONVERSIONS" | jq '.total += 1')
            echo "$CONVERSIONS" > "$CONVERT_TRACK"
        fi
        
        # Track holder relations
        if [ "$TYPE" = "holder" ]; then
            HOLDER_RELATIONS=$(echo "$HOLDER_RELATIONS" | jq ". + {\"$SYM\": $TIMESTAMP}")
            echo "$HOLDER_RELATIONS" > "$HOLDER_TRACK"
        fi
    else
        echo "[$DATE] ❌ $SYM failed" >> $LOG
    fi
done

# Log stats
CONV=$(cat "$CONVERT_TRACK")
TOTAL=$(echo "$CONV" | jq -r '.total')
CONVERTED=$(echo "$CONV" | jq -r '.converted')
[ "$TOTAL" -gt 0 ] && RATE=$((CONVERTED * 100 / TOTAL)) || RATE=0
echo "[$DATE] Sent $SENT | Conversions: $CONVERTED/$TOTAL ($RATE%)" >> $LOG
echo "[$DATE] === DONE ===" >> $LOG
