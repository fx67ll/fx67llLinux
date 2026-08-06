### 安装node服务和pm2服务
#### **前提条件**
确保服务器已安装 **Node.js** 和 **npm**（Node包管理器）。如果未安装，可通过以下命令快速安装：
```bash
# 使用NodeSource仓库安装Node.js 18.x（推荐版本）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs  # Ubuntu/Debian
# 或
sudo yum install -y nodejs      # CentOS/RHEL

# 验证安装
node -v    # 输出类似 v18.16.0
npm -v     # 输出类似 9.5.1
```

#### **步骤1：使用npm全局安装PM2**
PM2可以通过npm直接全局安装（需使用`sudo`权限）：
```bash
sudo npm install -g pm2
```
**参数说明**：
- `-g`：全局安装，将PM2添加到系统PATH中，可在任意目录使用。

#### **步骤2：验证PM2安装**
安装完成后，通过以下命令检查PM2版本，确认安装成功：
```bash
pm2 --version
```
输出类似：`5.3.0`（具体版本可能随时间更新）。

#### **步骤3：设置PM2开机自启动**
PM2提供了自动生成开机启动脚本的命令，支持多种Linux发行版（如Ubuntu、CentOS、Systemd等）。

#### **方法1：使用`pm2 startup`（推荐）**
运行以下命令，PM2会自动检测系统类型并生成对应的启动脚本：
```bash
pm2 startup
```
**输出示例**（以Systemd系统为例）：
```
[PM2] Init System found: systemd
[PM2] To setup the Startup Script, copy/paste the following command:
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u your_username --hp /home/your_username
```
复制并执行上述命令（替换`your_username`为你的用户名），完成开机自启动配置。

#### **方法2：手动配置Systemd服务（可选）**
如果`pm2 startup`无法自动生成脚本，可手动创建Systemd服务文件：
```bash
sudo nano /etc/systemd/system/pm2.service
```
在文件中粘贴以下内容（替换`your_username`为用户名）：
```ini
[Unit]
Description=PM2 process manager
Documentation=https://pm2.keymetrics.io/
After=network.target

[Service]
Type=forking
User=your_username
Group=your_username
WorkingDirectory=/home/your_username
ExecStart=/usr/bin/pm2 resurrect
ExecStop=/usr/bin/pm2 kill
Restart=always
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Environment=PATH=/usr/bin:/usr/local/bin:/home/your_username/.nvm/versions/node/v18.16.0/bin  # 替换为你的Node.js路径
Environment=PM2_HOME=/home/your_username/.pm2

[Install]
WantedBy=multi-user.target
```

保存后，启用并启动服务：
```bash
sudo systemctl enable pm2.service  # 开机自启动
sudo systemctl start pm2.service   # 立即启动
```

#### **步骤4：保存当前PM2进程列表（可选）**
如果已使用PM2启动了应用，可通过以下命令保存当前进程列表，确保开机后自动恢复：
```bash
pm2 save
```

#### **常用PM2命令**
安装完成后，可使用以下命令管理Node.js应用：
```bash
pm2 start app.js          # 启动应用
pm2 list                  # 查看所有运行中的应用
pm2 stop app_name         # 停止应用
pm2 restart app_name      # 重启应用
pm2 delete app_name       # 删除应用
pm2 logs                  # 查看所有应用的日志
pm2 monit                 # 监控应用资源使用情况
```

#### **常见问题解决**
1. **权限问题**：如果安装或运行时提示权限不足，确保使用`sudo`或检查npm全局目录的权限。
2. **Node.js路径问题**：如果PM2无法找到Node.js，可通过`which node`查看Node.js路径，并在`pm2 startup`命令中手动指定。
3. **开机自启动失败**：检查Systemd服务文件路径和用户权限是否正确，或使用`journalctl -u pm2.service`查看服务日志。


通过以上步骤，你已成功在Linux服务器上全局安装PM2，并配置了开机自启动。


### 使用 apt-get 安装指定版本的 Node.js 14.16.0
在 Ubuntu/Debian 系统中，`apt-get` 命令可以通过指定包的版本号来安装特定版本的软件。但需要注意，**系统默认的官方仓库（如 `ubuntu:focal`）中可能没有 Node.js 14.16.0 这个精确版本**，因此通常需要先添加包含该版本的第三方仓库（如 NodeSource）。

```
查询版本
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -

如果系统显示可以执行下方命令安装14版本就直接执行即可
sudo apt-get install -y nodejs

查看安装是否成功
node -v    # 输出 v14.16.0
npm -v     # 输出对应版本（如6.14.11）

为避免系统自动将 Node.js 升级到其他版本，可通过 `apt-mark hold` 锁定当前版本：
sudo apt-mark hold nodejs

**解锁方法**（如需升级到其他版本）：
sudo apt-mark unhold nodejs
```

#### **注意事项**
1. **仓库可用性**：NodeSource 仓库可能会更新或移除旧版本。如果 14.16.0 不可用，可尝试安装 14.x 系列的其他版本（如 14.21.3），或使用 NVM 安装精确版本。
2. **版本格式**：使用 `apt-cache madison nodejs` 查询到的版本格式可能因系统和仓库不同而略有差异（如 `14.16.0-1nodesource1`），需以实际查询结果为准。
3. **替代方案**：如果 apt-get 无法安装精确版本，推荐使用 [NVM（Node Version Manager）](https://github.com/nvm-sh/nvm)，它支持安装任意精确版本（包括 14.16.0），且不依赖系统仓库：
   ```bash
   # 安装 NVM
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
   source ~/.bashrc  # 重新加载配置

   # 使用 NVM 安装 14.16.0
   nvm install 14.16.0
   nvm use 14.16.0
   ```

通过以上步骤，你可以使用 `apt-get` 命令成功安装 Node.js 14.16.0 版本。




### 要在Linux服务器上安装 **Node.js 14.16.0** 这个精确版本，可以通过以下三种方式实现：
#### **方法1：使用NodeSource仓库（推荐）**
NodeSource仓库提供了包含特定小版本的安装包，适合直接安装指定版本。
##### **步骤1：安装Node.js 14.x仓库**
先添加Node.js 14.x的官方仓库：
```bash
# Ubuntu/Debian系统
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -

# CentOS/RHEL系统
curl -fsSL https://rpm.nodesource.com/setup_14.x | sudo -E bash -
```
##### **步骤2：安装Node.js 14.16.0**
NodeSource仓库中的包名通常包含版本号，可通过以下命令安装指定版本：
```bash
# Ubuntu/Debian系统
sudo apt-get install -y nodejs=14.16.0-deb-1nodesource1  # 精确版本号可能需通过`apt-cache madison nodejs`查询

# CentOS/RHEL系统
sudo yum install -y nodejs-14.16.0  # 若仓库中存在该精确版本
```
**注意**：NodeSource仓库可能不总是包含所有小版本（如14.16.0）。如果上述命令无法找到精确版本，可尝试方法2或方法3。

#### **方法2：使用NVM（Node Version Manager，推荐）**
NVM是管理多版本Node.js的最佳工具，支持安装精确的小版本（如14.16.0）。
##### **步骤1：安装NVM**
执行官方脚本安装NVM（稳定版）：
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
```
安装后，重新加载终端配置或执行以下命令使NVM生效：
```bash
source ~/.bashrc   # 或 ~/.zshrc（取决于你的Shell）
```
##### **步骤2：使用NVM安装Node.js 14.16.0**
直接指定精确版本号安装：
```bash
nvm install 14.16.0
```
安装完成后，使用以下命令切换到该版本：
```bash
nvm use 14.16.0
```
**验证**：检查版本是否正确：
```bash
node -v    # 输出 v14.16.0
npm -v     # 输出对应版本（如6.14.11）
```
##### **设置默认版本（可选）**
若希望每次启动终端自动使用14.16.0版本，可设置默认：

```bash
nvm alias default 14.16.0
```

#### **方法3：手动下载二进制文件（适用于任意版本）**
通过官方下载页面获取精确版本的二进制文件，手动配置环境变量。
##### **步骤1：下载Node.js 14.16.0二进制文件**
访问[Node.js官方下载页面](https://nodejs.org/en/download/releases/)，找到14.16.0版本，复制对应系统的二进制文件链接（如Linux 64位）：
```bash
# 下载Linux 64位二进制文件
wget https://nodejs.org/dist/v14.16.0/node-v14.16.0-linux-x64.tar.xz

# 解压文件
tar -xf node-v14.16.0-linux-x64.tar.xz
```
##### **步骤2：配置全局路径**
将解压后的文件夹移动到系统目录，并添加到环境变量：
```bash
# 移动到/usr/local目录（推荐）
sudo mv node-v14.16.0-linux-x64 /usr/local/node-v14.16.0

# 配置环境变量（编辑~/.bashrc或~/.zshrc）
echo 'export PATH="/usr/local/node-v14.16.0/bin:$PATH"' >> ~/.bashrc

# 使配置生效
source ~/.bashrc
```
##### **验证安装**
检查版本是否正确：
```bash
node -v    # 输出 v14.16.0
npm -v     # 输出对应版本（如6.14.11）
```

#### **推荐方案对比**
| 方法         | 优势                          | 适用场景                          |
|--------------|-------------------------------|-----------------------------------|
| **NVM**      | 支持多版本共存、精确控制版本  | 需要频繁切换Node.js版本的场景    |
| **NodeSource** | 安装简单、适合生产环境        | 固定版本、无需切换的生产服务器   |
| **手动二进制** | 可安装任意非官方版本          | 需要特殊编译参数或非标准版本的场景 |

如果只是需要固定使用14.16.0版本，推荐使用 **NVM** 或 **NodeSource**；如果仓库中没有精确的