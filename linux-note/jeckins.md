# Jeckins 学习笔记

### Jeckins 是什么？
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

### 在 Linux 中使用 yum 安装 Jeckins
1. 因为Jeckins是Java编写的，所以必须要先使用yum安装JDK，这里是安装JDK1.8的步骤
	> 先获取java相关版本：yum -y list java*