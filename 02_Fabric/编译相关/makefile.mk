
# Copyright IBM Corp All Rights Reserved.
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# -------------------------------------------------------------
# This makefile defines the following targets
#
# make项列表
#
# 构建所有
#   - all (default) - builds all targets and runs all non-integration tests/checks
# 运行所有测试和检查
#   - checks - runs all non-integration tests/checks
# 运行linter和verify来检查改动的文件
#   - desk-check - runs linters and verify to test changed packages
# 构建configtxgen，主要用来创建创世块、创建通道时的配置交易、更新通道的锚点交易
#   - configtxgen - builds a native configtxgen binary
# 构建configtxlator，configtxgen生成的配置是二进制，使用configtxlator转换为json
#   - configtxlator - builds a native configtxlator binary
# 构建cryptogen，提供加解密的程序
#   - cryptogen  -  builds a native cryptogen binary
# 构建idemixgen，用来创建身份（id）混合器创建配置文件
#   - idemixgen  -  builds a native idemixgen binary
# peer节点
#   - peer - builds a native fabric peer binary
# 排序节点
#   - orderer - builds a native fabric orderer binary
# 发布当前平台的包
#   - release - builds release packages for the host platform
# 发布所有平台的包
#   - release-all - builds release packages for all target platforms
# 跑单元测试
#   - unit-test - runs the go-test based unit tests
# 对更改过的文件跑单元测试
#   - verify - runs unit tests for only the changed package tree
# 以coverprofile模式对所有pkg跑单元测试
#   - profile - runs unit tests for all packages in coverprofile mode (slow)
#   - test-cmd - generates a "go test" string suitable for manual customization
# 安装go tools，TODO 安装到哪，镜像还是外部GOPATH下？
#   - gotools - installs go tools like golint
# 对所有代码运行lint
#   - linter - runs all code checks
# 检查dep依赖
#   - check-deps - check for vendored dependencies that are no longer used
# 检查所有代码Apache license
#   - license - checks go source files for Apache license header
# 构建所有的native程序，包含peer，orderer等
#   - native - ensures all native binaries are available
# 构建所有的docker镜像，docker-clean为清除镜像
#   - docker[-clean] - ensures all docker images are available[/cleaned]
# 列出所有相关的docker镜像
#   - docker-list - generates a list of docker images that 'make docker' produces
# 构建peer-docker镜像
#   - peer-docker[-clean] - ensures the peer container is available[/cleaned]
# 构建orderer-docker镜像
#   - orderer-docker[-clean] - ensures the orderer container is available[/cleaned]
# 构建tools-docker镜像
#   - tools-docker[-clean] - ensures the tools container is available[/cleaned]
# 基于.proto文件生成所有的protobuf文件
#   - protos - generate all protobuf artifacts based on .proto files
# 清理所有构建数据
#   - clean - cleans the build area
# 比clean更牛，还会清理掉持久状态数据
#   - clean-all - superset of 'clean' that also removes persistent state
# 清理发布的包
#   - dist-clean - clean release packages for all target platforms
# 清理单元测试状态数据
#   - unit-test-clean - cleans unit test state (particularly from docker)
# 执行基本的检查，比如license，拼写，lint等
#   - basic-checks - performs basic checks like license, spelling, trailing spaces and linter
# CI使用的选项
#   - enable_ci_only_tests - triggers unit-tests in downstream jobs. Applicable only for CI not to
#     use in the local machine.
# 拉去第三方docker镜像
#   - docker-thirdparty - pulls thirdparty images (kafka,zookeeper,couchdb)
# 把所有make docker所产生的镜像，打上latest tag
#   - docker-tag-latest - re-tags the images made by 'make docker' with the :latest tag
# 把所有make docker所产生的镜像，打上stable tag
#   - docker-tag-stable - re-tags the images made by 'make docker' with the :stable tag
# 生成命令参考文档
#   - help-docs - generate the command reference docs

# 基础版本
BASE_VERSION = 1.4.2
# 前一个版本
PREV_VERSION = 1.4.1
# chaintool版本
CHAINTOOL_RELEASE=1.1.3
# 基础镜像版本
BASEIMAGE_RELEASE=0.4.15

# 设置项目名称，如果没有设置，则使用hyperledger
# Allow to build as a submodule setting the main project to
# the PROJECT_NAME env variable, for example,
# export PROJECT_NAME=hyperledger/fabric-test
ifeq ($(PROJECT_NAME),true)
PROJECT_NAME = $(PROJECT_NAME)/fabric
else
PROJECT_NAME = hyperledger/fabric
endif

# 构建路径
# ?=指当没有指定BUILD_DIR时，才使用默认的`.build`作为构建目录
BUILD_DIR ?= .build
# 未知，全文未使用
NEXUS_REPO = nexus3.hyperledger.org:10001/hyperledger

# 额外版本：git commit号
EXTRA_VERSION ?= $(shell git rev-parse --short HEAD)
# 项目版本由基础版本和额外版本组成
PROJECT_VERSION=$(BASE_VERSION)-snapshot-$(EXTRA_VERSION)

# Go编译信息
# 设置包名
PKGNAME = github.com/$(PROJECT_NAME)
# CGO编译选项
CGO_FLAGS = CGO_CFLAGS=" "
# 当前CPU架构
ARCH=$(shell go env GOARCH)
# OS和CPU架构
MARCH=$(shell go env GOOS)-$(shell go env GOARCH)

# Go编译时传入的版本信息，主要是docker相关信息，比如
## var Version string = "latest"
## var CommitSHA string = "development build"
## var BaseVersion string = "0.4.15"
## var BaseDockerLabel string = "org.hyperledger.fabric"
## var DockerNamespace string = "hyperledger"
## var BaseDockerNamespace string = "hyperledger"

# defined in common/metadata/metadata.go
METADATA_VAR = Version=$(BASE_VERSION)
METADATA_VAR += CommitSHA=$(EXTRA_VERSION)
METADATA_VAR += BaseVersion=$(BASEIMAGE_RELEASE)
METADATA_VAR += BaseDockerLabel=$(BASE_DOCKER_LABEL)
METADATA_VAR += DockerNamespace=$(DOCKER_NS)
METADATA_VAR += BaseDockerNamespace=$(BASE_DOCKER_NS)

# 使用GO_LDFLAGS设置go的ldflag信息，传入METADATA_VAR
# patsubst指替换通配符
GO_LDFLAGS = $(patsubst %,-X $(PKGNAME)/common/metadata.%,$(METADATA_VAR))

GO_TAGS ?=

# chaintool下载链接
CHAINTOOL_URL ?= https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/chaintool-$(CHAINTOOL_RELEASE)/hyperledger-fabric-chaintool-$(CHAINTOOL_RELEASE).jar

export GO_LDFLAGS GO_TAGS

# 检查go、docker、git、curl这几个程序是否存在
EXECUTABLES ?= go docker git curl
K := $(foreach exec,$(EXECUTABLES),\
	$(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH: Check dependencies")))

# Go shim的依赖项，shim是chaincode的一个模块，可以先不去理解
GOSHIM_DEPS = $(shell ./scripts/goListFiles.sh $(PKGNAME)/core/chaincode/shim)

# protobuf相关的文件
PROTOS = $(shell git ls-files *.proto | grep -Ev 'vendor/|testdata/')

# 项目文件，不包含git、样例、图片、vendor等文件
# No sense rebuilding when non production code is changed
PROJECT_FILES = $(shell git ls-files  | grep -v ^test | grep -v ^unit-test | \
	grep -v ^.git | grep -v ^examples | grep -v ^devenv | grep -v .png$ | \
	grep -v ^LICENSE | grep -v ^vendor )
# docker镜像发布模板
RELEASE_TEMPLATES = $(shell git ls-files | grep "release/templates")
# 镜像列表
IMAGES = peer orderer ccenv buildenv tools
# 发布平台
RELEASE_PLATFORMS = windows-amd64 darwin-amd64 linux-amd64 linux-s390x linux-ppc64le
# 发布的package
RELEASE_PKGS = configtxgen cryptogen idemixgen discover configtxlator peer orderer

# 要发的pkg和它们的路径
pkgmap.cryptogen      := $(PKGNAME)/common/tools/cryptogen
pkgmap.idemixgen      := $(PKGNAME)/common/tools/idemixgen
pkgmap.configtxgen    := $(PKGNAME)/common/tools/configtxgen
pkgmap.configtxlator  := $(PKGNAME)/common/tools/configtxlator
pkgmap.peer           := $(PKGNAME)/peer
pkgmap.orderer        := $(PKGNAME)/orderer
pkgmap.block-listener := $(PKGNAME)/examples/events/block-listener
pkgmap.discover       := $(PKGNAME)/cmd/discover

# 把docker-env.mk包含进来，主要是docker构建相关的选项
include docker-env.mk

# all包含/依赖了编译程序、编译镜像和进行检查
# all会进行检查，本地编译和发布docker镜像
all: native docker checks

# 检查包含/依赖了基本检查、单元测试和集成测试
checks: basic-checks unit-test integration-test

# 基本检查指许可证、拼写和格式
basic-checks: license spelling trailing-spaces linter check-metrics-doc

# 包含/依赖检查和验证
desk-check: checks verify

help-docs: native
	@scripts/generateHelpDocs.sh

# 拉取第三方镜像，并打上tag，BASE_DOCKER_TAG定义在docker-env.mk
# 都是fabric定制的couchdb、zookeeper、kafka镜像
# Pull thirdparty docker images based on the latest baseimage release version
.PHONY: docker-thirdparty
docker-thirdparty:
	docker pull $(BASE_DOCKER_NS)/fabric-couchdb:$(BASE_DOCKER_TAG)
	docker tag $(BASE_DOCKER_NS)/fabric-couchdb:$(BASE_DOCKER_TAG) $(DOCKER_NS)/fabric-couchdb
	docker pull $(BASE_DOCKER_NS)/fabric-zookeeper:$(BASE_DOCKER_TAG)
	docker tag $(BASE_DOCKER_NS)/fabric-zookeeper:$(BASE_DOCKER_TAG) $(DOCKER_NS)/fabric-zookeeper
	docker pull $(BASE_DOCKER_NS)/fabric-kafka:$(BASE_DOCKER_TAG)
	docker tag $(BASE_DOCKER_NS)/fabric-kafka:$(BASE_DOCKER_TAG) $(DOCKER_NS)/fabric-kafka

# 调用脚本执行拼写检查
.PHONY: spelling
spelling:
	@scripts/check_spelling.sh

# 调用脚本执行许可证检查
.PHONY: license
license:
	@scripts/check_license.sh

# 调用脚本执行末尾空格检查
.PHONY: trailing-spaces
trailing-spaces:
	@scripts/check_trailingspaces.sh

# 包含gotools.mk，这个文件主要用来安装一些gotools，可以使用单个命令来装某个gotools，比如安装dep
# `make gotool.dep`，具体见该文件
include gotools.mk

# 实际调用gotools-install安装相关的gotools
.PHONY: gotools
gotools: gotools-install

# 以下这段设置是各程序的依赖
# 编译peer，依赖./build/bin/peer
# 编译peer-docker，依赖./build/image/peer/$(DUMMY)，DUMMY指DOCKER-TAG，定义在docker-env.mk
.PHONY: peer
peer: $(BUILD_DIR)/bin/peer
peer-docker: $(BUILD_DIR)/image/peer/$(DUMMY)

# orderer和镜像的依赖
.PHONY: orderer
orderer: $(BUILD_DIR)/bin/orderer
orderer-docker: $(BUILD_DIR)/image/orderer/$(DUMMY)

# 编译configtxgen的依赖
.PHONY: configtxgen
configtxgen: GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.CommitSHA=$(EXTRA_VERSION)
configtxgen: $(BUILD_DIR)/bin/configtxgen

# 编译configtxlator的依赖
configtxlator: GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.CommitSHA=$(EXTRA_VERSION)
configtxlator: $(BUILD_DIR)/bin/configtxlator

# 编译cryptogen的依赖
cryptogen: GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.CommitSHA=$(EXTRA_VERSION)
cryptogen: $(BUILD_DIR)/bin/cryptogen

# 编译idemixgen的依赖
idemixgen: GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.CommitSHA=$(EXTRA_VERSION)
idemixgen: $(BUILD_DIR)/bin/idemixgen

# 编译discover的依赖
discover: GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.Version=$(PROJECT_VERSION)
discover: $(BUILD_DIR)/bin/discover

# 编译tools相关的docker
tools-docker: $(BUILD_DIR)/image/tools/$(DUMMY)

# 生成构建环境（buildenv)镜像
buildenv: $(BUILD_DIR)/image/buildenv/$(DUMMY)

# 未知
ccenv: $(BUILD_DIR)/image/ccenv/$(DUMMY)

# 进行集成测试
.PHONY: integration-test
integration-test: gotool.ginkgo ccenv docker-thirdparty
	./scripts/run-integration-tests.sh

# 进行单元测试
unit-test: unit-test-clean peer-docker docker-thirdparty ccenv
	unit-test/run.sh

# 进行单元测试
unit-tests: unit-test

# CI选项
enable_ci_only_tests: unit-test

# 运行verify，就像注释说的，依然是单元测试
verify: export JOB_TYPE=VERIFY
verify: unit-test

# 运行带有profile的单元测试
profile: export JOB_TYPE=PROFILE
profile: unit-test

# Generates a string to the terminal suitable for manual augmentation / re-issue, useful for running tests by hand
test-cmd:
	@echo "go test -tags \"$(GO_TAGS)\""

# 编译所有docker镜像，依赖都是.build/image下
docker: $(patsubst %,$(BUILD_DIR)/image/%/$(DUMMY), $(IMAGES))

# 编译所有native程序，native指所有fabric本身的程序，依赖如下
native: peer orderer configtxgen cryptogen idemixgen configtxlator discover

# 运行linter
linter: check-deps buildenv
	@echo "LINT: Running code checks.."
	@$(DRUN) $(DOCKER_NS)/fabric-buildenv:$(DOCKER_TAG) ./scripts/golinter.sh

# 运行check-deps
check-deps: buildenv
	@echo "DEP: Checking for dependency issues.."
	@$(DRUN) $(DOCKER_NS)/fabric-buildenv:$(DOCKER_TAG) ./scripts/check_deps.sh

# 运行check-metrics-doc
check-metrics-doc: buildenv
	@echo "METRICS: Checking for outdated reference documentation.."
	@$(DRUN) $(DOCKER_NS)/fabric-buildenv:$(DOCKER_TAG) ./scripts/metrics_doc.sh check

# 运行generate-metrics-doc
generate-metrics-doc: buildenv
	@echo "Generating metrics reference documentation..."
	@$(DRUN) $(DOCKER_NS)/fabric-buildenv:$(DOCKER_TAG) ./scripts/metrics_doc.sh generate

# 安装chain tool
$(BUILD_DIR)/%/chaintool: Makefile
	@echo "Installing chaintool"
	@mkdir -p $(@D)
	curl -fL $(CHAINTOOL_URL) > $@
	chmod +x $@

# We (re)build a package within a docker context but persist the $GOPATH/pkg
# directory so that subsequent builds are faster
# 构建所有镜像和pkg
# DRUN是`docker run`和参数的简写
# 本地创建docker里要用到的gopath目录，然后挂载到docker里
# 然后在docker里按个编译pkgmap里面的程序，比如peer、orderer、cryptogen等等
$(BUILD_DIR)/docker/bin/%: $(PROJECT_FILES)
	$(eval TARGET = ${patsubst $(BUILD_DIR)/docker/bin/%,%,${@}})
	@echo "Building $@"
	@mkdir -p $(BUILD_DIR)/docker/bin $(BUILD_DIR)/docker/$(TARGET)/pkg
	@$(DRUN) \
		-v $(abspath $(BUILD_DIR)/docker/bin):/opt/gopath/bin \
		-v $(abspath $(BUILD_DIR)/docker/$(TARGET)/pkg):/opt/gopath/pkg \
		$(BASE_DOCKER_NS)/fabric-baseimage:$(BASE_DOCKER_TAG) \
		go install -tags "$(GO_TAGS)" -ldflags "$(DOCKER_GO_LDFLAGS)" $(pkgmap.$(@F))
	@touch $@

# 创建本地bin目录
$(BUILD_DIR)/bin:
	mkdir -p $@

# 运行changelog
changelog:
	./scripts/changelog.sh v$(PREV_VERSION) v$(BASE_VERSION)

# protoc-gen-go依赖.build/docker/gotools
$(BUILD_DIR)/docker/gotools/bin/protoc-gen-go: $(BUILD_DIR)/docker/gotools

# 构建go tools的docker镜像，给payload使用
# 创建本地目录(.build/docker/gotools)并挂载到(/opt/gotools)，依赖基础镜像，然后在docker中执行gotools.mk
# 最后调用gotools.mk生成程序，设置了GOTOOLS_BINDIR，生成的二进制会放在这个目录，因为这个目录映射了出来，
# 所以bin就在主机的`.build/docker/gotools/bin/`目录
# So, 如果构建成功，不需要像其他文章说的那样，需要手动拷贝protoc-gen-go到`.build/docker/gotools/bin/`目录
# 但是，如果翻墙失败，可以考虑手动复制protoc-gen-go的方式
$(BUILD_DIR)/docker/gotools: gotools.mk
	@echo "Building dockerized gotools"
	@mkdir -p $@/bin $@/obj
	@$(DRUN) \
		-v $(abspath $@):/opt/gotools \
		-w /opt/gopath/src/$(PKGNAME) \
		$(BASE_DOCKER_NS)/fabric-baseimage:$(BASE_DOCKER_TAG) \
		make -f gotools.mk GOTOOLS_BINDIR=/opt/gotools/bin GOTOOLS_GOPATH=/opt/gotools/obj

# 构建本地的运行文件，依赖设置都在上面了，这是进行构建，与Docker类似
# 程序即pkgmap中的程序
$(BUILD_DIR)/bin/%: $(PROJECT_FILES)
	@mkdir -p $(@D)
	@echo "$@"
	$(CGO_FLAGS) GOBIN=$(abspath $(@D)) go install -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))
	@echo "Binary available as $@"
	@touch $@

# 设置各镜像各自的payload文件
# 比如ccenv的payload拷贝会翻译成：cp .build/docker/gotools/bin/protoc-gen-go .build/bin/chaintool .build/goshim.tar.bz2 .build/image/ccenv/payload
# payload definitions'
$(BUILD_DIR)/image/ccenv/payload:      $(BUILD_DIR)/docker/gotools/bin/protoc-gen-go \
				$(BUILD_DIR)/bin/chaintool \
				$(BUILD_DIR)/goshim.tar.bz2
$(BUILD_DIR)/image/peer/payload:       $(BUILD_DIR)/docker/bin/peer \
				$(BUILD_DIR)/sampleconfig.tar.bz2
$(BUILD_DIR)/image/orderer/payload:    $(BUILD_DIR)/docker/bin/orderer \
				$(BUILD_DIR)/sampleconfig.tar.bz2
$(BUILD_DIR)/image/buildenv/payload:   $(BUILD_DIR)/gotools.tar.bz2 \
				$(BUILD_DIR)/docker/gotools/bin/protoc-gen-go

# 各镜像payload的实际拷贝
$(BUILD_DIR)/image/%/payload:
	mkdir -p $@
	cp $^ $@

.PRECIOUS: $(BUILD_DIR)/image/%/Dockerfile

# 根据image下的各目录中的Dockerfile.in生成对应的Dockerfile
$(BUILD_DIR)/image/%/Dockerfile: images/%/Dockerfile.in
	mkdir -p $(@D)
	@cat $< \
		| sed -e 's|_BASE_NS_|$(BASE_DOCKER_NS)|g' \
		| sed -e 's|_NS_|$(DOCKER_NS)|g' \
		| sed -e 's|_BASE_TAG_|$(BASE_DOCKER_TAG)|g' \
		| sed -e 's|_TAG_|$(DOCKER_TAG)|g' \
		> $@
	@echo LABEL $(BASE_DOCKER_LABEL).version=$(BASE_VERSION) \\>>$@
	@echo "     " $(BASE_DOCKER_LABEL).base.version=$(BASEIMAGE_RELEASE)>>$@

# 根据Dockerfile生成tools-image，并打上2个tag，分别是当前版本tag和latest tag
$(BUILD_DIR)/image/tools/$(DUMMY): $(BUILD_DIR)/image/tools/Dockerfile
	$(eval TARGET = ${patsubst $(BUILD_DIR)/image/%/$(DUMMY),%,${@}})
	@echo "Building docker $(TARGET)-image"
	$(DBUILD) -t $(DOCKER_NS)/fabric-$(TARGET) -f $(@D)/Dockerfile .
	docker tag $(DOCKER_NS)/fabric-$(TARGET) $(DOCKER_NS)/fabric-$(TARGET):$(DOCKER_TAG)
	docker tag $(DOCKER_NS)/fabric-$(TARGET) $(DOCKER_NS)/fabric-$(TARGET):$(ARCH)-latest
	@touch $@

# 根据Dockerfile、payload生成image下的所有镜像，比如orderer，然后打上tag
$(BUILD_DIR)/image/%/$(DUMMY): Makefile $(BUILD_DIR)/image/%/payload $(BUILD_DIR)/image/%/Dockerfile
	$(eval TARGET = ${patsubst $(BUILD_DIR)/image/%/$(DUMMY),%,${@}})
	@echo "Building docker $(TARGET)-image"
	$(DBUILD) -t $(DOCKER_NS)/fabric-$(TARGET) $(@D)
	docker tag $(DOCKER_NS)/fabric-$(TARGET) $(DOCKER_NS)/fabric-$(TARGET):$(DOCKER_TAG)
	docker tag $(DOCKER_NS)/fabric-$(TARGET) $(DOCKER_NS)/fabric-$(TARGET):$(ARCH)-latest
	@touch $@

# 打包gotools
$(BUILD_DIR)/gotools.tar.bz2: $(BUILD_DIR)/docker/gotools
	(cd $</bin && tar -jc *) > $@

# 打包goshim
$(BUILD_DIR)/goshim.tar.bz2: $(GOSHIM_DEPS)
	@echo "Creating $@"
	@tar -jhc -C $(GOPATH)/src $(patsubst $(GOPATH)/src/%,%,$(GOSHIM_DEPS)) > $@

# 打包sampleconfig
$(BUILD_DIR)/sampleconfig.tar.bz2: $(shell find sampleconfig -type f)
	(cd sampleconfig && tar -jc *) > $@

# 打包protos
$(BUILD_DIR)/protos.tar.bz2: $(PROTOS)

$(BUILD_DIR)/%.tar.bz2:
	@echo "Creating $@"
	@tar -jc $^ > $@

# 发布当前平台的relase包
# builds release packages for the host platform
release: $(patsubst %,release/%, $(MARCH))

# builds release packages for all target platforms
release-all: $(patsubst %,release/%, $(RELEASE_PLATFORMS))

release/%: GO_LDFLAGS=-X $(pkgmap.$(@F))/metadata.CommitSHA=$(EXTRA_VERSION)

release/windows-amd64: GOOS=windows
release/windows-amd64: $(patsubst %,release/windows-amd64/bin/%, $(RELEASE_PKGS))

release/darwin-amd64: GOOS=darwin
release/darwin-amd64: $(patsubst %,release/darwin-amd64/bin/%, $(RELEASE_PKGS))

release/linux-amd64: GOOS=linux
release/linux-amd64: $(patsubst %,release/linux-amd64/bin/%, $(RELEASE_PKGS))

release/%-amd64: GOARCH=amd64
release/linux-%: GOOS=linux

release/linux-s390x: GOARCH=s390x
release/linux-s390x: $(patsubst %,release/linux-s390x/bin/%, $(RELEASE_PKGS))

release/linux-ppc64le: GOARCH=ppc64le
release/linux-ppc64le: $(patsubst %,release/linux-ppc64le/bin/%, $(RELEASE_PKGS))

release/%/bin/configtxlator: $(PROJECT_FILES)
	@echo "Building $@ for $(GOOS)-$(GOARCH)"
	mkdir -p $(@D)
	$(CGO_FLAGS) GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(abspath $@) -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))

release/%/bin/configtxgen: $(PROJECT_FILES)
	@echo "Building $@ for $(GOOS)-$(GOARCH)"
	mkdir -p $(@D)
	$(CGO_FLAGS) GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(abspath $@) -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))

release/%/bin/cryptogen: $(PROJECT_FILES)
	@echo "Building $@ for $(GOOS)-$(GOARCH)"
	mkdir -p $(@D)
	$(CGO_FLAGS) GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(abspath $@) -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))

release/%/bin/idemixgen: $(PROJECT_FILES)
	@echo "Building $@ for $(GOOS)-$(GOARCH)"
	mkdir -p $(@D)
	$(CGO_FLAGS) GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(abspath $@) -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))

release/%/bin/discover: $(PROJECT_FILES)
	@echo "Building $@ for $(GOOS)-$(GOARCH)"
	mkdir -p $(@D)
	$(CGO_FLAGS) GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(abspath $@) -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))

release/%/bin/orderer: GO_LDFLAGS = $(patsubst %,-X $(PKGNAME)/common/metadata.%,$(METADATA_VAR))

release/%/bin/orderer: $(PROJECT_FILES)
	@echo "Building $@ for $(GOOS)-$(GOARCH)"
	mkdir -p $(@D)
	$(CGO_FLAGS) GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(abspath $@) -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))

release/%/bin/peer: GO_LDFLAGS = $(patsubst %,-X $(PKGNAME)/common/metadata.%,$(METADATA_VAR))

release/%/bin/peer: $(PROJECT_FILES)
	@echo "Building $@ for $(GOOS)-$(GOARCH)"
	mkdir -p $(@D)
	$(CGO_FLAGS) GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(abspath $@) -tags "$(GO_TAGS)" -ldflags "$(GO_LDFLAGS)" $(pkgmap.$(@F))

.PHONY: dist
dist: dist-clean dist/$(MARCH)

dist-all: dist-clean $(patsubst %,dist/%, $(RELEASE_PLATFORMS))

dist/%: release/%
	mkdir -p release/$(@F)/config
	cp -r sampleconfig/*.yaml release/$(@F)/config
	cd release/$(@F) && tar -czvf hyperledger-fabric-$(@F).$(PROJECT_VERSION).tar.gz *

# 在docker中生成protobuf文件
.PHONY: protos
protos: buildenv
	@$(DRUN) $(DOCKER_NS)/fabric-buildenv:$(DOCKER_TAG) ./scripts/compile_protos.sh

%-docker-list:
	$(eval TARGET = ${patsubst %-docker-list,%,${@}})
	@echo $(DOCKER_NS)/fabric-$(TARGET):$(DOCKER_TAG)

# 列出当前所有镜像
docker-list: $(patsubst %,%-docker-list, $(IMAGES))

%-docker-clean:
	$(eval TARGET = ${patsubst %-docker-clean,%,${@}})
	-docker images --quiet --filter=reference='$(DOCKER_NS)/fabric-$(TARGET):$(ARCH)-$(BASE_VERSION)$(if $(EXTRA_VERSION),-snapshot-*,)' | xargs docker rmi -f
	-@rm -rf $(BUILD_DIR)/image/$(TARGET) ||:

# 清理所有镜像
docker-clean: $(patsubst %,%-docker-clean, $(IMAGES))

docker-tag-latest: $(IMAGES:%=%-docker-tag-latest)

%-docker-tag-latest:
	$(eval TARGET = ${patsubst %-docker-tag-latest,%,${@}})
	docker tag $(DOCKER_NS)/fabric-$(TARGET):$(DOCKER_TAG) $(DOCKER_NS)/fabric-$(TARGET):latest

docker-tag-stable: $(IMAGES:%=%-docker-tag-stable)

%-docker-tag-stable:
	$(eval TARGET = ${patsubst %-docker-tag-stable,%,${@}})
	docker tag $(DOCKER_NS)/fabric-$(TARGET):$(DOCKER_TAG) $(DOCKER_NS)/fabric-$(TARGET):stable

.PHONY: clean
clean: docker-clean unit-test-clean release-clean
	-@rm -rf $(BUILD_DIR)

# 清理所有状态数据，依赖tools清理，发包清理
.PHONY: clean-all
clean-all: clean gotools-clean dist-clean
	-@rm -rf /var/hyperledger/*
	-@rm -rf docs/build/

# 发布版本清理
.PHONY: dist-clean
dist-clean:
	-@rm -rf release/windows-amd64/hyperledger-fabric-windows-amd64.$(PROJECT_VERSION).tar.gz
	-@rm -rf release/darwin-amd64/hyperledger-fabric-darwin-amd64.$(PROJECT_VERSION).tar.gz
	-@rm -rf release/linux-amd64/hyperledger-fabric-linux-amd64.$(PROJECT_VERSION).tar.gz
	-@rm -rf release/linux-s390x/hyperledger-fabric-linux-s390x.$(PROJECT_VERSION).tar.gz
	-@rm -rf release/linux-ppc64le/hyperledger-fabric-linux-ppc64le.$(PROJECT_VERSION).tar.gz

%-release-clean:
	$(eval TARGET = ${patsubst %-release-clean,%,${@}})
	-@rm -rf release/$(TARGET)

# 发包清理
release-clean: $(patsubst %,%-release-clean, $(RELEASE_PLATFORMS))

# 单元测试清理
.PHONY: unit-test-clean
unit-test-clean:
	cd unit-test && docker-compose down