#!/bin/bash

export FABRIC_CFG_PATH=$PWD/../config/
export PATH=${PWD}/../bin:$PATH

mkdir channel-artifacts/peer0-org1/
mkdir channel-artifacts/peer0-org2/
mkdir channel-artifacts/peer1-org2/
mkdir channel-artifacts/peer0-org3/
mkdir channel-artifacts/peer1-org3/
mkdir channel-artifacts/peer0-org4/
mkdir channel-artifacts/peer1-org4/
mkdir channel-artifacts/peer0-org5/
mkdir channel-artifacts/peer1-org5/
mkdir channel-artifacts/peer0-org6/




#组织一
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel fetch config channel-artifacts/peer0-org1/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer0-org1/config_block.pb --type common.Block --output channel-artifacts/peer0-org1/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer0-org1/config_block.json > channel-artifacts/peer0-org1/config.json
cp channel-artifacts/peer0-org1/config.json channel-artifacts/peer0-org1/config_copy.json

jq '.channel_group.groups.Application.groups.Org1MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org1.example.com","port": 7051}]},"version": "0"}}' channel-artifacts/peer0-org1/config_copy.json > channel-artifacts/peer0-org1/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer0-org1/config.json --type common.Config --output channel-artifacts/peer0-org1/config.pb
configtxlator proto_encode --input channel-artifacts/peer0-org1/modified_config.json --type common.Config --output channel-artifacts/peer0-org1/modified_config.pb
configtxlator compute_update --channel_id channel1 --original channel-artifacts/peer0-org1/config.pb --updated channel-artifacts/peer0-org1/modified_config.pb --output channel-artifacts/peer0-org1/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer0-org1/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer0-org1/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer0-org1/config_update.json)'}}}' | jq . > channel-artifacts/peer0-org1/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer0-org1/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer0-org1/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer0-org1/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem





#组织二
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer channel fetch config channel-artifacts/peer0-org2/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer0-org2/config_block.pb --type common.Block --output channel-artifacts/peer0-org2/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer0-org2/config_block.json > channel-artifacts/peer0-org2/config.json
cp channel-artifacts/peer0-org2/config.json channel-artifacts/peer0-org2/config_copy.json

jq '.channel_group.groups.Application.groups.Org2MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org2.example.com","port": 9051}]},"version": "0"}}' channel-artifacts/peer0-org2/config_copy.json > channel-artifacts/peer0-org2/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer0-org2/config.json --type common.Config --output channel-artifacts/peer0-org2/config.pb
configtxlator proto_encode --input channel-artifacts/peer0-org2/modified_config.json --type common.Config --output channel-artifacts/peer0-org2/modified_config.pb
configtxlator compute_update --channel_id channel1 --original channel-artifacts/peer0-org2/config.pb --updated channel-artifacts/peer0-org2/modified_config.pb --output channel-artifacts/peer0-org2/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer0-org2/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer0-org2/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel1", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer0-org2/config_update.json)'}}}' | jq . > channel-artifacts/peer0-org2/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer0-org2/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer0-org2/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer0-org2/config_update_in_envelope.pb -c channel1 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#2-----
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9053

peer channel fetch config channel-artifacts/peer1-org2/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer1-org2/config_block.pb --type common.Block --output channel-artifacts/peer1-org2/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer1-org2/config_block.json > channel-artifacts/peer1-org2/config.json
cp channel-artifacts/peer1-org2/config.json channel-artifacts/peer1-org2/config_copy.json

jq '.channel_group.groups.Application.groups.Org2MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer1.org2.example.com","port": 9053}]},"version": "0"}}' channel-artifacts/peer1-org2/config_copy.json > channel-artifacts/peer1-org2/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer1-org2/config.json --type common.Config --output channel-artifacts/peer1-org2/config.pb
configtxlator proto_encode --input channel-artifacts/peer1-org2/modified_config.json --type common.Config --output channel-artifacts/peer1-org2/modified_config.pb
configtxlator compute_update --channel_id channel2 --original channel-artifacts/peer1-org2/config.pb --updated channel-artifacts/peer1-org2/modified_config.pb --output channel-artifacts/peer1-org2/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer1-org2/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer1-org2/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel2", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer1-org2/config_update.json)'}}}' | jq . > channel-artifacts/peer1-org2/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer1-org2/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer1-org2/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer1-org2/config_update_in_envelope.pb -c channel2 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#组织三
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org3MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
export CORE_PEER_ADDRESS=localhost:9071

peer channel fetch config channel-artifacts/peer0-org3/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel3 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer0-org3/config_block.pb --type common.Block --output channel-artifacts/peer0-org3/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer0-org3/config_block.json > channel-artifacts/peer0-org3/config.json
cp channel-artifacts/peer0-org3/config.json channel-artifacts/peer0-org3/config_copy.json

jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org3.example.com","port": 9071}]},"version": "0"}}' channel-artifacts/peer0-org3/config_copy.json > channel-artifacts/peer0-org3/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer0-org3/config.json --type common.Config --output channel-artifacts/peer0-org3/config.pb
configtxlator proto_encode --input channel-artifacts/peer0-org3/modified_config.json --type common.Config --output channel-artifacts/peer0-org3/modified_config.pb
configtxlator compute_update --channel_id channel3 --original channel-artifacts/peer0-org3/config.pb --updated channel-artifacts/peer0-org3/modified_config.pb --output channel-artifacts/peer0-org3/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer0-org3/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer0-org3/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel3", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer0-org3/config_update.json)'}}}' | jq . > channel-artifacts/peer0-org3/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer0-org3/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer0-org3/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer0-org3/config_update_in_envelope.pb -c channel3 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#3-----
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org3MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
export CORE_PEER_ADDRESS=localhost:9073

peer channel fetch config channel-artifacts/peer1-org3/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer1-org3/config_block.pb --type common.Block --output channel-artifacts/peer1-org3/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer1-org3/config_block.json > channel-artifacts/peer1-org3/config.json
cp channel-artifacts/peer1-org3/config.json channel-artifacts/peer1-org3/config_copy.json

jq '.channel_group.groups.Application.groups.Org3MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer1.org3.example.com","port": 9073}]},"version": "0"}}' channel-artifacts/peer1-org3/config_copy.json > channel-artifacts/peer1-org3/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer1-org3/config.json --type common.Config --output channel-artifacts/peer1-org3/config.pb
configtxlator proto_encode --input channel-artifacts/peer1-org3/modified_config.json --type common.Config --output channel-artifacts/peer1-org3/modified_config.pb
configtxlator compute_update --channel_id channel2 --original channel-artifacts/peer1-org3/config.pb --updated channel-artifacts/peer1-org3/modified_config.pb --output channel-artifacts/peer1-org3/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer1-org3/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer1-org3/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel2", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer1-org3/config_update.json)'}}}' | jq . > channel-artifacts/peer1-org3/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer1-org3/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer1-org3/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer1-org3/config_update_in_envelope.pb -c channel2 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#组织四
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org4MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
export CORE_PEER_ADDRESS=localhost:8001

peer channel fetch config channel-artifacts/peer0-org4/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel4 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer0-org4/config_block.pb --type common.Block --output channel-artifacts/peer0-org4/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer0-org4/config_block.json > channel-artifacts/peer0-org4/config.json
cp channel-artifacts/peer0-org4/config.json channel-artifacts/peer0-org4/config_copy.json

jq '.channel_group.groups.Application.groups.Org4MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org4.example.com","port": 8001}]},"version": "0"}}' channel-artifacts/peer0-org4/config_copy.json > channel-artifacts/peer0-org4/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer0-org4/config.json --type common.Config --output channel-artifacts/peer0-org4/config.pb
configtxlator proto_encode --input channel-artifacts/peer0-org4/modified_config.json --type common.Config --output channel-artifacts/peer0-org4/modified_config.pb
configtxlator compute_update --channel_id channel4 --original channel-artifacts/peer0-org4/config.pb --updated channel-artifacts/peer0-org4/modified_config.pb --output channel-artifacts/peer0-org4/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer0-org4/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer0-org4/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel4", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer0-org4/config_update.json)'}}}' | jq . > channel-artifacts/peer0-org4/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer0-org4/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer0-org4/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer0-org4/config_update_in_envelope.pb -c channel4 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#4-----
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org4MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer1.org4.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
export CORE_PEER_ADDRESS=localhost:8003

peer channel fetch config channel-artifacts/peer1-org4/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel3 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer1-org4/config_block.pb --type common.Block --output channel-artifacts/peer1-org4/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer1-org4/config_block.json > channel-artifacts/peer1-org4/config.json
cp channel-artifacts/peer1-org4/config.json channel-artifacts/peer1-org4/config_copy.json

jq '.channel_group.groups.Application.groups.Org4MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer1.org4.example.com","port": 8003}]},"version": "0"}}' channel-artifacts/peer1-org4/config_copy.json > channel-artifacts/peer1-org4/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer1-org4/config.json --type common.Config --output channel-artifacts/peer1-org4/config.pb
configtxlator proto_encode --input channel-artifacts/peer1-org4/modified_config.json --type common.Config --output channel-artifacts/peer1-org4/modified_config.pb
configtxlator compute_update --channel_id channel3 --original channel-artifacts/peer1-org4/config.pb --updated channel-artifacts/peer1-org4/modified_config.pb --output channel-artifacts/peer1-org4/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer1-org4/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer1-org4/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel3", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer1-org4/config_update.json)'}}}' | jq . > channel-artifacts/peer1-org4/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer1-org4/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer1-org4/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer1-org4/config_update_in_envelope.pb -c channel3 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#组织五
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org5MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
export CORE_PEER_ADDRESS=localhost:8031

peer channel fetch config channel-artifacts/peer0-org5/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel5 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer0-org5/config_block.pb --type common.Block --output channel-artifacts/peer0-org5/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer0-org5/config_block.json > channel-artifacts/peer0-org5/config.json
cp channel-artifacts/peer0-org5/config.json channel-artifacts/peer0-org5/config_copy.json

jq '.channel_group.groups.Application.groups.Org5MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org5.example.com","port": 8031}]},"version": "0"}}' channel-artifacts/peer0-org5/config_copy.json > channel-artifacts/peer0-org5/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer0-org5/config.json --type common.Config --output channel-artifacts/peer0-org5/config.pb
configtxlator proto_encode --input channel-artifacts/peer0-org5/modified_config.json --type common.Config --output channel-artifacts/peer0-org5/modified_config.pb
configtxlator compute_update --channel_id channel5 --original channel-artifacts/peer0-org5/config.pb --updated channel-artifacts/peer0-org5/modified_config.pb --output channel-artifacts/peer0-org5/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer0-org5/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer0-org5/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel5", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer0-org5/config_update.json)'}}}' | jq . > channel-artifacts/peer0-org5/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer0-org5/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer0-org5/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer0-org5/config_update_in_envelope.pb -c channel5 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#5-----
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org5MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer1.org5.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
export CORE_PEER_ADDRESS=localhost:8033

peer channel fetch config channel-artifacts/peer1-org5/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel4 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer1-org5/config_block.pb --type common.Block --output channel-artifacts/peer1-org5/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer1-org5/config_block.json > channel-artifacts/peer1-org5/config.json
cp channel-artifacts/peer1-org5/config.json channel-artifacts/peer1-org5/config_copy.json

jq '.channel_group.groups.Application.groups.Org5MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer1.org5.example.com","port": 8033}]},"version": "0"}}' channel-artifacts/peer1-org5/config_copy.json > channel-artifacts/peer1-org5/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer1-org5/config.json --type common.Config --output channel-artifacts/peer1-org5/config.pb
configtxlator proto_encode --input channel-artifacts/peer1-org5/modified_config.json --type common.Config --output channel-artifacts/peer1-org5/modified_config.pb
configtxlator compute_update --channel_id channel4 --original channel-artifacts/peer1-org5/config.pb --updated channel-artifacts/peer1-org5/modified_config.pb --output channel-artifacts/peer1-org5/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer1-org5/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer1-org5/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel4", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer1-org5/config_update.json)'}}}' | jq . > channel-artifacts/peer1-org5/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer1-org5/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer1-org5/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer1-org5/config_update_in_envelope.pb -c channel4 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem



#组织六
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org6MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
export CORE_PEER_ADDRESS=localhost:9031

peer channel fetch config channel-artifacts/peer0-org6/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel5 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

configtxlator proto_decode --input channel-artifacts/peer0-org6/config_block.pb --type common.Block --output channel-artifacts/peer0-org6/config_block.json
jq .data.data[0].payload.data.config channel-artifacts/peer0-org6/config_block.json > channel-artifacts/peer0-org6/config.json
cp channel-artifacts/peer0-org6/config.json channel-artifacts/peer0-org6/config_copy.json

jq '.channel_group.groups.Application.groups.Org6MSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.org6.example.com","port": 9031}]},"version": "0"}}' channel-artifacts/peer0-org6/config_copy.json > channel-artifacts/peer0-org6/modified_config.json

configtxlator proto_encode --input channel-artifacts/peer0-org6/config.json --type common.Config --output channel-artifacts/peer0-org6/config.pb
configtxlator proto_encode --input channel-artifacts/peer0-org6/modified_config.json --type common.Config --output channel-artifacts/peer0-org6/modified_config.pb
configtxlator compute_update --channel_id channel5 --original channel-artifacts/peer0-org6/config.pb --updated channel-artifacts/peer0-org6/modified_config.pb --output channel-artifacts/peer0-org6/config_update.pb

configtxlator proto_decode --input channel-artifacts/peer0-org6/config_update.pb --type common.ConfigUpdate --output channel-artifacts/peer0-org6/config_update.json
# shellcheck disable=SC2046
echo '{"payload":{"header":{"channel_header":{"channel_id":"channel5", "type":2}},"data":{"config_update":'$(cat channel-artifacts/peer0-org6/config_update.json)'}}}' | jq . > channel-artifacts/peer0-org6/config_update_in_envelope.json
configtxlator proto_encode --input channel-artifacts/peer0-org6/config_update_in_envelope.json --type common.Envelope --output channel-artifacts/peer0-org6/config_update_in_envelope.pb

peer channel update -f channel-artifacts/peer0-org6/config_update_in_envelope.pb -c channel5 -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


