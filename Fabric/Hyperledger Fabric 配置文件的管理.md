#                                                                                             Hyperledger Fabric 配置文件的管理

## 1、配置简介

         目前Fabric节点在启动时，需要对Peer节点、Order节点，以及应用通道、组织身份等多种资源进行管理，因此需要一套进行配置、管理的完整机制。

### 1.1  配置文件及管理工具

主配置路径：一般指向/etc/hyperledger/fabric路径

####                                                                                                  表1.1-1相关配置路径、方式以及功能

| 节点        | 默认配置文件路径           |          配置指定方式          | 主要功能                    |
| ----------- | -------------------------- | :----------------------------: | --------------------------- |
| Peer节点    | $FABRIC_CFG_PATH/core.yaml | 配置文件、环境变量、命令行参数 | 指定Peer节点运行时的参数    |
| Orderer节点 | $FABRIC_CFG_PATH/core.yaml | 配置文件、环境变量、命令行参数 | 指定Orderer节点运行时的参数 |

**主要配置管理工具**：

     cryptogen        负责生成网络组织结构和身份文件
     
     configtxgen      负责生成通道相关配置
    
     configtxlator    对网络中配置进行编、解码，并计算配置更新量



### 1.2  Peer配置剖析

**Peer模块：**

#####1、提交节点（committer Peer）

      无法通过配置文件配置，当发起交易请求时需要指定相关的的Committer节点,可以存在多个

#####2、背书节点（Endorse Peer）

     无法通过配置文件配置，当发起交易请求时需要指定相关的的Committer节点，可以存在多个

#####3、Leader 节点（Leader Peer）

     产生方式是通过peer模块的配置文件core.yaml进行配置的，只有一个。

配置方式有两种：自主选举和强制指定

自主选举：推荐配置，系统会根据gossip协议自动在组织中选择某一个节点作为Leader，发生故障自动选择其他

强制指定：选择当前Peer作为Leader节点

#####4、锚节点（Anchor Peer）

     通过配置方式指定，配置信息在congfigtxgen模块的configtx.yaml中配置，只有一个。必须保证组织内部锚节点服务器处于可访问的状态

Host属性：Host属性表示本组织锚节点的访问地址，可以是IP地址或者域名，推荐采用域名方式

Port属性：Port属性表示本组织锚节点的访问端口

####core.yaml文件配置：

 #### core.yaml文件中一般包括五大部分：logging、peer、vm、chaincode、ledger

**logging**：定义peer服务的的日志记录级别和输出日志消息的格式；

```+go
logging:（设置优先级从高到低分别是 ERROR、WARN、INFO、DEBUG）
peer:  info  #全局的默认日志级别

#模块的日志级别，覆盖全局配置
cauthdsl: warning
gossip:   warning
ledger:   info 
msp:    warning
policies: warning
grpc:  error

```

**peer**：包括通用配置、gossip、events、tls等跟服务直接相关的核心配置；

```+go
通用相关配置：
peer:
id :peer0                      #节点ID
networkID:business             #网络的ID
listenAddress: 0.0.0.0:7051    # 节点在监听的本地网络接口地址（前边自己设置）
chaincodeListenAddress:0.0.0.0:7051#链码容器链接时的监听地址，可采用LAdd地址
address:0.0.0.0:7051           #节点对外的服务地址
addressAutoDetect: false       #是否自动探测对外服务地址

gomaxprocs:-1                  #Go进程数限制
fileSystemPath:/var/hyperledger/production #本地数据存放路径

BCCSP:                        #加密库的配置，包括算法、文件路径等
     Default:SW
     SW:
        Hash: SHA2            #Hash算法类型
        security:256
        FileKeyStore: #本地私钥文件路径，默认指向<mspConfigPath>/keystore
            keyStore:
            
   mspConfigPath:msp   #MSP的本地路径
   localMspId:DEFAULT  #Peer所关联的MSP的ID
   
   profile：       #是否启用Go自带的profiling支持进行调试
        enable：false
        listenAddress: 0.0.0.0:6060
        
 gossip相关配置：
 peer:
  gossip:
   bootstrap:127.0.0.1:7051#启动节点后所进行gossip连接的初始节点
   useLeaderElection:false  #是否动态选举代表节点
   orgLeader： true #是否指定本节点为组织代表节点
   endpoint： #本节点在组织内的gossip id
   
   maxBlockCountToStore: 100 #保存到内存中的区块个数上限
   maxPropagationBurstLatency:10ms #保存消息的最大时间，超过触发转给其他节点
   
   maxPropagationBurstSize:10 #保存的最大消息个数，超过触发转发给其他节点
   
   propagateIterations:1  #消息转发的次数
   propagatePeerNum: 3    #推送消息给指定个数的节点
   pullInterval: 4s       #拉取消息的时间间隔
   
   pullPeerNum:3 # 从指定个数的节点拉取消息
   requestStateInfoInterval: 4s #从节点拉取状态信息消息的间隔
   publishStateInfoInterval: 4s #向其他节点推动状态信息消息的间隔
   stateInfoRetentionInterval:  #状态信息消息的超时时间
   publishCertPeriod:10s  #启动后在心跳消息中包括证书的等待时间
   skipBlockVerification: false #是否不对区块消息进行校验，默认为false
   dialTimeout:   3s   #gRPC 连接拨号的超时
   connTimeout:   2s   #建立连接的超时
   recvBuffSize:  20   #收取消息的缓冲大小
   sendBuffSize:  200  #发送消息的缓冲大小
   digestWaitTime: 1s  #处理摘要数据的等待时间
   requestWaitTime: 1s #处理Nonce数据的等待时间
   responseWaitTime: 2s #终止拉取数据处理的等待时间
   aliveTimeInterval:5s #定期发送Alive心跳消息的时间间隔
   aliveEXpirationTimeout： 25s #Alive心跳消息的超时时间
   reconnnectionInterval：   25s #短线后重连的时间间隔
   externalEndpoint：            #节点被组织外节点感知时的地址
   
   election：
     startupGracePeriod:15s   #代表成员选举等待的时间
     membershipSampleInterval:  1s #检查成员稳定性的采样间隔
     leaderAliveThreshold:  10s    #Peer 尝试进行选举的等待超时
     leaderElectionDuration: 5s    #Peer 宣布自己为代表节点的等待时间
     
     events相关配置：
     peer:
       events:
            address: 0.0.0.0:7053 #本地服务监听地址
            buffersize: 100  #最大进行缓冲的消息数
            timeout:10ms     #当缓冲已满情况下，往缓冲中发送消息的超时。
            
     tls相关配置
     peer：
          tls：
             enabled：false #默认不开启TLS验证
             cert:
             file:tls/server.crt #本服务的身份验证证书，公开可见，访问者可通过该证书进行验证
             key:
             file:tls/server.key  #本服务的签名私钥
             rootcert:
            file:tls/ca.crt      #信任的根CA的证书
           serverhostoverride:       #是否指定进行TLS握手时的主机名称


```

**vm**：对链码运行环境的配置，目前主要支持Docker容器；

```+go
vm相关配置
vm:
   endpoint:unix:///var/run/docker.sock.  #Docker Daemon地址
   docker:
        tls:  #Docker Daemon 启用TLS时相关的证书配置
               enabled:false  
               ca:
                  file:docker/ca.crt
               cert:
                  file:docker/tls.crt
               key:
                  file:docker/tls.key
  attachStdout:false   #是否启用连接到标准输出
  hostConfig: #Docker相关的主机配置，包括网络配置、日志、内存等
      NetworkMode：host #host 意味着链码容器直接使用所在主机的网络命名空间
      Dns：
          #-192.168.0.1
      LogConfig:
          Type:json-file
          Config:
                max-size:"50m"
                max-file:"5"
                
          Memory:
                  
```



**chaincode**：跟链码相关的配置选项；

```+go
chaincode相关配置
chaincode:
   id:   #动态标记链码的信息，该信息会以标签形式
       path:
       name:
       
   #通用的本地编译环境，是一个Docker 镜像
   build:
   
   Golang:  #Go语言的链码部署生成镜像的基础Docker镜像
         runtime:
   car:    #car格式的链码部署生成镜像的基础Docker镜像
         runtime:
   java:   #生成Java链码容器时候基础镜像信息
         Dockerfile:
   startuptimeout:300s #启动链码容器的超时
   executetimeout:30s  #invoke和initialize命令执行超时
   deploytimeout:30s   #部署链码的命令执行超时
   
   node:net  #执行链码的模式
   
   keepalive:  0 #Peer和链码之间的心跳超时，小于或等于0意味着关闭
   
   system:  #系统链码的配置
      cscc:enable
      lscc:enable
      escc:enable
      vscc:enable
      qscc:enable
      
   logging:  #链码容器日志相关配置
     level:info
     shim: warning
     format:      
      
```



**ledger**：账本的相关配置；包括blockchain、state、history。

```+go
ledger相关配置
ledger:
   blockchain:
   
   state: #状态数据库配置
        stateDatabase:goleveldb #状态数据库类型
        couchDBConfig：    #如果启用 couchdb 数据库，配置连接信息
             couchDBAddress：127.0.0.1:5984
             username:
             password:
             maxRetries: 3 #出错后重试次数
             maxRetriesOnStartup:10 #启动出错的重试次数
             requestTimeout：35s #请求超时
             queryLimit:10000    #每个查询的最大返回记录数
             
  history:  
        enablehistoryDatabase:true  #是否启用历史数据库
  
  
```



### 1.3  Orderer配置剖析

       orderer节点可以组成集群在Fabric网络中提供排序服务，支持从命令行参数、环境变量或配置文件中读取配置消息。此模块负责对不同客户端发送的交易进行排序和打包，提供两种模式：Solo模式和Kafka模式。

#### orderer.yaml文件中一般包括四大部分General、FileLedger、RAMLedger、Kafka

**General**：主要是通用配置，如账本类型、服务信息、配置路径等。这些配置影响到服务的主要功能，十分重要；

```+go
General :
LedgerType : file #账本类型
ListenAddress : 1 2 7 .0 .0 .1 #服务绑定的监听地址
ListenPort: 7050 #服务绑定的监听端口

TLS: #启用 TLS 时的相关配置 
Enabled : true
PrivateKey: tls/server .key #Orderer 签名私钥 
Certificate : tls/server .crt #Orderer 身份证书
RootCAs : #信任的根证书
- tls/ca.crt
ClientAuthEnabled: false #是否对客户端也进行认证 ClientRootCAs:

LogLevel: info # 目志级别

GenesisMethod: provisional #初始区块的提供方式 GenesisProfile : Sample工nsecureSolo #初始区块使用的 Profile 
GenesisFile: genesisblock #使用现成初始区块文件时 ， 文件的路径

LocalMSPDir: msp #本地 MSP 文件的路径 
LocalMSPID: DEFAULT #MSP的ID
BCCSP : #密码库机制等，可以为 SW (软件实现)或 PKCSll (硬件安全模块) 

Default: SW
SW:
    Hash: SHA2 # Hash算法类型
    Security: 256
    FileKeyStore: #本地私钥文件路径，默认指向<mspConfigPath>/keystore
KeyStore:
 Profile   #是否启用 Go profiling
         Enabled: false
         Address: 0.0.0.0:6060
```



**FileLedger**：主要指定使用基于文件的账本类型的一些相关配置；

```+go
FileLedger:
Location: /var/hyperledger/production/orderer 
#指定存放区块文件的位置
Prefix:   hyperledegr-fabric-ordererledger
#如果不指定Location，则在临时目录下创建账本时目录的名称
```



**RAMLedger**：主要指定使用基于内存的账本类型时最多保留的区块个数

```+go
RAMLedger :
HistorySize: 1000  #保留的区块历史个数，超过该数字，则旧的块会被丢弃
```



**Kafka**：当Orderer使用Kafka集群作为后端时，配置Kafka的相关配置

```+go
Kafka :
Retry : # Kafka 未就绪时 Orderer 的重试配置 Shortinterval : 5s #操作失败后的快速重试阶段的问隔
ShortTotal : lOm   #快速重试阶段最多重试多长时间
Longinterval:  5m  #快速重试阶段仍然失 败后进入慢重试阶段 ，
Sm LongTotal : 12h  #慢重试阶段最多重试多长时间
慢重试阶段的时间间隔
#https://godoc.org/github.com/ShopifyIsarama#Config NetworkTimeouts : # sarama 网络超时时间
DialTimeout : 10s 
ReadTimeout : 10s 
WriteTmeout : 10s
Metadata:    # Kafka集群leader选举中的metadata请求参数            
   RetryBackoff : 250ms
    RetryMax : 3
Producer : #发送消息到 Kafka 集群时的超时   
      RetryBackoff : lOOms
      RetryMax : 3
Consumer: # 从Kafka 集群读取消息时的超时    
     RetryBackoff : 2s
```



### 1.4  cryptogen生成组织身份配置

       在Fabric网络中，需要通过证书和秘钥来管理和鉴别成员身份，需要进行证书生成和配置操作。基于Go语言的crypto库，fabric提供了cryptogen工具，主要实现代码在common/tools/cryptogen包下。



### 1.5   configtxgen生成通道配置

         由于区块链系统自身的分布式特性，对其中配置进行更新和管理是一件很有挑战的任务。在Fabric网络中，通过采用配置交易（**ConfigTX**）这一创新的设计来实现对通道相关配置的更新，配置更新操作如果被执行，也要像应用交易一样经过网络节点的共识确认。
    
         configtxgen可以配合cryptogen生成的组织结构身份文件使用，离线生成跟通道有关的配置信息。相关的实现在common/configtx包下。
    
         主要功能：生成启动的orderer需要的初始区块，并支持检查区块内容；生成创建应用通道需要的配置交易，并支持检查交易内容；生成锚点Peer的更新配置交易。

####  configtx.yaml配置文件

         主要包括：Profiles、Organizations、Orderer和Application



### 1.6  configtxlator转换配置

        configtxlator工具可以将这些配置文件在二进制格式和方便阅读编辑的Json格式之间进行转换，方便用户更新通道的



######RESTful接口：目前支持三个功能接口；分别进行解码、编码或者计算配置更新量。

















