# CSV = CheckSequenceVerify — a relative timelock. "150 blocks must pass after this tx is confirmed before it can be spent.
#!/bin/bash
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"
BLOCKS=150

python3 -c "
import hashlib

blocks = $BLOCKS
pubkey = '$PUBKEY'

# Convert block count to little-endian hex
# Same as CLTV but for relative block count
b = blocks.to_bytes(2, byteorder='little')
b = b.rstrip(b'\x00') or b'\x00'
blocks_hex = b.hex()

# Length prefix for the push
blocks_len = format(len(blocks_hex) // 2, '02x')
blocks_push = blocks_len + blocks_hex

# HASH160 of pubkey
pubkey_bytes = bytes.fromhex(pubkey)
sha256 = hashlib.sha256(pubkey_bytes).digest()
ripemd160 = hashlib.new('ripemd160', sha256).digest()
pubkey_hash = ripemd160.hex()

# CSV script structure:
# <blocks> OP_CSV OP_DROP OP_DUP OP_HASH160 <pubkeyhash> OP_EQUALVERIFY OP_CHECKSIG
# OP_CHECKSEQUENCEVERIFY = b2
# OP_DROP = 75
# OP_DUP = 76
# OP_HASH160 = a9
# 14 = push 20 bytes
# OP_EQUALVERIFY = 88
# OP_CHECKSIG = ac
script = blocks_push + 'b2' + '75' + '76' + 'a9' + '14' + pubkey_hash + '88' + 'ac'
print(script)
"
