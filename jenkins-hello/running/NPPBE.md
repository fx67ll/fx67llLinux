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

### v3
```shell
#!/bin/bash

# ======================== 环境配置（固定解决 Jenkins 找不到 node） ========================
export NODE_VERSION="v12.22.12"
export NODE_HOME="/root/.nvm/versions/node/$NODE_VERSION"
export PATH="$NODE_HOME/bin:/usr/bin:$PATH"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # 重置颜色

echo -e "${BLUE}=============================================================${NC}"
echo -e "${PURPLE}🚀 开始自动部署 Node 项目：NPPBE${NC}"
echo -e "${BLUE}=============================================================${NC}"

# ======================== 1. 创建打包文件 ========================
echo -e "\n${GREEN}📦 步骤1/6：创建项目压缩包${NC}"
cd /root/.jenkins/workspace/NPPBE
ls -a
tar -zcvf dist.tar.gz *
echo -e "${GREEN}✅ 项目打包完成！${NC}"

# ======================== 2. 创建目标目录 ========================
echo -e "\n${GREEN}📂 步骤2/6：检查并创建部署目录${NC}"
mkdir -p /usr/node/NPPBE
chmod -R 755 /usr/node/NPPBE
echo -e "${GREEN}✅ 目录准备完成！${NC}"

# ======================== 3. 复制文件 ========================
echo -e "\n${GREEN}📤 步骤3/6：复制压缩包到部署目录${NC}"
cd /root/.jenkins/workspace/NPPBE
cp /root/.jenkins/workspace/NPPBE/dist.tar.gz /usr/node/NPPBE

echo -e "\n${YELLOW}---------------------------------------------------------${NC}"
echo -e "${YELLOW}📋 工作区文件列表${NC}"
ls -a
rm -rf *
echo -e "${YELLOW}🧹 清理后工作区文件列表${NC}"
ls -a
echo -e "${YELLOW}---------------------------------------------------------${NC}"

# ======================== 4. 解压文件 ========================
echo -e "\n${GREEN}🗂️  步骤4/6：解压项目文件${NC}"
cd /usr/node/NPPBE
tar -zxvf dist.tar.gz -C ./
chmod -R 755 /usr/node/NPPBE

echo -e "\n${YELLOW}---------------------------------------------------------${NC}"
echo -e "${YELLOW}📋 部署目录文件列表${NC}"
ls -a
rm -r dist.tar.gz
rm -f .env
echo -e "${YELLOW}🧹 清理临时文件后${NC}"
ls -a
echo -e "${YELLOW}---------------------------------------------------------${NC}"

# ======================== 5. 复制环境配置 ========================
echo -e "\n${GREEN}⚙️  步骤5/6：复制环境配置文件 .env${NC}"
cd ../
cp /root/.jenkins/workspace/.env /usr/node/NPPBE
cd ./NPPBE
chmod 644 .env

echo -e "\n${YELLOW}---------------------------------------------------------${NC}"
echo -e "${YELLOW}📋 最终目录文件列表${NC}"
ls -a
echo -e "${YELLOW}---------------------------------------------------------${NC}"

# ======================== 6. 安装依赖 & 启动服务 ========================
echo -e "\n${GREEN}🔧 步骤6/6：安装依赖 & 启动应用${NC}"
cd /usr/node/NPPBE

echo -e "\n${BLUE}📥 正在安装 npm 依赖...${NC}"
npm install

echo -e "\n${BLUE}📂 进入 bin 目录${NC}"
cd bin

echo -e "\n${BLUE}📋 当前 PM2 进程列表：${NC}"
pm2 list

echo -e "\n${BLUE}🛑 停止旧服务（如有）：${NC}"
pm2 stop NPPBE || true

echo -e "\n${BLUE}▶️  启动新服务：${NC}"
pm2 start www --name="NPPBE"

echo -e "\n${BLUE}💾 保存 PM2 自启动：${NC}"
pm2 save

echo -e "\n${BLUE}✅ 最新运行状态：${NC}"
pm2 list

# ======================== 部署完成 ========================
echo -e "\n${PURPLE}=============================================================${NC}"
echo -e "${PURPLE}🎉 项目 NPPBE 部署全部完成！${NC}"
echo -e "${PURPLE}=============================================================${NC}"
```


### `NPPBE`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://run.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  