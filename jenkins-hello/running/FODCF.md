# FODCF的shell记录

#### v1
```shell
cp /root/.jenkins/workspace/neverUploadToGithub.js /root/.jenkins/workspace/FODCF/  
ls /root/.jenkins/workspace/FODCF/  
npm install
npm run build
cd dist
tar -zcvf dist.tar.gz *
cd /usr/share/nginx/html-90
ls
rm -rf *
ls
cd /root/.jenkins/workspace/FODCF
scp /root/.jenkins/workspace/FODCF/dist/dist.tar.gz /usr/share/nginx/html-90
rm -R dist
cd /usr/share/nginx/html-90
tar -zxvf dist.tar.gz -C ./
rm -R dist.tar.gz
```

#### v2
```shell
PROJECT_NAME=FODCF
PROJECT_PORT=90
echo "本次编译项目名称：$PROJECT_NAME，项目编号：$PROJECT_PORT"

pwd
node -v
npm -v
echo "开始安装依赖并编译"
npm install
npm run build

# 复制文件
echo "开始复制项目打包文件"
cd dist
tar -zcvf dist.tar.gz *
cd /usr/share/nginx/html-$PROJECT_PORT 
ls
rm -rf *
ls
cd /root/.jenkins/workspace/$PROJECT_NAME  
scp /root/.jenkins/workspace/$PROJECT_NAME/dist/dist.tar.gz /usr/share/nginx/html-$PROJECT_PORT  
rm -R dist  
cd /usr/share/nginx/html-$PROJECT_PORT  
tar -zxvf dist.tar.gz -C ./
rm -R dist.tar.gz

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

# 设置正确的文件权限 - 使用检测到的Nginx用户
chown -R $NGINX_USER:$NGINX_USER /usr/share/nginx/html-$PROJECT_PORT || { echo "设置文件所有者失败，尝试使用单用户"; chown -R $NGINX_USER /usr/share/nginx/html-$PROJECT_PORT || { echo "仍然无法设置文件所有者，请检查用户权限"; exit 1; } }
chmod -R 755 /usr/share/nginx/html-$PROJECT_PORT || { echo "设置文件权限失败"; exit 1; }
echo "已设置正确的文件权限"
```

#### v3
```shell
#!/bin/bash

# 记录执行日志
echo "开始部署 - $(date)"

# 打印项目和端口
PROJECT_NAME=FODCF
PROJECT_PORT=90
PROJECT_FILE_PATH=dist
echo "本次编译项目名称：$PROJECT_NAME，项目编号：$PROJECT_PORT"

# 显示当前路径和Java/Node版本
pwd
java -version
node -v
npm -v

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
cd $PROJECT_FILE_PATH || { echo "无法进入项目目录"; exit 1; }

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
cd /usr/share/nginx/html-$PROJECT_PORT || { echo "无法进入Nginx目录"; exit 1; }

# 备份当前内容
if [ "$(ls -A)" ]; then
  mv * "/tmp/nginx_backup_$(date +%Y%m%d%H%M%S)"
  echo "已备份当前Nginx内容"
fi

# 复制tar包到Nginx目录
cd /root/.jenkins/workspace/$PROJECT_NAME/$PROJECT_FILE_PATH || { echo "无法进入工作目录"; exit 1; }
scp /root/.jenkins/workspace/$PROJECT_NAME/$PROJECT_FILE_PATH/dist.tar.gz /usr/share/nginx/html-$PROJECT_PORT || { echo "复制tar包失败"; exit 1; }
rm -f ./dist.tar.gz
echo "已复制tar包并删除源文件"

# 解压tar包到Nginx目录
cd /usr/share/nginx/html-$PROJECT_PORT || { echo "无法进入Nginx目录"; exit 1; }
tar -zxvf dist.tar.gz -C ./ || { echo "解压tar包失败"; exit 1; }
rm -f dist.tar.gz

# 设置正确的文件权限 - 使用检测到的Nginx用户
chown -R $NGINX_USER:$NGINX_USER /usr/share/nginx/html-$PROJECT_PORT || { echo "设置文件所有者失败，尝试使用单用户"; chown -R $NGINX_USER /usr/share/nginx/html-$PROJECT_PORT || { echo "仍然无法设置文件所有者，请检查用户权限"; exit 1; } }
chmod -R 755 /usr/share/nginx/html-$PROJECT_PORT || { echo "设置文件权限失败"; exit 1; }
echo "已设置正确的文件权限"

# 检查index.html是否存在
if [ -f "/usr/share/nginx/html-$PROJECT_PORT/index.html" ]; then
  echo "部署成功: index.html文件存在"
else
  echo "警告: index.html文件不存在，请检查项目结构"
fi

# 重新加载Nginx配置 - 使用sudo权限
if command -v sudo &> /dev/null; then
    sudo systemctl reload nginx || { echo "重新加载Nginx配置失败"; exit 1; }
else
    systemctl reload nginx || { echo "重新加载Nginx配置失败"; exit 1; }
fi
echo "Nginx配置已重新加载"
echo "部署完成 - $(date)"
```

#### v4 添加调用超神独立服务的部署
```shell
#!/bin/bash

# 记录执行日志
echo "开始部署 - $(date)"

# 打印项目和端口
PROJECT_NAME=FODCF
PROJECT_PORT=90
PROJECT_CHAOSHEN_PORT=78
PROJECT_FILE_PATH=dist
PROJECT_CHAOSHEN_FILE_PATH=dist-chaoshen

echo "本次编译项目名称：$PROJECT_NAME"
echo "主项目端口：$PROJECT_PORT，混沌项目端口：$PROJECT_CHAOSHEN_PORT"

# 显示当前路径和Java/Node版本
pwd
java -version
node -v
npm -v

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

# 部署主项目
echo "=== 开始部署主项目（端口：$PROJECT_PORT）==="

# 进入主项目目录
cd $PROJECT_FILE_PATH || { echo "无法进入主项目目录"; exit 1; }

# 检查并删除已存在的tar文件
if [ -f "./dist.tar.gz" ]; then
  rm -f dist.tar.gz
  echo "已删除旧的dist.tar.gz文件"
else
  echo "dist.tar.gz文件不存在，继续执行"
fi

# 创建新的tar包
tar -zcvf dist.tar.gz ./* || { echo "创建主项目tar包失败"; exit 1; }
echo "成功创建主项目tar包"

# 切换到主项目Nginx目录
cd /usr/share/nginx/html-$PROJECT_PORT || { echo "无法进入主项目Nginx目录"; exit 1; }

# 备份当前内容
if [ "$(ls -A)" ]; then
  mv * "/tmp/nginx_backup_$(date +%Y%m%d%H%M%S)"
  echo "已备份当前主项目Nginx内容"
fi

# 复制tar包到主项目Nginx目录
cd /root/.jenkins/workspace/$PROJECT_NAME/$PROJECT_FILE_PATH || { echo "无法进入主项目工作目录"; exit 1; }
scp /root/.jenkins/workspace/$PROJECT_NAME/$PROJECT_FILE_PATH/dist.tar.gz /usr/share/nginx/html-$PROJECT_PORT || { echo "复制主项目tar包失败"; exit 1; }
rm -f ./dist.tar.gz
echo "已复制主项目tar包并删除源文件"

# 解压tar包到主项目Nginx目录
cd /usr/share/nginx/html-$PROJECT_PORT || { echo "无法进入主项目Nginx目录"; exit 1; }
tar -zxvf dist.tar.gz -C ./ || { echo "解压主项目tar包失败"; exit 1; }
rm -f dist.tar.gz

# 设置主项目正确的文件权限
chown -R $NGINX_USER:$NGINX_USER /usr/share/nginx/html-$PROJECT_PORT || { echo "设置主项目文件所有者失败，尝试使用单用户"; chown -R $NGINX_USER /usr/share/nginx/html-$PROJECT_PORT || { echo "仍然无法设置主项目文件所有者，请检查用户权限"; exit 1; } }
chmod -R 755 /usr/share/nginx/html-$PROJECT_PORT || { echo "设置主项目文件权限失败"; exit 1; }
echo "已设置主项目正确的文件权限"

# 检查主项目index.html是否存在
if [ -f "/usr/share/nginx/html-$PROJECT_PORT/index.html" ]; then
  echo "主项目部署成功: index.html文件存在"
else
  echo "警告: 主项目index.html文件不存在，请检查项目结构"
fi

# 部署混沌项目
echo "=== 开始部署混沌项目（端口：$PROJECT_CHAOSHEN_PORT）==="

# 返回到项目根目录
cd /root/.jenkins/workspace/$PROJECT_NAME || { echo "无法返回项目根目录"; exit 1; }

# 进入混沌项目目录
cd $PROJECT_CHAOSHEN_FILE_PATH || { echo "无法进入混沌项目目录"; exit 1; }

# 检查并删除已存在的tar文件
if [ -f "./dist-chaoshen.tar.gz" ]; then
  rm -f dist-chaoshen.tar.gz
  echo "已删除旧的dist-chaoshen.tar.gz文件"
else
  echo "dist-chaoshen.tar.gz文件不存在，继续执行"
fi

# 创建混沌项目新的tar包
tar -zcvf dist-chaoshen.tar.gz ./* || { echo "创建混沌项目tar包失败"; exit 1; }
echo "成功创建混沌项目tar包"

# 切换到混沌项目Nginx目录
cd /usr/share/nginx/html-$PROJECT_CHAOSHEN_PORT || { echo "无法进入混沌项目Nginx目录"; exit 1; }

# 备份当前内容
if [ "$(ls -A)" ]; then
  mv * "/tmp/nginx_backup_chaoshen_$(date +%Y%m%d%H%M%S)"
  echo "已备份当前混沌项目Nginx内容"
fi

# 复制tar包到混沌项目Nginx目录
cd /root/.jenkins/workspace/$PROJECT_NAME/$PROJECT_CHAOSHEN_FILE_PATH || { echo "无法进入混沌项目工作目录"; exit 1; }
scp /root/.jenkins/workspace/$PROJECT_NAME/$PROJECT_CHAOSHEN_FILE_PATH/dist-chaoshen.tar.gz /usr/share/nginx/html-$PROJECT_CHAOSHEN_PORT || { echo "复制混沌项目tar包失败"; exit 1; }
rm -f ./dist-chaoshen.tar.gz
echo "已复制混沌项目tar包并删除源文件"

# 解压tar包到混沌项目Nginx目录
cd /usr/share/nginx/html-$PROJECT_CHAOSHEN_PORT || { echo "无法进入混沌项目Nginx目录"; exit 1; }
tar -zxvf dist-chaoshen.tar.gz -C ./ || { echo "解压混沌项目tar包失败"; exit 1; }
rm -f dist-chaoshen.tar.gz

# 设置混沌项目正确的文件权限
chown -R $NGINX_USER:$NGINX_USER /usr/share/nginx/html-$PROJECT_CHAOSHEN_PORT || { echo "设置混沌项目文件所有者失败，尝试使用单用户"; chown -R $NGINX_USER /usr/share/nginx/html-$PROJECT_CHAOSHEN_PORT || { echo "仍然无法设置混沌项目文件所有者，请检查用户权限"; exit 1; } }
chmod -R 755 /usr/share/nginx/html-$PROJECT_CHAOSHEN_PORT || { echo "设置混沌项目文件权限失败"; exit 1; }
echo "已设置混沌项目正确的文件权限"

# 检查混沌项目index.html是否存在
if [ -f "/usr/share/nginx/html-$PROJECT_CHAOSHEN_PORT/index.html" ]; then
  echo "混沌项目部署成功: index.html文件存在"
else
  echo "警告: 混沌项目index.html文件不存在，请检查项目结构"
fi

# 重新加载Nginx配置 - 使用sudo权限
if command -v sudo &> /dev/null; then
    sudo systemctl reload nginx || { echo "重新加载Nginx配置失败"; exit 1; }
else
    systemctl reload nginx || { echo "重新加载Nginx配置失败"; exit 1; }
fi
echo "Nginx配置已重新加载"
echo "所有项目部署完成 - $(date)"
```


### `FODCF`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://run.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  