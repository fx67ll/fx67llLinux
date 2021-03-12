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
	> 按 `s` 开始修改  
	> `export JAVA_HOME=/usr/soft/install/jdk1.8.0_144`  
	> `export PATH=$PATH:$JAVA_HOME/bin`  
	> 按 `esc` 停止编辑，按 `:` 开始输入，输入 `wq` 保存并退出
5. 依次输入 `jps` 、`java` 、`javac` 检查安装是否成功即可

+ [参考资料一](https://blog.csdn.net/weixin_43893397/article/details/102636437 "参考资料一")
+ [参考资料二](https://blog.csdn.net/weixin_44538107/article/details/88683530 "参考资料二")


### Linux 环境下安装tomcat
1. 利用 xFtp 上传 `tomcat.gz` 包至安装目录下，我的目录是 `/usr/soft/sort`
2. 解压安装包至指定目录下，我的是同目录下的install文件夹
	> `tar -zxvf /usr/soft/sort/apache-tomcat-9.0.7.tar.gz -C /usr/soft/install/`
3. 配置环境变量，注意实践中我并未找到教程中的那个文件，我修改的文件是 `/etc` 目录下的 `profile` 文件，没有后缀
	> `vim /etc/profile`
4. 在文件的最后一行添加如下内容
	> 按 `s` 开始修改  
	> `CATALINA_HOME=/usr/local/tomcat/apache-tomcat-9.0.7`  
	> `CATALINA_BASE=/usr/local/tomcat/apache-tomcat-9.0.7`  
	> 按 `esc` 停止编辑，按 `:` 开始输入，输入 `wq` 保存并退出
5. 在 `/usr/soft/install/apache-tomcat-9.0.7/conf` 目录下修改配置文件
	> Tomcat默认会监听3个端口：默认主端口8080，默认shutdown端口8005，默认AJP1.3端口8003  
	> 修改默认端口为自己想要的，AJP端口直接注释掉即可
6. 进入 `/usr/soft/install/apache-tomcat-9.0.7/bin` 目录下启动或停止
	> `./startup.sh` 启动，通过 `ip:端口` 查看到 tomcat 主页就算启动成功了  
	> `./shutdown.sh` 停止
7. 进入 `/usr/soft/install/apache-tomcat-9.0.7/logs` 目录下查看日志
	> `tail -f catalina.out` 查看日志  
	> `ctrl + c` 退出查看

+ [参考资料一](https://bbs.csdn.net/topics/394631214 "参考资料一")
+ [参考资料二](https://download.csdn.net/download/u011255725/10397595?utm_source=bbsseo "参考资料二")
+ [参考资料三](https://www.cnblogs.com/yangxiansen/p/7860001.html "参考资料三")
+ [参考资料四](https://zhidao.baidu.com/question/1306779967502674339.html "参考资料四")
+ [参考资料五](https://blog.csdn.net/qq_26922757/article/details/82910376 "参考资料五")
+ [参考资料六](https://blog.csdn.net/simon_1/article/details/18449921 "参考资料六")