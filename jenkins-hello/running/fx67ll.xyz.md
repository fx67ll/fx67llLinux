# fx67ll.xyz的shell记录

#### v1
```shell
pwd  
java -version  
cd fx67ll.xyz  
if [ -f "./dist.tar.gz" ];then  
  rm -R dist.tar.gz  
else  
  echo "文件不存在"  
fi  
tar -zcvf dist.tar.gz ./*  
cd /usr/share/nginx/html  
ls  
rm -rf *  
ls  
cd /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz  
scp /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz/dist.tar.gz /usr/share/nginx/html  
rm -R ./dist.tar.gz  
cd /usr/share/nginx/html  
tar -zxvf dist.tar.gz -C ./  
rm -R dist.tar.gz  
```

#### v2
```shell
#!/bin/bash

# 记录执行日志
echo "开始部署 - $(date)"

# 显示当前路径和Java版本
pwd
java -version

# 确定Nginx用户
NGINX_USER=$(ps aux | grep nginx | grep -v grep | awk '{print $1}' | head -1)
if [ -z "$NGINX_USER" ]; then
    # 如果无法通过进程确定用户，则使用常见的默认值
    if [ -f /etc/debian_version ]; then
        NGINX_USER="www-data"
    else
        NGINX_USER="nginx"
    fi
fi
echo "检测到Nginx用户: $NGINX_USER"

# 进入项目目录
cd fx67ll.xyz || { echo "无法进入项目目录"; exit 1; }

# 检查并删除已存在的tar文件
if [ -f "./dist.tar.gz" ]; then
  rm -f dist.tar.gz
  echo "已删除旧的dist.tar.gz文件"
else
  echo "dist.tar.gz文件不存在，继续执行"
fi

# 创建新的tar包
tar -zcvf dist.tar.gz ./* || { echo "创建tar包失败"; exit 1; }
echo "成功创建tar包"

# 切换到Nginx目录
cd /usr/share/nginx/html-8070 || { echo "无法进入Nginx目录"; exit 1; }

# 备份当前内容
if [ "$(ls -A)" ]; then
  mv * "/tmp/nginx_backup_$(date +%Y%m%d%H%M%S)"
  echo "已备份当前Nginx内容"
fi

# 复制tar包到Nginx目录
cd /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz || { echo "无法进入工作目录"; exit 1; }
scp /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz/dist.tar.gz /usr/share/nginx/html-8070 || { echo "复制tar包失败"; exit 1; }
rm -f ./dist.tar.gz
echo "已复制tar包并删除源文件"

# 解压tar包到Nginx目录
cd /usr/share/nginx/html-8070 || { echo "无法进入Nginx目录"; exit 1; }
tar -zxvf dist.tar.gz -C ./ || { echo "解压tar包失败"; exit 1; }
rm -f dist.tar.gz

# 设置正确的文件权限 - 使用检测到的Nginx用户
chown -R $NGINX_USER:$NGINX_USER /usr/share/nginx/html-8070 || { echo "设置文件所有者失败，尝试使用单用户"; chown -R $NGINX_USER /usr/share/nginx/html-8070 || { echo "仍然无法设置文件所有者，请检查用户权限"; exit 1; } }
chmod -R 755 /usr/share/nginx/html-8070 || { echo "设置文件权限失败"; exit 1; }
echo "已设置正确的文件权限"

# 检查index.html是否存在
if [ -f "/usr/share/nginx/html-8070/index.html" ]; then
  echo "部署成功: index.html文件存在"
else
  echo "警告: index.html文件不存在，请检查项目结构"
fi

# # 重新加载Nginx配置 - 使用sudo权限
# if command -v sudo &> /dev/null; then
#     sudo systemctl reload nginx || { echo "重新加载Nginx配置失败"; exit 1; }
# else
#     systemctl reload nginx || { echo "重新加载Nginx配置失败"; exit 1; }
# fi
# echo "Nginx配置已重新加载"
# echo "部署完成 - $(date)"

# 重新加载Nginx配置 - 宝塔专用（带提示 + 不中断构建）
echo "正在重新加载 Nginx 配置..."
if /www/server/nginx/sbin/nginx -s reload 2>/dev/null; then
    echo "✅ Nginx 配置重新加载成功"
else
    echo "⚠️警告: Nginx 配置 reload 失败，但项目已部署完成（不影响访问）"
fi
echo "部署完成 - $(date)"
```

#### v2
```shell
#!/bin/bash

# 记录执行日志
echo "开始部署 - $(date)"

# 显示当前路径和Java版本
pwd
java -version

# 确定Nginx用户
NGINX_USER=$(ps aux | grep nginx | grep -v grep | awk '{print $1}' | head -1)
if [ -z "$NGINX_USER" ]; then
    # 如果无法通过进程确定用户，则使用常见的默认值
    if [ -f /etc/debian_version ]; then
        NGINX_USER="www-data"
    else
        NGINX_USER="nginx"
    fi
fi
echo "检测到Nginx用户: $NGINX_USER"

# 进入项目目录
cd fx67ll.xyz || { echo "无法进入项目目录"; exit 1; }

# 修正 index.html 中的静态资源路径（fx67ll.xyz-lib 已更名为 nav.fx67ll.com）
if [ -f "./index.html" ]; then
  sed -i 's#fx67ll\.xyz-lib#nav.fx67ll.com#g' index.html
  echo "已将 index.html 中的资源路径从 fx67ll.xyz-lib 改为 nav.fx67ll.com"
else
  echo "警告: index.html 不存在，跳过路径修正"
fi

# 检查并删除已存在的tar文件
if [ -f "./dist.tar.gz" ]; then
  rm -f dist.tar.gz
  echo "已删除旧的dist.tar.gz文件"
else
  echo "dist.tar.gz文件不存在，继续执行"
fi

# 创建新的tar包
tar -zcvf dist.tar.gz ./* || { echo "创建tar包失败"; exit 1; }
echo "成功创建tar包"

# 切换到Nginx目录
cd /usr/share/nginx/html-8070 || { echo "无法进入Nginx目录"; exit 1; }

# 备份当前内容
if [ "$(ls -A)" ]; then
  mv * "/tmp/nginx_backup_$(date +%Y%m%d%H%M%S)"
  echo "已备份当前Nginx内容"
fi

# 复制tar包到Nginx目录
cd /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz || { echo "无法进入工作目录"; exit 1; }
scp /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz/dist.tar.gz /usr/share/nginx/html-8070 || { echo "复制tar包失败"; exit 1; }
rm -f ./dist.tar.gz
echo "已复制tar包并删除源文件"

# 解压tar包到Nginx目录
cd /usr/share/nginx/html-8070 || { echo "无法进入Nginx目录"; exit 1; }
tar -zxvf dist.tar.gz -C ./ || { echo "解压tar包失败"; exit 1; }
rm -f dist.tar.gz

# 设置正确的文件权限 - 使用检测到的Nginx用户
chown -R $NGINX_USER:$NGINX_USER /usr/share/nginx/html-8070 || { echo "设置文件所有者失败，尝试使用单用户"; chown -R $NGINX_USER /usr/share/nginx/html-8070 || { echo "仍然无法设置文件所有者，请检查用户权限"; exit 1; } }
chmod -R 755 /usr/share/nginx/html-8070 || { echo "设置文件权限失败"; exit 1; }
echo "已设置正确的文件权限"

# 检查index.html是否存在
if [ -f "/usr/share/nginx/html-8070/index.html" ]; then
  echo "部署成功: index.html文件存在"
else
  echo "警告: index.html文件不存在，请检查项目结构"
fi

# 重新加载Nginx配置 - 宝塔专用（带提示 + 不中断构建）
echo "正在重新加载 Nginx 配置..."
if /www/server/nginx/sbin/nginx -s reload 2>/dev/null; then
    echo "✅ Nginx 配置重新加载成功"
else
    echo "⚠️警告: Nginx 配置 reload 失败，但项目已部署完成（不影响访问）"
fi
echo "部署完成 - $(date)"
```

#### v3
```shell
#!/bin/bash

# 记录执行日志
echo "开始部署 - $(date)"

# 显示当前路径和Java版本
pwd
java -version

# 确定Nginx用户
NGINX_USER=$(ps aux | grep nginx | grep -v grep | awk '{print $1}' | head -1)
if [ -z "$NGINX_USER" ]; then
    # 如果无法通过进程确定用户，则使用常见的默认值
    if [ -f /etc/debian_version ]; then
        NGINX_USER="www-data"
    else
        NGINX_USER="nginx"
    fi
fi
echo "检测到Nginx用户: $NGINX_USER"

# 进入项目目录
cd fx67ll.xyz || { echo "无法进入项目目录"; exit 1; }

# 修正 index.html 中的静态资源路径（fx67ll.xyz-lib 已更名为 nav.fx67ll.com）
if [ -f "./index.html" ]; then
  sed -i 's#fx67ll\.xyz-lib#nav.fx67ll.com#g' index.html
  echo "已将 index.html 中的资源路径从 fx67ll.xyz-lib 改为 nav.fx67ll.com"
else
  echo "警告: index.html 不存在，跳过路径修正"
fi

# 检查并删除已存在的tar文件
if [ -f "./dist.tar.gz" ]; then
  rm -f dist.tar.gz
  echo "已删除旧的dist.tar.gz文件"
else
  echo "dist.tar.gz文件不存在，继续执行"
fi

# 创建新的tar包
tar -zcvf dist.tar.gz ./* || { echo "创建tar包失败"; exit 1; }
echo "成功创建tar包"

# 切换到Nginx目录
cd /usr/share/nginx/html-8070 || { echo "无法进入Nginx目录"; exit 1; }

# 备份当前内容
if [ "$(ls -A)" ]; then
  mv * "/tmp/nginx_backup_$(date +%Y%m%d%H%M%S)"
  echo "已备份当前Nginx内容"
fi

# 复制tar包到Nginx目录
cd /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz || { echo "无法进入工作目录"; exit 1; }
scp /root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz/dist.tar.gz /usr/share/nginx/html-8070 || { echo "复制tar包失败"; exit 1; }
rm -f ./dist.tar.gz
echo "已复制tar包并删除源文件"

# 解压tar包到Nginx目录
cd /usr/share/nginx/html-8070 || { echo "无法进入Nginx目录"; exit 1; }
tar -zxvf dist.tar.gz -C ./ || { echo "解压tar包失败"; exit 1; }
rm -f dist.tar.gz

# 设置正确的文件权限 - 使用检测到的Nginx用户
chown -R $NGINX_USER:$NGINX_USER /usr/share/nginx/html-8070 || { echo "设置文件所有者失败，尝试使用单用户"; chown -R $NGINX_USER /usr/share/nginx/html-8070 || { echo "仍然无法设置文件所有者，请检查用户权限"; exit 1; } }
chmod -R 755 /usr/share/nginx/html-8070 || { echo "设置文件权限失败"; exit 1; }
echo "已设置正确的文件权限"

# 检查index.html是否存在
if [ -f "/usr/share/nginx/html-8070/index.html" ]; then
  echo "部署成功: index.html文件存在"
else
  echo "警告: index.html文件不存在，请检查项目结构"
fi

# ===== 更新 error-page 错误页 =====
# nginx 的 error_page 指向 /usr/share/nginx/html/error-page/，与主站(html-8070)分开存放，
# 主部署的 tar 包不会覆盖它，所以这里单独同步：先删整个目录再从源码复制新的。
ERROR_PAGE_SRC="/root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz/error-page"
ERROR_PAGE_DST="/usr/share/nginx/html/error-page"
echo "开始更新 error-page 错误页..."
if [ -d "$ERROR_PAGE_SRC" ]; then
  # 备份并删除旧的 error-page 整个目录
  if [ -d "$ERROR_PAGE_DST" ]; then
    mv "$ERROR_PAGE_DST" "/tmp/error_page_backup_$(date +%Y%m%d%H%M%S)"
    echo "已备份旧 error-page 目录"
  fi
  # 复制新的 error-page（保留目录结构）
  cp -r "$ERROR_PAGE_SRC" "$ERROR_PAGE_DST" || { echo "复制 error-page 失败"; exit 1; }
  # 设置权限
  chown -R $NGINX_USER:$NGINX_USER "$ERROR_PAGE_DST" || chown -R $NGINX_USER "$ERROR_PAGE_DST" || echo "警告: error-page 设置所有者失败"
  chmod -R 755 "$ERROR_PAGE_DST" || echo "警告: error-page 设置权限失败"
  # 校验关键文件
  if [ -f "$ERROR_PAGE_DST/40x/common/404.html" ] && [ -f "$ERROR_PAGE_DST/50x/common/50x.html" ]; then
    echo "✅ error-page 更新成功: 404.html 与 50x.html 均存在"
  else
    echo "⚠️警告: error-page 关键文件缺失，请检查源码结构"
  fi
else
  echo "⚠️警告: 源 error-page 目录不存在 ($ERROR_PAGE_SRC)，跳过错误页更新"
fi

# 重新加载Nginx配置 - 宝塔专用（带提示 + 不中断构建）
echo "正在重新加载 Nginx 配置..."
if /www/server/nginx/sbin/nginx -s reload 2>/dev/null; then
    echo "✅ Nginx 配置重新加载成功"
else
    echo "⚠️警告: Nginx 配置 reload 失败，但项目已部署完成（不影响访问）"
fi
echo "部署完成 - $(date)"
```

#### v4
```shell
#!/bin/bash
set -eo pipefail

# ===================== 配置变量区 =====================
PROJECT_DIR="/root/.jenkins/workspace/fx67ll.xyz/fx67ll.xyz"
# 主站 nav.fx67ll.com 部署目标
NGINX_WEB_ROOT="/usr/share/nginx/html-8070"
# resume站点部署目标
RESUME_WEB_ROOT="/usr/share/nginx/html-528"
RESUME_SRC="${PROJECT_DIR}/resume.fx67ll.com/dist"
# error-page
ERROR_PAGE_SRC="${PROJECT_DIR}/error-page"
ERROR_PAGE_DST="/usr/share/nginx/html/error-page"

TMP_BACKUP_DIR="/tmp"
RETENTION_DAYS=7
SUB_FOLDER_NAME="nav.fx67ll.com"
# =====================================================

# 记录执行日志
echo "====== 开始部署 - $(date '+%Y-%m-%d %H:%M:%S') ======"

# 显示当前路径和Java版本
pwd
java -version

# 确定Nginx用户
NGINX_USER=$(ps aux | grep nginx | grep -v grep | awk '{print $1}' | head -1)
if [ -z "$NGINX_USER" ]; then
    if [ -f /etc/debian_version ]; then
        NGINX_USER="www-data"
    else
        NGINX_USER="nginx"
    fi
fi
echo "检测到Nginx用户: $NGINX_USER"

# 进入项目工作目录
cd "${PROJECT_DIR}" || { echo "❌ 无法进入项目目录 ${PROJECT_DIR}"; exit 1; }

# ========= 将 nav.fx67ll.com 内部全部文件提升到项目根目录，删除子文件夹 =========
if [ -d "./${SUB_FOLDER_NAME}" ]; then
    echo "✅ 检测到 ${SUB_FOLDER_NAME} 目录，开始将内部文件提升至项目根目录"
    mv -f ./${SUB_FOLDER_NAME}/* ./ 2>/dev/null || true
    rm -rf ./${SUB_FOLDER_NAME}
    echo "✅ ${SUB_FOLDER_NAME} 文件已提取到根目录，文件夹已删除"
else
    echo "ℹ️ ${SUB_FOLDER_NAME} 目录不存在，跳过目录提升操作"
fi

# 清理本地旧打包产物
if [ -f "./dist.tar.gz" ]; then
    rm -f ./dist.tar.gz
    echo "✅ 已删除旧的dist.tar.gz文件"
else
    echo "dist.tar.gz 不存在，继续执行"
fi

# 打包主站，排除dist.tar.gz自身
tar -zcvf dist.tar.gz --exclude=dist.tar.gz ./* || { echo "❌ 创建tar包失败"; exit 1; }
echo "✅ 成功创建dist.tar.gz打包文件"

TIMESTAMP=$(date +%Y%m%d%H%M%S)

# ---------------------- 部署主站 html-8070 ----------------------
echo "====== 开始部署主站 html-8070 ======"
NGINX_BACKUP="${TMP_BACKUP_DIR}/nginx_html8070_backup_${TIMESTAMP}"
if [ -n "$(ls -A "${NGINX_WEB_ROOT}" 2>/dev/null)" ]; then
    mv "${NGINX_WEB_ROOT}"/* "${NGINX_BACKUP}" 2>/dev/null || true
    echo "✅ 主站旧内容备份至 ${NGINX_BACKUP}"
fi

cp -f ./dist.tar.gz "${NGINX_WEB_ROOT}/" || { echo "❌ 复制tar包到Nginx主站目录失败"; exit 1; }
rm -f ./dist.tar.gz

cd "${NGINX_WEB_ROOT}" || { echo "❌ 无法进入Nginx主站目录 ${NGINX_WEB_ROOT}"; exit 1; }
tar -zxvf dist.tar.gz -C ./ || { echo "❌ 解压tar包失败"; exit 1; }
rm -f dist.tar.gz

chown -R "${NGINX_USER}:${NGINX_USER}" "${NGINX_WEB_ROOT}" || {
    echo "⚠️ 设置完整属组失败，尝试仅设置用户"
    chown -R "${NGINX_USER}" "${NGINX_WEB_ROOT}" || {
        echo "❌ 设置主站文件所有者失败，请检查用户是否存在"
        exit 1
    }
}
chmod -R 755 "${NGINX_WEB_ROOT}" || { echo "❌ 设置主站文件权限失败"; exit 1; }
echo "✅ 主站目录权限已设置"

if [ -f "${NGINX_WEB_ROOT}/index.html" ]; then
    echo "✅ 主站部署校验通过: index.html 文件存在"
else
    echo "⚠️警告: 主站 index.html 文件不存在，请检查项目打包结构"
fi

# ---------------------- 部署 resume.fx67ll.com -> html-528 新增模块 ----------------------
echo "====== 开始部署 resume站点 html-528 ======"
RESUME_BACKUP="${TMP_BACKUP_DIR}/nginx_html528_backup_${TIMESTAMP}"
if [ -d "${RESUME_SRC}" ]; then
    # 备份清空目标目录
    if [ -n "$(ls -A "${RESUME_WEB_ROOT}" 2>/dev/null)" ]; then
        mv "${RESUME_WEB_ROOT}"/* "${RESUME_BACKUP}" 2>/dev/null || true
        echo "✅ resume旧内容备份至 ${RESUME_BACKUP}"
    fi
    # 复制dist全部内容
    cp -r "${RESUME_SRC}"/* "${RESUME_WEB_ROOT}/" || { echo "❌ 复制resume dist文件失败"; exit 1; }

    chown -R "${NGINX_USER}:${NGINX_USER}" "${RESUME_WEB_ROOT}" || {
        echo "⚠️ resume 设置完整属组失败，尝试仅设置用户"
        chown -R "${NGINX_USER}" "${RESUME_WEB_ROOT}" || echo "⚠️ resume 设置所有者警告，请核对nginx用户"
    }
    chmod -R 755 "${RESUME_WEB_ROOT}" || echo "⚠️ resume 设置权限警告"

    if [ -f "${RESUME_WEB_ROOT}/index.html" ]; then
        echo "✅ resume站点部署校验通过: index.html 存在"
    else
        echo "⚠️警告: resume站点 index.html 缺失，请检查resume.fx67ll.com/dist目录"
    fi
else
    echo "⚠️警告: resume源目录不存在 ${RESUME_SRC}，跳过resume部署"
fi

# ===================== 更新 error-page 错误页 =====================
echo "====== 开始更新 error-page 错误页 ======"
if [ -d "${ERROR_PAGE_SRC}" ]; then
    ERROR_PAGE_BACKUP="${TMP_BACKUP_DIR}/error_page_backup_${TIMESTAMP}"
    if [ -d "${ERROR_PAGE_DST}" ]; then
        mv "${ERROR_PAGE_DST}" "${ERROR_PAGE_BACKUP}"
        echo "✅ 旧 error-page 已备份至 ${ERROR_PAGE_BACKUP}"
    fi

    cp -r "${ERROR_PAGE_SRC}" "${ERROR_PAGE_DST}" || { echo "❌ 复制 error-page 失败"; exit 1; }

    chown -R "${NGINX_USER}:${NGINX_USER}" "${ERROR_PAGE_DST}" || chown -R "${NGINX_USER}" "${ERROR_PAGE_DST}" || echo "⚠️ warning: error-page 设置所有者失败"
    chmod -R 755 "${ERROR_PAGE_DST}" || echo "⚠️ warning: error-page 设置权限失败"

    if [ -f "${ERROR_PAGE_DST}/40x/common/404.html" ] && [ -f "${ERROR_PAGE_DST}/50x/common/50x.html" ]; then
        echo "✅ error-page 更新成功: 404.html & 50x.html 校验通过"
    else
        echo "⚠️警告: error-page 关键页面缺失，请核对源码目录"
    fi
else
    echo "⚠️警告: 源 error-page 目录不存在 ${ERROR_PAGE_SRC}，跳过错误页更新"
fi

# ===================== 清理tmp中过期备份，避免磁盘占满 =====================
echo "====== 清理${RETENTION_DAYS}天以上历史备份文件 ====="
find "${TMP_BACKUP_DIR}" -maxdepth 1 -type d -name "nginx_html8070_backup_*" -mtime +${RETENTION_DAYS} -exec rm -rf {} \;
find "${TMP_BACKUP_DIR}" -maxdepth 1 -type d -name "nginx_html528_backup_*" -mtime +${RETENTION_DAYS} -exec rm -rf {} \;
find "${TMP_BACKUP_DIR}" -maxdepth 1 -type d -name "error_page_backup_*" -mtime +${RETENTION_DAYS} -exec rm -rf {} \;
echo "✅ 过期备份清理完成"

# 重新加载Nginx（宝塔）
echo "====== 重载 Nginx 配置 ======"
if /www/server/nginx/sbin/nginx -s reload 2>/dev/null; then
    echo "✅ Nginx reload 成功"
else
    echo "⚠️警告：Nginx reload失败，但业务文件已经部署完成，不影响静态资源访问"
fi

echo "====== 🎉 部署全部完成 - $(date '+%Y-%m-%d %H:%M:%S') ======"
```


### `fx67ll.xyz`在`github`中用的`Personal access tokens`是`jenkins-token-test`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://run.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  