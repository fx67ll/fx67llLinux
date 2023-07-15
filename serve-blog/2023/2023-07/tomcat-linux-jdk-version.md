# 详解在Linux中修改Tomcat使用的jdk版本

### 问题分析
1. 由于部署个人项目使用了`openjdk11`，但是我之前安装的是`jdk1.8`，jdk版本升级的后果就是，tomcat运行的时候报一点小bug（因为之前安装tomcat默认使用了系统的jdk版本）  
2. 所以就想着把tomcat使用的jdk版本调回原来的，找了很多资料之后，决定在tomcat的运行文件中覆盖使用的jdk版本路径  
3. 需要注意的是，`openjdk11`没有jre目录，所以一定要注意将`JRE_HOME=$JAVA_HOME/jre`中的jre删掉  

### 详细步骤
1. 检查tomcat安装目录下`/bin/catalina.sh`和`/bin/setclasspath.sh`文件  
2. 分别在这两个文件的头部添加以下局部变量覆盖系统环境变量  
	> `export JAVA_HOME=/usr/soft/install/jdk1.8.0_144`  
	> `export JRE_HOME=$JAVA_HOME/`  
	> `export PATH=$PATH:$JAVA_HOME/bin`  
3. 两个文件修改完成之后，在`bin`目录下执行`./version.sh`，会打印出来`jdk版本`  
4. 还有点需要注意的是，tomcat如果运行不成功或者运行多个之后，可能会出现访问的问题，不要重复开重复关，检查配置都没有问题之后再去打开  
	> 查看tomcat是否在运行 `ps -ef |grep tomcat`  
	> 如果在运行，可以杀掉进程之后再重启 `kill -9 pid  # pid为相应的进程号`  
5. 最后再总结一下关闭和开启tomcat的命令，均在bin目录下执行  
	> 开启 `./startup.sh`  
	> 关闭 `./shutdown.sh`  

### 如何修复linux相关配置文件中的非法字符`^M`
1. 因为tomcat的配置文件过长，直接在linux中使用`vim`命令修改属实比较痛苦，笔者直接将文件用 xftp 拉下来，直接在编辑器中修改，但是会导致文件中出现非法字符`^M`  
2. `^M`是windows下的断元字符，在linux中无法识别
3. 可以通过安装linux工具来处理，按顺序执行以下命令即可
	+ 安装工具包 `yum install -y dos2unix`  
	+ 格式化文档 `dos2unix (需要格式化的文档地址)`  


我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2023/2023-07/tomcat-linux-jdk-version.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***