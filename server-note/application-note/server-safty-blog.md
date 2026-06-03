# 服务器入侵应急响应与安全加固全指南

---

# 服务器被 NTR 事件记录
**分析时间**：2026-06-01  
**受影响服务器**：hcss-ecs-695e  
**攻击类型**：SSH密码爆破 + 加密货币挖矿木马 + 双重持久化后门

---

## 一、攻击事件复盘
### 1.1 攻击时间线
| 时间 | 事件 | 风险等级 |
|------|------|----------|
| 2025-03-17 19:47 | 服务器初始化部署 | - |
| 2026-05-31 20:22 | 攻击者IP `220.250.52.101` 通过SSH密码登录`halo`用户 | 高危 |
| 2026-05-31 20:47 | 意大利IP `151.47.111.200` 二次登录，开始横向操作 | 高危 |
| 2026-05-31 20:59 | 挖矿包 `dota3.tar.gz` 写入 `/tmp/.X291-unix/` 临时目录 | 中危 |
| 2026-05-31 21:19 | 完整木马套件部署至 `/home/halo/.configrc7/` | 高危 |

### 1.2 攻击技术细节
#### 入侵入口：弱密码SSH认证
- 服务器未禁用SSH密码登录，`halo`账号使用弱密码或被泄露
- 攻击者通过自动化工具批量扫描全网开放22端口的服务器，进行字典爆破
- 两个攻击IP均为境外恶意节点，其中`151.47.111.200`归属意大利WIND TRE运营商

#### 恶意载荷：XMR门罗币挖矿木马
- 主挖矿进程伪装成内核线程 `kthreadadd64`，并通过`httpd`进程启动以混淆视听
- 完整执行命令：`/usr/sbin/httpd .rsync/c/kthreadadd64 -t 525`（`-t`指定挖矿线程数）
- 木马套件包含：启动脚本`run`、初始化脚本`init01`、定时任务`crond`、日志清理工具`delsshdv`、停止脚本`stop`、挖矿进程管理`rmkwork`

#### 持久化机制：双重后门保障
1. **定时任务后门**：篡改`halo`和`root`用户的crontab，每分钟检查并重启挖矿进程
2. **SSH公钥后门**：在`~/.ssh/authorized_keys`中植入攻击者公钥，即使修改密码也能登录

---

## 二、应急响应处置步骤
### 第一步：网络隔离（最高优先级）
**立即在云控制台安全组执行以下操作**：
- 仅允许你的办公IP访问22端口（SSH）
- 临时关闭所有非必要入站端口（80/443除外）
- 禁止服务器主动出站连接（防止下载更多恶意文件）

> ⚠️ 警告：此步骤必须最先执行，否则攻击者可能在你清理过程中重新入侵

### 第二步：终止所有恶意进程
```bash
# 精确查找并杀死挖矿主进程
ps aux | grep -E "kthreadadd|\.rsync|httpd.*kthread" | grep -v grep | awk '{print $2}' | xargs kill -9

# 批量查杀相关进程
pkill -9 -f kthreadadd64
pkill -9 -f ".rsync/c"
pkill -9 -f "dota3"

# 确认无残留进程
ps aux | grep -E "kthreadadd|\.rsync"
```

### 第三步：彻底清除恶意文件
```bash
# 删除临时目录挖矿包
rm -rf /tmp/.X291-unix/
rm -rf /var/tmp/.X291-unix/

# 删除用户目录下的木马套件
rm -rf /home/halo/.configrc7/

# 全局搜索可能遗漏的恶意文件
find / -name "dota3.tar.gz" -o -name "kthreadadd64" -o -name ".configrc7" 2>/dev/null
```

### 第四步：清除定时任务后门
```bash
# 清除所有用户的crontab
crontab -u halo -r
crontab -u root -r

# 检查系统级定时任务
rm -rf /etc/cron.d/*malicious*
cat /etc/crontab | grep -v "^#"
ls -la /etc/cron.hourly/ /etc/cron.daily/ /etc/cron.weekly/

# 检查用户级crontab目录
ls -la /var/spool/cron/crontabs/
```

### 第五步：清除SSH公钥后门
```bash
# 备份并清空halo用户的authorized_keys
cp /home/halo/.ssh/authorized_keys /home/halo/.ssh/authorized_keys.bak
> /home/halo/.ssh/authorized_keys

# 检查root用户的公钥文件
> /root/.ssh/authorized_keys

# 修复文件权限（防止被重新写入）
chmod 600 /home/halo/.ssh/authorized_keys
chmod 700 /home/halo/.ssh/
chown -R halo:halo /home/halo/.ssh/
```

### 第六步：SSH服务加固
```bash
# 修改halo用户密码（使用强密码：16位以上，包含大小写字母、数字和特殊符号）
passwd halo

# 编辑SSH配置文件
nano /etc/ssh/sshd_config
```

修改以下关键配置项：
```ini
# 禁用root远程登录
PermitRootLogin no

# 彻底禁用密码认证（必须先确保密钥登录正常）
PasswordAuthentication no

# 禁用空密码登录
PermitEmptyPasswords no

# 限制最大认证尝试次数
MaxAuthTries 3

# 限制登录会话数
MaxSessions 2
```

重启SSH服务使配置生效：
```bash
systemctl restart sshd
```

> ⚠️ 重要：在禁用密码登录前，**务必先测试密钥登录是否正常**，否则会导致自己无法登录服务器

### 第七步：IP封禁与防火墙配置
1. 在云控制台安全组中永久封禁以下IP：
   - `220.250.52.101`
   - `151.47.111.200`

2. 配置宝塔面板防火墙（推荐）：
   - 访问：`https://baota.fx67ll.com/firewall`
   - 添加IP黑名单，禁止上述IP所有端口访问
   - 开启SSH防爆破功能

### 第八步：深度后门排查
```bash
# 1. 检查是否存在UID=0的后门账号
awk -F: '$3==0 && $1!="root"' /etc/passwd

# 2. 检查所有可登录用户
cat /etc/passwd | grep -E "/bin/bash|/bin/sh" | grep -v root

# 3. 检查SUID权限文件（可能被替换为后门）
find /usr/bin /usr/sbin /bin /sbin -perm -4000 -type f 2>/dev/null

# 4. 检查动态链接库劫持（常见木马手段）
cat /etc/ld.so.preload
cat /etc/ld.so.conf.d/*

# 5. 检查自启动服务
systemctl list-unit-files --type=service | grep enabled | grep -v "@"

# 6. 检查rc.local自启动
cat /etc/rc.local
ls -la /etc/profile.d/

# 7. 查找带immutable锁定的顽固文件
find / -type f -exec lsattr {} \; 2>/dev/null | grep 'i'

# 8. 检查最近3天修改的系统文件
find /etc /usr/bin /usr/sbin /bin /sbin -mtime -3 -type f 2>/dev/null
```

---

## 三、全面安全隐患自查清单
### 3.1 账号与权限安全
```bash
# 查看所有可登录用户
cat /etc/passwd | grep -v nologin | grep -v false

# 查看最近新增用户
ls -lt /etc/shadow | head -10

# 查看sudo提权用户
cat /etc/sudoers | grep -v '^#' | grep -v '^$'
ls /etc/sudoers.d/
```

### 3.2 SSH服务安全
```bash
# 查看SSH配置
grep -v '^#' /etc/ssh/sshd_config | grep -v '^$'

# 查看登录历史
lastlog
last -n 20

# 查看登录失败记录
grep "Failed password" /var/log/auth.log | tail -20
```

### 3.3 网络与端口安全
```bash
# 查看所有监听端口
ss -tulnp

# 重点检查高危端口
ss -tulnp | grep -E "6379|3306|27017|6379|8080|9000"
```

> ✅ 安全标准：除80/443外，所有服务端口不应监听`0.0.0.0`，应改为`127.0.0.1`或通过安全组限制访问

### 3.4 系统完整性检查
```bash
# 检查关键系统文件修改时间
stat /bin/ps /bin/ls /usr/bin/curl /usr/bin/wget /usr/bin/top

# 对比系统安装时间，若修改时间晚于安装时间则可能被篡改
```

### 3.5 自查结果判断标准
| 检查项 | 安全状态 | 风险状态 |
|--------|----------|----------|
| UID=0账号 | 仅root用户 | 存在其他UID=0账号 |
| authorized_keys | 仅包含自己的公钥 | 存在陌生公钥 |
| ld.so.preload | 空文件 | 包含任何内容 |
| 定时任务 | 无陌生任务 | 存在未知定时任务 |
| 监听端口 | 仅80/443/22(受限) | 高危端口监听0.0.0.0 |
| 锁定文件 | 无带`i`属性的可疑文件 | 存在系统目录外的锁定文件 |

---

## 四、Fail2Ban 防爆破部署指南
Fail2Ban是一款开源的入侵防御工具，通过监控系统日志自动封禁恶意IP，是SSH防爆破的最佳实践。

### 4.1 安装与基础配置
```bash
# 更新系统并安装
apt update -y
apt install fail2ban -y

# 启动服务并设置开机自启
systemctl enable --now fail2ban
systemctl status fail2ban
```

### 4.2 SSH防爆破最优配置
创建SSH专用配置文件：
```bash
cat > /etc/fail2ban/jail.d/sshd.conf <<EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3        # 3次失败即封禁
bantime = 604800    # 封禁7天（60*60*24*7）
findtime = 300      # 5分钟内统计失败次数
ignoreip = 127.0.0.1 你的办公IP 服务器内网IP
EOF
```

重启服务使配置生效：
```bash
systemctl restart fail2ban
```

### 4.3 常用管理命令
```bash
# 查看SSH防护状态
fail2ban-client status sshd

# 查看所有被封禁的IP
fail2ban-client banned

# 解封指定IP
fail2ban-client set sshd unbanip 1.2.3.4

# 查看封禁日志
tail -f /var/log/fail2ban.log

# 统计历史攻击IP排名
grep "Ban" /var/log/fail2ban.log | awk '{print $NF}' | sort | uniq -c | sort -nr | head -20

# 查看今日封禁记录
grep $(date +%Y-%m-%d) /var/log/fail2ban.log | grep Ban
```

---

## 五、长期安全加固建议
### 5.1 系统级安全
1. **优先考虑重装系统**：深度入侵后无法100%保证清除所有后门，重装是最安全的选择
2. **启用云厂商主机安全服务**：如华为云企业主机安全、阿里云安骑士，提供实时入侵检测
3. **定期更新系统补丁**：`apt update && apt upgrade -y`，修复系统漏洞
4. **最小化安装原则**：只安装必要的软件包，减少攻击面

### 5.2 访问控制
1. **强制SSH密钥认证**：彻底禁用密码登录，使用RSA 4096位或Ed25519密钥
2. **IP白名单机制**：所有管理端口（SSH、宝塔、数据库）仅允许指定IP访问
3. **多因素认证**：为SSH和宝塔面板启用2FA双因素认证
4. **最小权限原则**：每个应用使用独立用户，禁止应用以root权限运行

### 5.3 数据安全
1. **定期自动备份**：配置每日自动备份，备份数据存储在独立的云存储中
2. **异地备份**：重要数据同时备份到不同地域的存储服务
3. **备份验证**：定期测试备份数据的可恢复性

### 5.4 监控与告警
1. **配置登录告警**：异常IP登录时立即发送邮件/短信通知
2. **资源监控**：监控CPU、内存、网络使用率，异常升高时及时告警
3. **日志审计**：定期检查系统日志和应用日志，发现可疑行为

### 5.5 宝塔面板专项加固
1. **修改默认端口**：将宝塔面板默认8888端口改为其他高端口
2. **开启面板SSL**：使用HTTPS访问面板
3. **启用面板验证码**：登录时需要输入验证码
4. **限制面板访问IP**：仅允许你的办公IP访问面板
5. **定期更新宝塔版本**：及时修复面板漏洞

---

## 六、结论与后续行动
本次攻击是典型的**SSH弱密码导致的挖矿木马入侵事件**，攻击者通过自动化工具爆破弱密码成功后，植入了XMRig挖矿木马，并通过crontab定时任务和SSH公钥建立了双重持久化后门。

### 立即执行的行动项
1. 按照本指南完成所有应急响应步骤
2. 部署Fail2Ban防爆破工具
3. 彻底禁用SSH密码登录，仅使用密钥认证
4. 配置云安全组IP白名单

### 7天内完成的行动项
1. 评估是否需要重装系统
2. 启用云厂商主机安全服务
3. 配置自动备份策略
4. 完成所有应用服务的安全加固

### 长期维护项
1. 每月进行一次全面安全自查
2. 每季度更新一次系统和软件
3. 每年进行一次渗透测试

> ⚠️ 最后提醒：服务器安全是一个持续的过程，没有一劳永逸的解决方案。保持警惕，定期检查，及时更新，才能有效防范各类攻击。
