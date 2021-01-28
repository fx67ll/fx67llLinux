# Nginx 学习笔记

### 使用Nginx简单的代理Linux服务器主页
+ 安装nginx
+ 配置防火墙的端口
+ 启动nginx
	> `/usr/sbin/nginx`  
+ 关闭nginx
	> `nginx -s stop`  
+ 如果出现`nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)`之类的错误
	> `lsof -i:80`查看监听80端口的进程  
	> `kill -9 28767`杀进程，最后一个参数是进程的PID  
+ nginx默认配置存放地址
	> `/etc/nginx` -> ***nginx.conf***  
+ nginx默认页面存放地址
	> `/usr/share/nginx/html` -> ***index.html***  