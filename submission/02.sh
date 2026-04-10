# A P2SH transaction hides a redeemScript inside the scriptSig. When spending, the sender reveals the full redeemScript. It lives inside vin[0].scriptSig but we extract it specifically.

#!/bin/bash
transaction="020000000121654fa95d5a268abf96427e3292baed6c9f6d16ed9e80511070f954883864b100000000d90047304402201c97b48215f261055e41b765ab025e77a849b349698ed742b305f2c845c69b3f022013a5142ef61db1ff425fbdcdeb3ea370aaff5265eee0956cff9aa97ad9a357e301473044022000a402ec4549a65799688dd531d7b18b03c6379416cc8c29b92011987084e9f402205470e24781509c70e2410aaa6d827aa133d6df2c578e96a496b885584fb039200147522102da2f10746e9778dd57bd0276a4f84101c4e0a711f9cfd9f09cde55acbdd2d1912102bfde48be4aa8f4bf76c570e98a8d287f9be5638412ab38dede8e78df82f33fa352aeffffffff0188130000000000001600142c48d3401f6abed74f52df3f795c644b4398844600000000"

# decoderawtransaction gives us the full structure
# vin[0].scriptSig.hex contains the full unlocking script
# For P2SH, the redeemScript is the LAST item pushed onto the stack
# in the scriptSig — it's the final hex push after all the signatures
# We use decodescript on the scriptSig hex to find the redeemScript
SCRIPTSIG_HEX=$(bitcoin-cli -regtest decoderawtransaction "$transaction" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data['vin'][0]['scriptSig']['hex'])
")

# decodescript decodes a script hex and reveals its structure
# For P2SH inputs, it shows the embedded redeemScript
bitcoin-cli -regtest decodescript "$SCRIPTSIG_HEX" | python3 -c "
import sys, json
data = json.load(sys.stdin)
# p2sh field shows what the redeemScript hashes to
# but we want the actual redeemScript — it's in 'segwit.hex' or we parse manually
# The redeemScript is the last push in the scriptSig
# In a multisig P2SH: OP_0 <sig1> <sig2> <redeemScript>
# We extract it from the 'asm' field — it's the last space-separated item
asm = data['asm']
# asm looks like: '0 <sig1> <sig2> <redeemscript_hex>'
parts = asm.split()
print(parts[-1])
"
