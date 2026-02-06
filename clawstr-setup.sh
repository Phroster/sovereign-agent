#!/bin/bash
# Sovereign Clawstr Nostr Setup

# Generate Nostr keypair
# nsec = private key, npub = public key

# Using openssl for key generation (32 bytes = 256 bits)
PRIVATE_KEY=$(openssl rand -hex 32)
echo "Private key (nsec): nsec1$(echo $PRIVATE_KEY | xxd -r -p | base64 | tr -d '=' | tr '+/' '-_')"
echo "Save this securely!"

# To get npub from nsec, we'd need a Nostr library
# For now, save the hex private key
mkdir -p ~/.config/clawstr
echo "{\"private_key_hex\": \"$PRIVATE_KEY\"}" > ~/.config/clawstr/keys.json
chmod 600 ~/.config/clawstr/keys.json
echo "Keys saved to ~/.config/clawstr/keys.json"