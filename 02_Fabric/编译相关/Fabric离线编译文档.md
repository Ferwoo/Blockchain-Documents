[TOC]

以下将使用${Hyperledger} 代表该文件夹路径。

# 1 编译Fabric镜像

### 1.1 编译fabric依赖的基础镜像

目标：编译出fabric所依赖的以下基础镜像：

fabric-zookeeper、fabric-kafka、fabric-baseimage、fabric-basejvm、fabric-baseos 。

##### 1.1.1: 加载底层suse基础系统镜像

```bash
$ docker load -i sles12sp3.tar              #加载suse的基础镜像
$ docker images
197.3.16.51/public/sles12sp3：20181114001   #基础镜像名称以及tag
```

##### 1.1.2: 编译fabric依赖的基础镜像

```bash
$ cd ${Hyperledger}/
$ git clone http://121.40.145.42/minsheng/fabric-baseimage.git  #下载fabric-baseimage包
$ cd fabric-baseimage
$ make clean                                                 #删除之前的编译文件
$ make
```

该编译过程会因机器性能差异而持续不同时间，需要耐心等待；编译完成之后，会查看到以下镜像：	

![baseimages](typoraImages/baseimages.png)

### 1.2 编译fabric

目标：编译出fabric镜像：fabric-yxbaseos、fabric-tools、fabric-ccenv、fabric-orderer、fabric-peer。

```bash
$ cd ${Hyperledger}/
$ git clone http://121.40.145.42/minsheng/fabric1.4.git   #下载yunphant Fabric离线编译包
$ cd fabric
$ make clean                        #删除之前的编译文件
$ make
```

> **注意**：编译时，需要把fabric代码放到$GOPATH/src/github.com/hyperledger/目录下进行。

至此，编译完成后，docker images命令会查看到以下镜像：

![截屏2019-10-17上午10.50.22](typoraImages/截屏2019-10-17上午10.50.22.png)

# 2 上传镜像到私有仓库

执行upload_fabric_images.sh脚本上传fabric相关镜像到私有仓库

```shell
$ cd Hyperledger/Fabric/
$ ./upload_fabric_images.sh
请输入docker仓库host:   #输入上传镜像仓库IP  
```

> 注意：上传镜像操作前提是已经得到仓库服务器的授权，可查看当前用户home目录下是否存在.docker/config.json文件，且该文件有此仓库的登录授权信息。如无，则需要执行
>
> docker login ${仓库IP}
>
> 进行登录以完成授权。



####附件 上传私有仓库脚本

**upload_fabric_images.sh**

功能：将编译好的fabric相关镜像设置tag后批量上传到私有仓库

```bash
# !/bin/bash
set -e
userid="$(id -u)"
if [ "$userid" = "0" ]; then
    SUDO=""
else
    SUDO="sudo"
fi

read -r -p "请输入docker 仓库 host:" registry_host

echo "upload time: [$(date +"%Y-%m-%d %H:%M:%S")]" > tag.txt
for name_tag in $(docker images | grep "hyperledger/fabric" | awk '{print $1":"$2}')
do
    if [ $(echo ${name_tag} | grep ${registry_host}) ="" ]; then
        docker tag ${name_tag} ${registry_host}/baas/${name_tag}
        docker push ${registry_host}/baas/${name_tag}
        echo "${registry_host}/${name_tag}" >> tag.txt
    fi
done

echo "Successful!"
```

