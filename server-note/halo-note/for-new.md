# 记录一下halo迁移流程和命令

### 新服务器安装 java jdk
```
sudo apt update && sudo apt install openjdk-11-jdk  # Ubuntu/Debian
# 或 sudo yum install java-11-openjdk              # CentOS
```

### 新服务器安装 halo
#### 安装之前
1. 先不要停止老服务器的应用，使用小工具导出相关数据，导完之后把华为云的cdn服务停一下，域名指向改为新服务器的ip，新服务器的8090端口也要同步开启
2. 同时使用xftp去halo用户下的`/home/halo/.halo`目录中，导出所有文件（注意！upload文件夹的图片存在中文名，需要把xftp的属性改为UTF-8，不然导出会报错）  
3. 下载好新的`halo.jar`包之后，按下方的安装命令步骤去走
4. 然后配置好nginx（先不配置https，确保http下可以访问再配置），启动全新的应用，在引导界面选择老数据导入，使用第一步里导出的`data.json`即可  
5. 最后再将第二步里的所有文件夹直接覆盖到新的服务器目录下的同文件夹中即可（导出的时候新老服务器里的应用最好停止再处理）  

#### 安装命令（待整理归纳）
```
创建一个名为 halo 的用户（名字可以随意）
useradd -m halo

给予 sudo 权限
usermod -aG sudo halo  

为 halo 用户创建密码
passwd halo

登录到 halo 账户
su - halo

创建存放 运行包 的目录，这里以 ~/app 为例
mkdir ~/app && cd ~/app

下载运行包（废弃）
wget https://dl.halo.run/release/halo-1.5.2.jar -O halo.jar（官方不再维护1.5版本，下不到了，使用新的命令处理）

获取 Halo 1.5.2 版本的下载链接
RELEASE_URL=$(curl -s https://api.github.com/repos/halo-dev/halo/releases/tags/v1.5.2 | grep "browser_download_url.*halo-1.5.2.jar" | cut -d '"' -f 4)

下载 JAR 文件到 ~/app 目录
cd ~/app && wget "$RELEASE_URL" -O halo.jar

创建 工作目录
mkdir ~/.halo && cd ~/.halo

下载示例配置文件到 工作目录（不需要，直接用老的）
wget https://dl.halo.run/config/application-template.yaml -O ./application.yaml （不需要下载，直接从老的服务器里拉过来）

编辑配置文件，配置数据库或者端口等，如需配置请参考 配置参考（不需要，直接用老的）
vim application.yaml

测试运行 Halo
cd ~/app && java -jar halo.jar

如看到类似以下日志输出，则代表启动成功。
run.halo.app.listener.StartedListener    : Halo started at         http://127.0.0.1:8090
run.halo.app.listener.StartedListener    : Halo admin started at   http://127.0.0.1:8090/admin
run.halo.app.listener.StartedListener    : Halo has started successfully!

打开 http://ip:端口号 即可看到安装引导界面。
如测试启动正常，请继续看作为服务运行部分，第 8 步仅仅作为测试。当你关闭 ssh 连接之后，服务会停止。你可使用 CTRL+C 停止运行测试进程。
如果需要配置域名访问，建议先配置好反向代理以及域名解析再进行初始化。
如果通过 http://ip: 端口号 的形式无法访问，请到服务器厂商后台将运行的端口号添加到安全组，如果服务器使用了 Linux 面板，请检查此 Linux 面板是否有还有安全组配置，需要同样将端口号添加到安全组。

作为服务运行
退出 halo 账户，登录到 root 账户
如果当前就是 root 账户，请略过此步骤。
exit

下载 Halo 官方的 halo.service 模板（废弃）
wget https://dl.halo.run/config/halo.service -O /etc/systemd/system/halo.service（直接从老服务器拉）

修改 halo.service
vim /etc/systemd/system/halo.service

修改配置
YOUR_JAR_PATH：Halo 运行包的绝对路径，例如 /home/halo/app/halo.jar，注意：此路径不支持 ~ 符号。
USER：运行 Halo 的系统用户，如果有按照上方教程创建新的用户来运行 Halo，修改为你创建的用户名称即可。反之请删除 User=USER。

示例
[Unit]
Description=Halo Service
Documentation=https://halo.run
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=USER
ExecStart=/usr/bin/java -server -Xms256m -Xmx256m -jar YOUR_JAR_PATH
ExecStop=/bin/kill -s QUIT $MAINPID
Restart=always
StandOutput=syslog

StandError=inherit

[Install]
WantedBy=multi-user.target

重新加载 systemd
systemctl daemon-reload

运行服务
systemctl start halo

在系统启动时启动服务
systemctl enable halo

您可以查看服务日志检查启动状态
journalctl -n 20 -u halo

查看 halo 服务运行状态
systemctl status halo
```