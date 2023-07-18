# 解决 Https 站点请求 Http 接口服务后报 the content must be served over HTTPS 错误的问题

### 问题分析
之前将自己所有的`Http`站点全部更新为`Https`站点，但是请求后端服务的时候还是时候`Http`请求，  
导致部署之后，直接在控制台报 `This request has been blocked; the content must be served over HTTPS;` 的错误  

### 解决思路
因为我不想耗费精力，将所有的后台接口服务也更新为支持`Https`请求，所以访问了一些资料之后，发现了一个非常巧妙的思路，省时省力解决这个问题。  
那就是直接使用Nginx将后端服务的`http`请求地址代理到前端`Https`站点的一个目录下，经过Nginx这一层将后端`Http`请求包装成`Https`请求  

### 举个栗子
1. 比如你之前的后台服务请求地址是：`http://bbb.com`（甚至你的请求地址是`ip+端口`都没关系）  
2. 然后你的前端站点部署的域名是：`https:/aaa.com`  
3. 你可以通过修改Nginx配置，将后台请求的服务地址转发到前端域名地址的一个目录下，比如：`https:/aaa.com/bbb-api`  
4. 这样就可以让Nginx帮你完美解决`http`请求无法访问`https`站点的问题~~~牛逼o(￣▽￣)ｄ  

### Nginx配置示例
这里没有放出全部的配置示例，因为只需要修改前端域名中443端口的监听配置即可
```
server
{
	listen 443 ssl;
	server_name aaa.com;
	
	ssl_certificate               /etc/ssl/aaa.com.crt;
	ssl_certificate_key           /etc/ssl/aaa.com.key;
	ssl_protocols                 TLSv1.1 TLSv1.2 TLSv1.3;
	ssl_ciphers                   ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
	ssl_prefer_server_ciphers     on;
	ssl_session_cache             shared:SSL:1m;
	ssl_session_timeout           10m;
	
	# 这里是前端https站点的配置
	location / {
		proxy_pass http://ip:端口;
	}
	
	# 这里是转发到另一个后台http请求的配置，也可以直接用ip+端口
	location /bbb-api/ {
		proxy_pass http://bbb.com/;
	}
}
```

我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2023/2023-03/nginx-api-https.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***