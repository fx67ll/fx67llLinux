# fx67ll.com的shell记录

```shell
pwd
java -version
cd dist
if [ -f "./dist.tar.gz" ];then
  rm -R dist.tar.gz
else
  echo "文件不存在"
fi
tar -zcvf dist.tar.gz ./*
cd /usr/share/nginx/html-1023
ls
rm -rf *
ls
cd /root/.jenkins/workspace/fx67ll.com/dist
scp /root/.jenkins/workspace/fx67ll.com/dist/dist.tar.gz /usr/share/nginx/html-1023
rm -R ./dist.tar.gz
cd /usr/share/nginx/html-1023
tar -zxvf dist.tar.gz -C ./
rm -R dist.tar.gz
```


### `fx67ll.com`在`github`中用的`Personal access tokens`是`jenkins-token-test`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://test.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  