# 服务器被 NTR 事件记录

---

## 服务器攻击分析报告

> 分析时间：2026-06-01  
> 服务器：hcss-ecs-695e

---

### 一、攻击类型

**SSH密码爆破 + 加密货币挖矿木马 + 持久化后门**

---

### 二、攻击时间线

| 时间 | 事件 |
|------|------|
| 2025-03-17 19:47 | 服务器开机/部署 |
| 2026-05-31 20:22 | 攻击者IP `220.250.52.101` 通过SSH密码登录成功（用户`halo`） |
| 2026-05-31 20:47 | 攻击者IP `151.47.111.200`（意大利米兰）再次登录 |
| 2026-05-31 21:19 | 木马文件写入 `/home/halo/.configrc7/` |
| 2026-05-31 20:59 | 挖矿包 `dota3.tar.gz` 写入 `/tmp/.X291-unix/` |

---

### 三、攻击细节

#### 1. 入侵入口 — SSH密码登录

- 两个境外IP成功以密码方式登录 `halo` 用户
- 服务器开启了SSH密码认证，`halo` 账号密码过弱或被泄露

**攻击者IP：**
- `220.250.52.101`
- `151.47.111.200`（意大利米兰，WIND TRE S.P.A.）

#### 2. 部署挖矿木马

- 恶意进程藏在 `/tmp/.X291-unix/.rsync/c/`，可执行文件名为 `kthreadadd64`（伪装成内核线程）
- 挖矿进程伪装成 `httpd` 运行：`/usr/sbin/httpd .rsync/c/kthreadadd64 -t 525`
- 下载了 `dota3.tar.gz`（典型 XMRig 挖矿包命名）
- `/home/halo/.configrc7/` 下有完整木马套件：`run`、`init01`、`crond`、`delsshdv`、`stop`、`rmkwork` 等

#### 3. 持久化机制

- 篡改了 `crontab`，添加多条定时任务，实现开机重启后自动拉起木马、重新下载恶意脚本
- 在 `~/.ssh/authorized_keys` 中植入了攻击者的SSH公钥，即使改密码也能继续登录

---

### 四、解决步骤

#### 第一步：立即隔离（防止进一步扩散）

在云控制台安全组，只保留你自己IP的SSH访问，封锁其余所有入站。

#### 第二步：终止恶意进程

```bash
# 找到并杀死挖矿进程
ps aux | grep -E "kthreadadd|\.rsync"
kill -9 <PID>

# 批量杀
pkill -f kthreadadd64
pkill -f ".rsync/c"
```

#### 第三步：清除恶意文件

```bash
rm -rf /tmp/.X291-unix/
rm -rf /home/halo/.configrc7/
```

#### 第四步：清除恶意定时任务

```bash
crontab -u halo -r    # 清除halo用户的crontab
crontab -u root -r    # 清除root的crontab（如有）

# 检查系统级cron
cat /etc/crontab
ls /etc/cron.d/
```

#### 第五步：清除SSH后门密钥

```bash
# 先查看当前内容
cat /home/halo/.ssh/authorized_keys

# 清空，再写入你自己的公钥
> /home/halo/.ssh/authorized_keys
```

#### 第六步：修改密码 & 加固SSH

```bash
# 修改halo用户密码（设置强密码）
passwd halo
```

编辑 `/etc/ssh/sshd_config`，修改以下两项：

```
PasswordAuthentication no
PermitRootLogin no
```

```bash
systemctl restart sshd
```

#### 第七步：封锁攻击者IP

在云控制台安全组规则中，封锁：
- `220.250.52.101`
- `151.47.111.200`

#### 第八步：检查是否有其他后门

```bash
# 查看所有登录用户
cat /etc/passwd | grep -v nologin

# 检查SUID文件（可能被替换）
find / -perm -4000 -type f 2>/dev/null

# 查看最近被修改的文件
find /tmp /var /home -mtime -3 -type f 2>/dev/null
```

---

### 五、后续安全建议

1. **如条件允许，强烈建议重装系统** — 深度入侵后难以保证完全清除
2. **启用云厂商主机安全服务**（如阿里云安骑士、腾讯云主机安全）
3. **SSH改用密钥认证**，彻底禁用密码登录
4. **定期备份数据**，与系统盘分离
5. **设置登录告警**，异常IP登录立即通知

---

### 六、结论

攻击者通过SSH密码爆破入侵了 `halo` 账号，植入了挖矿木马（消耗服务器CPU资源），并通过 crontab + authorized_keys 建立了双重持久化后门。建议按上述步骤处理后评估是否需要重装系统。


------------------------------------------------------------------------------------------------------------------------


## 全套安全隐患自查命令（逐条复制发送执行）

### 一、检查异常账号与权限
```bash
# 1. 查看所有可登录用户
cat /etc/passwd | grep -v nologin | grep -v false

# 2. 查看UID0后门账号（最高权限）
awk -F: '$3==0 && $1!="root"' /etc/passwd

# 3. 查看最近新增用户
ls -lt /etc/shadow

# 4. 查看sudo提权用户
cat /etc/sudoers | grep -v '^#' | grep -v '^$'
ls /etc/sudoers.d/
```

---

### 二、检查SSH所有后门
```bash
# 1. 查看root登录密钥
cat /root/.ssh/authorized_keys

# 2. 查看SSH配置异常
grep -v '^#' /etc/ssh/sshd_config | grep -v '^$'

# 3. 查看最近SSH登录记录
lastlog
last
```

---

### 三、检查定时任务（复活木马重灾区）
```bash
# root定时
crontab -l

# 系统全局定时
ls -la /etc/cron.d/
ls -la /var/spool/cron/
cat /etc/crontab
```

---

### 四、检查命令劫持与预加载后门
```bash
# 动态链接劫持（高频木马手段）
cat /etc/ld.so.preload

# 检查环境变量恶意劫持
echo $PATH
env | grep -i proxy
```

---

### 五、检查自启动恶意服务
```bash
# 查看异常开机自启
systemctl list-unit-files --type=service | grep enabled

# 检查rc.local后门
cat /etc/rc.local
ls /etc/profile.d/
```

---

### 六、检查隐藏恶意文件&顽固锁文件
```bash
# 查找带immutable锁定的文件（木马最爱）
find / -type f -iwholename "*" -exec lsattr {} \; 2>/dev/null | grep 'i'

# 查找临时目录隐藏恶意文件
find /tmp /var/tmp -name ".*" 2>/dev/null
```

---

### 七、检查端口对外监听（严防内网服务裸奔）
```bash
ss -tulnp
```
重点排查：**6379、3306、8080、9876** 等非必要端口监听0.0.0.0

---

### 八、检查异常内核模块&隐藏进程
```bash
lsmod
ps auxf
```

---

### 九、检查系统日志入侵痕迹
```bash
# 查看登录失败爆破记录
grep Failed /var/log/auth.log
```

---

### 十、检查文件完整性（关键系统文件是否被篡改）
```bash
stat /bin/ps
stat /bin/ls
stat /usr/bin/curl
```
修改时间和系统安装时间不一致=大概率被替换

---

#### 自查结果判断标准
1. 无UID=0非root账号 ✅
2. authorized_keys无陌生公钥 ✅
3. ld.so.preload为空 ✅
4. 无陌生定时任务、无陌生自启服务 ✅
5. 对外只开放80/443/22(仅你IP) ✅
6. 无带`i`锁定的可疑文件 ✅

#### 发现隐患快速处理
1. 陌生公钥：`> /root/.ssh/authorized_keys`清空
2. 异常定时：直接删除对应cron文件
3. ld.so.preload有内容：`> /etc/ld.so.preload`清空
4. 多余监听端口：关闭对应服务+防火墙封禁

#### 最终极简安全配置
1. 命令配置
```bash
# 关闭root远程登录+禁用密码登录  
# 也可以打开只允许秘钥登录，目前是用宝塔界面生成的登录秘钥，shell生成秘钥后续可以研究一下  
# 再去华为云安全组，**22端口只放行你本机公网IP**，彻底封死爆破入侵  
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```
2. 宝塔配置
+ 直接在`https://baota.fx67ll.com/firewall`配置即可，界面清晰明了（**当前被入侵后开启ip限制 + 秘钥登录双重配置**）  
+ SSH 防爆破如果已经安装过了，可以不打开，还需要加强`nginx tomcat baota halo mysql redis mongodb`这些应用的防爆破配置  
+ 告警推送记得把本机ip加入白名单（**华为云的安全组和宝塔告警推送要同步添加ip白名单**）  


------------------------------------------------------------------------------------------------------------------------


## Fire2Ban

### 安装
1. 安装 fail2ban（必走）
```bash
apt update -y
apt install fail2ban -y
```
2. 开机自启 + 启动服务
```bash
systemctl enable --now fail2ban
systemctl restart fail2ban
```
3. 生成安全配置（**防爆破最强规则，直接全部复制到shell里执行就可以了**）
```bash
cat > /etc/fail2ban/jail.d/sshd.conf <<EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 86400
findtime = 600
ignoreip = 127.0.0.1
EOF
```
```shell
# 安全配置说明
maxretry = 5 → 最多错 5 次
bantime = 86400 → 封 24 小时
findtime = 600 → 10 分钟内
```
4. 重启生效
```bash
systemctl restart fail2ban
```

### 常用命令
1. 查看是否在运行
```bash
systemctl status fail2ban
```
2. 查看 SSH 防爆破状态（看封了谁）
```bash
fail2ban-client status sshd
```
3. 解封某个 IP（比如你自己误封）
```bash
fail2ban-client set sshd unbanip 1.2.3.4
```
4. 查看所有被 ban 的 IP
```bash
fail2ban-client banned
```
5. 查看配置设置
```bash
cat /etc/fail2ban/jail.d/sshd.conf
```
6. 修改配置设置（**Ctrl+O → 回车 → Ctrl+X 保存退出 → 必须重启才生效**）
```bash
nano /etc/fail2ban/jail.d/sshd.conf
```
7. 查看封禁日志
```bash
tail -f /var/log/fail2ban.log
```
8. 统计历史所有被Ban的攻击IP+次数
```bash
grep "Ban" /var/log/fail2ban.log |awk '{print $NF}'|sort|uniq -c|sort -nr
```
9. 统计今日封禁记录
```bash
grep $(date +%Y-%m-%d) /var/log/fail2ban.log |grep Ban
```
10. 统计SSH原生失败登录日志
```bash
grep Failed /var/log/auth.log
```