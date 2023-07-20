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
4. `/etc/ssl` ssl证书目录  


### Halo服务运维相关命令
```
# 修改配置文件
vim ~/.halo/application.yaml

# 重启、停止、启动、查询状态
sudo systemctl restart halo
sudo systemctl stop halo
sudo systemctl start halo
sudo systemctl status halo

# 设置开机自动启动
sudo systemctl enable halo
```
#### Halo配置文件
*注意！！！*配置文件详细说明请参考[官方文档](https://docs.halo.run/1.6/getting-started/config)  
```
server:
  port: 8090
  # Response data gzip.
  compression:
    enabled: false
	
spring:
  datasource:
    # H2 database configuration.
    driver-class-name: org.h2.Driver
    console:
      settings:
	    # 修改这里可以开启h2数据库访问，平时关闭
        web-allow-others: false
      path: /h2-console
	  # 修改这里可以开启h2数据库访问，平时关闭
      enabled: false

halo:
  # Your admin client path is https://your-domain/{admin-path}
  admin-path: admin
  # memory or level，
  cache: memory
```


### SSL证书需要每年更新
#### SSL证书失效后重新部署的相关问题
1. SSL证书下发之前选择DNS自动验证即可，记得删除之前的验证
2. SSL证书重新签发之后，检查证书下发的域名和nginx.conf配置文件中的指向的是否一致！！！ 
3. SSL证书统一存储在`/etc/ssl`目录下  
4. 注意！！！更换证书之后需要有一定的时间清除缓存的证书，切勿心急~~~


## 未来需要完成的一个重要脚本
需要在服务器炸了或者重启之后，能够自动重新启动所有需要的服务，完成类似halo那样的持续维护功能