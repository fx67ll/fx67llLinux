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


### Linux 环境下配置 JDK & Tomcat 并配合 Nginx 部署
参考收藏夹里的一系列文件夹写一个指南出来  
PS: 有些文件windows里面修改完之后还是需要去linux中去掉空格，因为回车的占位符不同会报错`bash: $'\r': command not found`


### Linux 环境下安装 JDK 
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


### Linux 环境下安装 Tomcat
1. 利用 xFtp 上传 `tomcat.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/apache-tomcat-9.0.7.tar.gz -C /usr/soft/install/`
3. 配置环境变量，注意实践中我并未找到教程中的那个文件，我修改的文件是 `/etc` 目录下的 `profile` 文件，没有后缀
	> `vim /etc/profile`
4. 在文件的最后一行添加如下内容
	> 按 `i` 开始修改（注意 `s` 会删除当前选中字符）  
	> `export CATALINA_HOME=/usr/soft/install/apache-tomcat-9.0.7`  
	> `export CATALINA_BASE=/usr/soft/install/apache-tomcat-9.0.7`  
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
#### 修改 Tomcat 默认指定的 jdk 版本
1. 由于部署个人项目使用了`openjdk11`，但是我之前安装的是`jdk1.8`，jdk版本升级的后果就是，tomcat运行的时候报一点小bug（因为之前安装tomcat默认使用了系统的jdk版本）  
2. 所以就想着把tomcat使用的jdk版本调回原来的，找了很多资料之后，决定在tomcat的运行文件中覆盖使用的jdk版本路径  
3. 需要注意的是，`openjdk11`没有jre目录，所以一定要注意将`JRE_HOME=$JAVA_HOME/jre`中的jre删掉  
4. 检查tomcat安装目录下`/bin/catalina.sh`和`/bin/setclasspath.sh`文件  
5. 分别在这两个文件的头部添加以下局部变量覆盖系统环境变量  
	> `export JAVA_HOME=/usr/soft/install/jdk1.8.0_144`  
	> `export JRE_HOME=$JAVA_HOME/`  
	> `export PATH=$PATH:$JAVA_HOME/bin`  
5. 两个文件修改完成之后，在`bin`目录下执行`./version.sh`，会打印出来`jdk版本`  
6. 还有点需要注意的是，tomcat如果运行不成功或者运行多个之后，可能会出现访问的问题，不要重复开重复关，检查配置都没有问题之后再去打开  
	> 查看tomcat是否在运行 `ps -ef |grep tomcat`  
	> 如果在运行，可以杀掉进程之后再重启 `kill -9 pid  # pid为相应的进程号`  
7. 最后再总结一下关闭和开启tomcat的命令，均在bin目录下执行  
	> 开启 `./startup.sh`  
	> 关闭 `./shutdown.sh`  
#### 修复文件中的`^M`
1. [Linux下删除^M文件的方法](https://www.cnblogs.com/rsapaper/p/15697099.html)  
2. [安装 dos2unix](https://blog.csdn.net/qq_36389107/article/details/84500781)  
3. 操作命令记录
	+ `cat -A /usr/soft/install/apache-tomcat-9.0.7/conf/server.xml`  
	+ `dos2unix /usr/soft/install/apache-tomcat-9.0.7/conf/server.xml`  
	+ ------------------------------------------------------  
	+ `cat -A /usr/soft/install/apache-tomcat-9.0.7/bin/catalina.sh`  
	+ `dos2unix /usr/soft/install/apache-tomcat-9.0.7/bin/catalina.sh`  
	+ ------------------------------------------------------  
	+ `cat -A /usr/soft/install/apache-tomcat-9.0.7/bin/setclasspath.sh`  
	+ `dos2unix /usr/soft/install/apache-tomcat-9.0.7/bin/setclasspath.sh`  

+ [参考资料一](https://bbs.csdn.net/topics/394631214 "参考资料一")
+ [参考资料二](https://download.csdn.net/download/u011255725/10397595?utm_source=bbsseo "参考资料二")
+ [参考资料三](https://www.cnblogs.com/yangxiansen/p/7860001.html "参考资料三")
+ [参考资料四](https://zhidao.baidu.com/question/1306779967502674339.html "参考资料四")
+ [参考资料五](https://blog.csdn.net/qq_26922757/article/details/82910376 "参考资料五")
+ [参考资料六](https://blog.csdn.net/simon_1/article/details/18449921 "参考资料六")


### Linux 环境下安装 MongoDB
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


### Linux 环境下安装 Nodejs
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


### Linux 环境下部署基于 Express 的 Nodejs 项目
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


### Linux 环境下安装 MySQL
1. 利用 xFtp 上传 `mysql.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz -C /usr/soft/install/`
3. 创建用户  
	> `groupadd mysql`  
4. 创建组  
	> `useradd -r -g mysql mysql`  
5. 将安装目录所有者及所属组改为mysql
	> `chown -R mysql.mysql /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
6. 进入mysql目录并创建data文件夹用于存放数据库表之类的数据  
	> `cd /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
	> `mkdir data`  
7. 准备初始化，首先要安装依赖库libaio
	> `yum install libaio`  
8. 准备初始化
	> `/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/bin/mysqld --user=mysql --basedir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/ --datadir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/data --initialize`  
	> 这一步务必记住初始密码，它位于输出日志的末尾（数据库管理员临时密码）  
	> 我的输出日志示例`20xx-xx-xxTxx:xx:xx.493483Z 1 [Note] A temporary password is generated for root@localhost: 这里是初始的临时密码`  
9. 配置系统环境变量  
	> 编辑 `vim /etc/profile`  
	> 添加以下环境变量
	> `export MYSQL_HOME=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
	> `export PATH=$PATH:$MYSQL_HOME/bin`  
	> 更新 `source /etc/profile`
10. 配置mysql配置
	> `datadir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/data`  
	> `basedir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
	> `socket=/tmp/mysql.sock`（这行很重要，不然后续socket连接会出问题）  
	> `user=mysql`  
	> `port=3306`  
	> `innodb_file_ per_table=1`  
	> `character-set-server=utf8`  
	> 这里最好查询一下所有配置的含义，可以参考 [这篇文章](https://www.cnblogs.com/captain_jack/archive/2010/10/12/1848496.html)  
11. 这里需要操作两个目录，用于配置文件中部分文件的运行，不然直接启动会报错，建议先完成错误解决方案中的代码  
	> 第一个错误`mysqld_safe error: log-error set to /var/log/mariadb/mariadb.log`  
	> 第一个错误解决方案，新建并添加权限  
	> `mkdir /var/log/mariadb`  
	> `touch /var/log/mariadb/mariadb.log`  
	> `chown -R mysql:mysql /var/log/mariadb/`  
	> 第二个错误`mysqld_safe Directory '/var/lib/mysql' for UNIX socket file don't exists.`  
	> 第二个错误解决方案，新建并添加权限  
	> `mkdir /var/lib/mysql`  
	> `chmod 777 /var/lib/mysql`  
	> [参考文档一](https://blog.csdn.net/qq_34218345/article/details/106951035)  
	> [参考文档二](https://blog.csdn.net/qq_32331073/article/details/76229420)  
12. 将mysql加入服务
	> `cp /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/support-files/mysql.server /etc/init.d/mysql`  
13. 设置开机启动
	> `chkconfig mysql on`  
14. 添加软连接
	> `ln -s /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/support-files/mysql.server /etc/init.d/mysql`  
	> `ln -s /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/bin/mysql /usr/bin/mysql`  
15. 启动mysql
	> `service mysql start`  
16. 使用初始密码登录
	> 执行 `mysql -u root -p`（socket连接）  
	> 或者执行 `mysql -u root -h 127.0.0.1 -p`（本地连接）  
	> 输入密码，可以直接去前面保存的初始密码复制过来  
17. 修改初始密码
	> `use mysql;`（注意mysql语句使用英文`;`结束！！！）  
	> `mysql> update user set authentication_string=passworD("你的新密码") where user='root';`（mysql5.7及以上版本需要使用`authentication_string`字段来修改密码，有些博文并未提及，需要注意！！！）  
	> 这个也可修改密码，效果同上 `set password=password("你的新秘密");`  
	> 重新加载权限表 `flush privileges;`  
	> 退出mysql `exit;`  

+ [参考资料一 ———— linux下mysql的安装与使用](https://www.cnblogs.com/shenjianping/p/10984540.html)  
+ [参考资料二 ———— linux 安装 mysql简单教程](https://blog.csdn.net/weixin_42734930/article/details/81743047)  
+ [参考资料三 ———— linux下mysql配置文件my.cnf详解](https://www.cnblogs.com/captain_jack/archive/2010/10/12/1848496.html)  
+ [参考资料四 ———— 启动mysql报错mysqld_safe error: log-error set to /var/log/mariadb/mariadb.log](https://blog.csdn.net/qq_34218345/article/details/106951035)  
+ [参考资料五 ———— mysqld_safe Directory ‘/var/lib/mysql‘ for UNIX socket file don‘t exists.](https://blog.csdn.net/qq_32331073/article/details/76229420)  
+ [参考资料六 ———— linux下将mysql加入到环境变量](https://blog.csdn.net/huanghuizz/article/details/84472590?spm=1001.2014.3001.5502)  
+ [参考资料七 ———— MySQL--启动和关闭MySQL服务](https://www.cnblogs.com/net5x/articles/10033056.html)  
+ [参考资料八 ———— mysql报错：You must reset your password using ALTER USER statement before executing this statement.](https://www.cnblogs.com/benpao1314/p/11534696.html)  
+ [参考资料九 ———— Linux下修改Mysql密码的三种方式](https://www.cnblogs.com/surplus/p/11642773.html)  
+ [参考资料十 ———— 查看MySQL是否在运行](https://blog.csdn.net/weixin_34025051/article/details/93185516)  


### Linux 环境下安装 Redis（待整理补充）  
1. 利用 xFtp 上传 `redis.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`  
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/redis-6.2.6.tar.gz -C /usr/soft/install/`
3. 下面我先简易写一下，后续再整理丰富
	+ CentOS7默认使用4.8的gcc，需要升级gcc至5.3以上版本  
	+ 升级之后使用`make`命令编译，这里就是用到gcc这个编译工具  
	+ 配置安装目录下的src目录下的`redis-server`的环境变量，然后可以直接在系统中调用`redis-server`命令  
	+ 修改`redis.conf`中的配置，需要注意的是，默认配置贼他妈长，请下载到本地修改，完事之后[去除`^M`的符号](https://blog.csdn.net/chencheng126/article/details/43951547)  
	+ 测试能否启动`redis-server redis.conf`，然后一堆命令，查看进程命令，连接登录redis命令，发现6379端口的进程即可  
	+ 如果需要使用密码登录，可以使用这个命令`redis-cli -h 127.0.0.1 -p 6379 -a (这里是配置文件里写的密码)`
	+ 设置redis开机自启动，输入命令添加新的配置文件，验证新配置，查看服务状态
	+ 关闭redis服务，可以使用密码连接到redis服务之后使用`shutdown`，显示*not connected*即为关闭成功  
	+ 检查redis服务状态 `ps -ef | grep redis`  
	+ 检查redis进程信息 `top -p (上一个命令查询到的 PID)`
4. 由于是服务端高频应用，继续放到服务端服务器（阿里轻量云或其他后续迁移的机器）中使用，练习也使用服务端机器操作，西部数码中的服务停止  
5. 参考资料记录  
	+ [Redis 配置登录密码](https://www.cnblogs.com/ryanzheng/p/9501204.html)  
	+ [Redis启动与关闭](https://blog.csdn.net/m0_58746619/article/details/125874797)  
*—————————————————————————————————————但是该教程记得先补充完整，再看看哪些安装教程可以写成博客—————————————————————————————————————*
