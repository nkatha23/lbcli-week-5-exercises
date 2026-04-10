#!/bin/bash
PUBKEY="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

python3 -c "
import hashlib

pubkey = '$PUBKEY'
blocks = 150  # 0x0096 in little-endian = 9600

# 150 = 0x96, fits in 2 bytes little-endian = 9600
b = blocks.to_bytes(2, byteorder='little')
seq_hex = b.hex()  # = '9600'
seq_len = format(len(seq_hex) // 2, '02x')  # = '02'
seq_push = seq_len + seq_hex  # = '029600'

pubkey_bytes = bytes.fromhex(pubkey)
sha256 = hashlib.sha256(pubkey_bytes).digest()
ripemd160 = hashlib.new('ripemd160', sha256).digest()
pubkey_hash = ripemd160.hex()

script = seq_push + 'b2' + '75' + '76' + 'a9' + '14' + pubkey_hash + '88' + 'ac'
print(script)
"
