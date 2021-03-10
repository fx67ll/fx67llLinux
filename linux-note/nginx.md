# Nginx 学习笔记

### 使用Nginx简单的代理Linux服务器主页
+ 安装nginx
+ 配置防火墙的端口
+ 启动nginx
	> `nginx`
	> `/usr/sbin/nginx`  
	> `nginx -c /etc/nginx/nginx.conf`
+ 关闭nginx
	> `nginx -s stop`  
+ 测试nginx配置文件
	> `nginx -t`  
+ 重启nginx
	> `nginx -s reload`  
+ 如果出现`nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)`之类的报错
	> `lsof -i:80`查看监听80端口的进程  
	> `kill -9 28767`杀进程，最后一个参数是进程的PID  
+ 如果出现`worker_processes" directive is duplicate`之类的报错
	> 检查是否有重复的`nginx.conf`文件出现，删除即可
+ nginx默认配置存放地址
	> `/etc/nginx` -> ***nginx.conf***  
+ nginx默认页面存放地址
	> `/usr/share/nginx/html` -> ***index.html***  

### 使用Nginx代理多个应用多个域名

### 重启nginx失效，就一个个杀pid，杀完再重启就好了

### 先代理不同端口(80/81/82)并映射一个服务器文件夹，
### 再代理不同域名到默认端口并通过不同域名(即server_name)来映射回到不同端口，这样就可以完成同一服务器不同域名展示不同应用或接口

### Nginx部署SSL证书
+ 下载nginx可用的ssl证书文件，再把这两个文件放到我们的服务器中，推荐放到/etc/ssl/目录下
+ 在`nginx.conf`文件中配置443端口的监听，写入ssl相关配置接口，参考`nginx-hello -> nginx.conf`