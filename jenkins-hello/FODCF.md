# FODCF的shell记录

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


### `FODCF`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://test.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  