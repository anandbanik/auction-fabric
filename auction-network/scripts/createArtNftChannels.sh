#!/bin/bash

DELAY="$1"
MAX_RETRY="$2"
VERBOSE="$3"
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}

# import utils
. scripts/envVar.sh

if [ ! -d "channel-artifacts" ]; then
	mkdir channel-artifacts
fi


createChannelTx() {

    CHANNEL_PROFILE=$1
    CHANNEL_NAME=$2

    echo "Generating ChannelTX configuration for Profile - ${CHANNEL_PROFILE} in channel - ${CHANNEL_NAME}"
	set -x
	configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME}
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate channel configuration transaction..."
		exit 1
	fi
	echo
}

createAnchorPeerTx() {

    orgmsp=$1
    CHANNEL_NAME=$2
    CHANNEL_PROFILE=$3

	echo "#######    Generating anchor peer update for ${orgmsp} for channel ${CHANNEL_NAME} ##########"
	set -x
	configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/${orgmsp}anchors.tx -channelID ${CHANNEL_NAME} -asOrg ${orgmsp}
	res=$?
	set +x
	if [ $res -ne 0 ]; then
		echo "Failed to generate anchor peer update for ${orgmsp}..."
		exit 1
	fi
	echo

}

createChannel() {
	setGlobals "AuctionHouse"
    CHANNEL_NAME=$1
	# Poll in case the raft leader is not set yet
	local rc=1
	local COUNTER=1
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
		sleep $DELAY
		if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        set -x
				peer channel create -o localhost:7050 -c ${CHANNEL_NAME} -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block >&log.txt
				res=$?
        set +x
		else
				set -x
				peer channel create -o localhost:7050 -c ${CHANNEL_NAME} --ordererTLSHostnameOverride orderer.art-nft.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
				res=$?
				set +x
		fi
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo
	echo "===================== Channel '${CHANNEL_NAME}' created ===================== "
	echo
}

joinChannel() {
  ORG=$1
  CHANNEL_NAME=$2
  setGlobals $ORG
	local rc=1
	local COUNTER=1
	## Sometimes Join takes time, hence retry
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    set -x
    peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
	cat log.txt
	echo
	verifyResult $res "After $MAX_RETRY attempts, ${ORG} has failed to join channel '${CHANNEL_NAME}' "
}

updateAnchorPeers() {
  ORG=$1
  CHANNEL_NAME=$2
  setGlobals $ORG

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.art-nft.com -c ${CHANNEL_NAME} -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx >&log.txt
    res=$?
    set +x
  else
    set -x
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.art-nft.com -c ${CHANNEL_NAME} -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Anchor peer update failed"
  echo "===================== Anchor peers updated for org '$CORE_PEER_LOCALMSPID' on channel '${CHANNEL_NAME}' ===================== "
  sleep $DELAY
  echo
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}


FABRIC_CFG_PATH=${PWD}/configtx

## Create channeltx for channel seller
echo "### Generating channeltx configuration transaction for ArtNft network ###"
createChannelTx "SellerChannel" "seller"
createChannelTx "AuthenticationChannel" "authentication"
createChannelTx "AppraisalChannel" "appraisal"


## Create anchorpeertx
echo "### Generating anchorpeertx configuration transactions for seller channel ###"
createAnchorPeerTx "AuctionHouseMSP" "seller" "SellerChannel"
createAnchorPeerTx "AuthenticatorMSP" "seller" "SellerChannel"
createAnchorPeerTx "AppraiserMSP" "seller" "SellerChannel"

FABRIC_CFG_PATH=$PWD/../config/

## Create channel
echo "Creating channels seller"
createChannel "seller"
echo "Join AuctionHouse peers to the channel seller"
joinChannel "AuctionHouse" "seller"
echo "Updating anchor peers for channel seller for AuctionHouse"
updateAnchorPeers "AuctionHouse" "seller"
echo "Join Authenticator peers to the channel...seller"
joinChannel "Authenticator" "seller"
echo "Updating anchor peers for channel seller for Authenticator"
updateAnchorPeers "Authenticator" "seller"
echo "Join Appraiser peers to the channel...seller"
joinChannel "Appraiser" "seller"
echo "Updating anchor peers for channel seller for Appraiser"
updateAnchorPeers "Appraiser" "seller"
echo
echo "========= Channel seller successfully joined =========== "
echo

FABRIC_CFG_PATH=${PWD}/configtx
echo "### Generating anchorpeertx configuration transactions for authentication channel ###"
createAnchorPeerTx "AuctionHouseMSP" "authentication" "AuthenticationChannel"
createAnchorPeerTx "AuthenticatorMSP" "authentication" "AuthenticationChannel"

FABRIC_CFG_PATH=$PWD/../config/
echo "Creating channels authentication"
createChannel "authentication"
echo "Join AuctionHouse peers to the channel authentication"
joinChannel "AuctionHouse" "authentication"
echo "Updating anchor peers for authentication for AuctionHouse"
updateAnchorPeers "AuctionHouse" "authentication"
echo "Join Authenticator peers to the channel...authentication"
joinChannel "Authenticator" "authentication"
echo "Updating anchor peers for authentication for Authenticator"
updateAnchorPeers "Authenticator" "authentication"
echo
echo "========= Channel authentication successfully joined =========== "
echo

FABRIC_CFG_PATH=${PWD}/configtx
echo "### Generating anchorpeertx configuration transactions for appraisal channel ###"
createAnchorPeerTx "AuctionHouseMSP" "appraisal" "AppraisalChannel"
createAnchorPeerTx "AppraiserMSP" "appraisal" "AppraisalChannel"
FABRIC_CFG_PATH=$PWD/../config/
echo "Creating channels appraisal"
createChannel "appraisal"
echo "Join AuctionHouse peers to the channel appraisal"
joinChannel "AuctionHouse" "appraisal"
echo "Updating anchor peers for appraisal for AuctionHouse"
updateAnchorPeers "AuctionHouse" "appraisal"
echo "Join Appraiser peers to the channel...appraisal"
joinChannel "Appraiser" "appraisal"
echo "Updating anchor peers for appraisal for Appraiser"
updateAnchorPeers "Appraiser" "appraisal"
echo
echo "========= Channel appraisal successfully joined =========== "
echo
exit 0