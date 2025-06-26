# 记录一下nginx站点迁移的步骤流程

### 静态网站
1. 先把旧服务器目录`/usr/share`下的`nginx`文件夹复制到新的服务器的相同目录下  
2. 再逐一开放相关网站的端口号，并在新的nginx文件夹中增加对应域名的配置，最后再指定的nginx配置文件夹中新增端口号和静态文件对应的配置  
3. 每开放一个端口，还一定要记得开放一个防火墙的端口。执行命令`sudo ufw allow 端口号`即可  

#### nginx端口号对应静态文件首页的配置，是如何被`nginx.conf`主配置文件识别的
```
# 这里表示 Nginx 会自动加载 /www/server/nginx/conf/vhost/nginx-fx67ll/ 目录下的所有配置文件
include /www/server/nginx/conf/vhost/nginx-fx67ll/*.conf;
```


### 后台服务
#### express node 服务
1. 从旧服务器的`/usr/node`目录拷贝相关应用到新服务器同目录，注意不要拷贝`node_modules`目录  
2. 依次安装`node@14.16.0`和`pm2@4.5.5`依赖  
3. 安装完成后执行以下命令  
```
cd /usr/node/NPPBE
npm install
cd bin
pm2 list
pm2 start www --name="NPPBE"
```
4. 切记环境变量文件名称为`.env`

#### jenkins java 服务



