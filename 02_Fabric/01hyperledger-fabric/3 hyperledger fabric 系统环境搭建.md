[TOC]


# 3 hyperledger fabric 系统环境搭建


ubantu环境下搭建fabric所需环境。
Mac下配置ubantu虚拟机，教程可以参考上文。
准备好ubantu系统后，开始进行环境搭建



## 环境搭建

快速入门:  http://hyperledger-fabric.readthedocs.io/en/release-1.1/getting_started.html

### 前提

#### 安装git

```
$ sudo apt update
$ sudo apt install git
```

#### 安装curl

```
$ sudo apt install curl
```

#### 安装vim

```
$ sudo apt install vim
```

### 安装Docker

```
$ sudo apt update
$ docker --version
$ sudo apt install docker.io
```

#### 查看Docker版本信息

version 1.12+

```
$ docker --version
```

输出: `Docker version 1.13.1, build 092cba3`

### 安装Docker Compose

```
$ docker-compose --version
$ sudo apt install docker-compose
```

#### 查看DockerCompose版本信息

```
$ docker-compose --version
```

输出: `docker-compose version 1.8.0, build unknown`

### Golang

Fabric1.1.0版本要求Go1.9+

Fabric1.0.0版本要求Go1.7+

上传go1.10.1.linux-amd64.tar.gz

#### 解压文件

```
$ tar -zxvf go1.10.1.linux-amd64.tar.gz
```
或者  

```
tar -zxvf go1.10.1.linux-amd64.tar.gz -C /usr/local
```


#### 编辑环境变量文件
sudo vim /etc/profile
```
$ vim .bashrc 
```
添加如下内容:

或者：
```
export GOROOT=/usr/local/go
```
```
export GOPATH=$HOME/gocode
export GOROOT=$HOME/go
export PATH=$GOROOT/bin:$PATH
```

```
$ source .bashrc
$ go versionsour
```
或者 
```
source /etc/profile
```

输出: `go version go1.10.1 linux/amd64`

> 如果系统中有旧版本的golang,则使用如下命令卸载旧版本的golang,然后再重新安装
>
> ```
> $ su -
> # apt-get remove golang-go --purge && apt-get autoremove --purge && apt-get clean
> ```



### 安装Node与npm

#### 安装nvm

```
$ sudo apt update
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.10/install.sh | bash

$ export NVM_DIR="$HOME/.nvm"
$ [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
```

#### 安装Node

```
$ nvm install v8.11.1
```

#### 检查Node版本

```
$ node -v
```

输出:   `v8.11.1`

#### 检查npm版本

```
$ npm -v
```

输出:   `5.6.0`

### Hyperledger Fabric Samples 下载安装

#### 创建一个空目录

```
$ mkdir hyfa
```

#### 进入该目录

```
$ cd hyfa
```

#####下载方式:

**新建文件bootstrap.sh**

```
$ vim bootstrap.sh
```

将c中的内容拷贝保存退出

**赋予bootstrap.sh可执行权限并运行**

```
$ chmod +x bootstrap.sh
```

**配置docker加速器**

配置docker加速器的目的是为了在下载docker镜像文件时加速

```
$ curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://8890cb8b.m.daocloud.io
```

**重启docker服务**

```
$ sudo systemctl restart docker.service
```

**执行`bootstrap.sh`**

**确定网络稳定,否则会导致各种问题，例如下载到一半时网络超时，下载失败等等**

```
$ sudo ./bootstrap.sh 1.1.0
```

下载完成后, 查看相关输出内容, 如果下载有失败的镜像, 可再次执行  `$ sudo ./bootstrap.sh 1.1.0`  命令

*****

安装完成后输出:

```
hyperledger/fabric-ca          latest          72617b4fa9b4   5 weeks ago    299 MB
hyperledger/fabric-ca          x86_64-1.1.0    72617b4fa9b4   5 weeks ago    299 MB
hyperledger/fabric-tools       latest          b7bfddf508bc   5 weeks ago    1.46 GB
hyperledger/fabric-tools       x86_64-1.1.0    b7bfddf508bc   5 weeks ago    1.46 GB
hyperledger/fabric-orderer     latest          ce0c810df36a   5 weeks ago    180 MB
hyperledger/fabric-orderer     x86_64-1.1.0    ce0c810df36a   5 weeks ago    180 MB
hyperledger/fabric-peer        latest          b023f9be0771   5 weeks ago    187 MB
hyperledger/fabric-peer        x86_64-1.1.0    b023f9be0771   5 weeks ago    187 MB
hyperledger/fabric-javaenv     latest          82098abb1a17   5 weeks ago    1.52 GB
hyperledger/fabric-javaenv     x86_64-1.1.0    82098abb1a17   5 weeks ago    1.52 GB
hyperledger/fabric-ccenv       latest          c8b4909d8d46   5 weeks ago    1.39 GB
hyperledger/fabric-ccenv       x86_64-1.1.0    c8b4909d8d46   5 weeks ago    1.39 GB
hyperledger/fabric-zookeeper   latest          92cbb952b6f8   2 months ago   1.39 GB
hyperledger/fabric-zookeeper   x86_64-0.4.6    92cbb952b6f8   2 months ago   1.39 GB
hyperledger/fabric-kafka       latest          554c591b86a8   2 months ago   1.4 GB
hyperledger/fabric-kafka       x86_64-0.4.6    554c591b86a8   2 months ago   1.4 GB
hyperledger/fabric-couchdb     latest          7e73c828fc5b   2 months ago   1.56 GB
hyperledger/fabric-couchdb     x86_64-0.4.6    7e73c828fc5b   2 months ago   1.56 GB
```

#### 添加环境变量

```
$ export PATH=<path to download location>/bin:$PATH
```

注: <path to download location>表示下载的`fabric-samples`文件目录所在路径

```
例:  $ export PATH=$HOME/hyfa/fabric-samples/bin:$PATH
```



`HyperLedger Fabric`环境搭建完成



