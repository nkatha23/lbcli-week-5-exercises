#!/bin/bash
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

python3 -c "
import hashlib

pubkey = '$PUBKEY'

# Calculate time-based CSV value
# 6 months = 6 x 30 days = 180 days
seconds = 180 * 24 * 3600       # = 15,552,000 seconds
units = seconds // 512           # = 30,375 units (512-second granularity)
sequence = units | 0x400000      # set bit 22 = type flag for time-based

# Convert to little-endian hex
# Need enough bytes to hold the value
b = sequence.to_bytes(4, byteorder='little')
b = b.rstrip(b'\x00') or b'\x00'
seq_hex = b.hex()

# Length prefix for script push
seq_len = format(len(seq_hex) // 2, '02x')
seq_push = seq_len + seq_hex

# HASH160 of pubkey
pubkey_bytes = bytes.fromhex(pubkey)
sha256 = hashlib.sha256(pubkey_bytes).digest()
ripemd160 = hashlib.new('ripemd160', sha256).digest()
pubkey_hash = ripemd160.hex()

# CSV script:
# <sequence> OP_CSV OP_DROP OP_DUP OP_HASH160 <pubkeyhash> OP_EQUALVERIFY OP_CHECKSIG
# b2 = OP_CHECKSEQUENCEVERIFY
# 75 = OP_DROP
# 76 = OP_DUP
# a9 = OP_HASH160
# 14 = push 20 bytes
# 88 = OP_EQUALVERIFY
# ac = OP_CHECKSIG
script = seq_push + 'b2' + '75' + '76' + 'a9' + '14' + pubkey_hash + '88' + 'ac'
print(script)
"
# Block vs Time CSV comparison:
# Block-based (05.sh):
#   150 blocks → sequence = 0x0096
#   No type flag needed

# Time-based (08.sh):
#   180 days → 15,552,000 sec ÷ 512 = 30,375 units
#   30,375 | 0x400000 = 4,224,679
#   Type flag (bit 22) tells nodes "interpret this as time not blocks"