# 服务器重启记录


### 逐一重启以下服务
1. 重启 Nginx 服务  
	+ `nginx`  
2. 重启 Tomcat 服务  
	+ `cd /usr/soft/install/apache-tomcat-9.0.7/bin`  
	+ `./startup.sh`  
3. 检查 MySQL 服务，`5.7`和`8.0`两个版本  
	+ 5.7 - service mysql start？（没验证过，下次验证）
	+ 8.0 - service mysql80 start
4. 检查 MongoDB 服务  
	+ `cd /usr/soft/install/mongodb-linux-x86_64-rhel70-4.4.4/bin`  
	+ `./mongod -f mongodb.conf`  
	+ *炸了貌似只能重装，目前还不会运维MongoDB*
5. 重启 Node 服务  
	+ `cd /usr/node/JDSMS`  
	+ `pm2 start app.js --name="fx67llNode"`  
6. 重启防火墙
	+ `service iptables start`  
	+ 检查防火墙状态 `service iptables status`  


### 服务器重要文件目录  
1. `/usr/soft` 各类软件安装包和解压包  
2. `/usr/share/nginx` nginx代理的静态文件地址  
3. `/etc/nginx` nginx配置文件目录


### SSL证书需要每年更新
#### SSL证书失效后重新部署的相关问题
1. SSL证书下发之前选择DNS自动验证即可，记得删除之前的验证
2. SSL证书重新签发之后，检查证书下发的域名和nginx.conf配置文件中的指向的是否一致！！！


### 未来需要完成的一个重要脚本
需要在服务器炸了或者重启之后，能够自动重新启动所有需要的服务，完成类似halo那样的持续维护功能