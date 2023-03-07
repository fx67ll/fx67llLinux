# JTCEE的shell记录

pwd
java -version
cd unpackage/dist/build/h5
if [ -f "./dist.tar.gz" ];then
  rm -R dist.tar.gz
else
  echo "文件不存在"
fi
tar -zcvf dist.tar.gz ./*
cd /usr/share/nginx/html-87
ls
rm -rf *
ls
cd /root/.jenkins/workspace/JTCEE/unpackage/dist/build/h5
scp /root/.jenkins/workspace/JTCEE/unpackage/dist/build/h5/dist.tar.gz /usr/share/nginx/html-87
rm -R ./dist.tar.gz
cd /usr/share/nginx/html-87
tar -zxvf dist.tar.gz -C ./
rm -R dist.tar.gz


### `JTCEE`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  