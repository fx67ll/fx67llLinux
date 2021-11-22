# 解决ip和域名都能够ping通但是启动nginx无法访问网页的问题  

### 解决思路
1. 最近双11逛西部数码的官网看看有没有什么服务器优惠的时候，发现了可以申请一个一块钱用一整年的SSL证书，立马心动下单了，想想俺也可以用`https`装装X了哈哈  
2. 不过在部署完证书，并调整nginx代理将初始端口指向`443端口`之时，突然发现个人站点访问不到了，有点奇怪  
3. 但是，遇到问题先别慌，先检查服务器的运行状态，一切OK，再检查是否能够ping通我的IP和域名，好没问题  
4. 咦这么奇怪的嘛，在我脑子没有转过弯之前，我一直没注意我的防火墙端口只开放到了初始端口，并没有开放`443端口`，啊，我在搞什么啊  
5. 于是，在`/etc/sysconfig/iptables`文件中开放`443端口`，重启防火墙，OK，网页访问正常了  
6. 总结，我真是个大傻X哈哈哈哈哈  

### 开启443端口流程
1. `cd /etc/sysconfig`进入该目录，检查是否存储了`iptables`文件  
2. `vim iptables`使用`vim编辑器`修改`iptables`文件，按下`i`进入编辑模式  
3. 在初始端口那行下面添加`-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT`，开放443端口  
4. `service iptables restart`重启防火墙即可  

### liunx防火墙命令
linux中主要分为旧版的iptables防火墙和新版的firewall防火墙  

#### iptables防火墙
1. 查看防火墙状态  `service iptables status`  
2. 停止防火墙  `service iptables stop`  
3. 启动防火墙  `service iptables start`  
4. 重启防火墙  `service iptables restart`  
5. 永久关闭防火墙  `chkconfig iptables off`  
6. 永久关闭防火墙后重启  `chkconfig iptables on`  

#### firewall防火墙
1. 查看防火墙服务状态  `systemctl status firewalld`  
2. 查看防火墙状态  `firewall-cmd --state`  
3. 停止防火墙  `service firewalld stop`  
4. 启动防火墙  `service firewalld start`  
5. 重启防火墙  `service firewalld restart`  
6. 查看防火墙规则  `firewall-cmd --list-all`  
7. 查看80端口是否开放  `firewall-cmd --query-port=80/tcp`  
8. 开放80端口  `firewall-cmd --permanent --add-port=80/tcp`  
9. 移除80端口  `firewall-cmd --permanent --remove-port=80/tcp`  
10. 开放和移除端口都是对配置文件做出了修改，需要重启防火墙，下面是`8/9`命令中的参数解析  
	+ `firewall-cmd`  是`linux`提供的操作`firewall`的一个工具  
	+ `--permanent`  表示设置为持久  
	+ `--add-port`  表示添加的端口  


我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2021/2021-11/ping-web.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***