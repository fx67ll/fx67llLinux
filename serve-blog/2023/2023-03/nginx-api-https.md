# 解决 Https 站点请求 Http 服务后报 the content must be served over HTTPS 错误的问题

### 问题分析
1. 之前将自己所有的`Http`站点全部更新为`Https`站点，但是请求后端服务的时候还是时候`Http`请求  
2. 导致部署之后，直接在控制台报 `This request has been blocked; the content must be served over HTTPS;` 的错误  

### 解决思路
1. 但是，我又不想耗费精力，将所有的后台服务也更新为支持`Https`请求  
2. 所以，访问了一些资料之后，发现了一个非常巧妙的思路，省时省力解决这个问题
3. 那就是直接使用Nginx将后端服务请求地址代理到`Https`前端站点的根目录下，经过Nginx这一层将后端`Http`请求包装成`Https`请求  

### 举个例子
比如你之前的后台服务请求地址是：http://xxx.com/api  
你可以修改Nginx配置*从这里继续写*
完美解决~~~牛逼o(￣▽￣)ｄ


#### 参考资料
[](https://blog.csdn.net/weixin_39255905/article/details/125168464)


我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2023/2023-03/nginx-api-https.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***