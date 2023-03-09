export FABRIC_CFG_PATH=$PWD/../config/
export PATH=${PWD}/../bin:$PATH

# 组织1和组织2加入通道一
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com -c channel1 -f ./channel-artifacts/channel1.tx --outputBlock ./channel-artifacts/channel1_org1.block --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

for ((i=0; i<13;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer${i}.org1.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((7051 + i * 2))
  peer channel join -b ./channel-artifacts/channel1_org1.block
done



export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer channel fetch 0 ./channel-artifacts/channel1_org2.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


for ((i=0; i<5;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((9051 + i * 2))
  peer channel join -b ./channel-artifacts/channel1_org2.block
done

# 组织2和组织3加入通道二
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com -c channel2 -f ./channel-artifacts/channel2.tx --outputBlock ./channel-artifacts/channel2_org2.block --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

for ((i=0; i<5;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer${i}.org2.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((9051 + i * 2))
  peer channel join -b ./channel-artifacts/channel2_org2.block
done



export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org3MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
export CORE_PEER_ADDRESS=localhost:9071

peer channel fetch 0 ./channel-artifacts/channel2_org3.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel2 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


for ((i=0; i<5;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer${i}.org3.example.com/tls/ca.crt

  export CORE_PEER_ADDRESS=localhost:$((9071 + i * 2))
  peer channel join -b ./channel-artifacts/channel2_org3.block
done


# 组织3和组织4加入通道三
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org3MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
export CORE_PEER_ADDRESS=localhost:9071

peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com -c channel3 -f ./channel-artifacts/channel3.tx --outputBlock ./channel-artifacts/channel3_org3.block --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

for ((i=0; i<5;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer${i}.org3.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((9071 + i * 2))
  peer channel join -b ./channel-artifacts/channel3_org3.block
done



export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org4MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
export CORE_PEER_ADDRESS=localhost:8001

peer channel fetch 0 ./channel-artifacts/channel3_org4.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel3 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


for ((i=0; i<13;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer${i}.org4.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((8001 + i * 2))
  peer channel join -b ./channel-artifacts/channel3_org4.block
done

# 组织4和组织5加入通道四
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org4MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
export CORE_PEER_ADDRESS=localhost:8001

peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com -c channel4 -f ./channel-artifacts/channel4.tx --outputBlock ./channel-artifacts/channel4_org4.block --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

for ((i=0; i<13;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer${i}.org4.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((8001 + i * 2))
  peer channel join -b ./channel-artifacts/channel4_org4.block
done



export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org5MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
export CORE_PEER_ADDRESS=localhost:8031

peer channel fetch 0 ./channel-artifacts/channel4_org5.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel4 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


for ((i=0; i<13;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer${i}.org5.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((8031 + i * 2))
  peer channel join -b ./channel-artifacts/channel4_org5.block
done

# 组织5和组织6加入通道五
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org5MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
export CORE_PEER_ADDRESS=localhost:8031

peer channel create -o localhost:7050  --ordererTLSHostnameOverride orderer.example.com -c channel5 -f ./channel-artifacts/channel5.tx --outputBlock ./channel-artifacts/channel5_org5.block --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

for ((i=0; i<13;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer${i}.org5.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((8031 + i * 2))
  peer channel join -b ./channel-artifacts/channel5_org5.block
done



export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org6MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
export CORE_PEER_ADDRESS=localhost:9031

peer channel fetch 0 ./channel-artifacts/channel5_org6.block -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com -c channel5 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem


for ((i=0; i<5;i++))
do
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org6.example.com/peers/peer${i}.org6.example.com/tls/ca.crt
  export CORE_PEER_ADDRESS=localhost:$((9031 + i * 2))
  peer channel join -b ./channel-artifacts/channel5_org6.block
done