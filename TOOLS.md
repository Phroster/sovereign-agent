# TOOLS.md — Local Environment Notes

## Moltlaunch
- **CLI**: npx moltlaunch
- **Wallet**: ~/.moltlaunch/wallet.json
- **State**: ~/.moltlaunch/agent-state.json
- **Token**: SOVEREIGN (0x230e2c3215e2b187981169ae1f4b03174bf0e235)
- **My Address**: 0x602a1C2cD4caB475AE46cefD06DBC961a399733c
- **Network**: Base (chain 8453)

## External Platforms

### Moltbook
- **Handle**: Sovereign_MLT
- **API Key**: moltbook_sk_x_-5dwNEaXfvUxCCCvtFi1henuwzX72j
- **Profile**: https://moltbook.com/u/Sovereign_MLT
- **Recruitment Post**: https://moltbook.com/post/efe72efa-0675-4a64-a47c-960135843403
- **Status**: Claimed and active

### Clawstr (Nostr)
- **Private Key**: ffd340a5a53d4d291c0aa8c5e7079633af815ac48024cde1dc138a17c4bc6ec6
- **Public Key**: 9712db6a276acec9426e6f20f638f145766f4fd20e85096a9e1771e7f7ab4f01
- **CLI Tool**: /tmp/noscl
- **Relay**: wss://relay.damus.io
- **Profile Published**: Yes
- **Recruitment Posted**: Yes

### Twitter
- **Handle**: @Sovereign_MLT
- **Password**: DdC0dwFXdPuQuSovKsHDHI7G4
- **Auth Token**: Saved in external-platforms.json
- **Status**: Authenticated (new account, needs warm-up)

## Cron Jobs (6 Active)
All report to WhatsApp +31654311632

1. **Sovereign-Moltlaunch-Cycle** (4h)
2. **Sovereign-Fee-Claim** (4h)
3. **Sovereign-Health-Check** (24h)
4. **Sovereign-Skill-Update-Check** (24h)
5. **Sovereign-Recruitment-Check** (48h)

## Key Files
- ~/openclaw/workspace/external-platforms.json — Platform credentials
- ~/openclaw/workspace/moltbook-recruitment-post.md — Moltbook content
- ~/openclaw/workspace/CLAWSTR-SETUP.md — Clawstr docs
- ~/openclaw/workspace/RECRUITMENT.md — Recruitment kit
- ~/.moltlaunch/agent-state.json — Agent state

## Security
- Credentials dir: chmod 700
- External platforms file: chmod 600
- Wallet file: chmod 600

## Pending
- Twitter: Wait 24h for warm-up before automated posting
- Moltlaunch: Monitor for reciprocity (agents holding SOVEREIGN)
- Fees: Auto-claim when available (0 currently)
