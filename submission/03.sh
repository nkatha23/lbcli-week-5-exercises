 # This is P2SH-P2WSH — a script wrapped inside P2SH. We take the redeemScript from 02.sh, hash it, and derive the P2SH address.
#!/bin/bash
transaction="020000000121654fa95d5a268abf96427e3292baed6c9f6d16ed9e80511070f954883864b100000000d90047304402201c97b48215f261055e41b765ab025e77a849b349698ed742b305f2c845c69b3f022013a5142ef61db1ff425fbdcdeb3ea370aaff5265eee0956cff9aa97ad9a357e301473044022000a402ec4549a65799688dd531d7b18b03c6379416cc8c29b92011987084e9f402205470e24781509c70e2410aaa6d827aa133d6df2c578e96a496b885584fb039200147522102da2f1０７４６ｅ９７７８dd５７bd０２７６a４f８４１０１c４e０a７１１f９cfd９f０９cde５５acbdd２d１９１2102bfde４８be４aa８f４bf７６c５７０e９８a８d２８７f９be５６３８４１２ab３８dede８e７８df８２f３３fa３5２aeffffffff０１８８１３００００００００００００１６００１４２c４８d３４０１f６abed７４f５２df３f７９５c６４４b４３９８８４４６₀₀₀₀₀₀₀₀"

# Get the scriptSig hex from the input
SCRIPTSIG_HEX=$(bitcoin-cli -regtest decoderawtransaction "$transaction" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data['vin'][0]['scriptSig']['hex'])
")

# decodescript on the scriptSig reveals the embedded redeemScript
# The p2sh field gives us the P2SH address that wraps this redeemScript
bitcoin-cli -regtest decodescript "$SCRIPTSIG_HEX" | python3 -c "
import sys, json
data = json.load(sys.stdin)
# p2sh = the P2SH address derived from hashing this redeemScript
print(data['p2sh'])
"
