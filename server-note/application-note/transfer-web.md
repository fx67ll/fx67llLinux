# 网站站点迁移流程记录

### 静态站点
1. 先把旧服务器目录`/usr/share`下的`nginx`文件夹复制到新的服务器的相同目录下  
2. 再逐一开放相关网站的端口号，并在新的nginx文件夹中增加对应域名的配置，最后再指定的nginx配置文件夹中新增端口号和静态文件对应的配置  
3. 每开放一个端口，还一定要记得开放一个防火墙的端口。执行命令`sudo ufw allow 端口号`即可  

#### nginx端口号对应静态文件首页的配置，是如何被`nginx.conf`主配置文件识别的
```
# 这里表示 Nginx 会自动加载 /www/server/nginx/conf/vhost/nginx-fx67ll/ 目录下的所有配置文件
include /www/server/nginx/conf/vhost/nginx-fx67ll/*.conf;
```


### Node服务
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


### 自动化可持续部署服务
#### jenkins java 服务
1. 在旧服务器`/usr/soft/sort`目录中下载tomcat安装包  
2. 在旧服务器`/root/.jenkins`目录中下载`jobs/plugins/secrets/users/config.xml`这些目录和文件  
3. 在旧服务器`/usr/soft/install/apache-tomcat-9.0.7`目录中下载所有文件夹和文件  
4. 在新服务器中利用 xFtp 上传 `tomcat.gz` 包至安装目录下`/usr/soft/sort`  
5. 解压安装包至指定目录下`tar -zxvf /usr/soft/sort/apache-tomcat-9.0.7.tar.gz -C /usr/soft/install/`  
6. 配置环境变量，注意实践中我并未找到教程中的那个文件，我修改的文件是 `/etc` 目录下的 `profile` 文件，没有后缀  
	> `vim /etc/profile`  
7. 在文件的最后一行添加如下内容  
	> 按 `i` 开始修改（注意 `s` 会删除当前选中字符）  
	> `export CATALINA_HOME=/usr/soft/install/apache-tomcat-9.0.7`  
	> `export CATALINA_BASE=/usr/soft/install/apache-tomcat-9.0.7`  
	> 按 `esc` 停止编辑，按 `:` 开始输入，输入 `wq` 保存并退出  
8. 输入 `source /etc/profile` ，无报错立即生效  
9. 拷贝备份的`/usr/soft/install/apache-tomcat-9.0.7`目录文件覆盖到新安装的tomcat中  
10. 进入 `/usr/soft/install/apache-tomcat-9.0.7/bin` 目录下启动或停止  
	> 启动前记得先删除新安装的tomcat中`webapps`目录中的`jenkins`文件夹  
	> `./startup.sh` 启动，通过 `ip:端口` 查看到 tomcat 主页就算启动成功了  
	> `./shutdown.sh` 停止  
11. 启动新的jenkins之后，先走一下新手流程，然后再关闭，将之前备份的`/root/.jenkins`目录中的文件和文件夹都覆盖到新服务器同目录  
12. 重新启动tomcat即可  
13. 之前没有试过覆盖`secrets`文件夹，不知道凭证能否直接覆盖使用，如果不可以，还需要重新添加凭证，并且每一个流程都要重新使用新的凭证  
14. 凭证相关请参考原先的`jenkins`安装记录博客的内容  


### 遇到的问题
#### 没有请求接口直接访问html之后报403权限不足
1. 虽然配置中没有直接问题，但 403 错误最常见的原因是 Nginx 用户（如 nginx 或 www-data）对 /usr/share/nginx/html-8070 目录或 index.html 文件没有读取权限  
2. 确保 Nginx 用户对目录和文件有正确的权限，若权限不足，修改为 Nginx 可访问的权限  
```
chmod -R 755 /usr/share/nginx/html-8070  # 目录权限
chmod 644 /usr/share/nginx/html-8070/index.html  # 文件权限
```