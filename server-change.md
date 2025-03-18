# 后端服务迁移流程记录

### 主要流程
1. 安装宝塔面板，宝塔相关服务可以在linux上输入`bt`命令  
2. 检查防火墙端口，服务器和宝塔的防火墙端口都要检查并开放（*直接参考原服务器依次抄一份到新服务器*）  
	+ 8888 宝塔初始端口  
	+ 3306 mysql初始端口  
	+ 6379 redis初始端口  
	+ 9897 ruoyi服务端口  
3. mysql服务迁移流程  
	+ 宝塔下载安装mysql  
	+ 修改账号密码
	+ 分别使用 `mysql -u root -p` 命令和外部工具 `DBeaver` 连接验证一下  
	+ 使用宝塔备份数据的功能迁移mysql数据  
4. redis服务迁移流程  
	+ 宝塔下载安装redis  
	+ 修改账号密码，直接修改配置文件中 `requirepass` 选项，再重启服务即可  
	+ 修改配置文件中 `bind 127.0.0.1`这一行，将其注释掉，或者改为 `bind 0.0.0.0` 允许所有IP的连接
	+ 修改配置文件中 `protected-mode` 为 `no`
	+ 分别使用 `redis-cli` 命令和外部工具 `RedisDesktopManagement` 连接验证一下  
	+ 使用 `BGSAVE` 命令持久化旧服务器的数据，生成文件 `dump.rdb`，停止新服务器redis服务，复制到新服务器，重启服务即可迁移redis数据  
5. 使用宝塔安装 `jdk1.8` & `tomcat9`，上传服务包至 `/home/ruoyi`，使用宝塔界面配置服务并启动即可  
6. 修改nginx配置文件中，fx67ll后台管理系统的api映射地址，直接搜关键字`api`即可查询到，改为新服务器的ip地址  
7. 安装mongodb服务，修改node应用的`.env`文件中，mongodb的远程连接地址，使用`pm2 restart <应用名称> --update-env`重启服务并更新后台环境   
8. 其余配置参考老的宝塔，一步一步拷贝设置就行了

#### Redis数据迁移流程详细记录
```
# 在原服务器上创建数据快照（同步操作，可能会阻塞）
1. redis-cli 
2. 输入密码
3. BGSAVE

# 快照文件通常位于工作目录，通常是 redis.conf 中的 dir 选项指定的位置

# 将 dump.rdb 文件复制到新服务器，手动复制也行
scp /path/to/redis/dump.rdb user@newserver:/path/to/redis/
 
# 在新服务器上启动 Redis 服务
redis-server --port 6379 --bind 0.0.0.0 --dir /path/to/redis/ --dbfilename dump.rdb
```


### 宝塔面板绑定域名以及ssl证书的流程
1. 先关闭面板本身的 *ssl开关* ，可视化界面关闭不一定成功，在 *ssh面板* 输入 `bt` 命令关闭即可  
2. 可以绑定域名访问，也可以不绑定域名访问，绑定后仍然需要使用 `域名+端口号` 的方式访问  
3. 监听 `80端口`，使用 *nginx代理* 原来宝塔的 `http地址` 就可以完成域名绑定
4. 监听 `443端口` 就可以使用 `https地址` 访问，*ssl证书* 申请流程不在此记录了  

#### 宝塔Nginx配置记录
```
server {
	listen  80;
	server_name ez13.top;
	location / {
		proxy_pass http://ez13.top:1023;
		# proxy_pass http://124.71.201.142:1023;
	}
}

server
{
	listen 443 ssl;
	server_name ez13.top;
	
	ssl_certificate               /etc/ssl/ez13.top/ez13.top.crt;
	ssl_certificate_key           /etc/ssl/ez13.top/ez13.top.key;
	ssl_protocols                 TLSv1.1 TLSv1.2 TLSv1.3;
	ssl_ciphers                   ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
	ssl_prefer_server_ciphers     on;
	ssl_session_cache             shared:SSL:1m;
	ssl_session_timeout           10m;
	
	location / {
		proxy_pass http://ez13.top:1023;
		# proxy_pass http://124.71.201.142:1023;
	}
}
```
