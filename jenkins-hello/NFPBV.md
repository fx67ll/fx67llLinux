# NFPBV的shell记录

npm install  
npm run build  
cd dist  
tar -zcvf dist.tar.gz *  
cd /usr/share/nginx/html-83  
ls  
rm -rf *  
ls  
cd /root/.jenkins/workspace/NFPBV  
scp /root/.jenkins/workspace/NFPBV/dist/dist.tar.gz /usr/share/nginx/html-83  
rm -R dist  
cd /usr/share/nginx/html-83  
tar -zxvf dist.tar.gz -C ./  
rm -R dist.tar.gz  


### `NFPBV`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  