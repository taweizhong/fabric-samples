#!/bin/bash

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

################################################################################
#
#   安装链码CC1
#
################################################################################
# 打包链码
peer lifecycle chaincode package cc1.tar.gz --path ./chaincode/cc1/go --lang golang --label cc1

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# 安装链码
peer lifecycle chaincode install cc1.tar.gz

# 查询对等节点，从而找到链代码的包 ID
peer lifecycle chaincode queryinstalled > ./packageID/cc1.txt
awk '{print $3}' ./packageID/cc1.txt |awk '/^cc1/ {print $1}' |awk -F "," '{print $1}' > ./packageID/cc1.dat
read cc1 < ./packageID/cc1.dat
export CC_PACKAGE_ID=$cc1
# 包 ID保存为环境变量

# 组织1批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel1 --name cc1 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer lifecycle chaincode install cc1.tar.gz

# 组织2批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel1 --name cc1 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# 检查通道成员是否已批准相同的链代码定义
peer lifecycle chaincode checkcommitreadiness --channelID channel1 --name cc1 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# 链代码定义提交到通道
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel1 --name cc1 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# 确认链代码定义已提交到通道
peer lifecycle chaincode querycommitted --channelID channel1 --name cc1 --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# 初始化
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C channel1 -n cc1 --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
# 查询
peer chaincode query -C channel1 -n cc1 -c '{"Args":["queryAllFarms"]}'


################################################################################
#
#   安装链码CC2
#
################################################################################
# 打包链码
peer lifecycle chaincode package cc2.tar.gz --path ./chaincode/cc2/go --lang golang --label cc2

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

# 安装链码
peer lifecycle chaincode install cc2.tar.gz

# 查询对等节点，从而找到链代码的包 ID
peer lifecycle chaincode queryinstalled > ./packageID/cc2.txt
awk '{print $3}' ./packageID/cc2.txt |awk '/^cc2/ {print $1}' |awk -F "," '{print $1}' > ./packageID/cc2.dat
read cc2 < ./packageID/cc2.dat
export CC_PACKAGE_ID=$cc2
# 包 ID保存为环境变量

# 组织2批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel2 --name cc2 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org3MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
export CORE_PEER_ADDRESS=localhost:9071

peer lifecycle chaincode install cc2.tar.gz

# 组织3批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel2 --name cc2 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# 检查通道成员是否已批准相同的链代码定义
peer lifecycle chaincode checkcommitreadiness --channelID channel2 --name cc2 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# 链代码定义提交到通道
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel2 --name cc2 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:9071 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

# 确认链代码定义已提交到通道
peer lifecycle chaincode querycommitted --channelID channel2 --name cc2 --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# 初始化
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C channel2 -n cc2 --peerAddresses localhost:9071 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
# 查询
peer chaincode query -C channel2 -n cc2 -c '{"Args":["queryAllFarms"]}'


################################################################################
#
#   安装链码CC3
#
################################################################################
# 打包链码
peer lifecycle chaincode package cc3.tar.gz --path ./chaincode/cc3/go --lang golang --label cc3

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org3MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
export CORE_PEER_ADDRESS=localhost:9071

# 安装链码
peer lifecycle chaincode install cc3.tar.gz

# 查询对等节点，从而找到链代码的包 ID
peer lifecycle chaincode queryinstalled > ./packageID/cc3.txt
awk '{print $3}' ./packageID/cc3.txt |awk '/^cc3/ {print $1}' |awk -F "," '{print $1}' > ./packageID/cc3.dat
read cc3 < ./packageID/cc3.dat
export CC_PACKAGE_ID=$cc3
# 包 ID保存为环境变量

# 组织3批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel3 --name cc3 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org4MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
export CORE_PEER_ADDRESS=localhost:8001

peer lifecycle chaincode install cc3.tar.gz

# 组织4批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel3 --name cc3 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# 检查通道成员是否已批准相同的链代码定义
peer lifecycle chaincode checkcommitreadiness --channelID channel3 --name cc3 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# 链代码定义提交到通道
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel3 --name cc3 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:9071 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses localhost:8001 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt

# 确认链代码定义已提交到通道
peer lifecycle chaincode querycommitted --channelID channel3 --name cc3 --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# 初始化
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C channel3 -n cc3 --peerAddresses localhost:9071 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt --peerAddresses localhost:8001 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
# 查询
peer chaincode query -C channel3 -n cc3 -c '{"Args":["queryAllFarms"]}'


################################################################################
#
#   安装链码CC4
#
################################################################################
# 打包链码
peer lifecycle chaincode package cc4.tar.gz --path ./chaincode/cc4/go --lang golang --label cc4

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org4MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
export CORE_PEER_ADDRESS=localhost:8001

# 安装链码
peer lifecycle chaincode install cc4.tar.gz

# 查询对等节点，从而找到链代码的包 ID
peer lifecycle chaincode queryinstalled > ./packageID/cc4.txt
awk '{print $3}' ./packageID/cc4.txt |awk '/^cc4/ {print $1}' |awk -F "," '{print $1}' > ./packageID/cc4.dat
read cc4 < ./packageID/cc4.dat
export CC_PACKAGE_ID=$cc4
# 包 ID保存为环境变量

# 组织4批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel4 --name cc4 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org5MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
export CORE_PEER_ADDRESS=localhost:8031

peer lifecycle chaincode install cc4.tar.gz

# 组织5批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel4 --name cc4 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# 检查通道成员是否已批准相同的链代码定义
peer lifecycle chaincode checkcommitreadiness --channelID channel4 --name cc4 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# 链代码定义提交到通道
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel4 --name cc4 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:8031 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt --peerAddresses localhost:8001 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt

# 确认链代码定义已提交到通道
peer lifecycle chaincode querycommitted --channelID channel4 --name cc4 --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# 初始化
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C channel4 -n cc4 --peerAddresses localhost:8031 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt --peerAddresses localhost:8001 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org4.example.com/peers/peer0.org4.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
# 查询
peer chaincode query -C channel4 -n cc4 -c '{"Args":["queryAllFarms"]}'

################################################################################
#
#   安装链码CC5
#
################################################################################
# 打包链码
peer lifecycle chaincode package cc5.tar.gz --path ./chaincode/cc5/go --lang golang --label cc5

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org5MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org5.example.com/users/Admin@org5.example.com/msp
export CORE_PEER_ADDRESS=localhost:8031

# 安装链码
peer lifecycle chaincode install cc5.tar.gz

# 查询对等节点，从而找到链代码的包 ID
peer lifecycle chaincode queryinstalled > ./packageID/cc5.txt
awk '{print $3}' ./packageID/cc5.txt |awk '/^cc5/ {print $1}' |awk -F "," '{print $1}' > ./packageID/cc5.dat
read cc5 < ./packageID/cc5.dat
export CC_PACKAGE_ID=$cc5
# 包 ID保存为环境变量

# 组织5批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel5 --name cc5 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org6MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp
export CORE_PEER_ADDRESS=localhost:9031

peer lifecycle chaincode install cc5.tar.gz

# 组织6批准链码定义
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel5 --name cc5 --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# 检查通道成员是否已批准相同的链代码定义
peer lifecycle chaincode checkcommitreadiness --channelID channel5 --name cc5 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --output json

# 链代码定义提交到通道
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID channel5 --name cc5 --version 1.0 --sequence 1 --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --peerAddresses localhost:8031 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt --peerAddresses localhost:9031 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt

# 确认链代码定义已提交到通道
peer lifecycle chaincode querycommitted --channelID channel5 --name cc5 --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
# 初始化
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C channel5 -n cc5 --peerAddresses localhost:8031 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org5.example.com/peers/peer0.org5.example.com/tls/ca.crt --peerAddresses localhost:9031 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
# 查询
peer chaincode query -C channel5 -n cc5 -c '{"Args":["queryAllFarms"]}'