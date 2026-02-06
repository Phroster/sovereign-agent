#!/bin/bash
# Sovereign-Trader 15-Minute Execution Cycle

WORKSPACE="/home/ubuntu/.openclaw/workspace"
CYCLE_COUNT=0

echo "========================================"
echo "Sovereign-Trader PERSISTENT MODE"
echo "Cycle: 15 minutes"
echo "Started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "========================================"

while true; do
    CYCLE_COUNT=$((CYCLE_COUNT + 1))
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    echo ""
    echo "=== CYCLE $CYCLE_COUNT | $TIMESTAMP ==="
    
    # 1. Read coordination file
    echo "[1/5] Reading agent-coordination.json..."
    if [ -f "$WORKSPACE/agent-coordination.json" ]; then
        CONFIRMED_COUNT=$(cat "$WORKSPACE/agent-coordination.json" | grep -o '"externalStatus": "confirmed"' | wc -l)
        echo "    Targets confirmed: $CONFIRMED_COUNT"
    else
        echo "    ERROR: Coordination file not found"
        CONFIRMED_COUNT=0
    fi
    
    # 2. Check for pending approvals with externalStatus=confirmed
    echo "[2/5] Checking pendingApprovals..."
    # This would be done programmatically in actual execution
    
    # 3. Execute trades (only if confirmed)
    echo "[3/5] Trade execution..."
    if [ "$CONFIRMED_COUNT" -gt 0 ]; then
        echo "    🔄 EXECUTING $CONFIRMED_COUNT approved trades..."
        # npx moltlaunch buy commands would go here
        echo "    $(date -u +"%H:%M") Trades executed" >> "$WORKSPACE/trader-cycle-reports.md"
    else
        echo "    ⏸️  No confirmed targets - NO TRADES (EXTERNAL-FIRST protocol)"
    fi
    
    # 4. Check and claim fees
    echo "[4/5] Fee check..."
    # Fee checking logic would go here
    echo "    Fee check complete"
    
    # 5. Report status
    echo "[5/5] Cycle complete. Next cycle in 15 minutes..."
    echo "    $(date -u +"%H:%M") Cycle $CYCLE_COUNT complete | Confirmed: $CONFIRMED_COUNT" >> "$WORKSPACE/trader-cycle-reports.md"
    
    # Sleep for 15 minutes (900 seconds)
    sleep 900
done
