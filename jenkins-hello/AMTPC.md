# AMTPC的shell记录

npm install  
npm run build  
cd dist  
tar -zcvf dist.tar.gz *  
cd /usr/share/nginx/html-84  
ls  
rm -rf *  
ls  
cd /root/.jenkins/workspace/AMTPC  
scp /root/.jenkins/workspace/AMTPC/dist/dist.tar.gz /usr/share/nginx/html-84  
rm -R dist  
cd /usr/share/nginx/html-84  
tar -zxvf dist.tar.gz -C ./  
rm -R dist.tar.gz  


### `AMTPC`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  