# 后端服务迁移流程记录

### 主要流程
1. 安装宝塔面板  
2. 检查防火墙端口，服务器和宝塔的防火墙端口都要检查并开放  
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