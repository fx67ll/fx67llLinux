# NPPBE的shell记录

#### v1
```shell
ls -a
tar -zcvf dist.tar.gz *
cd /usr/node/NPPBE
rm -rf *
cd /root/.jenkins/workspace/NPPBE
scp /root/.jenkins/workspace/NPPBE/dist.tar.gz /usr/node/NPPBE
echo ---------------------------------------------------------
echo /root/.jenkins/workspace/NPPBE filelist
ls -a
rm -rf *
echo /root/.jenkins/workspace/NPPBE filelist after 'rm -rf *'
ls -a
echo ---------------------------------------------------------
cd /usr/node/NPPBE
tar -zxvf dist.tar.gz -C ./
echo ---------------------------------------------------------
echo /usr/node/NPPBE filelist
ls -a
rm -r dist.tar.gz
rm -f .env
echo /usr/node/NPPBE filelist after 'rm -r/-f'
ls -a
echo ---------------------------------------------------------
cd ../
scp /root/.jenkins/workspace/.env /usr/node/NPPBE
cd ./NPPBE
echo ---------------------------------------------------------
echo /usr/node/NPPBE filelist last
ls -a
echo ---------------------------------------------------------
npm install
cd bin
pm2 list
pm2 start www --name="NPPBE"
```

#### v2
```shell
#!/bin/bash

# 创建打包文件
echo "创建打包文件"
cd /root/.jenkins/workspace/NPPBE
ls -a
tar -zcvf dist.tar.gz *

# 确保目标目录存在且权限正确
echo "检查并设置目标目录权限"
mkdir -p /usr/node/NPPBE
chmod -R 755 /usr/node/NPPBE

# 复制文件到目标目录
echo "复制文件到目标目录"
cd /root/.jenkins/workspace/NPPBE
scp /root/.jenkins/workspace/NPPBE/dist.tar.gz /usr/node/NPPBE

echo ---------------------------------------------------------
echo /root/.jenkins/workspace/NPPBE filelist
ls -a
rm -rf *
echo /root/.jenkins/workspace/NPPBE filelist after 'rm -rf *'
ls -a
echo ---------------------------------------------------------

# 解压文件并设置权限
echo "解压文件并设置权限"
cd /usr/node/NPPBE
tar -zxvf dist.tar.gz -C ./
chmod -R 755 /usr/node/NPPBE

echo ---------------------------------------------------------
echo /usr/node/NPPBE filelist
ls -a
rm -r dist.tar.gz
rm -f .env
echo /usr/node/NPPBE filelist after 'rm -r/-f'
ls -a
echo ---------------------------------------------------------

# 复制环境文件
echo "复制环境文件"
cd ../
scp /root/.jenkins/workspace/.env /usr/node/NPPBE
cd ./NPPBE
chmod 644 .env

echo ---------------------------------------------------------
echo /usr/node/NPPBE filelist last
ls -a
echo ---------------------------------------------------------

# 安装依赖并启动应用
echo "安装依赖并启动应用"
cd /usr/node/NPPBE
npm install
cd bin

# 确保 PM2 以正确的用户运行
echo "列出 PM2 进程"
pm2 list

# 停止现有应用（如果有）
echo "停止现有应用"
pm2 stop NPPBE || true

# 启动应用
echo "启动新应用"
pm2 start www --name="NPPBE"

# 保存 PM2 进程列表
echo "保存 PM2 进程列表"
pm2 save

# 显示应用状态
echo "显示应用状态"
pm2 list
```


### `NPPBE`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://test.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  