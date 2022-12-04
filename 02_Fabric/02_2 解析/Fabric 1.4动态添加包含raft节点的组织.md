# Fabric 1.4动态添加包含raft节点的组织
## 1.部署架构图

![](https://i.stack.imgur.com/pksuR.png)


在fabric网络中org1有2个orderer、2个peer，现在加入另一个组织org2，org2存在1个orderer，2个peer。

![](https://i.stack.imgur.com/3DZxl.png)



## 2.添加组织到系统链

此时需要添加在下面Organizations添加org2相关信息(要在orderer里面添加可参与排序，以下操作为特殊说明皆在cli容器内部执行，备注若不添加到SampleConsortium/Organizations，则可能在创建通道报错不属于联盟)

```
    SampleMultiNodeEtcdRaft:
        <<: *ChannelDefaults
        Capabilities:
            <<: *ChannelCapabilities
        Orderer:
            <<: *OrdererDefaults
            Organizations:
            - *Org1
            Capabilities:
                <<: *OrdererCapabilities
        Consortiums:
            SampleConsortium:
                Organizations:
                - *Org1
```

1. 生成org2组织信息
    ```
    # 此时在宿主机测试目录下，非cli容器
    export FABRIC_CFG_PATH=$PWD
    configtxgen --printOrg Org2MSP >channel-artifacts/org2.json
    ```
2. 设置环境变量
    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/orderer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem
    export CHANNEL_NAME=testchainid
    ```
3. 获取系统通道配置块并转换成json格式
    ```
    peer channel fetch config config_block.pb -o orderer0.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
    
    configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
    ```
4. 将组织org2相关信息org2.json添加到config.json orderer groups位置

    ```
    jq -s '.[0] * {"channel_group":{"groups":{"Orderer":{"groups": {"Org2MSP":.[1]}}}}}' config.json ./channel-artifacts/org2.json > modified_config_in.json
    ```
5. 将组织org2相关信息org2.json添加到config.json Consortiums groups SampleConsortium groups位置

    ```
    jq -s ".[0] * {"channel_group":{"groups":{"Consortiums":{"groups": {"SampleConsortium":{"groups":{"Org2MSP":.[1]}}}}}}}" modified_config_in.json ./channel-artifacts/org2.json > modified_config.json
    ```

6. 将组织org2的orderer tls添加到config.json orderer consenters位置
    ```
    # 生成需要添加的json文件
    export TLS_FILE=crypto/peerOrganizations/org2.example.com/peers/orderer0.org2.example.com/tls/server.crt
    
    echo "{\"client_tls_cert\":\"$(cat $TLS_FILE | base64 |xargs echo | sed 's/ //g')\",\"host\":\"orderer0.org2.example.com\",\"port\":7050,\"server_tls_cert\":\"$(cat $TLS_FILE | base64 |xargs echo | sed 's/ //g')\"}" > org2consenter.json

    # 将org2consenter.json 添加到Orderer/values/ConsensusType/value/metadata/consenters
    
    jq ".channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [$(cat org2consenter.json)]" modified_config.json > modified_config_add.json
    ```
7. 转换成pb格式及计算更新
   
    ```
    # 获取配置的更新
    configtxlator proto_encode --input config.json --type common.Config --output config.pb
    
    configtxlator proto_encode --input modified_config_add.json --type common.Config --output modified_config.pb
   
    configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org2_update.pb
    
    configtxlator proto_decode --input org2_update.pb --type common.ConfigUpdate | jq . > org2_update.json
    ```
8. 构建交易及签名
    ```
    # 构建envelope message
    echo '{"payload":{"header":{"channel_header":{"channel_id":"testchainid", "type":2}},"data":{"config_update":'$(cat org2_update.json)'}}}' | jq . > org2_update_in_envelope.json
    
    configtxlator proto_encode --input org2_update_in_envelope.json --type common.Envelope --output org2_update_in_envelope.pb
    
    # 需要切换变量签名，因只有org1 发送交易会自动签名
    peer channel signconfigtx -f org2_update_in_envelope.pb
    ```
9. 发送更新配置的交易
    ```
    # 请记住切换环境变量到org1的admin/msp
    peer channel update -f org2_update_in_envelope.pb -c $CHANNEL_NAME -o orderer0.org1.example.com:7050 --tls --cafile $ORDERER_CA
    
    2019-07-22 11:32:20.970 UTC [channelCmd] InitCmdFactory -> INFO 001 Endorser and orderer connections initialized
    2019-07-22 11:32:20.996 UTC [channelCmd] update -> INFO 002 Successfully submitted channel update
    ```
10. 获取最新配置块给org2的orderer作为启动块
    ```
    peer channel fetch config last_config_block.pb -o orderer0.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
    
    cp last_config_block.pb ./channel-artifacts/last_config.block
    ```
11 .启动org2的peer/orderer

## 3. 按照上述步骤添加到应用链mychannel

1. 设置环境变量
    ```
    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/orderer0.org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem
    export CHANNEL_NAME=mychannel
    ```
2. 获取应用通道配置块并转换成json格式
    ```
    peer channel fetch config config_block.pb -o orderer0.org1.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
    
    configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
    ```
3. 将组织org2相关信息org2.json添加到config.json orderer及Application groups位置
    ```
    jq -s '.[0] * {"channel_group":{"groups":{"Orderer":{"groups": {"Org2MSP":.[1]}}}}}' config.json ./channel-artifacts/org2.json > modified_config_in.json
    
    jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org2MSP":.[1]}}}}}' modified_config_in.json ./channel-artifacts/org2.json > modified_config.json
    ```
4. 将组织org2的orderer tls添加到config.json orderer consenters位置
    ```
    # 生成需要添加的json文件
    export TLS_FILE=crypto/peerOrganizations/org2.example.com/peers/orderer0.org2.example.com/tls/server.crt
    
    echo "{\"client_tls_cert\":\"$(cat $TLS_FILE | base64 |xargs echo | sed 's/ //g')\",\"host\":\"orderer0.org2.example.com\",\"port\":7050,\"server_tls_cert\":\"$(cat $TLS_FILE | base64 |xargs echo | sed 's/ //g')\"}" > org2consenter.json

    # 将org2consenter.json 添加到Orderer/values/ConsensusType/value/metadata/consenters
    
    jq ".channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [$(cat org2consenter.json)]" modified_config.json > modified_config_add.json
    ```
5. 转换成pb格式及计算更新
   
    ```
    # 获取配置的更新
    configtxlator proto_encode --input config.json --type common.Config --output config.pb
    
    configtxlator proto_encode --input modified_config_add.json --type common.Config --output modified_config.pb
   
    configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org2_update.pb
    
    configtxlator proto_decode --input org2_update.pb --type common.ConfigUpdate | jq . > org2_update.json
    ```
6. 构建交易及签名
    ```
    # 构建envelope message
    echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org2_update.json)'}}}' | jq . > org2_update_in_envelope.json
    
    configtxlator proto_encode --input org2_update_in_envelope.json --type common.Envelope --output org2_update_in_envelope.pb
    
    # 需要切换变量签名，因只有org1 发送交易会自动签名
    peer channel signconfigtx -f org2_update_in_envelope.pb
    ```
7. 发送更新配置的交易
    ```
    # 请记住切换环境变量到org1的admin/msp
    peer channel update -f org2_update_in_envelope.pb -c $CHANNEL_NAME -o orderer0.org1.example.com:7050 --tls --cafile $ORDERER_CA
    ```
结果如下：
```
2019-07-22 11:59:22.609 UTC [orderer.consensus.etcdraft] apply -> INFO 16e Applied config change to add node 1, current nodes in channel: [1] channel=mychannel node=3
2019-07-22 11:59:22.609 UTC [orderer.consensus.etcdraft] apply -> INFO 16f Applied config change to add node 2, current nodes in channel: [1 2] channel=mychannel node=3
2019-07-22 11:59:22.609 UTC [orderer.consensus.etcdraft] writeBlock -> INFO 170 Got block [3], expect block [4], this node was forced to catch up channel=mychannel node=3
2019-07-22 11:59:22.609 UTC [orderer.consensus.etcdraft] apply -> INFO 171 Applied config change to add node 3, current nodes in channel: [1 2 3] channel=mychannel node=3
```