# Linux 学习笔记

### Linux 服务器初始化配置步骤
1. 下载Xshell和Xftp家庭中文版
2. 用服务器提供商提供的账号密码创建连接
3. 艹，太几把坑了，添加一个用户组的命令是groupadd而不是addgroup，教程有误请注意
	> `groupadd admin`
4. 添加一个用户名
	> `useradd -d /home/fx67ll -s /bin/bash -m fx67ll`  
	> 上面命令中，参数d指定用户的主目录，参数s指定用户的shell，参数m表示如果该目录不存在，则创建该目录  
5. 设置用户密码，注意在xshell中密码输入的时候是不显示的
	> `passwd fx67ll`  
	> 然后根据提示输入两次修改的密码即可
6. 将新用户（fx67ll）添加到用户组（admin）
	> `usermod -a -G admin fx67ll `  
7. 接着，为新用户设定sudo权限
	> `visudo`  
	> 按`a`进入编辑模式，按`: -> wq`退出并保存，[进入退出vim编辑器详见](https://www.cnblogs.com/crazylqy/p/5649860.html "linux系统中如何进入退出vim编辑器，方法及区别")  
	> [Linux下的vim常用操作详见](https://www.cnblogs.com/bjphp/p/8468330.html "Linux下的vim常用操作")
8. 设置SSH免密登录，不会弄，后面有空再弄吧


### Linux 环境下配置jdk&tomcat并配合nginx部署
参考收藏夹里的一系列文件夹写一个指南出来  
PS: 有些文件windows里面修改完之后还是需要去linux中去掉空格，因为回车的占位符不同会报错`bash: $'\r': command not found`


### Linux 环境下安装jdk 
1. 利用 xFtp 上传 `jdk.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/jdk-8u144-linux-x64.tar.gz -C /usr/soft/install/`
3. 配置环境变量，注意实践中我并未找到教程中的那个文件，我修改的文件是 `/etc` 目录下的 `profile` 文件，没有后缀
	> `vim /etc/profile`
4. 在文件的最后一行添加如下内容
	> 按 `i` 开始修改（注意 `s` 会删除当前选中字符）  
	> `export JAVA_HOME=/usr/soft/install/jdk1.8.0_144`  
	> `export PATH=$PATH:$JAVA_HOME/bin`  
	> 按 `esc` 停止编辑，按 `:` 开始输入，输入 `wq` 保存并退出
5. 输入 `source /etc/profile` ，无报错立即生效
6. 依次输入 `jps` 、`java` 、`javac` 检查安装是否成功即可

+ [参考资料一](https://blog.csdn.net/weixin_43893397/article/details/102636437 "参考资料一")
+ [参考资料二](https://blog.csdn.net/weixin_44538107/article/details/88683530 "参考资料二")


### Linux 环境下安装tomcat
1. 利用 xFtp 上传 `tomcat.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/apache-tomcat-9.0.7.tar.gz -C /usr/soft/install/`
3. 配置环境变量，注意实践中我并未找到教程中的那个文件，我修改的文件是 `/etc` 目录下的 `profile` 文件，没有后缀
	> `vim /etc/profile`
4. 在文件的最后一行添加如下内容
	> 按 `i` 开始修改（注意 `s` 会删除当前选中字符）  
	> `export CATALINA_HOME=/usr/local/tomcat/apache-tomcat-9.0.7`  
	> `export CATALINA_BASE=/usr/local/tomcat/apache-tomcat-9.0.7`  
	> 按 `esc` 停止编辑，按 `:` 开始输入，输入 `wq` 保存并退出
5. 输入 `source /etc/profile` ，无报错立即生效
6. 在 `/usr/soft/install/apache-tomcat-9.0.7/conf` 目录下修改配置文件
	> Tomcat默认会监听3个端口：默认主端口8080，默认shutdown端口8005，默认AJP1.3端口8003  
	> 修改默认端口为自己想要的，AJP端口直接注释掉即可
7. 进入 `/usr/soft/install/apache-tomcat-9.0.7/bin` 目录下启动或停止
	> `./startup.sh` 启动，通过 `ip:端口` 查看到 tomcat 主页就算启动成功了  
	> `./shutdown.sh` 停止
8. 进入 `/usr/soft/install/apache-tomcat-9.0.7/logs` 目录下查看日志
	> `tail -f catalina.out` 查看日志  
	> `ctrl + c` 退出查看

+ [参考资料一](https://bbs.csdn.net/topics/394631214 "参考资料一")
+ [参考资料二](https://download.csdn.net/download/u011255725/10397595?utm_source=bbsseo "参考资料二")
+ [参考资料三](https://www.cnblogs.com/yangxiansen/p/7860001.html "参考资料三")
+ [参考资料四](https://zhidao.baidu.com/question/1306779967502674339.html "参考资料四")
+ [参考资料五](https://blog.csdn.net/qq_26922757/article/details/82910376 "参考资料五")
+ [参考资料六](https://blog.csdn.net/simon_1/article/details/18449921 "参考资料六")


### Linux 环境下安装MongoDB
1. 利用 xFtp 上传 `mongodb.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/mongodb-linux-x86_64-rhel70-4.4.4.tgz -C /usr/soft/install/`
3. 配置环境变量，注意实践中我并未找到教程中的那个文件，我修改的文件是 `/etc` 目录下的 `profile` 文件，没有后缀
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
	> `mongodb://root:******@211.149.128.130:27017/test?authSource=admin&readPreference=primary&ssl=false`  
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
	> 添加用户名密码的操作参考 `node.md` 文件中的相关记录  

+ [参考资料一](https://blog.csdn.net/yzh_1346983557/article/details/81735755 "参考资料一")
+ [参考资料二](https://www.jb51.net/article/119514.htm "参考资料二")
+ [参考资料三](https://blog.csdn.net/Dn1115680109/article/details/88754067 "参考资料三")
+ [参考资料四](https://www.imooc.com/article/78846 "参考资料四")


### Linux 环境下安装Nodejs
1. 利用 xFtp 上传 `node.tar.xz` 包至安装目录下，我的目录是 `/usr/soft/sort`
	> 下载安装包时候一定要注意下***linux使用的tar.xz文件***，不要下***source源码文件***  
	> 我之前弄错了疑惑了很久为什么解压之后没有bin目录  
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `xz -d /usr/soft/sort/node-v14.16.0-linux-x64.tar.xz`  
	> `tar -xvf /usr/soft/sort/node-v14.16.0-linux-x64.tar -C /usr/soft/install`  
3. 配置环境变量，注意实践中我并未找到教程中的那个文件，我修改的文件是 `/etc` 目录下的 `profile` 文件，没有后缀
	> `vim /etc/profile`
4. 在文件的最后一行添加如下内容
	> 按 `i` 开始修改（注意 `s` 会删除当前选中字符）  
	> `export NODE_HOME=/usr/soft/install/node-v14.16.0-linux-x64`  
	> `export PATH=$PATH:$NODE_HOME/bin`  
	> `export NODE_PATH=$NODE_HOME/lib/node_modules`  
	> 按 `esc` 停止编辑，按 `:` 开始输入，输入 `wq` 保存并退出  
5. 输入 `source /etc/profile` ，无报错立即生效
6. 输入 `node -v` 和 `npm -v` 测试是否可以正常显示版本


### Linux 环境下部署基于Express的Nodejs项目
1. 全局安装pm2进程管理工具
	> `npm install pm2 -g`
	> 常用命令如下  
	> `pm2 start ./bin/wwww` 启动项目 
	> `pm2 list` 查看当前进程列表  
	> `pm2 logs id` 查看某个id的进程的实时日志，按 `ctrl + c` 退出  
	> `pm2 restart id` 重启某个id的进程  
	> `--update-env` 启动时附上这个参数表示更新变量后重启  
	> `pm2 delete id` 杀掉某个id的进程  
2. 我是在 `/usr` 目录下创建了一个 `/node` 来存放需要部署的node项目
3. 上传完项目后，执行 `npm install` -> `cd bin` -> `pm2 start www` -> `pm2 logs 0`  
4. 浏览器地址输入 `http://211.149.128.130:3000` 看到首页即可  


### 下一步是尝试安装mysql以及部署java应用程序，可以使用若依的那套试试水，单应用和分布式都可以玩玩