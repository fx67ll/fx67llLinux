# 服务器重启记录

1. 重启 Nginx 服务  
	+ `nginx`  
2. 重启 Tomcat 服务  
	+ `cd /usr/soft/install/apache-tomcat-9.0.7/bin`  
	+ `./startup.sh`  
3. 检查 MySQL 服务  
4. 检查 MongoDB 服务  
	+ `cd /usr/soft/install/mongodb-linux-x86_64-rhel70-4.4.4/bin`  
	+ `./mongod -f mongodb.conf`  
5. 重启 Node 服务  
	+ `cd /usr/node/JDSMS`  
	+ `pm2 start app.js --name="fx67llNode"`  

**PS: Node项目一直没有启动起来，下次再处理，这次没有记录完**