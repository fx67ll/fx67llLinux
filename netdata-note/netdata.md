# netdata 安装命令记录

[官方教程地址](https://learn.netdata.cloud/docs/installing/)  

### 安装命令
一条linux命令安装，无更新，使用稳定版，不发送数据给官方用于优化软件（还有一个可选项连接到官方的云，单服务器安装我直接忽略了）
```
wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh --disable-telemetry
```

`--no-updates` for no updates
Do you want automatic updates? default: enabled

`--stable-channel` for stable
Do you want nightly or stable releases? default: nightly

`--disable-telemetry` for no contribute
Do you want to contribute anonymous statistics? default: enabled


### 安装记录
出现下方的文字表示安装完毕，中途需要输入几次`y`确认进程推进
*如果安装中途有问题自动停止了，请不要担心，可能是因为网络原因连接不上github，请多执行几次上方的安装命令，尝试即可，笔者尝试了三次才完全安装成功*
```
Successfully installed the Netdata Agent.

Official documentation can be found online at https://learn.netdata.cloud/docs/.

Looking to monitor all of your infrastructure with Netdata? Check out Netdata Cloud at https://app.netdata.cloud.

Join our community and connect with us on:
  - GitHub: https://github.com/netdata/netdata/discussions
  - Discord: https://discord.gg/5ygS846fR6
  - Our community forums: https://community.netdata.cloud/

```

### 启动停止
请开放防火墙`19999`端口后再启动，启动后访问`IP:19999`即可  
```
启动
service netdata start

重启
service netdata restart

查看19999端口情况
netstat -ntulp | grep 19999
lsof -i:19999
```
