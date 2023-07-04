# 服务器重启记录


### 逐一重启以下服务
1. 重启 Nginx 服务  
	+ `nginx`  
2. 重启 Tomcat 服务，主要为了跑`jenkins`  
	+ `cd /usr/soft/install/apache-tomcat-9.0.7/bin`  
	+ `./startup.sh`  
3. 检查 MongoDB 服务  
	+ `cd /usr/soft/install/mongodb-linux-x86_64-rhel70-4.4.4/bin`  
	+ `./mongod -f mongodb.conf`  
	+ *炸了貌似只能重装，目前还不会运维MongoDB*
4. 重启 Node 服务  
	+ `cd /usr/node/JDSMS`  
	+ `pm2 start app.js --name="fx67llNode"`  
5. 重启防火墙
	+ `service iptables start`  
	+ 检查防火墙状态 `service iptables status`  
6. 各类练习用的数据库服务，需要注意！！！*因为都已在前台应用集合服务器上关闭，所以暂时不需要关注开启*
	+ MySQL-5.7 
	+ `service mysql start/status/stop`  
	+ MySQL-8.0 
	+ `service mysql80 start/status/stop`  
	+ Redis 服务搞起来相对于 MySQL 稍微复杂点  
	+ Redis 开启
	+ `cd /usr/soft/install/mongodb-linux-x86_64-rhel70-4.4.4/bin`  
	+ `redis-server redis.conf`  
	+ Redis 关闭
	+ 使用root账户登录redis-cli `redis-cli -h 127.0.0.1 -p 6379 -a (这里是配置文件里写的密码)`  
	+ `shutdown`，显示*not connected*即为关闭成功


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