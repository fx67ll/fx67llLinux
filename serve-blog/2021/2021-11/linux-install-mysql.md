# 详解在Linux中安装配置MySQL  

最近在整理自己私人服务器上的各种阿猫阿狗，正好就顺手详细记录一下清理之后重装的步骤，今天先写点数据库的内容，关于在`Linux`中安装配置`MySQL`  

### 安装环境
CentOS7 + MySQL5.7

### 下载安装包
[mysql-5.7.26 版本下载地址（点击链接直接下载）](https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz)  

### 操作步骤
1. 利用 xFtp 上传 `mysql.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz -C /usr/soft/install/`
3. 创建组  
	> `groupadd mysql`  
4. 创建用户  
	> `useradd -r -g mysql mysql`  
5. 将安装目录所有者及所属组改为mysql
	> `chown -R mysql.mysql /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
6. 进入mysql目录并创建data文件夹用于存放数据库表之类的数据  
	> `cd /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
	> `mkdir data`  
7. 准备初始化，首先要安装依赖库libaio
	> `yum install libaio`  
8. 准备初始化，这一步务必记住初始密码，它位于输出日志的末尾（数据库管理员临时密码）  
	> 注意这是一整条命令：`/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/bin/mysqld --user=mysql --basedir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/ --datadir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/data --initialize`  
	> 
	> 我的输出日志示例：`20xx-xx-xxTxx:xx:xx.493483Z 1 [Note] A temporary password is generated for root@localhost: 这里是初始的临时密码`  
9. 配置系统环境变量  
	+ 编辑 `vim /etc/profile`  
	+ 添加以下环境变量  
		> `export MYSQL_HOME=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
		> `export PATH=$PATH:$MYSQL_HOME/bin`  
	+ 更新 `source /etc/profile`
10. 配置mysql配置，这里最好查询一下所有配置的含义，可以参考 [这篇文章](https://www.cnblogs.com/captain_jack/archive/2010/10/12/1848496.html)  
	> `datadir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/data`  
	> `basedir=/usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64`  
	> `socket=/tmp/mysql.sock`（这行很重要，不然后续socket连接会出问题）  
	> `user=mysql`  
	> `port=3306`  
	> `innodb_file_ per_table=1`  
	> `character-set-server=utf8`  
11. 这里需要操作两个目录，用于配置文件中部分文件的运行，不然直接启动会报错，建议先完成错误解决方案中的代码  
	+ 第一个错误`mysqld_safe error: log-error set to /var/log/mariadb/mariadb.log`  
	+ 第一个错误解决方案，新建并添加权限  
		> `mkdir /var/log/mariadb`  
		> `touch /var/log/mariadb/mariadb.log`  
		> `chown -R mysql:mysql /var/log/mariadb/`  
	+ 第二个错误`mysqld_safe Directory '/var/lib/mysql' for UNIX socket file don't exists.`  
	+ 第二个错误解决方案，新建并添加权限  
		> `mkdir /var/lib/mysql`  
		> `chmod 777 /var/lib/mysql`  
	+ [参考文档一](https://blog.csdn.net/qq_34218345/article/details/106951035)  
	+ [参考文档二](https://blog.csdn.net/qq_32331073/article/details/76229420)  
12. 将mysql加入服务
	> `cp /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/support-files/mysql.server /etc/init.d/mysql`  
13. 设置开机启动
	> `chkconfig mysql on`  
14. 添加软连接
	> `ln -s /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/support-files/mysql.server /etc/init.d/mysql`  
	> 
	> `ln -s /usr/soft/install/mysql-5.7.26-linux-glibc2.12-x86_64/bin/mysql /usr/bin/mysql`  
15. 启动mysql
	> `service mysql start`  
16. 使用初始密码登录
	+ 执行 `mysql -u root -p`（socket连接）  
	+ 或者执行 `mysql -u root -h 127.0.0.1 -p`（本地连接）  
	+ 输入密码，可以直接去前面保存的初始密码复制过来  
17. 修改初始密码
	+ `use mysql;`（注意mysql语句使用英文`;`结束！！！）  
	+ `mysql> update user set authentication_string=passworD("你的新密码") where user='root';`（mysql5.7及以上版本需要使用`authentication_string`字段来修改密码，有些博文并未提及，需要注意！！！）  
	+ 这个也可修改密码，效果同上 `set password=password("你的新秘密");`  
	+ 重新加载权限表 `flush privileges;`  
	+ 退出mysql `exit;`  


[参考资料一 ———— linux下mysql的安装与使用](https://www.cnblogs.com/shenjianping/p/10984540.html)  
[参考资料二 ———— linux 安装 mysql简单教程](https://blog.csdn.net/weixin_42734930/article/details/81743047)  
[参考资料三 ———— linux下mysql配置文件my.cnf详解](https://www.cnblogs.com/captain_jack/archive/2010/10/12/1848496.html)  
[参考资料四 ———— 启动mysql报错mysqld_safe error: log-error set to /var/log/mariadb/mariadb.log](https://blog.csdn.net/qq_34218345/article/details/106951035)  
[参考资料五 ———— mysqld_safe Directory ‘/var/lib/mysql‘ for UNIX socket file don‘t exists.](https://blog.csdn.net/qq_32331073/article/details/76229420)  
[参考资料六 ———— linux下将mysql加入到环境变量](https://blog.csdn.net/huanghuizz/article/details/84472590?spm=1001.2014.3001.5502)  
[参考资料七 ———— MySQL--启动和关闭MySQL服务](https://www.cnblogs.com/net5x/articles/10033056.html)  
[参考资料八 ———— mysql报错：You must reset your password using ALTER USER statement before executing this statement.](https://www.cnblogs.com/benpao1314/p/11534696.html)  
[参考资料九 ———— Linux下修改Mysql密码的三种方式](https://www.cnblogs.com/surplus/p/11642773.html)  
[参考资料十 ———— 查看MySQL是否在运行](https://blog.csdn.net/weixin_34025051/article/details/93185516)  


我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2021/2021-11/linux-install-mysql.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***