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
1. 因为Jenkins是Java编写的，所以必须要先安装JDK配置好Java运行环境，`java -version`查看是否已经安装  
2. 在 [官网下载war包（这里使用的事2.289.1 LTS 稳定版）](http://mirrors.jenkins-ci.org/war-stable/2.289.1/)  
3. 传到服务器的`tomcat -> webapps`目录下，不用修改`tomcat`配置，直接访问`[](http://211.149.128.130:81/)(tomcat主页地址)/jenkins`，第一次访问稍微等一下时间比较长  
4. 会进入页面输入安装密码，这时候不要直接找那个密码文件，依次执行以下命令：
	> `cd /var` 进入根目录var文件夹下  
	> `sudo chmod -R 777 root` 修改权限（不懂命令具体含义，后期有空详细了解）  
	> `/root/.jenkins/secrets/initialAdminPassword` 在根目录var文件夹执行该命令  
	> `/root/.jenkins/secrets/initialAdminPassword: line 1: dcfa3d4cbaff4732b38113005ac33c5d: command not found` 会出现这句话，line1后面的就是密码了  

### jenkins 结合 github 实现自动化构建  
1. 本文主要参考[该文](https://blog.csdn.net/w6990548/article/details/106242009 "感谢博主~此去几何~")记录实现，从第四大步开始  
2. 在`github`生成`Personal access token`  
	> 1. 通过这个路径找到按钮，`github --> 头像 --> Settings --> Developer settings --> Personal access tokens --> Generate new token`  
	> ![在github生成pat](img/jenkin/2-1.在github生成pat.png "在github生成pat")  
	> 2. 勾选以下选项，点击`Generate token`生成令牌，然后别操作注意下一步！！！  
	> ![新增pat的选项](img/jenkin/2-2.新增pat的选项.png "新增pat的选项")  
	> 3. 注意！！！生成令牌后一定要记录保存到本地txt中，因为只会在新增完成后显示一次  
	> ![注意记录保存生成的令牌](img/jenkin/2-3.注意记录保存生成的令牌.png "注意记录保存生成的令牌")  
3. 在`github`中具体需要持续集成的项目下设置`Webhooks`  
	> 1. 通过这个步骤点击按钮，`找到你需要持续集成的项目 -> Setting -> Webhooks -> add webhook`  
	> ![添加新的webhook](img/jenkin/3-1.添加新的webhook.png "添加新的webhook")  
	> 2. 按下图填写`webhook`地址  
	> ![新增webhook需要填写的选项](img/jenkin/3-2.新增webhook需要填写的选项.png "新增webhook需要填写的选项")  
	> 3. 新增完成后一般都是灰色，后面测试完成之后会提示地址是否能联通  
	> ![新增完成的状态](img/jenkin/3-3.新增完成的状态.png "新增完成的状态")  
4. 在`jenkins`中设置`github`之前生成的凭据，这里我相较于原文提前设置了，因为我用的jenkins版本是`2.289.1`，导致我在设置途中新增凭据一直失败，所以提前设置好全局凭据    
	> 1. 通过这个路径找到按钮，`系统管理 -> Manage Credentials -> 全局超链接随便点一个进去 -> 添加凭据`  
	> ![添加凭据步骤一](img/jenkin/4-1.添加凭据步骤一.png "添加凭据步骤一")  
	> ![添加凭据步骤二](img/jenkin/4-1.添加凭据步骤二.png "添加凭据步骤二")  
	> ![添加凭据步骤三](img/jenkin/4-1.添加凭据步骤三.png "添加凭据步骤三")  
	> 2. 把`github`中的`Personal access token`添加到`Secret text`  
	> ![添加ST](img/jenkin/4-2.添加ST.png "添加ST")  
	> 3. 把`github`中的`SSH`钥匙添加到`SSH Username with private key`，生成`SSH钥匙`参考下文  
	> [如何利用tortoiseGit生成SSH钥匙](https://blog.csdn.net/yhcad/article/details/88624286)  
	> ![github中ssh钥匙的位置](img/jenkin/4-3.github中ssh钥匙的位置.png "github中ssh钥匙的位置")  
	> ![添加SSH钥匙](img/jenkin/4-4.添加SSH钥匙.png "添加SSH钥匙")  
5. 在`jenkins`中设置`github`配置  
	> 1. 创建一个新任务，构建自由风格项目  
	> ![创建新任务](img/jenkin/5-1.创建新任务.png "创建新任务")  
	> 2. 配置`github`项目地址  
	> ![配置github项目地址](img/jenkin/5-2.配置github项目地址.png "配置github项目地址")  
	> 3. 配置`github`源码地址  
	> ![配置github源码地址](img/jenkin/5-3.配置github源码地址.png "配置github源码地址")  
	> ![检查webhook地址是否正确](img/jenkin/5-3.检查webhook地址是否正确.png "检查webhook地址是否正确")  
	> 4. 剩余配置  
	> ![剩余配置](img/jenkin/5-4.剩余配置.png "剩余配置")  
	> 5. 编写shell命令执行自动化构建  
	> ![编写shell命令执行自动化构建](img/jenkin/5-5.编写shell命令执行自动化构建.png "编写shell命令执行自动化构建")  
	> 6. 测试  
	> ![测试一](img/jenkin/5-6.测试一.png "测试一")  
	> ![测试二](img/jenkin/5-6.测试二.png "测试二")  
	> ![测试三](img/jenkin/5-6.测试三.png "测试三")  