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

#### 重启nginx失效，就一个个杀pid，杀完再重启就好了


### 解决 Vue 路由 配置 history模式之后刷新页面白屏的问题
1. 一个根目录单个站点
```
server {
	listen       8888;
	server_name  localhost;
	location / {
		root       /usr/nginx/html;
		index      index.html;
		# 在这里添加一个配置项即可解决
		try_files  $uri $uri/ /index.html;
	}
}
```
2. 一个根目录下面挂多个站点
```
server {
	listen       8888;
	server_name  localhost;
	# 通过 localhost:8888/aaa/ 访问
	location /aaa {
		root       /usr/nginx/html-aaa;
		index      index.html;
		try_files  $uri $uri/ /aaa/index.html;
	}
	# 通过 localhost:8888/bbb/ 访问
	location /bbb {
		root       /usr/nginx/html-bbb;
		index      index.html;
		try_files  $uri $uri/ /bbb/index.html;
	}
}
```


### 如何使用Nginx使用不同域名代理多个应用服务
1. 先代理不同端口并映射一个服务器文件夹，
2. 再代理不同域名到默认端口并通过不同域名(即server_name)来映射回到不同端口，这样就可以完成同一服务器不同域名展示不同应用服务
3. 注意经过 Nginx 代理端口之后可以直接通过域名访问，不需要开放防火墙的端口了！！！一般只有数据库端口和默认端口需要开放~


### Nginx部署SSL证书
1. 下载 Nginx 可用的ssl证书文件，再把这两个文件放到我们的服务器中，推荐放到`/etc/ssl/`目录下
2. 在`nginx.conf`文件中配置443端口的监听（*注意开放防火墙443端口*），写入ssl相关配置接口，参考`nginx-hello -> nginx.conf`
3. 强制使用https访问 `rewrite ^(.*)$  https://$host$1 permanent;`


### Nginx部署多个SSL证书
只需要上传新的证书，并监听新的`server_name`即可


### Nginx如何强制Http请求跳转Https请求
1. 跳转301，新版本Nginx推荐使用的配置写法
```
return 301 https://$server_name$request_uri; #http跳转https
```
2. 覆写地址，老版本Nginx的配置写法
```
# 指定域名的方式
rewrite ^(.*)$  https://xxx.xxx.xxx permanent;
# 通用
rewrite ^(.*)$  https://$host$1 permanent;
```
3. 错误码497，不推荐
```
error_page 497  https://$host$uri?$args;
```


### 如何配置Nginx资源访问不到的时候，跳转到统一的错误页面
1. Nginx提供了`error_page`配置来监听错误跳转统一的错误页面
```
# error_page 语法
error_page code [ code... ] [ = | =answer-code ] uri | @named_location 
```
2. 配置示例
```
server {
	listen       8888;
	server_name  localhost;
	location / {
		root       /usr/nginx/html;
		index      index.html;
		try_files  $uri $uri/ /index.html;
	}
	# 配置当报 404 错误访问的界面
	error_page 404 /40x.html;
	location = /40x.html {
		root  /usr/nginx/html-404;
	}
	# 配置当报 50 开头错误访问的界面
	error_page 500 502 503 504 /50x.html;
	location = /50x.html {
		root  /usr/nginx/html-50x;
	}
}
```
3. 注意！！！`error_page`配置时`加=`和`不加=`的区别  
```
# 这样可以访问错误页面时 http status 为 404 或 50x ，并且页面内容是 404.html/50x.html 的内容
error_page 404 /40x.html
error_page 500 502 503 504 /50x.html;
================================================
# 这样配置访问错误页面时 http status 为 200 ，但页面内容是 404.html 的内容
error_page 404 500 = /40x.html;
================================================ 
# 这样配置访问错误页面时 http status 为 404 ，但页面内容是 404.html 的内容
error_page 404 500 =404 /40x.html;
 ===============================================
# 也可以把 404请求 直接跳转到 301 到某个域上
error_page 404 =301 https://xxx.com/404;
```


### Nginx常用命令
1. 开启服务：
```
start nginx
或者直接点击Nginx目录下的nginx.exe 
```
2. 停止服务：nginx停止命令stop与quit参数的区别在于stop是快速停止nginx，可能并不保存相关信息，quit是完整有序的停止nginx  ，并保存相关信息。nginx启动与停止命令的效果都可以通过Windows任务管理器中的进程选项卡观察。
```
nginx -s stop
nginx -s quit
```
3. 重启服务：
```
nginx -s reload
```
4. 其他命令重启、关闭nginx
```
#  搜索 Nginx 进程命令号
ps -ef | grep nginx
========================
# 从容停止 Nginx
kill -QUIT 主进程号
========================
# 快速停止 Nginx
kill -TERM 主进程号
========================
# 强制停止 Nginx
pkill -9 nginx
========================
# 平滑重启 Nginx
kill -HUP 主进程号
```
5. 检查配置文件语法是否正确
```
nginx -t
========================
# 或者显示指定配置文件
nginx -t -c /usr/nginx/conf/nginx.conf
```

#### 之前找了很多编辑器插件格式化nginx配置文件一直没有生效，找了一个实用工具：[Nginx配置文件在线格式化工具网站](https://okcode.vip/dev/nginx-formatter)  