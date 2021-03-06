'use strict';

const { Wallets, Gateway, X509WalletMixin } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const fs = require('fs');
const path = require('path');

async function main() {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..','organizations','peerOrganizations','auctionhouse.art-nft.com', 'connection-auctionhouse.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new CA client for interacting with the CA.
        const caURL = ccp.certificateAuthorities['ca.auctionhouse.art-nft.com'].url;
        const ca = new FabricCAServices(caURL);

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);
        console.log(`Wallet path: ${walletPath}`);

        // Check to see if we've already enrolled the user.
        const userExists = await wallet.get('clientUser');
        if (userExists) {
            console.log('An identity for the user "clientUser" already exists in the wallet');
            return;
        }

        // Check to see if we've already enrolled the admin user.
        const adminIdentity = await wallet.get('admin');
        if (!adminIdentity) {
            console.log('An identity for the admin user "admin" does not exist in the wallet');
            console.log('Run the enrollAdmin.js application before retrying');
            return;
        }

        // build a user object for authenticating with the CA
        const provider = wallet.getProviderRegistry().getProvider(adminIdentity.type);
        const adminUser = await provider.getUserContext(adminIdentity, 'admin');
        //adminUser.setAffiliation('auctionhouse.supplychain');

        /*
        ca.revoke({
            enrollmentID: 'clientUser',
            reason: 'testing'
        }, adminUser);
        */

        // Register the user, enroll the user, and import the new identity into the wallet.
        
        const secret = await ca.register({
            //affiliation: 'org1.department1',
            enrollmentID: 'clientUser',
            role: 'client'
        }, adminUser);
        const enrollment = await ca.enroll({
            enrollmentID: 'clientUser',
            enrollmentSecret: secret
        });
        const x509Identity = {
            credentials: {
                certificate: enrollment.certificate,
                privateKey: enrollment.key.toBytes(),
            },
            mspId: 'AuctionHouseMSP',
            type: 'X.509',
        };

        await wallet.put('clientUser', x509Identity);
        console.log('Successfully registered and enrolled admin user "clientUser" and imported it into the wallet');

    } catch (error) {
        console.error(`Failed to register user "clientUser": ${error}`);
        process.exit(1);
    }
}

main();