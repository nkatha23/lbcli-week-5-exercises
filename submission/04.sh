# CLTV = CheckLockTimeVerify — an absolute timelock opcode in Bitcoin Script. The script says "this coin cannot be spent until timestamp X has passed.
#!/bin/bash
TIMESTAMP=1495584032
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

# Convert timestamp to little-endian hex
# Bitcoin script uses little-endian encoding for numbers
# python3 converts the integer to bytes then hex
TIMESTAMP_HEX=$(python3 -c "
import struct
# Pack timestamp as 5-byte little-endian integer
# '<' = little-endian, 'Q' = unsigned 64-bit, then take first 5 bytes
ts = $TIMESTAMP
# Convert to little-endian bytes, remove trailing zeros but keep minimum bytes
b = ts.to_bytes(5, byteorder='little')
# Strip trailing null bytes but keep at least 1 byte
b = b.rstrip(b'\x00') or b'\x00'
print(b.hex())
")

# A CLTV script structure:
# <timestamp> OP_CHECKLOCKTIMEVERIFY OP_DROP OP_DUP OP_HASH160 <pubkeyhash> OP_EQUALVERIFY OP_CHECKSIG
# In hex opcodes:
# OP_CHECKLOCKTIMEVERIFY = b1
# OP_DROP = 75
# OP_DUP = 76
# OP_HASH160 = a9
# OP_EQUALVERIFY = 88
# OP_CHECKSIG = ac

# Get the pubkey hash (HASH160 of the pubkey)
PUBKEY_HASH=$(bitcoin-cli -regtest decodescript "${PUBKEY}" 2>/dev/null \
  | grep -oP '"p2pkh":\s*"\K[^"]+' || echo "")

# Use python3 to build the full CLTV script
python3 -c "
timestamp_hex = '$TIMESTAMP_HEX'
pubkey = '$PUBKEY'

# Push the timestamp bytes onto the stack
ts_len = len(timestamp_hex) // 2  # number of bytes
ts_push = format(ts_len, '02x') + timestamp_hex  # length prefix + data

# OP_CHECKLOCKTIMEVERIFY = b1
# OP_DROP = 75  
# OP_DUP = 76
# OP_HASH160 = a9
# 14 = push 20 bytes (pubkey hash length)
# OP_EQUALVERIFY = 88
# OP_CHECKSIG = ac

import hashlib
# HASH160 = RIPEMD160(SHA256(pubkey))
pubkey_bytes = bytes.fromhex(pubkey)
sha256 = hashlib.sha256(pubkey_bytes).digest()
ripemd160 = hashlib.new('ripemd160', sha256).digest()
pubkey_hash = ripemd160.hex()

script = ts_push + 'b1' + '75' + '76' + 'a9' + '14' + pubkey_hash + '88' + 'ac'
print(script)
"
