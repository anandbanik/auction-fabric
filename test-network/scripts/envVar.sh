#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/msp/tlscacerts/tlsca.art-nft.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/ca.crt

# This is a workaround for Line76. Need to find an elegant solution
export PEER0_ORGAuctionHouse_CA=${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/ca.crt
export PEER0_ORGAuthenticator_CA=${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/ca.crt
export PEER0_ORGAppraiser_CA=${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/msp/tlscacerts/tlsca.art-nft.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/ordererOrganizations/art-nft.com/users/Admin@art-nft.com/msp
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"  
  fi
  echo "Using organization ${USING_ORG}"
  if [ $USING_ORG = "AuctionHouse" ]; then
    export CORE_PEER_LOCALMSPID="${USING_ORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/users/Admin@auctionhouse.art-nft.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG = "Authenticator" ]; then
    export CORE_PEER_LOCALMSPID="${USING_ORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/users/Admin@authenticator.art-nft.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

  elif [ $USING_ORG = "Appraiser" ]; then
    export CORE_PEER_LOCALMSPID="${USING_ORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/users/Admin@appraiser.art-nft.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that takes the parameters from a chaincode operation
# (e.g. invoke, query, instantiate) and checks for an even number of
# peers and associated org, then sets $PEER_CONN_PARMS and $PEERS
parsePeerConnectionParameters() {
  # check for uneven number of peer and org parameters

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "true" ]; then
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    fi
    # shift by two to get the next pair of peer/org parameters
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}
