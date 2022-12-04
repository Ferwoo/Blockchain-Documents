## 版本管理规则

1. 使用release分支发布大版本，使用tag在release分支上发布小版本。
1. release分支名与fabric release分支名关联：fabric使用release-1.4，云象在前面加前缀`yx-`，比如：`yx-release-1.4`。
1. fabric源码会合入到云象的修改版fabric，所以云象的tag也要与fabric原生tag有区分，云象的tag前加`yx-`，为了方便和原生Fabric版本对应 ， **云象`yx-v1.4.2`一定和fabric的`v1.4.2`是对应的** 。
1. 内部测试版本在末尾加`alpha.x`，对外提供版本，即生产环境加`beta-x`。

## 版本发布流程

1. 建立【发布计划】任务
1. 按照版本规划，所有特性、修复都已合并，并且通过CI测试
1. 按照tag规则，打tag，发布release
1. 为当前版本构建docker镜像，并把带`*-snapshot-*`的镜像，推到镜像仓库
1. 把tag、commit、镜像信息等填写到【发布计划】任务





