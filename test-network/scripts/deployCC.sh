
CHANNEL_NAME="$1"
CHAINCODE_NAME="$2"
CC_RUNTIME_LANGUAGE="$3"
VERSION="$4"
DELAY="$5"
MAX_RETRY="$6"
VERBOSE="$7"
CC_END_POLICY="$8"
CC_COLL_CONFIG="$9"
: ${CHANNEL_NAME:="mychannel"}
: ${CHAINCODE_NAME:="fabcar"}
: ${CC_RUNTIME_LANGUAGE:="java"}
: ${VERSION:="1"}
: ${DELAY:="3"}
: ${MAX_RETRY:="5"}
: ${VERBOSE:="false"}
: ${CC_END_POLICY:="NA"}
: ${CC_COLL_CONFIG:="NA"}
CC_RUNTIME_LANGUAGE=`echo "$CC_RUNTIME_LANGUAGE" | tr [:upper:] [:lower:]`

FABRIC_CFG_PATH=$PWD/../config/

if [ "$CC_RUNTIME_LANGUAGE" = "go" -o "$CC_RUNTIME_LANGUAGE" = "golang" ] ; then
	CC_RUNTIME_LANGUAGE=golang
	CC_SRC_PATH="../chaincode/fabcar/go/"

	echo Vendoring Go dependencies ...
	pushd ../chaincode/fabcar/go
	GO111MODULE=on go mod vendor
	popd
	echo Finished vendoring Go dependencies

elif [ "$CC_RUNTIME_LANGUAGE" = "javascript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH="../chaincode/fabcar/javascript/"

elif [ "$CC_RUNTIME_LANGUAGE" = "java" ]; then
	CC_RUNTIME_LANGUAGE=java
	CC_SRC_PATH="../chaincode/${CHAINCODE_NAME}/install"

  if [ ! -d "../chaincode/${CHAINCODE_NAME}/src" ]; then
    echo "Incorrect Chaincode name or Chaincode folder does not exists"
    exit 1
  fi

	echo Compiling Java code ...
	pushd ../chaincode/${CHAINCODE_NAME}
  mvn clean package
  rm -rf ./install
  mkdir install
  cp $(find ./target/ -maxdepth 1 -type f -iname '*deploy.jar') ./install
	popd
	echo Finished compiling Java code

else
	echo The chaincode language ${CC_RUNTIME_LANGUAGE} is not supported by this script
	echo Supported chaincode languages are: go, javascript, java
	exit 1
fi

# import utils
. scripts/envVar.sh

# For PDC
echo "Policy: ${CC_END_POLICY} and Collection: ${CC_COLL_CONFIG}"
if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

packageChaincode() {
  ORG=$1
  setGlobals $ORG
  set -x
  peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CHAINCODE_NAME}_${VERSION} >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode packaging on peer0.org${ORG} has failed"
  echo "===================== Chaincode is packaged on peer0.org${ORG} ===================== "
  echo
}

# installChaincode PEER ORG
installChaincode() {
  ORG=$1
  setGlobals $ORG
  set -x
  peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz >&log.txt
  res=$?
  set +x
  cat log.txt
  verifyResult $res "Chaincode installation on peer0.${ORG} has failed"
  echo "===================== Chaincode is installed on peer0.${ORG} ===================== "
  echo
}

# queryInstalled PEER ORG
queryInstalled() {
  ORG=$1
  setGlobals $ORG
  set -x
  peer lifecycle chaincode queryinstalled >&log.txt
  res=$?
  set +x
  cat log.txt
	PACKAGE_ID=$(sed -n "/${CHAINCODE_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
  verifyResult $res "Query installed on peer0.${ORG} has failed"
  echo PackageID is ${PACKAGE_ID}
  echo "===================== Query installed successful on peer0.${ORG} on channel ===================== "
  echo
}

# approveForMyOrg VERSION PEER ORG
approveForMyOrg() {
  ORG=$1
  setGlobals $ORG

  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ] ; then
    set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION} --waitForEvent >&log.txt
    set +x
  else
    set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.art-nft.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${VERSION} --init-required --package-id ${PACKAGE_ID} --sequence ${VERSION} ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    set +x
  fi
  cat log.txt
  verifyResult $res "Chaincode definition approved on peer0.${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode definition approved on peer0.${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo
}

# checkCommitReadiness VERSION PEER ORG
checkCommitReadiness() {
  ORG=$1
  shift 1
  setGlobals $ORG
  echo "===================== Checking the commit readiness of the chaincode definition on peer0.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local COUNTER=1
	# continue to poll
  # we either get a successful response, or reach MAX RETRY
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to check the commit readiness of the chaincode definition on peer0.org${ORG} secs"
    set -x
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} --version ${VERSION} --sequence ${VERSION} ${CC_END_POLICY} ${CC_COLL_CONFIG} --output json --init-required >&log.txt
    res=$?
    set +x
		#test $res -eq 0 || continue
    let rc=0
    for var in "$@"
    do
      grep "$var" log.txt &>/dev/null || let rc=1
    done
		COUNTER=$(expr $COUNTER + 1)
	done
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Checking the commit readiness of the chaincode definition successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Check commit readiness result on peer0.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

# commitChaincodeDefinition VERSION PEER ORG (PEER ORG)...
commitChaincodeDefinition() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ] ; then
    set -x
    peer lifecycle chaincode commit -o localhost:7050 --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} --init-required >&log.txt
    res=$?
    set +x
  else
    set -x
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.art-nft.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} $PEER_CONN_PARMS --version ${VERSION} --sequence ${VERSION} --init-required ${CC_END_POLICY} ${CC_COLL_CONFIG} >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Chaincode definition commit failed on peer0.org${ORG} on channel '$CHANNEL_NAME' failed"
  echo "===================== Chaincode definition committed on channel '$CHANNEL_NAME' ===================== "
  echo
}

# queryCommitted ORG
queryCommitted() {
  ORG=$1
  setGlobals $ORG
  EXPECTED_RESULT="Version: ${VERSION}, Sequence: ${VERSION}, Endorsement Plugin: escc, Validation Plugin: vscc"
  echo "===================== Querying chaincode definition on peer0.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local COUNTER=1
	# continue to poll
  # we either get a successful response, or reach MAX RETRY
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to Query committed status on peer0.org${ORG}, Retry after $DELAY seconds."
    set -x
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CHAINCODE_NAME} >&log.txt
    res=$?
    set +x
		test $res -eq 0 && VALUE=$(cat log.txt | grep -o '^Version: [0-9], Sequence: [0-9], Endorsement Plugin: escc, Validation Plugin: vscc')
    test "$VALUE" = "$EXPECTED_RESULT" && let rc=0
		COUNTER=$(expr $COUNTER + 1)
	done
  echo
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query chaincode definition successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
		echo
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Query chaincode definition result on peer0.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

chaincodeInvokeInit() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o localhost:7050 -C $CHANNEL_NAME -n ${CHAINCODE_NAME} $PEER_CONN_PARMS --isInit -c '{"function":"initLedger","Args":[]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.art-nft.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CHAINCODE_NAME} $PEER_CONN_PARMS --isInit -c '{"function":"initLedger","Args":[]}' >&log.txt
    res=$?
    set +x
  fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
}

chaincodeInvoke() {
  parsePeerConnectionParameters $@
  res=$?
  verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

  # while 'peer chaincode' command can get the orderer endpoint from the
  # peer (if join was successful), let's supply it directly as we know
  # it using the "-o" option
  if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
    set -x
    peer chaincode invoke -o localhost:7050 -C $CHANNEL_NAME -n ${CHAINCODE_NAME} $PEER_CONN_PARMS  -c '{"function":"initLedger","Args":[]}' >&log.txt
    res=$?
    set +x
  else
    set -x
    peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.art-nft.com --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CHAINCODE_NAME} $PEER_CONN_PARMS -c '{"function":"initLedger","Args":[]}' >&log.txt
    res=$?
    set +x
	fi
  cat log.txt
  verifyResult $res "Invoke execution on $PEERS failed "
  echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
  echo
}

chaincodeQuery() {
  ORG=$1
  setGlobals $ORG
  echo "===================== Querying on peer0.org${ORG} on channel '$CHANNEL_NAME'... ===================== "
	local rc=1
	local COUNTER=1
	# continue to poll
  # we either get a successful response, or reach MAX RETRY
	while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ] ; do
    sleep $DELAY
    echo "Attempting to Query peer0.org${ORG} ...$(($(date +%s) - starttime)) secs"
    set -x
    peer chaincode query -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["health"]}' >&log.txt
    res=$?
    set +x
		let rc=$res
		COUNTER=$(expr $COUNTER + 1)
	done
  echo
  cat log.txt
  if test $rc -eq 0; then
    echo "===================== Query successful on peer0.org${ORG} on channel '$CHANNEL_NAME' ===================== "
		echo
  else
    echo "!!!!!!!!!!!!!!! After $MAX_RETRY attempts, Query result on peer0.org${ORG} is INVALID !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}

## at first we package the chaincode
packageChaincode "AuctionHouse"

## Install chaincode on peer0.org1 and peer0.org2
if [ "$CHANNEL_NAME" == "authentication" ]; then
  echo "Installing chaincode on AuctionHouse Peers..."
  installChaincode "AuctionHouse"
  echo "Install chaincode on Authenticator Peers..."
  installChaincode "Authenticator"
elif [ "$CHANNEL_NAME" == "appraisal" ]; then
  echo "Installing chaincode on AuctionHouse Peers..."
  installChaincode "AuctionHouse"
  echo "Install chaincode on Appraiser Peers..."
  installChaincode "Appraiser"
else
  echo "Installing chaincode on AuctionHouse Peers..."
  installChaincode "AuctionHouse"
  echo "Install chaincode on Authenticator Peers..."
  installChaincode "Authenticator"
  echo "Install chaincode on Appraiser Peers..."
  installChaincode "Appraiser"
fi
## query whether the chaincode is installed
queryInstalled "AuctionHouse"

if [ "$CHANNEL_NAME" == "authentication" ]; then
  ## approve the definition for AuctionHouse
  approveForMyOrg "AuctionHouse"
  ## now approve also for Authenticator
  approveForMyOrg "Authenticator"  
elif [ "$CHANNEL_NAME" == "appraisal" ]; then
  ## approve the definition for AuctionHouse
  approveForMyOrg "AuctionHouse"
  ## now approve also for Appraiser
  approveForMyOrg "Appraiser"
else
  ## approve the definition for AuctionHouse
  approveForMyOrg "AuctionHouse"
  ## now approve also for Authenticator
  approveForMyOrg "Authenticator"
  ## now approve also for Appraiser
  approveForMyOrg "Appraiser"
fi


## now that we know for sure both orgs have approved, commit the definition
if [ "$CHANNEL_NAME" == "authentication" ]; then
  commitChaincodeDefinition "AuctionHouse" "Authenticator"
elif [ "$CHANNEL_NAME" == "appraisal" ]; then
  commitChaincodeDefinition "AuctionHouse" "Appraiser"
else
  commitChaincodeDefinition "AuctionHouse" "Authenticator" "Appraiser"
fi


## query on both orgs to see that the definition committed successfully
if [ "$CHANNEL_NAME" == "authentication" ]; then
  queryCommitted "AuctionHouse"
  queryCommitted "Authenticator"
elif [ "$CHANNEL_NAME" == "appraisal" ]; then
  queryCommitted "AuctionHouse"
  queryCommitted "Appraiser"
else
  queryCommitted "AuctionHouse"
  queryCommitted "Authenticator"
  queryCommitted "Appraiser"
fi
## Invoke the chaincode
if [ "$CHANNEL_NAME" == "authentication" ]; then
  chaincodeInvokeInit "AuctionHouse" "Authenticator"
elif [ "$CHANNEL_NAME" == "appraisal" ]; then
  chaincodeInvokeInit "AuctionHouse" "Appraiser"
else 
  chaincodeInvokeInit "AuctionHouse" "Authenticator" "Appraiser"
fi

sleep 10

## Invoke the chaincode
if [ "$CHANNEL_NAME" == "authentication" ]; then
  chaincodeInvoke "AuctionHouse" "Authenticator"
elif [ "$CHANNEL_NAME" == "appraisal" ]; then
  chaincodeInvoke "AuctionHouse" "Appraiser"
else
  chaincodeInvoke "AuctionHouse" "Authenticator" "Appraiser"
fi

# Query chaincode on peer0.org1
echo "Querying chaincode on peer0.org1..."
chaincodeQuery "AuctionHouse"

exit 0
