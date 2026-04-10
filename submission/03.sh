#!/bin/bash
REDEEM_SCRIPT="522102da2f10746e9778dd57bd0276a4f84101c4e0a711f9cfd9f09cde55acbdd2d1912102bfde48be4aa8f4bf76c570e98a8d287f9be5638412ab38dede8e78df82f33fa352ae"

# decodescript on the redeemScript itself reveals:
# - p2sh: the P2SH address wrapping the redeemScript directly
# - segwit.p2sh-segwit: the P2SH address wrapping the WITNESS version
# The question asks for P2SH wrapping the WITNESS redeemScript
# That lives at: segwit -> p2sh-segwit field
bitcoin-cli -regtest decodescript "$REDEEM_SCRIPT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
# segwit field contains the SegWit version of this script
# p2sh-segwit inside segwit = P2SH address wrapping the witness script
print(data['segwit']['p2sh-segwit'])
"
