#!/bin/bash
REDEEM_SCRIPT="522102da2f10746e9778dd57bd0276a4f84101c4e0a711f9cfd9f09cde55acbdd2d1912102bfde48be4aa8f4bf76c570e98a8d287f9be5638412ab38dede8e78df82f33fa352ae"

# decodescript takes a raw script hex and derives addresses from it
# p2sh field = the P2SH address you get by hashing this redeemScript
# This is how P2SH works: hash the redeemScript → that hash IS the address
bitcoin-cli -regtest decodescript "$REDEEM_SCRIPT" \
  | grep -oP '"p2sh":\s*"\K[^"]+'
