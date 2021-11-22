# Tomcat 学习笔记

### Linux 中修改Tomcat使用的jdk版本
1. 由于部署Halo使用了`openjdk11`，但是我的tomcat之前用的是`jdk1.8`，版本升级的后果就是运行的时候报一点小bug  
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