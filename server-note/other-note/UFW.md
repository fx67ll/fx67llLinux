### UFW 是什么？—— 简单易用的 Linux 防火墙工具  
#### **一、UFW 的定义与定位**  
**UFW（Uncomplicated Firewall）** 是 Linux 系统中一个基于 **iptables** 的简化防火墙工具，旨在通过更简洁的命令行接口管理网络规则，尤其适合新手或需要快速配置防火墙的场景。它默认随 Ubuntu、Debian 等 Debian 系系统预装，RedHat/CentOS 系则常用 `firewalld` 或直接使用 `iptables`。  

#### **二、UFW 的核心特点**  
1. **易用性**：  
   - 摒弃 `iptables` 复杂的规则语法，采用“允许/拒绝”等自然语言式命令（如 `sudo ufw allow 80/tcp`）。  
   - 支持规则编号管理，方便批量删除或修改。  
2. **基于状态检测**：  
   - 自动跟踪网络连接状态（如已建立的连接、新连接请求），简化规则配置（例如允许出站连接自动响应入站回复）。  
3. **安全性设计**：  
   - 默认拒绝所有入站连接，仅允许已明确配置的端口，降低未授权访问风险。  
   - 支持 IPv4/IPv6 双协议栈，规则可同时应用于两种网络协议。  

#### **三、UFW 与 iptables 的关系**  
UFW 本质是 iptables 的一层“包装”，其核心逻辑仍依赖 iptables 实现：  
- **用户视角**：通过 UFW 命令（如 `allow`/`deny`）配置规则。  
- **系统视角**：UFW 将用户命令转换为 iptables 规则并写入 `/etc/ufw/rules.conf`，最终由 iptables 执行。  
- **优势对比**：  
  | 特性         | UFW                  | iptables             |  
  |--------------|----------------------|----------------------|  
  | 学习成本     | 低（命令简洁）       | 高（需理解内核表结构）|  
  | 规则管理     | 支持编号、状态跟踪   | 纯文本规则，需手动维护|  
  | 灵活性       | 中（适合基础场景）   | 高（适合复杂策略）   |  

#### **四、UFW 的基本工作逻辑**  
1. **规则链结构**：  
   - 基于 iptables 的 `filter` 表，默认包含 `INPUT`（入站）、`OUTPUT`（出站）、`FORWARD`（转发）链。  
   - 规则优先级：先匹配用户自定义规则，再匹配默认规则（默认拒绝入站，允许出站）。  
2. **状态检测机制**：  
   - 当数据包属于“已建立连接”（如服务器响应客户端的请求）时，自动允许通过，无需额外规则。  
   - 仅对“新连接请求”（如外部访问服务器端口）严格校验规则。  

#### **五、典型应用场景**  
- **服务器安全**：开放 Web 服务端口（80/443）、SSH 端口（22），拒绝其他未使用端口。  
- **家庭网络**：限制特定设备访问内网服务（如仅允许家用电脑访问 NAS 端口）。  
- **开发测试**：临时开放开发端口（如 3000、8080），避免暴露全端口。  

#### **六、简单示例：快速启用 UFW**  
1. **查看当前状态**：  
   ```bash
   sudo ufw status  # 显示是否启用及规则列表
   ```  
2. **允许 SSH 访问（避免锁死连接）**：  
   ```bash
   sudo ufw allow 22/tcp
   ```  
3. **允许 Web 服务端口**：  
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```  
4. **启用防火墙**：  
   ```bash
   sudo ufw enable  # 启用后，未允许的端口将被拒绝
   ```  

#### **七、总结**  
UFW 是 Linux 系统中“简单而不简陋”的防火墙方案，通过抽象复杂的 iptables 规则，让普通用户也能快速构建基础的网络安全屏障。对于需要精细化控制的场景（如端口转发、复杂协议过滤），仍需结合 iptables 或专业防火墙工具使用，但对日常服务器防护而言，UFW 已足够高效实用。


### UFW 常用操作及查看开放端口的方法  
#### **一、UFW 常用操作命令**  
##### 1. **查看防火墙状态**  
```bash
sudo ufw status  # 简洁状态
sudo ufw status verbose  # 详细状态（显示规则编号、协议等）
sudo ufw status numbered  # 显示带编号的规则列表（便于删除）
```  

##### 2. **启用/禁用防火墙**  
```bash
sudo ufw enable  # 启用防火墙（首次启用会提示确认，避免锁死 SSH 连接）
sudo ufw disable  # 临时禁用防火墙（重启后不保留）
```  

##### 3. **允许/拒绝端口访问**  
- **允许单个端口**（如 80 端口）：  
  ```bash
  sudo ufw allow 80  # 允许所有协议访问 80 端口
  sudo ufw allow 80/tcp  # 仅允许 TCP 协议访问 80 端口
  sudo ufw allow 80/udp  # 仅允许 UDP 协议访问 80 端口
  ```  
- **允许端口范围**（如 8000-9000）：  
  ```bash
  sudo ufw allow 8000-9000/tcp
  ```  
- **拒绝端口**：  
  ```bash
  sudo ufw deny 99  # 拒绝所有对 99 端口的访问
  ```  

##### 4. **允许/拒绝特定 IP 访问**  
- **允许指定 IP 访问所有端口**：  
  ```bash
  sudo ufw allow from 192.168.1.100  # 允许 192.168.1.100 访问所有开放端口
  ```  
- **允许指定 IP 访问特定端口**：  
  ```bash
  sudo ufw allow from 192.168.1.100 to any port 22  # 仅允许该 IP 访问 SSH 端口
  ```  
- **拒绝指定 IP**：  
  ```bash
  sudo ufw deny from 192.168.1.100
  ```  

##### 5. **删除规则**  
- 通过规则编号删除（需先执行 `sudo ufw status numbered` 查看编号）：  
  ```bash
  sudo ufw delete 3  # 删除第 3 条规则
  ```  
- 通过命令格式删除（与添加规则时的命令相反）：  
  ```bash
  sudo ufw delete allow 80  # 删除允许 80 端口的规则
  ```  

##### 6. **重启防火墙**  
```bash
sudo ufw reload  # 重新加载规则（修改规则后建议执行）
```  


#### **二、查看当前所有开放的防火墙端口**  
##### 1. **通过 UFW 状态查看**  
```bash
sudo ufw status  # 直接显示已开放的端口，格式如：`22/tcp, 80/tcp, 443/tcp`  
```  
示例输出：  
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
80/tcp (v6)                ALLOW       Anywhere (v6)
443/tcp (v6)               ALLOW       Anywhere (v6)
```  

##### 2. **通过规则文件查看**  
UFW 规则存储在 `/etc/ufw/rules.conf`，可直接查看：  
```bash
cat /etc/ufw/rules.conf
```  
示例片段：  
```
*filter
:ufw-before-input - [0:0]
-A ufw-before-input -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A ufw-before-input -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A ufw-before-input -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
```  
其中 `--dport` 后的端口号即为开放端口。  


##### 3. **结合系统端口监听情况验证**  
UFW 开放端口后，需确保服务实际监听该端口（否则开放无意义）：  
```bash
netstat -tuln  # 查看所有 TCP/UDP 监听端口
```  
示例输出：  
```
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN     
```  


#### **三、注意事项**  
1. **云服务器安全组同步**：若使用华为云等平台，需在云控制台的 **安全组规则** 中同时开放对应端口，否则 UFW 规则可能被云平台防火墙拦截。  
2. **规则优先级**：UFW 规则按添加顺序生效，后添加的规则不会覆盖前序规则，需通过编号删除旧规则。  
3. **首次启用风险**：首次执行 `sudo ufw enable` 时，若未允许 SSH 端口（22），可能导致远程连接断开，需通过云平台控制台（如华为云的 VNC 登录）重新配置。  

通过以上方法可全面管理 UFW 规则并验证端口开放状态，建议定期检查规则列表以确保服务器安全。
