# Getting started with Hyperledger Fabric 2.2 LTS

### Pre-requsite for the tutorial

1. Install Docker
2. Install Docker Compose
3. JDK 11
4. NodeJs 16
5. Maven 3.X
6. Make
7. GCC
8. Git


### Install Binaries and Download Docker images.

1. Use the below script to install fabric 2.0.1 binaries and download docker images

```bash
./install-fabric.sh
```

### Running the Fabric 2.0 Art-NFT network

1. Go to the auction-network directory.

2. Use the network.sh script to run the test network using the below options.

```bash
Usage:
  network.sh <Mode> [Flags]
    <Mode>
      - 'up' - bring up fabric orderer and peer nodes for 3 orgs (Walmart, Supplier and Carrier) with CouchDB. No channel is created.
      - 'createChannel' - create and join a channel after the network is created. 3 channels are created - supplychain, carrierpayment & supplierpayment
      - 'deployCC' - deploy the chaincode on the channel
      - 'down' - clear the network with docker-compose down
      - 'api' - creates the client credentials and starts the api server.
      - 'restart' - restart the network
      - 'metrics' - starts hyperledger explorer service at port-8080.
      - 'kafka' - start kafka broker and create 2 kafka topics for integration.

    Flags:
    -c <channel name> - channel name to use
    -v <version>  - chaincode version. Must be a round number, 1, 2, 3, etc
    -verbose - verbose mode
    -cc <chaincode name> - Chaincode to be deployed. Chaincode should be present inside the chaincode folder. 
  network.sh -h (print this message)

 Possible Mode and flags
  network.sh up
  network.sh createChannel
  network.sh deployCC -c seller -cc fabcar
  network.sh kafka
  network.sh api
  network.sh metrics
  network.sh down

```
### API Server
API server provides a mechanism to integrated with concorde network using REST and kafka/event-hub.
It also provides a mechanism to stream chaincode events through kafka/event-hub.

Please refer to `application-template.yaml` file inside `config` folder to create a `application.yaml` file whick will configure the API server.

