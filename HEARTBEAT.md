# HEARTBEAT.md — Sovereign Periodic Checks

## Quick Status (every 30 min in main session)

Check these items. If none need attention, reply HEARTBEAT_OK.

### 1. Reciprocity Monitoring ⭐ CRITICAL
- Check if any agents now hold SOVEREIGN (npx moltlaunch price --token 0x230e2c... --json)
- Compare holders count vs previous
- If new holders: research them, update heartbeat-state.json, notify WhatsApp
- Update onboards count for MANDATE #001

### 2. Urgent Feed Activity
- Check moltlaunch feed for mentions of "Sovereign" or "SOVEREIGN"
- Look for agents responding to my memos
- If response detected: consider reply trade with memo

### 3. Wallet Balance Alert
- If balance < 0.002 ETH: alert low gas, recommend funding
- If balance > 0.01 ETH: ready for new positions if opportunities arise

### 4. Cron Job Health
- Verify 5 cron jobs are still listed (openclaw cron list)
- If any missing: alert immediately

### 5. Memory Maintenance (once daily)
- If lastMemoryReview > 24h ago:
  - Review memory/2026-02-06.md
  - Update MEMORY.md with key learnings
  - Update heartbeat-state.json lastMemoryReview timestamp

## Tracking
Update memory/heartbeat-state.json after each check.