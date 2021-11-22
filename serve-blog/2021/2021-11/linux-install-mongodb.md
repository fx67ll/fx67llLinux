# 详解在Linux中安装配置MongoDB  

最近在整理自己私人服务器上的各种阿猫阿狗，正好就顺手详细记录一下清理之后重装的步骤，今天先写点数据库的内容，关于在`Linux`中安装配置`MongoDB`  
说实话为什么会装`MongoDB`呢，因为之前因为公司需要做点`Nodejs`的中间件，我顺手玩了一下`MongoDB`的`CRUD`，文档型数据库还是挺有意思的  

### 安装环境
CentOS7 + MongoDB4.4

### 下载安装包
[mongodb-4.4.4 版本下载地址（点击链接直接下载）](https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.4.4.tgz)  

### 操作步骤
1. 利用 xFtp 上传 `mongodb.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/mongodb-linux-x86_64-rhel70-4.4.4.tgz -C /usr/soft/install/`
3. 配置环境变量
	> `vim /etc/profile`
4. 在文件的最后一行添加如下内容
	> 按 `i` 开始修改（注意 `s` 会删除当前选中字符）  
	> `export PATH=$PATH:/usr/soft/install/mongodb-linux-x86_64-rhel70-4.4.4/bin`  
	> 按 `esc` 停止编辑，按 `:` 开始输入，输入 `wq` 保存并退出  
	> 之前都会用一个别名来拼接地址，其实直接写完整地址也可以，`$PATH` 应该是代指之前存有的 `PATH变量`  
5. 输入 `source /etc/profile` ，无报错立即生效
6. 创建数据存放文件夹和日志记录文件夹，为后面的配置文件使用
	> 在主目录下创建 `/data/db` 来存放数据  
	> 在主目录下创建 `logs` 来存放日志  
7. 创建运行时使用的配置文件
	> 在主目录下进入bin目录 `cd /bin`  
	> 创建配置文件 `vim mongodb.conf`  
	> 输入以下配置（一定要写完整地址，教程上面是相对地址，结果我启动的时候一直报配置错误）  
	> `dbpath = /usr/soft/install/mongodb-linux-x86_64-rhel70-4.4.4/data/db  # 数据文件存放目录`  
	> `logpath = /usr/soft/install/mongodb-linux-x86_64-rhel70-4.4.4/logs  # 日志文件存放目录`  
	> `port = 27017  # 端口`  
	> `fork = true  # 以守护程序的方式启用，即在后台运行`  
	> `# auth=true  # 需要认证，如果放开注释，就必须创建MongoDB的账号，使用账号与密码才可远程访问，第一次安装建议注释`  
	> `bind_ip = 0.0.0.0  # 允许远程访问，或者直接注释，127.0.0.1是只允许本地访问`  
	> 注意如果不创建账号，是可以直连数据库的，但是创建了账号之后是不能直连的必须要带账号密码才可以连接，例如下面这样  
	> `mongodb://root:******@xxx.xxx.xxx.xxx:27017/test?authSource=admin&readPreference=primary&ssl=false`  
	> 问号后面内容后期了解清楚，之前不加一直无法连接上  
	> 注意：注释符号 `#` 和数据之间必须是一个空格  
8. 测试运行和关闭数据库
	> 在主目录下进入bin目录 `cd /bin`  
	> 启动 `./mongod -f mongodb.conf`  
	> 关闭 `pkill mongod`（教程介绍了三种方法，目前我只有这一种命令成功了）  
	> 检查端口是否已经被占用 `netstat -nltp|grep 27017` 或者 `top`  
9. 相关错误提示
	> `child process failed,existed with error number 1` 之类的错误是配置文件写错，之前就是相对地址而不是全地址导致一直报这个错没有成功运行  
	> `Mongodb enable authentication` 开启了权限或者是创建了账户密码，就需要使用用户名密码连接登录，裸连会直接报这个没有权限的错误  


[参考资料一 ———— Linux安装、运行MongoDB](https://blog.csdn.net/yzh_1346983557/article/details/81735755)  
[参考资料二 ———— 在Linux服务器中配置mongodb环境的步骤](https://www.jb51.net/article/119514.htm)  
[参考资料三 ———— ERROR: child process failed, exited with error number 1](https://blog.csdn.net/Dn1115680109/article/details/88754067)  


我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2021/2021-11/linux-install-mongodb.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***