# MCDPC的shell记录

```shell
npm install  
npm run build  
cd dist  
tar -zcvf dist.tar.gz *  
cd /usr/share/nginx/html-85  
ls  
rm -rf *  
ls  
cd /root/.jenkins/workspace/MCDPC  
scp /root/.jenkins/workspace/MCDPC/dist/dist.tar.gz /usr/share/nginx/html-85  
rm -R dist  
cd /usr/share/nginx/html-85  
tar -zxvf dist.tar.gz -C ./  
rm -R dist.tar.gz  
```


### `MCDPC`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://test.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  