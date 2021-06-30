# Hyperledger Fabric REST Integration

### Description:-
<p>This component provides a mechanism to invoke and query fabric chaincode using a REST-based API interface.</br>
Additionally, it can also invoke chaincode using a asynchronous method and can publish chaincode events to Kafka/Event-Hub topics.</p>

## Key Feature:-</br>
1. Invoke Chaincode with REST.</br>
2. Query Chaincode with REST.</br>
3. Invoke Chaincode with Kafka/Event-Hub.</br>
4. Publish chaincode events from multiple channels to Kafka/Event-Hub.</br>

## Prerequisites:-</br>
1. Fabric 2.x network.</br>
2. Connection Profile YAML file.</br>
3. Wallet (.id) file.</br>
4. Java and Maven is installed.
5. (Optional) Kafka/Event-Hub configuration for invoking chaincode asynchronously.</br>
6. (Optional) Kafka/Event-Hub configuration for publishing chaincode events.</br>

## API Endpoints - Swagger Endpoint:-</br>
URL - [http://localhost:8081/hlf-rest-client/swagger-ui.html](http://localhost:8081/hlf-rest-client/swagger-ui.html)

## Event-driven Design
#### Asynchronous Integration to invoke chaincode
This component supports event-based architecture by consuming transactions through Kafka & Azure EventHub. 
To configure it, use the below configuration in the application.yml file.
```
Kafka:
  integration:
    brokerHost: <Hostname with Port>
    groupId: <Group ID>
    topic: <Topic Name>
    # For Azure EventHub
    jaasConfig: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=sb://<Hostname>/;SharedAccessKeyName=<key-name>;SharedAccessKey=<key-value>";
```
The component accepts JSON payload and 3 headers to invoke the chaincode.
Please find below the keys for the headers:-
```
1. channel_name
2. function_name
3. chaincode_name
```

#### Capture Chaincode events:-
This component supports capturing chaincode events and publish it to Kafka or Azure EventHub. This can be useful for integrating with offchain DB.
To configure it, use the below configuration in the application.yml file.
```
fabric:
  events:
    enabled: true
    chaincode: mychannel1,mychannel2  #Comma-separated list for listening to events from multiple channels 
Kafka:
  eventListener:
    brokerHost: <Hostname with Port>
    topic: <Topic Name>
    # For Azure EventHub
    jaasConfig: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=sb://<Hostname>/;SharedAccessKeyName=<key-name>;SharedAccessKey=<key-value>";
```
The component will send the same JSON payload sent by the chaincode and add the following headers.

```
1. fabric_tx_id
2. event_name
3. channel_name
4. event_type (value: chaincode_event)
```

#### Capture Block events:-
This component supports capturing block events and publish it to Kafka or Azure EventHub. This can be useful for integrating with offchain DB where adding events to chaincode is not possible (for ex - Food-Trust anchor channel).
To configure it, use the below configuration in the application.yml file.
```
fabric:
  events:
    enabled: true
    block: mychannel1,mychannel2  #Comma-separated list for listening to events from multiple channels 
Kafka:
  eventListener:
    brokerHost: <Hostname with Port>
    topic: <Topic Name>
    # For Azure EventHub
    jaasConfig: org.apache.kafka.common.security.plain.PlainLoginModule required username="$ConnectionString" password="Endpoint=sb://<Hostname>/;SharedAccessKeyName=<key-name>;SharedAccessKey=<key-value>";
```
The component will send the same JSON payload sent by the chaincode and add the following headers.

```
1. fabric_tx_id
2. channel_name
3. chaincode name
4. function_name
5. event_type (value: block_event)
```
