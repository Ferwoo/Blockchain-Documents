# 4 fabric-sample目录功能介绍：

![fabric-sample目录](http://p88vmzsqy.bkt.clouddn.com/fabric%E7%9B%AE%E5%BD%95%E7%BB%93%E6%9E%84.png)


### fabric-samples/chaincode:
官方提供的链码示例，智能合约的示例

### fabric-samples/chaincode-docker-devmode:
用于在开发模式下测试的环境。
开发人员开发完成后，想要快速的测试，验证结果。
### fabric-samples/fabcar:
提供的node.js的简单示例
### fabric-samples/fabric-ca:
简单的证书
### fabric-samples/first-network：
搭建fabric网络的目录

### fabric-samples/bin:

![fabric-samples/bin目录](http://p88vmzsqy.bkt.clouddn.com/fabric-bin.png)

* cryptogen:用来生成组织结构及相应的证书密钥，在联盟链中有哪些组织，及对应组织下有哪些节点

```
    orderer
    org 
        org1
            
            peer0.org1.example.com
            peer1.org1.example.com
        org2
            peer0.org2.example.com
            peer0.org2.example.com
    
```
什么组织可以访问通道中的数据，依赖于生成的证书及密钥

* configtxgen：
    * 用来生成orderer服务的初始区块（创世区块）
    * 还可以生成对应的通道交易配置文件（包含了通道中的成员，及访问策略）
    * 生成Anchor（锚节点更新文件）
        * 用来跨组织的数据交换
        * 发现通道内新加入的组织/节点
        * 
每个组织都会有一个anchor
* configtxlator
    * 用来添加新组织











