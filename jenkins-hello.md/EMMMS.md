# EMMMS的shell记录

pwd  
node -v  
npm -v  
npm install  
npm run build  
cd dist  
tar -zcvf dist.tar.gz *  
cd /usr/share/nginx/html-82  
ls  
rm -rf *  
ls  
cd /root/.jenkins/workspace/EMMMS  
scp /root/.jenkins/workspace/EMMMS/dist/dist.tar.gz /usr/share/nginx/html-82  
rm -R dist  
cd /usr/share/nginx/html-82  
tar -zxvf dist.tar.gz -C ./  
rm -R dist.tar.gz  


### `EMMMS`在`github`中用的`Personal access tokens`是`jenkins-token`  