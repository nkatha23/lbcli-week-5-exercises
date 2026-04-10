#!/bin/bash
PUBKEY1="02da2f10746e9778dd57bd0276a4f84101c4e0a711f9cfd9f09cde55acbdd2d191"
PUBKEY2="02bfde48be4aa8f4bf76c570e98a8d287f9be5638412ab38dede8e78df82f33fa3"
PUBKEY3="02e3af28965693b9ce1228f9d468149b831d6a0540b25e8a9900f71372c11fb277"

# createmultisig builds the multisig address AND redeemScript
# 2 = minimum signatures required (2-of-3)
# We extract just the redeemScript hex field
bitcoin-cli -regtest createmultisig 2 \
  "[\"$PUBKEY1\",\"$PUBKEY2\",\"$PUBKEY3\"]" \
  | grep -oP '"redeemScript":\s*"\K[^"]+'



# What's a redeemScript?
# P2SH address = HASH160(redeemScript)

# redeemScript for 2-of-3 multisig looks like:
# OP_2 <pubkey1> <pubkey2> <pubkey3> OP_3 OP_CHECKMULTISIG

# In hex:
# 52 = OP_2
# 21 = push 33 bytes (compressed pubkey length)
# <33 bytes pubkey1>
# 21 <33 bytes pubkey2>
# 21 <33 bytes pubkey3>
# 53 = OP_3
# ae = OP_CHECKMULTISIG