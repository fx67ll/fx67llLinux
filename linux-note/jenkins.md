# Jenkins 学习笔记

### Jenkins 是什么？
+ Jenkins是一个开源的、提供友好操作界面的持续集成(CI)工具，起源于Hudson（Hudson是商用的），主要用于持续、自动的构建/测试软件项目、监控外部任务的运行（这个比较抽象，暂且写上，不做解释）。
+ Jenkins用Java语言编写，可在Tomcat等流行的servlet容器中运行，也可独立运行。
+ 通常与版本管理工具(SCM)、构建工具结合使用。常用的版本控制工具有SVN、GIT，构建工具有Maven、Ant、Gradle。

### 什么是CI?
+ CI(Continuous integration，中文意思持续集成)是一种软件开发时间
+ 持续集成强调开发人员提交了新代码之后，立刻进行构建、（单元）测试
+ 根据测试结果，我们可以确定新代码和原有代码能否正确地集成在一起

### 什么是CD?
+ CD(Continuous Delivery，中文意思持续交付)是在持续集成的基础上，将集成后的代码部署到更贴近真实运行环境(类生产环境)中
+ 比如，我们完成单元测试后，可以把代码部署到连接数据库的Staging环境中更多的测试,如果代码没有问题，可以继续手动部署到生产环境

### 在 Linux 中使用 yum 安装 Jenkins
1. 因为Jenkins是Java编写的，所以必须要先使用yum安装JDK，这里是安装JDK1.8的步骤
	> 先获取java相关版本：yum -y list java
2. ***未完待续***

### 在 Linux 中直接部署 Jenkins.war
1. 在 [官网下载war包（这里使用的事2.289.1 LTS 稳定版）](http://mirrors.jenkins-ci.org/war-stable/2.289.1/)  
2. 传到服务器的`tomcat -> webapps`目录下，不用修改`tomcat`配置，直接访问`[](http://211.149.128.130:81/)(tomcat主页地址)/jenkins`，第一次访问稍微等一下时间比较长  
3. 会进入页面输入安装密码，这时候不要直接找那个密码文件，依次执行以下命令：
	> `cd /var` 进入根目录var文件夹下  
	> `sudo chmod -R 777 root` 修改权限（不懂命令具体含义，后期有空详细了解）  
	> `/root/.jenkins/secrets/initialAdminPassword` 在根目录var文件夹执行该命令  
	> `/root/.jenkins/secrets/initialAdminPassword: line 1: dcfa3d4cbaff4732b38113005ac33c5d: command not found` 会出现这句话，line1后面的就是密码了  