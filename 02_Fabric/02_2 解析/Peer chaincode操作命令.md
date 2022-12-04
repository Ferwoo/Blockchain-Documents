#                     Peer chaincode操作命令

一、简单介绍

     用户可以通过命令操作链码，支持的链码命令有：install|instantiate|invoke|package|query|signpackage|upgrade，未来还会支持start、stop命令。这些操作管理了链码的整个生存周期，如下图：

![img](images/20180313161028638)

二、操作步骤：

        我们可以通过一些简单的操作在我们的操作系统上看到命令的help。
    
        命令：docker run -it hyperledger/fabric-peer bash
    
        通过上述命令我们先启动peer，在通过下面命令查看peer支持操作。
    
        命令：peer chaincode --help

显示如下：

Operate a chaincode: install|instantiate|invoke|package|query|signpackage|upgrade.
Usage:
peer chaincode [command]

 Available Commands:
  install         Package the specified chaincode into a deployment spec and save it on the peer's path.
  instantiate    Deploy the specified chaincode to the network.
  invoke           Invoke the specified chaincode.
  package        Package the specified chaincode into a deployment spec.
  query             Query using the specified chaincode.
  signpackage   Sign the specified chaincode package
  upgrade            Upgrade chaincode.

Flags:
      --cafile string      Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      -o, --orderer string     Ordering service endpoint
      --tls                      Use TLS when communicating with the orderer endpoint

Global Flags:
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
      --test.coverprofile string     Done (default "coverage.cov")
      -v, --version                            Display current version of fabric peer server



Use "peer chaincode [command] --help" for more information about a command.   

        在通过下面命令查看install等操作的help。
    
        命令：peer chaincode install -h

显示如下：

Usage:
  peer chaincode install [flags]

Flags:
  -c, --ctor string      Constructor message for the chaincode in JSON format (default "{}")
  -h, --help             help for install
  -l, --lang string      Language the chaincode is written in (default "golang")
  -n, --name string      Name of the chaincode
  -p, --path string      Path to chaincode
  -v, --version string   Version of the chaincode specified in install/instantiate/upgrade commands

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint


命令：peer chaincode instantiate -h
Usage:
  peer chaincode instantiate [flags]

Flags:
  -C, --channelID string   The channel on which this command should be executed (default "testchainid")
  -c, --ctor string        Constructor message for the chaincode in JSON format (default "{}")
  -E, --escc string        The name of the endorsement system chaincode to be used for this chaincode
  -l, --lang string        Language the chaincode is written in (default "golang")
  -n, --name string        Name of the chaincode
  -P, --policy string      The endorsement policy associated to this chaincode
  -v, --version string     Version of the chaincode specified in install/instantiate/upgrade commands
  -V, --vscc string        The name of the verification system chaincode to be used for this chaincode

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint


查看：peer chaincode invoke -h
Invoke the specified chaincode. It will try to commit the endorsed transaction to the network.

Usage:
  peer chaincode invoke [flags]

Flags:
  -C, --channelID string   The channel on which this command should be executed (default "testchainid")
  -c, --ctor string        Constructor message for the chaincode in JSON format (default "{}")
  -n, --name string        Name of the chaincode

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
  -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint
  -v, --version                    Display current version of fabric peer server



查看：peer chaincode query -h
Get endorsed result of chaincode function call and print it. It won't generate transaction.

Usage:
  peer chaincode query [flags]

Flags:
  -C, --channelID string   The channel on which this command should be executed (default "testchainid")
  -c, --ctor string        Constructor message for the chaincode in JSON format (default "{}")
  -x, --hex                If true, output the query value byte array in hexadecimal. Incompatible with --raw
  -n, --name string        Name of the chaincode
  -r, --raw                If true, output the query value as raw bytes, otherwise format as a printable string
  -t, --tid string         Name of a custom ID generation algorithm (hashing and decoding) e.g. sha256base64

Global Flags:
      --cafile string              Path to file containing PEM-encoded trusted certificate(s) for the ordering endpoint
      --logging-level string       Default logging level and overrides, see core.yaml for full syntax
      -o, --orderer string             Ordering service endpoint
      --test.coverprofile string   Done (default "coverage.cov")
      --tls                        Use TLS when communicating with the orderer endpoint
  -v, --version                    Display current version of fabric peer server

还可以采取类似的方法继续查看别的操作，这里就不再贴出命令和显示。



三、命令参数解释

| 参数         | 类型   | 含义                                                         |
| ------------ | ------ | ------------------------------------------------------------ |
| --cafile     | string | Ordere节点的TLS证书，PEM格式编码，启用TLS时有效              |
| -C/--chainID | string | 所面向的通道，默认值为“testid”                               |
| -c/--ctor    | string | 链码执行的参数信息，json格式，默认为{}                       |
| -E/--escc    | string | 指定使用背书系统链码的名称，默认“escc”                       |
| -l/--lang    | string | 链码编写语言，默认“golang”                                   |
| -n/--name    | string | 链码名称                                                     |
| -o/--orderer | string | Orderer服务地址                                              |
| -p/--path    | string | 链码的本地路径                                               |
| -P/--policy  | string | 链码所关联的背书策略                                         |
| -t/--tid     | string | ChaincodeInvocationSpec中ID的生成算法和编码，目前支持默认的sha256/base64 |
| --tls        | string | 与Orderer通信是否启用TLS                                     |
| -v/--version | string | install/upgrade等命令中指定的版本信息                        |
| -V/--vscc    | string | 指定所使用验证系统链码的名称，默认“vscc”                     |

接下来我们看看那些参数在使用中是必须的，如下表：

| 命令        | -C 通道 | -c 参数 | -E escc | -l 语言 | -n 名称 | -o Orderer | -p 路径 | -P policy | -v 版本 | -V vscc |
| ----------- | ------- | ------- | ------- | ------- | ------- | ---------- | ------- | --------- | ------- | ------- |
| install     | 不支持  | 支持    | 不支持  | 支持    | 必需    | 不支持     | 必需    | 不支持    | 必需    | 不支持  |
| instantiate | 必需    | 必需    | 支持    | 支持    | 必需    | 支持       | 不支持  | 支持      | 必需    | 支持    |
| upgrade     | 必需    | 必需    | 支持    | 支持    | 必需    | 支持       | 不支持  | 不支持    | 必需    | 支持    |
| package     | 不支持  | 支持    | 不支持  | 支持    | 必需    | 不支持     | 必需    | 不支持    | 必需    | 不支持  |
| invoke      | 支持    | 必需    | 不支持  | 支持    | 必需    | 支持       | 不支持  | 不支持    | 不支持  | 不支持  |
| query       | 支持    | 必需    | 不支持  | 支持    | 必需    | 不支持     | 不支持  | 不支持    | 不支持  | 不支持  |

四、总结

       附一些官方的cli命令：

// peer chaincode invoke -C myc1 -n marbles -c '{"Args":["initMarble","marble1","blue","35","tom"]}'
// peer chaincode invoke -C myc1 -n marbles -c '{"Args":["initMarble","marble2","red","50","tom"]}'
// peer chaincode invoke -C myc1 -n marbles -c '{"Args":["initMarble","marble3","blue","70","tom"]}'
// peer chaincode invoke -C myc1 -n marbles -c '{"Args":["transferMarble","marble2","jerry"]}'
// peer chaincode invoke -C myc1 -n marbles -c '{"Args":["transferMarblesBasedOnColor","blue","jerry"]}'
// peer chaincode invoke -C myc1 -n marbles -c '{"Args":["delete","marble1"]}'

// peer chaincode query -C myc1 -n marbles -c '{"Args":["readMarble","marble1"]}'
// peer chaincode query -C myc1 -n marbles -c '{"Args":["getMarblesByRange","marble1","marble3"]}'
// peer chaincode query -C myc1 -n marbles -c '{"Args":["getHistoryForMarble","marble1"]}'

// Rich Query (Only supported if CouchDB is used as state database):
//   peer chaincode query -C myc1 -n marbles -c '{"Args":["queryMarblesByOwner","tom"]}'
//   peer chaincode query -C myc1 -n marbles -c '{"Args":["queryMarbles","{\"selector\":{\"owner\":\"tom\"}}"]}'