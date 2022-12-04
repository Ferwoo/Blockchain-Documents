##                                       Policy相关概念解读

###1、权限策略的实现

权限策略会具体指定可以执行某项操作的身份集合。

以通道相关的策略为例，一般包括对读操作（例如获取通道的交易、区块等数据）、写操作（例如向通道发起交易）、管理操作（例如加入通道、修改通道的配置信息）等进行权限限制。对策略自身的修改通过额外指定的修改策略（mod_policy）来进行管理。

操作者在发起操作时，其签名组合需要满足策略指定的身份结合规则，才可以被允许执行相应的操作。

实现上，每种策略结构都要实现 Evaluate(signatureSet []*cb.SignedData) error 方法。该方法中会对于给定的一组签名数据，按照给定规则进行检验，看是否符合约定的条件。符合则说明满足了该策略；反之则拒绝。

###2、policy的定义

 相关配置实例文件目录在：fabric/sampleconfig/configtx.yaml

Policy Type 目前包括两种：*SIGNATURE* 和 *IMPLICIT_META*

signature 类型的policy 本质上是由msp principals 构成的 ，可以按照以下的方式去组织policy：5个org中要 有4个org admin进行签名。或者”由组织A去签名，或其他两个组织的admin进行签名”。
ImplicitMetaPolicy，此策略类型不如SignaturePolicy灵活，并且仅在配置上下文中有效。 它汇总了在配置层次结构中更深层次评估策略的结果，这些策略最终由SignaturePolicies定义。 它支持良好的默认规则，如“大多数组织管理员策略”。

####(1)签名策略/signature policies

```
Organizations:

    # SampleOrg defines an MSP using the sampleconfig. It should never be used
    # in production but may be used as a template for other definitions.
    - &SampleOrg
        # Name is the key by which this org will be referenced in channel
        # configuration transactions.
        # Name can include alphanumeric characters as well as dots and dashes.
        Name: SampleOrg

        # ID is the key by which this org's MSP definition will be referenced.
        # ID can include alphanumeric characters as well as dots and dashes.
        ID: SampleOrg

        # MSPDir is the filesystem path which contains the MSP configuration.
        MSPDir: msp

        # Policies defines the set of policies at this level of the config tree
        # For organization policies, their canonical path is usually
        #   /Channel/<Application|Orderer>/<OrgName>/<PolicyName>
        Policies: &SampleOrgPolicies
            Readers:
                Type: Signature
                Rule: "OR('SampleOrg.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('SampleOrg.admin', 'SampleOrg.peer', 'SampleOrg.client')"
            Writers:
                Type: Signature
                Rule: "OR('SampleOrg.member')"
                # If your MSP is configured with the new NodeOUs, you might
                # want to use a more specific rule like the following:
                # Rule: "OR('SampleOrg.admin', 'SampleOrg.client')"
            Admins:
                Type: Signature
                Rule: "OR('SampleOrg.admin')"

        # AnchorPeers defines the location of peers which can be used for
        # cross-org gossip communication. Note, this value is only encoded in
        # the genesis block in the Application section context.
        AnchorPeers:
            - Host: 127.0.0.1
Port: 7051
```

 Role：根据证书角色来区分，如 Admin、Member、Client、Peer 等

逻辑关系操作符OR, AND, NOutOf

#### (2)ImplicitMeta 隐式标签

```
# Organizations lists the orgs participating on the application side of the
    # network.
    Organizations:

    # Policies defines the set of policies at this level of the config tree
    # For Application policies, their canonical path is
    #   /Channel/Application/<PolicyName>
    Policies: &ApplicationDefaultPolicies
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"

    # Capabilities describes the application level capabilities, see the
    # dedicated Capabilities section elsewhere in this file for a full
    # description
    Capabilities:
        <<: *ApplicationCapabilities
```

Rule语法 .
MAJORITY - 满足主要的子组的策略
ANY - 满足任意子组的policy
ALL - 满足所有的子组的policy

### 3、系统链码的不同plolicy配置（访问控制列表 Access Control Lists(ACL)）

```
Application: &ApplicationDefaults
    ACLs: &ACLsDefault
        # This section provides defaults for policies for various resources
        # in the system. These "resources" could be functions on system chaincodes
        # (e.g., "GetBlockByNumber" on the "qscc" system chaincode) or other resources
        # (e.g.,who can receive Block events). This section does NOT specify the resource's
        # definition or API, but just the ACL policy for it.
        #
        # User's can override these defaults with their own policy mapping by defining the
        # mapping under ACLs in their channel definition

        #---Lifecycle System Chaincode (lscc) function to policy mapping for access control---#

        # ACL policy for lscc's "getid" function
        lscc/ChaincodeExists: /Channel/Application/Readers

        # ACL policy for lscc's "getdepspec" function
        lscc/GetDeploymentSpec: /Channel/Application/Readers

        # ACL policy for lscc's "getccdata" function
        lscc/GetChaincodeData: /Channel/Application/Readers

        # ACL Policy for lscc's "getchaincodes" function
        lscc/GetInstantiatedChaincodes: /Channel/Application/Readers

        #---Query System Chaincode (qscc) function to policy mapping for access control---#

        # ACL policy for qscc's "GetChainInfo" function
        qscc/GetChainInfo: /Channel/Application/Readers

        # ACL policy for qscc's "GetBlockByNumber" function
        qscc/GetBlockByNumber: /Channel/Application/Readers

        # ACL policy for qscc's  "GetBlockByHash" function
        qscc/GetBlockByHash: /Channel/Application/Readers

        # ACL policy for qscc's "GetTransactionByID" function
        qscc/GetTransactionByID: /Channel/Application/Readers

        # ACL policy for qscc's "GetBlockByTxID" function
        qscc/GetBlockByTxID: /Channel/Application/Readers

        #---Configuration System Chaincode (cscc) function to policy mapping for access control---#

        # ACL policy for cscc's "GetConfigBlock" function
        cscc/GetConfigBlock: /Channel/Application/Readers

        # ACL policy for cscc's "GetConfigTree" function
        cscc/GetConfigTree: /Channel/Application/Readers

        # ACL policy for cscc's "SimulateConfigTreeUpdate" function
        cscc/SimulateConfigTreeUpdate: /Channel/Application/Readers

        #---Miscellanesous peer function to policy mapping for access control---#

        # ACL policy for invoking chaincodes on peer
        peer/Propose: /Channel/Application/Writers

        # ACL policy for chaincode to chaincode invocation
        peer/ChaincodeToChaincode: /Channel/Application/Readers

        #---Events resource to policy mapping for access control###---#

        # ACL policy for sending block events
        event/Block: /Channel/Application/Readers

        # ACL policy for sending filtered block events
        event/FilteredBlock: /Channel/Application/Readers
```

