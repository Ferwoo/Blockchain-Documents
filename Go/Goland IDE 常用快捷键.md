#                                   Goland IDE 常用快捷键

###文件相关快捷键：

```
CTRL+E，打开最近浏览过的文件。  
CTRL+SHIFT+E，打开最近更改的文件。  
CTRL+N，可以快速打开struct结构体。  
CTRL+SHIFT+N，可以快速打开文件。 
```

###代码格式化：

```
CTRL+ALT+T，可以把代码包在一个块内，例如if{…}else{…}。  
CTRL+ALT+L，格式化代码。  
CTRL+空格，代码提示。  
CTRL+/，单行注释。CTRL+SHIFT+/，进行多行注释。  
CTRL+B，快速打开光标处的结构体或方法（跳转到定义处）。  
CTRL+“+/-”，可以将当前方法进行展开或折叠。  
```

###查找和定位：

```
CTRL+R，替换文本。  
CTRL+F，查找文本。  
CTRL+SHIFT+F，进行全局查找。  
CTRL+G，快速定位到某行。  
```

###代码编辑：

```go
ALT+Q，可以看到当前方法的声明。  
CTRL+Backspace，按单词进行删除。  
SHIFT+ENTER，可以向下插入新行，即使光标在当前行的中间。  
CTRL+X，删除当前光标所在行。  
CTRL+D，复制当前光标所在行。  
ALT+SHIFT+UP/DOWN，可以将光标所在行的代码上下移动。  
CTRL+SHIFT+U，可以将选中内容进行大小写转化。 
```





##                                      iTerm2 快捷命令

快捷命令说明：

| 命令                                                 | 说明           |
| ---------------------------------------------------- | -------------- |
| command + t                                          | 新建标签       |
| command + w                                          | 关闭标签       |
| command + 数字 command + 左右方向键                  | 切换标签       |
| command + enter                                      | 切换全屏       |
| command + f                                          | 查找           |
| command + d                                          | 垂直分屏       |
| command + shift + d                                  | 水平分屏       |
| command + option + 方向键 command + [ 或 command + ] | 切换屏幕       |
| command + ;                                          | 查看历史命令   |
| command + shift + h                                  | 查看剪贴板历史 |
| ctrl + u                                             | 清除当前行     |
| ctrl + l                                             | 清屏           |
| ctrl + a                                             | 到行首         |
| ctrl + e                                             | 到行尾         |
| ctrl + f/b                                           | 前进后退       |
| ctrl + p                                             | 上一条命令     |
| ctrl + r                                             | 搜索命令历史   |

​                                                              

                                    ###                                             Mac终端命令



### 目录操作

| 命令名 | 功能描述             | 使用举例         |
| ------ | -------------------- | ---------------- |
| mkdir  | 创建一个目录         | mkdir dirname    |
| rmdir  | 删除一个目录         | rmdir dirname    |
| mvdir  | 移动或重命名一个目录 | mvdir dir1 dir2  |
| cd     | 改变当前目录         | cd dirname       |
| pwd    | 显示当前目录的路径名 | pwd              |
| ls     | 显示当前目录的内容   | ls -la           |
| dircmp | 比较两个目录的内容   | dircmp dir1 dir2 |

#### 文件操作

| 命令名 | 功能描述               | 使用举例                  |
| ------ | ---------------------- | ------------------------- |
| cat    | 显示或连接文件         | cat filename              |
| pg     | 分页格式化显示文件内容 | pg filename               |
| more   | 分屏显示文件内容       | more filename             |
| od     | 显示非文本文件的内容   | od -c filename            |
| cp     | 复制文件或目录         | cp file1 file2            |
| rm     | 删除文件或目录         | rm filename               |
| mv     | 改变文件名或所在目录   | mv file1 file2            |
| ln     | 联接文件               | ln -s file1 file2         |
| find   | 使用匹配表达式查找文件 | find . -name "*.c" -print |
| file   | 显示文件类型           | file filename             |
| open   | 使用默认的程序打开文件 | open filename             |

### 选择操作

| 命令名 | 功能描述                       | 使用举例                     |
| ------ | ------------------------------ | ---------------------------- |
| head   | 显示文件的最初几行             | head -20 filename            |
| tail   | 显示文件的最后几行             | tail -15 filename            |
| cut    | 显示文件每行中的某些域         | cut -f1,7 -d: /etc/passwd    |
| colrm  | 从标准输入中删除若干列         | colrm 8 20 file2             |
| paste  | 横向连接文件                   | paste file1 file2            |
| diff   | 比较并显示两个文件的差异       | diff file1 file2             |
| sed    | 非交互方式流编辑器             | sed "s/red/green/g" filename |
| grep   | 在文件中按模式查找             | grep "^[a-zA-Z]" filename    |
| awk    | 在文件中查找并处理模式         | awk '{print $1 $1}' filename |
| sort   | 排序或归并文件                 | sort -d -f -u file1          |
| uniq   | 去掉文件中的重复行             | uniq file1 file2             |
| comm   | 显示两有序文件的公共和非公共行 | comm file1 file2             |
| wc     | 统计文件的字符数、词数和行数   | wc filename                  |
| nl     | 给文件加上行号                 | nl file1 >file2              |

### 安全操作

| 命令名 | 功能描述               | 使用举例                |
| ------ | ---------------------- | ----------------------- |
| passwd | 修改用户密码           | passwd                  |
| chmod  | 改变文件或目录的权限   | chmod ug+x filename     |
| umask  | 定义创建文件的权限掩码 | umask 027               |
| chown  | 改变文件或目录的属主   | chown newowner filename |
| chgrp  | 改变文件或目录的所属组 | chgrp staff filename    |
| xlock  | 给终端上锁             | xlock -remote           |

### 编程操作

| 命令名 | 功能描述                 | 使用举例                   |
| ------ | ------------------------ | -------------------------- |
| make   | 维护可执行程序的最新版本 | make                       |
| touch  | 更新文件的访问和修改时间 | touch -m 05202400 filename |
| dbx    | 命令行界面调试工具       | dbx a.out                  |
| xde    | 图形用户界面调试工具     | xde a.out                  |

### 进程操作

| 命令名 | 功能描述               | 使用举例         |
| ------ | ---------------------- | ---------------- |
| ps     | 显示进程当前状态       | ps u             |
| kill   | 终止进程               | kill -9 30142    |
| nice   | 改变待执行命令的优先级 | nice cc -c *.c   |
| renice | 改变已运行进程的优先级 | renice +20 32768 |

### 时间操作

| 命令名 | 功能描述                 | 使用举例   |
| ------ | ------------------------ | ---------- |
| date   | 显示系统的当前日期和时间 | date       |
| cal    | 显示日历                 | cal 8 1996 |
| time   | 统计程序的执行时间       | time a.out |

### 网络与通信操作

| 命令名 | 功能描述                          | 使用举例                    |
| ------ | --------------------------------- | --------------------------- |
| telnet | 远程登录                          | telnet hpc.sp.net.edu.cn    |
| rlogin | 远程登录                          | rlogin hostname -l username |
| rsh    | 在远程主机执行指定命令            | rsh f01n03 date             |
| ftp    | 在本地主机与远程主机之间传输文件  | ftp ftp.sp.net.edu.cn       |
| rcp    | 在本地主机与远程主机 之间复制文件 | rcp file1 host1:file2       |
| ping   | 给一个网络主机发送 回应请求       | ping hpc.sp.net.edu.cn      |
| mail   | 阅读和发送电子邮件                | mail                        |
| write  | 给另一用户发送报文                | write username pts/1        |
| mesg   | 允许或拒绝接收报文                | mesg n                      |

### Korn Shell 命令

| 命令名  | 功能描述                        | 使用举例        |
| ------- | ------------------------------- | --------------- |
| history | 列出最近执行过的 几条命令及编号 | history         |
| r       | 重复执行最近执行过的 某条命令   | r -2            |
| alias   | 给某个命令定义别名              | alias del=rm -i |
| unalias | 取消对某个别名的定义            | unalias del     |

### 其它命令

| 命令名 | 功能描述                       | 使用举例     |
| ------ | ------------------------------ | ------------ |
| uname  | 显示操作系统的有关信息         | uname -a     |
| clear  | 清除屏幕或窗口内容             | clear        |
| env    | 显示当前所有设置过的环境变量   | env          |
| who    | 列出当前登录的所有用户         | who          |
| whoami | 显示当前正进行操作的用户名     | whoami       |
| tty    | 显示终端或伪终端的名称         | tty          |
| stty   | 显示或重置控制键定义           | stty -a      |
| du     | 查询磁盘使用情况               | du -k subdir |
| df     | 显示文件系统的总空间和可用空间 | df /tmp      |
| w      | 显示当前系统活动的总信息       | w            |