

function createAuctionHouse {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/auctionhouse.art-nft.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-auctionhouse --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-auctionhouse.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-auctionhouse.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-auctionhouse.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-auctionhouse.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-auctionhouse --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-auctionhouse --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-auctionhouse --id.name auctionhouseadmin --id.secret auctionhouseadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/auctionhouse.art-nft.com/peers
  mkdir -p organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-auctionhouse -M ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/msp --csr.hosts peer0.auctionhouse.art-nft.com --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-auctionhouse -M ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls --enrollment.profile tls --csr.hosts peer0.auctionhouse.art-nft.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/tlsca/tlsca.auctionhouse.art-nft.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/ca
  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/peers/peer0.auctionhouse.art-nft.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/ca/ca.auctionhouse.art-nft.com-cert.pem

  mkdir -p organizations/peerOrganizations/auctionhouse.art-nft.com/users
  mkdir -p organizations/peerOrganizations/auctionhouse.art-nft.com/users/User1@auctionhouse.art-nft.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-auctionhouse -M ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/users/User1@auctionhouse.art-nft.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/auctionhouse.art-nft.com/users/Admin@auctionhouse.art-nft.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://auctionhouseadmin:auctionhouseadminpw@localhost:7054 --caname ca-auctionhouse -M ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/users/Admin@auctionhouse.art-nft.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/auctionhouse/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/auctionhouse.art-nft.com/users/Admin@auctionhouse.art-nft.com/msp/config.yaml

}


function createAuthenticator {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/authenticator.art-nft.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-authenticator --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-authenticator.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-authenticator.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-authenticator.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-authenticator.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-authenticator --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-authenticator --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-authenticator --id.name authenticatoradmin --id.secret authenticatoradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/authenticator.art-nft.com/peers
  mkdir -p organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-authenticator -M ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/msp --csr.hosts peer0.authenticator.art-nft.com --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-authenticator -M ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls --enrollment.profile tls --csr.hosts peer0.authenticator.art-nft.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/tlsca/tlsca.authenticator.art-nft.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/ca
  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/peers/peer0.authenticator.art-nft.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/ca/ca.authenticator.art-nft.com-cert.pem

  mkdir -p organizations/peerOrganizations/authenticator.art-nft.com/users
  mkdir -p organizations/peerOrganizations/authenticator.art-nft.com/users/User1@authenticator.art-nft.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-authenticator -M ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/users/User1@authenticator.art-nft.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/authenticator.art-nft.com/users/Admin@authenticator.art-nft.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://authenticatoradmin:authenticatoradminpw@localhost:8054 --caname ca-authenticator -M ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/users/Admin@authenticator.art-nft.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/authenticator/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/authenticator.art-nft.com/users/Admin@authenticator.art-nft.com/msp/config.yaml

}

function createAppraiser {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/appraiser.art-nft.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-appraiser --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-appraiser.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-appraiser.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-appraiser.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-appraiser.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-appraiser --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-appraiser --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-appraiser --id.name appraiseradmin --id.secret appraiseradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/appraiser.art-nft.com/peers
  mkdir -p organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-appraiser -M ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/msp --csr.hosts peer0.appraiser.art-nft.com --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-appraiser -M ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls --enrollment.profile tls --csr.hosts peer0.appraiser.art-nft.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/server.key

  mkdir ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/tlsca/tlsca.appraiser.art-nft.com-cert.pem

  mkdir ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/ca
  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/peers/peer0.appraiser.art-nft.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/ca/ca.appraiser.art-nft.com-cert.pem

  mkdir -p organizations/peerOrganizations/appraiser.art-nft.com/users
  mkdir -p organizations/peerOrganizations/appraiser.art-nft.com/users/User1@appraiser.art-nft.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-appraiser -M ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/users/User1@appraiser.art-nft.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x

  mkdir -p organizations/peerOrganizations/appraiser.art-nft.com/users/Admin@appraiser.art-nft.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://appraiseradmin:appraiseradminpw@localhost:10054 --caname ca-appraiser -M ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/users/Admin@appraiser.art-nft.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/appraiser/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/appraiser.art-nft.com/users/Admin@appraiser.art-nft.com/msp/config.yaml

}


function createOrderer {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/ordererOrganizations/art-nft.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/art-nft.com
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/art-nft.com/msp/config.yaml


  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

	mkdir -p organizations/ordererOrganizations/art-nft.com/orderers
  mkdir -p organizations/ordererOrganizations/art-nft.com/orderers/art-nft.com

  mkdir -p organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/msp --csr.hosts orderer.art-nft.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/art-nft.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls --enrollment.profile tls --csr.hosts orderer.art-nft.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/server.key

  mkdir ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/msp/tlscacerts/tlsca.art-nft.com-cert.pem

  mkdir ${PWD}/organizations/ordererOrganizations/art-nft.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/art-nft.com/orderers/orderer.art-nft.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/art-nft.com/msp/tlscacerts/tlsca.art-nft.com-cert.pem

  mkdir -p organizations/ordererOrganizations/art-nft.com/users
  mkdir -p organizations/ordererOrganizations/art-nft.com/users/Admin@art-nft.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/art-nft.com/users/Admin@art-nft.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/art-nft.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/art-nft.com/users/Admin@art-nft.com/msp/config.yaml


}
