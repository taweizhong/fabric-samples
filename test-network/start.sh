#!/bin/bash

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
# 生成排序节点组织结构
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"
# 生成其他的组结构
for ((i=1; i<7;i++))
do
  cryptogen generate --config=./organizations/cryptogen/crypto-config-org${i}.yaml --output="organizations"
done
# 生成系统通道的初始区块
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./system-genesis-block/genesis.block

# 启动网络
docker-compose -f ./docker/docker-compose-test-net.yaml up -d
# 创建通道配置文件

for ((i=1;i<6;i++))
do
  configtxgen -profile TwoOrgsChannel${i} -outputCreateChannelTx ./channel-artifacts/channel${i}.tx -channelID channel${i}
done

. ./ccp.sh