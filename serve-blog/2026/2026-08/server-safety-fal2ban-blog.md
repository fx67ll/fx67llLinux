# Fail2Ban 防护部署与运维手册

> 适配宝塔 Linux 面板，生产可用，覆盖 **SSH + Nginx SSL + MySQL + Redis + MongoDB** 五套端口防护，内置 Recidive 惯犯加重封禁机制。

---

## 一、快速上手

### 1.1 安装与启动

```bash
# 安装
apt update -y && apt install fail2ban -y

# 开机自启 + 启动
systemctl enable --now fail2ban
systemctl restart fail2ban
```

### 1.2 核心参数速览

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `maxretry` | 5 | 最大失败次数 |
| `findtime` | 600 | 统计时间窗口（秒），即 10 分钟内 |
| `bantime` | 86400 | 封禁时长（秒），即 24 小时 |
| `ignoreip` | 127.0.0.1 | 白名单 IP，**务必加上本机公网 IP** |

> 💡 **修改配置后必须执行 `fail2ban-client reload` 才生效**，不要只重启服务。

---

## 二、五套防护监狱

### 2.1 SSH 暴力破解防护 ✅ 必装

```bash
cat > /etc/fail2ban/jail.d/sshd.conf <<'EOF'
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 600
bantime = 86400
ignoreip = 127.0.0.1
EOF
```

- **防护对象**：SSH 22 端口密码爆破
- **过滤器**：系统内置 `sshd`，无需自定义

---

### 2.2 Nginx SSL 恶意扫描防护

#### 过滤器配置

```bash
cat > /etc/fail2ban/filter.d/ssl-fail.conf <<'EOF'
[Definition]
# 匹配 SSL + failed + client:IP 的异常握手报错
failregex = .*SSL.*failed.*client: <HOST>
ignoreregex =
EOF
```

#### 监狱配置

```bash
cat > /etc/fail2ban/jail.d/ssl-protect.conf <<'EOF'
[ssl-protect]
enabled = true
filter = ssl-fail
logpath = /www/wwwlogs/nginx_error.log
maxretry = 5
findtime = 600
bantime = 86400
banaction = iptables-multiport
banaction_allports = true
ignoreip = 127.0.0.1
EOF
```

- **防护对象**：Nginx 异常 SSL 握手扫描
- **关键特性**：`banaction_allports = true` → 封禁该 IP 所有端口，避免换端口扫描

---

### 2.3 MySQL 数据库防爆破

#### 前置优化（必须执行，否则匹配失效）

```bash
# 检查是否已开启详细错误日志
grep log_error_verbosity /etc/my.cnf

# 无输出则写入配置
sed -i '/\[mysqld\]/a log_error_verbosity = 3' /etc/my.cnf

# 重启 MySQL
/etc/init.d/mysqld restart

# 赋予日志可读权限
chmod 644 /www/server/data/hcss-ecs-695e.err

# 查看历史爆破记录
grep "Access denied" /www/server/data/hcss-ecs-695e.err | tail -20
```

#### 过滤器配置

```bash
cat > /etc/fail2ban/filter.d/mysql.conf <<'EOF'
[INCLUDES]
before = common.conf

[Definition]
_daemon = mysqld
# 万能匹配：时间开头，中间任意字符，最后匹配 Access denied + <HOST>
failregex = ^.*Access denied for user .*@'<HOST>'
ignoreregex =
EOF
```

#### 监狱配置

```bash
cat > /etc/fail2ban/jail.d/mysql.conf <<'EOF'
[mysql]
enabled = true
port = 3306
filter = mysql
logpath = /www/server/data/hcss-ecs-695e.err
maxretry = 5
findtime = 600
bantime = 86400
action = iptables[name=MySQL, port=3306, protocol=tcp]
ignoreip = 127.0.0.1
EOF
```

- **防护对象**：MySQL 3306 端口账户暴力破解
- **⚠️ 注意**：`logpath` 中的主机名需替换为你服务器的实际主机名

---

### 2.4 Redis 防爆破

#### 过滤器配置

```bash
cat > /etc/fail2ban/filter.d/redis.conf <<'EOF'
[Definition]
failregex = ^.*Failed password for user .* from <HOST>
            ^.*Authentication failed for user .* from <HOST>
            ^.*ERR invalid password from <HOST>
            ^.*Client sent AUTH, but no password is set from <HOST>
ignoreregex =
EOF
```

#### 监狱配置

```bash
cat > /etc/fail2ban/jail.d/redis.conf <<'EOF'
[redis]
enabled = true
port = 6379
filter = redis
logpath = /www/server/redis/redis.log
maxretry = 5
findtime = 600
bantime = 86400
action = iptables[name=Redis, port=6379, protocol=tcp]
ignoreip = 127.0.0.1
EOF
```

- **防护对象**：Redis 6379 未授权访问 / 密码爆破
- **⚠️ 注意**：宝塔 Redis 默认关闭日志，需在面板开启

---

### 2.5 MongoDB 防爆破

#### 过滤器配置

```bash
cat > /etc/fail2ban/filter.d/mongodb.conf <<'EOF'
[Definition]
# 多种认证失败关键词，兼容各 Mongo 版本
failregex = .*"msg":"(Auth failed|Authentication failed|Authentication failure|login failed|Unauthorized|auth error)".*"(remote|client)":"<HOST>:\d+"
# 端口扫描、恶意连接重置
            .*"errmsg":".*Connection reset by peer".*"(remote|client)":"<HOST>:\d+"
# 异常中途断连探测
            .*"Interrupted operation as its client disconnected".*"(remote|client)":"<HOST>:\d+"

# 适配宝塔 Mongo 标准 JSON 日志时间戳
datepattern = {"t":{"\$date":"%%Y-%%m-%%dT%%H:%%M:%%S\.%%f\+\d{2}:\d{2}"}}

# 正确忽略本地 127.0.0.1 连接，修复引号转义
ignoreregex = "\"(remote|client)\":\"127\.0\.0\.1:"
EOF
```

#### 监狱配置

```bash
cat > /etc/fail2ban/jail.d/mongodb.conf <<'EOF'
[mongodb]
enabled = true
port = 27017
filter = mongodb
logpath = /www/server/mongodb/log/config.log
maxretry = 5
findtime = 600
bantime = 86400
action = iptables[name=MongoDB, port=27017, protocol=tcp]
ignoreip = 127.0.0.1
EOF
```

- **防护对象**：MongoDB 27017 账户暴力破解
- **⚠️ 注意**：MongoDB 需开启权限认证，无密码登录不会产生认证失败日志

---

### 2.6 Recidive 惯犯加重封禁 ⭐ 推荐

> 利用 Fail2ban 原生自带的 `recidive` 过滤器，无需自定义 filter。
> **规则**：30 天内累计被任意监狱封禁 3 次的 IP，自动升级为**永久封禁**。

```bash
cat > /etc/fail2ban/jail.d/recidive.conf <<'EOF'
[recidive]
enabled  = true
filter   = recidive
logpath  = /var/log/fail2ban.log
findtime = 2592000
maxretry = 3
bantime  = -1
banaction = iptables-multiport
banaction_allports = true
ignoreip = 127.0.0.1
EOF
```

| 参数 | 值 | 含义 |
|------|-----|------|
| `findtime` | 2592000 | 30 天统计窗口 |
| `maxretry` | 3 | 累计被封 3 次触发 |
| `bantime` | -1 | **永久封禁** |

---

## 三、部署校验 & 生效

### 3.1 全局语法校验

```bash
fail2ban-client -t
```

### 3.2 热加载规则（不清除现有封禁）

```bash
fail2ban-client reload
```

### 3.3 查看全部监狱状态

```bash
# 汇总查看所有启用监狱
fail2ban-client status

# 逐个查看详情
fail2ban-client status sshd
fail2ban-client status ssl-protect
fail2ban-client status mysql
fail2ban-client status redis
fail2ban-client status mongodb
fail2ban-client status recidive
```

> ✅ **正常表现**：日志路径正常显示，Failed/Banned 初始为 0，仅统计重载后新增日志，历史旧日志不计数。

### 3.4 全量正则匹配测试（迁移部署必跑）

```bash
# SSH
fail2ban-regex /var/log/auth.log /etc/fail2ban/filter.d/sshd.conf

# Nginx SSL 扫描
fail2ban-regex /www/wwwlogs/nginx_error.log /etc/fail2ban/filter.d/ssl-fail.conf

# MySQL
fail2ban-regex /www/server/data/hcss-ecs-695e.err /etc/fail2ban/filter.d/mysql.conf

# Redis
fail2ban-regex /www/server/redis/redis.log /etc/fail2ban/filter.d/redis.conf

# MongoDB
fail2ban-regex /www/server/mongodb/log/config.log /etc/fail2ban/filter.d/mongodb.conf
```

| 结果 | 含义 |
|------|------|
| Failregex 总数 > 0 | 规则正常抓取攻击日志 |
| Failregex = 0 | 日志路径错误 / 暂无对应攻击日志 |

---

## 四、统一运维管理

### 4.1 全局概览

```bash
# 服务是否存活
systemctl status fail2ban

# 所有监狱运行状态
fail2ban-client status

# 全局所有被封禁 IP（所有监狱合并）
fail2ban-client banned

# 实时全局监控所有封禁行为
tail -f /var/log/fail2ban.log
```

**日志标识区分**：

| 日志关键字 | 对应监狱 | 含义 |
|-----------|---------|------|
| `[sshd] Ban` | SSH 防护 | SSH 密码爆破封禁 |
| `[ssl-protect] Ban` | SSL 防护 | 恶意 SSL 扫描 IP 封禁 |
| `[mysql] Ban` | MySQL 防护 | 数据库爆破封禁 |
| `[redis] Ban` | Redis 防护 | 未授权/密码爆破封禁 |
| `[mongodb] Ban` | MongoDB 防护 | 账户暴力破解封禁 |
| `[recidive] Ban` | 惯犯防护 | 多次违规永久封禁 |

### 4.2 分监狱操作

#### 查看单个监狱详情

```bash
fail2ban-client status <监狱名> | grep Banned
```

#### 解封误封 IP

```bash
fail2ban-client set sshd unbanip 1.2.3.4
fail2ban-client set ssl-protect unbanip 1.2.3.4
fail2ban-client set mysql unbanip 1.2.3.4
fail2ban-client set redis unbanip 1.2.3.4
fail2ban-client set mongodb unbanip 1.2.3.4
```

#### 手动临时封禁测试 IP

```bash
fail2ban-client set sshd banip 1.2.3.4
fail2ban-client set ssl-protect banip 1.2.3.4
fail2ban-client set mysql banip 1.2.3.4
fail2ban-client set redis banip 1.2.3.4
fail2ban-client set mongodb banip 1.2.3.4
```

### 4.3 批量配置修改

#### 放宽失败次数为 10 次

```bash
sed -i 's/maxretry = 5/maxretry = 10/' /etc/fail2ban/jail.d/sshd.conf
sed -i 's/maxretry = 5/maxretry = 10/' /etc/fail2ban/jail.d/ssl-protect.conf
sed -i 's/maxretry = 5/maxretry = 10/' /etc/fail2ban/jail.d/mysql.conf
sed -i 's/maxretry = 5/maxretry = 10/' /etc/fail2ban/jail.d/redis.conf
sed -i 's/maxretry = 5/maxretry = 10/' /etc/fail2ban/jail.d/mongodb.conf
fail2ban-client reload
```

#### 缩短封禁时长为 1 小时

```bash
sed -i 's/bantime = 86400/bantime = 3600/' /etc/fail2ban/jail.d/sshd.conf
sed -i 's/bantime = 86400/bantime = 3600/' /etc/fail2ban/jail.d/ssl-protect.conf
sed -i 's/bantime = 86400/bantime = 3600/' /etc/fail2ban/jail.d/mysql.conf
sed -i 's/bantime = 86400/bantime = 3600/' /etc/fail2ban/jail.d/redis.conf
sed -i 's/bantime = 86400/bantime = 3600/' /etc/fail2ban/jail.d/mongodb.conf
fail2ban-client reload
```

### 4.4 白名单管理

#### 批量新增白名单 IP（所有监狱同步）

```bash
NEW_IP="123.45.67.89"
sed -i "/^ignoreip/s/$/ $NEW_IP/" /etc/fail2ban/jail.d/sshd.conf
sed -i "/^ignoreip/s/$/ $NEW_IP/" /etc/fail2ban/jail.d/ssl-protect.conf
sed -i "/^ignoreip/s/$/ $NEW_IP/" /etc/fail2ban/jail.d/mysql.conf
sed -i "/^ignoreip/s/$/ $NEW_IP/" /etc/fail2ban/jail.d/redis.conf
sed -i "/^ignoreip/s/$/ $NEW_IP/" /etc/fail2ban/jail.d/mongodb.conf
fail2ban-client reload
```

> ⚠️ **本机被误封？** 所有 jail 的 `ignoreip` 必须全部填入本机公网 IP，**缺一不可**。

### 4.5 查看各监狱配置文件

```bash
cat /etc/fail2ban/jail.d/sshd.conf
cat /etc/fail2ban/jail.d/ssl-protect.conf
cat /etc/fail2ban/jail.d/mysql.conf
cat /etc/fail2ban/jail.d/redis.conf
cat /etc/fail2ban/jail.d/mongodb.conf
```

### 4.6 重置单个监狱配置（异常重建）

以 Redis 为例：

```bash
rm -f /etc/fail2ban/filter.d/redis.conf
rm -f /etc/fail2ban/jail.d/redis.conf
# 重新执行对应部署步骤重建配置
fail2ban-client reload
```

---

## 五、攻击日志统计

### 5.1 历史封禁统计

```bash
# 统计历史所有被 Ban 的攻击 IP + 次数（按次数倒序）
grep "Ban" /var/log/fail2ban.log | awk '{print $NF}' | sort | uniq -c | sort -nr
```

### 5.2 今日封禁记录

```bash
grep $(date +%Y-%m-%d) /var/log/fail2ban.log | grep Ban
```

### 5.3 SSH 原生失败登录日志

```bash
grep Failed /var/log/auth.log
```

### 5.4 SSL 攻击日志排查

```bash
# 检索所有 SSL 握手失败历史记录
grep -i "ssl.*failed" /www/wwwlogs/nginx_error.log

# 实时监控新增 SSL 报错
tail -f /www/wwwlogs/nginx_error.log | grep -i ssl
```

---

## 六、排错指南

### 6.1 通用故障

| 现象 | 原因 | 解决方法 |
|------|------|---------|
| 本机被误封 | 白名单不全 | 所有 jail 的 `ignoreip` 都要加本机公网 IP |
| 正则匹配数为 0 | 日志路径 / 权限 / 无对应报错 | 核对路径、权限、日志内容 |
| 修改配置不生效 | 未重载 | 执行 `fail2ban-client reload` |
| status 提示找不到 filter/jail | 文件名写错 / 语法错误 | 用 `fail2ban-client -t` 定位报错 |

### 6.2 各监狱专属故障

| 监狱 | 常见问题 | 排查方法 |
|------|---------|---------|
| **MySQL** | 匹配无数据但日志有 Access denied | 未开启 `log_error_verbosity=3` 或日志权限不足 |
| **MySQL** | 日志路径报错 | 执行 `grep log_error /etc/my.cnf` 获取真实文件名 |
| **SSL 防护** | 正常用户频繁误封 | 调高 `maxretry` 至 10~15 |
| **SSL 防护** | 封禁后仍可访问网站 | 确认 `banaction_allports = true` 存在 |
| **Redis** | 匹配为 0 | 宝塔 Redis 默认关闭日志，面板开启即可 |
| **MongoDB** | 匹配为 0 | 未开启权限认证，无密码登录不产生失败日志 |

---

## 七、每日巡检最简流程

```bash
# 1. 检查服务运行状态
systemctl status fail2ban

# 2. 汇总所有监狱状态
fail2ban-client status

# 3. 列出所有被封禁 IP
fail2ban-client banned

# 4. 查看今日新增封禁记录
grep $(date +%Y-%m-%d) /var/log/fail2ban.log | grep Ban

# 5. 实时跟踪攻击拦截日志
tail -f /var/log/fail2ban.log
```

---

## 八、服务器迁移检查清单

- [ ] **1. 安装服务**
  - CentOS：`yum install fail2ban -y`
  - Debian/Ubuntu：`apt install fail2ban -y`

- [ ] **2. 复制过滤器文件至 `/etc/fail2ban/filter.d/`**
  - ssl-fail.conf、mysql.conf、redis.conf、mongodb.conf（sshd 为系统内置）

- [ ] **3. 复制监狱配置至 `/etc/fail2ban/jail.d/`**
  - sshd.conf、ssl-protect.conf、mysql.conf、redis.conf、mongodb.conf、recidive.conf

- [ ] **4. 统一修改全部 jail 的 `ignoreip`** 为本机公网 IP、内网网段

- [ ] **5. 修正 mysql.conf 内 `logpath`** 为当前服务器 MySQL 错误日志文件名

- [ ] **6. MySQL 执行前置优化脚本** 开启详细错误日志

- [ ] **7. 校验全局语法** `fail2ban-client -t`

- [ ] **8. 热加载规则** `fail2ban-client reload`

- [ ] **9. 查看状态** 确认所有监狱正常加载

- [ ] **10. 逐条执行 `fail2ban-regex`** 校验所有过滤器匹配正常

- [ ] **11. 手动 ban 一个测试 IP** 验证 iptables 封禁功能生效

---

## 九、关键自查判断标准

| 现象 | 判断 |
|------|------|
| `fail2ban-client status <jail>` 报错找不到 filter/jail | 配置文件缺失 / 文件名写错 |
| `fail2ban-regex` 匹配数为 0 | 日志路径错误 / 日志无对应失败记录 |
| 匹配数几千，但 Total failed 始终 0 | 均为历史旧日志，仅新产生报错才会触发封禁 |
| 正常运行但频繁误封自己 | 检查 `ignoreip` 是否包含公网 / 内网网段 |

---

## 附录：配置文件路径速查

| 类型 | 路径 |
|------|------|
| 监狱配置 | `/etc/fail2ban/jail.d/*.conf` |
| 过滤器配置 | `/etc/fail2ban/filter.d/*.conf` |
| Fail2ban 日志 | `/var/log/fail2ban.log` |
| SSH 认证日志 | `/var/log/auth.log` |
| Nginx 错误日志 | `/www/wwwlogs/nginx_error.log` |
| MySQL 错误日志 | `/www/server/data/hcss-ecs-695e.err` |
| Redis 日志 | `/www/server/redis/redis.log` |
| MongoDB 日志 | `/www/server/mongodb/log/config.log` |

---

我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！
如果您喜欢这篇文章，欢迎访问我的 [本文 github 仓库地址](https://github.com/fx67ll/fx67llLinux/serve-blog/2026/2026-08/server-safety-fal2ban-blog.md)，为我点一颗 Star，Thanks~ :)
***转发请注明参考文章地址，非常感谢！！！***
