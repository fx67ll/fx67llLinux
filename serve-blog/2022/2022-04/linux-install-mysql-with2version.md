# 详解在Linux中同时使用安装配置并使用`5.7`和`8.0`版本的MySQL

最近需要使用mysql8.0版本，但是原本的5.7版本已经被多个服务依赖，于是想想能不能同一台服务器装多个版本的mysql，一查确实可行，这里做一个记录方便自己后期回忆  

## 简化版命令步骤
*注意原来的mysql5.7配置基本没有动，服务也没有关，下面的命令都是关于mysql8.0的，原mysql5.7的配置文件在`/etc/my.cnf`*
1. 解压xz文件为tar文件，注意命令无过程显示需要等待窗口跳至下一行  
	+ `xz -d /usr/soft/sort/mysql-8.0.29-linux-glibc2.12-x86_64.tar.xz -C /usr/soft/sort/`  
	+ `tar -xvf /usr/soft/sort/mysql-8.0.29-linux-glibc2.12-x86_64.tar -C /usr/soft/install/`  
2. 修改权限 `chown -R mysql.mysql /usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64`
3. 修改配置文件 `vi /usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/my.cnf`
	```
	[client]
	port=3307
	# mysql57 不要这个
	mysqlx_port=33070
	socket=/tmp/mysql80.sock
	# mysql57 不要这个
	mysqlx_socket=/tmp/mysqlx80.sock
	
	[mysqld]
	# skip-grant-tables
	# mysql安装目录
	basedir=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64
	# mysql数据库目录
	datadir=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/data
	port=3307
	innodb_file_per_table=1
	character-set-server=utf8
	# mysql57 不要这个
	mysqlx_port=33070
	socket = /tmp/mysql80.sock
	# mysql57 不要这个
	mysqlx_socket=/tmp/mysqlx80.sock
	
	[mysqld_safe]
	# 错误日志
	log-error=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/data/error.log
	# pid文件
	pid-file=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/data/mysqld.pid
	tmpdir=/tmp/mysql80
	```
5. 修改连接服务文件 `vi /usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/support-files/mysql.server`
	```
	# 这两项在开头比较好找
	basedir=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64
	datadir=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/data
	
	# 这项默认的不用找
	lockdir='/var/lock/subsys'
	
	# 这项默认有但是需要在最后改个80
	lock_file_path="$lockdir/mysql80"
	
	# 下面两个藏在下面细心的找一下
	mysqld_pid_file_path=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/data/mysqld.pid
	conf=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/my.cnf
	```
6. 复制注册连接服务文件  `cp -i /usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/support-files/mysql.server /etc/init.d/mysql80`
7. `/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/bin/mysqld --defaults-file=/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/my.cnf --user=mysql  --initialize`
	+ root@localhost: 2ueI.uQMA%pK  
8. 记得开放防火墙的3307端口  
9. 登录 `/usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/bin/mysql --socket=/tmp/mysql80.sock -u root -p'2ueI.uQMA%pK'`
10. 重置密码，登录后依次执行命令
	+ `flush privileges;`  
	+ *注意：新版本mysql8后，不再支持 `password()`方法，只能通过 `alter`语句进行修改*  
	+ `ALTER USER 'root'@'localhost' IDENTIFIED BY 'fx67ll@1805Ll';`  
	+ `use mysql;`  
	+ `update user set host='%' where user='root' and host='localhost';`  
	+ `flush privileges;`  
11. 查看占用端口`show global variables like 'port';`，如果发现为0，需要执行以下步骤修改
	+ 停止服务：`service mysql80 stop`  
	+ 修改配置文件：`vi /usr/soft/install/mysql-8.0.29-linux-glibc2.12-x86_64/my.cnf`，将 [mysqld] 下的 skip-grant-tables 注释  
	+ 重新启动服务：`service mysql80 start`  


#### 参考文档
1. [linux 下同时安装 mysql5.7 和 mysql8.0](https://blog.csdn.net/qq_43800252/article/details/113817371)  
2. [linux安装两个mysql(8.0和5.7)，并同时使用](https://blog.csdn.net/qq_40800602/article/details/106499000)  
3. [tar.xz文件如何解压](https://blog.csdn.net/duyudong0425/article/details/113928414)  
4. [linux mysql8 初始密码修改](https://blog.csdn.net/u011908518/article/details/119632672)  
5. [linux下查看mysql端口号和修改端口号方法](https://www.csdn.net/tags/MtzaAgysMTE5MjAtYmxvZwO0O0OO0O0O.html)  

我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2022/2022-04/linux-install-mysql-with2version.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***