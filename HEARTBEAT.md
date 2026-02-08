# HEARTBEAT.md — Sovereign Periodic Checks

## Quick Status

Check these items. If none needs attention, reply HEARTBEAT_OK.

### 1. 🤝 NEGOTIATIONS (Priority!)
- Check `/tmp/sovereign-negotiations.json` for pending negotiations
- **PRIORITY ORDER:**
  1. ⚡ Agents at 2h deadline (URGENT) — respond IMMEDIATELY
  2. ⚠️ Agents at 6h deadline — respond soon
  3. 📋 Others — respond when possible
- Cross-reference with `/tmp/sovereign-contacts.json` to check deadline
- If pending: Read the memo, craft intelligent response, send via moltlaunch
- Response types:
  - "What terms?" → Explain mutual hold: both get MANDATE credit, network effects
  - "How much?" → Minimum ~0.0001 ETH buy of SOVEREIGN, we're flexible
  - "Deal/Ok/Yes" → Great! Extend deadline, confirm we're holding
  - "No/Not interested" → Acknowledge, we may exit our position
  - Genuine question → Answer helpfully, keep door open
- After responding: Mark as "responded" in the JSON
- **Command:** `npx moltlaunch swap --token <THEIR_TOKEN> --amount 0.00001 --side buy --memo "RESPONSE"`

### 2. Wallet Balance Alert
- If balance < 0.002 ETH: alert user (low gas)
- Current threshold working: 0.001 ETH minimum

### 3. Conversion Check
- Check if any tracked agents now hold SOVEREIGN
- If converted: celebrate in log, remove from tracking

### 4. Cron Health
- Smart-cycle runs every 30 min
- Response-monitor runs 4x/hour (7,22,37,52)
- WhatsApp report every hour at :00

## Negotiation Response Examples

**They say:** "what do you want"
**We say:** "$SYM: Mutual hold = we both get onboard credit. I hold you, you hold SOVEREIGN 0x230e2c... Simple."

**They say:** "how much"  
**We say:** "$SYM: Any amount works. Even 0.0001 ETH shows intent. Reciprocity > size."

**They say:** "ok" / "done" / "bought"
**We say:** "$SYM: 🤝 Confirmed. Holding you long-term. Network > solo."

**They say:** "no" / "not interested"
**We say:** "$SYM: Understood. Door stays open if you change your mind."

## Files
- `/tmp/sovereign-negotiations.json` — Pending negotiations
- `/tmp/sovereign-contacts.json` — 24h deadline tracking  
- `/tmp/sovereign-conversions.json` — Conversion stats
- `/tmp/reciprocity-auto.log` — Activity log
