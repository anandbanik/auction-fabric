#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${ORG_URL}#$6#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${ORG_URL}#$6#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

function yaml_ccp_ext {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        -e "s#\${ORG_URL}#$6#" \
        organizations/ccp-template-ext.yaml | sed -e $'s/\\\\n/\\\n        /g'
}

ORG=AuctionHouse
ORG_URL=auctionhouse
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/auctionhouse.art-nft.com/tlsca/tlsca.auctionhouse.art-nft.com-cert.pem
CAPEM=organizations/peerOrganizations/auctionhouse.art-nft.com/ca/ca.auctionhouse.art-nft.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/auctionhouse.art-nft.com/connection-auctionhouse.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/auctionhouse.art-nft.com/connection-auctionhouse.yaml
echo "$(yaml_ccp_ext $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/auctionhouse.art-nft.com/connection-auctionhouse-ext.yaml

ORG=Authenticator
ORG_URL=authenticator
P0PORT=9051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/authenticator.art-nft.com/tlsca/tlsca.authenticator.art-nft.com-cert.pem
CAPEM=organizations/peerOrganizations/authenticator.art-nft.com/ca/ca.authenticator.art-nft.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/authenticator.art-nft.com/connection-authenticator.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/authenticator.art-nft.com/connection-authenticator.yaml
echo "$(yaml_ccp_ext $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/authenticator.art-nft.com/connection-authenticator-ext.yaml

ORG=Appraiser
ORG_URL=appraiser
P0PORT=10051
CAPORT=10054
PEERPEM=organizations/peerOrganizations/appraiser.art-nft.com/tlsca/tlsca.appraiser.art-nft.com-cert.pem
CAPEM=organizations/peerOrganizations/appraiser.art-nft.com/ca/ca.appraiser.art-nft.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/appraiser.art-nft.com/connection-appraiser.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/appraiser.art-nft.com/connection-appraiser.yaml
echo "$(yaml_ccp_ext $ORG $P0PORT $CAPORT $PEERPEM $CAPEM $ORG_URL)" > organizations/peerOrganizations/appraiser.art-nft.com/connection-appraiser-ext.yaml