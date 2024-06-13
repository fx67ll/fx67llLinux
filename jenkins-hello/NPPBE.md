# NPPBE的shell记录

```shell
ls -a
tar -zcvf dist.tar.gz *
cd /usr/node/NPPBE
rm -rf *
cd /root/.jenkins/workspace/NPPBE
scp /root/.jenkins/workspace/NPPBE/dist.tar.gz /usr/node/NPPBE
echo ---------------------------------------------------------
echo /root/.jenkins/workspace/NPPBE filelist
ls -a
rm -rf *
echo /root/.jenkins/workspace/NPPBE filelist after 'rm -rf *'
ls -a
echo ---------------------------------------------------------
cd /usr/node/NPPBE
tar -zxvf dist.tar.gz -C ./
echo ---------------------------------------------------------
echo /usr/node/NPPBE filelist
ls -a
rm -r dist.tar.gz
rm -f .env
echo /usr/node/NPPBE filelist after 'rm -r/-f'
ls -a
echo ---------------------------------------------------------
cd ../
scp /root/.jenkins/workspace/.env /usr/node/NPPBE
cd ./NPPBE
echo ---------------------------------------------------------
echo /usr/node/NPPBE filelist last
ls -a
echo ---------------------------------------------------------
npm install
cd bin
pm2 list
pm2 start www --name="NPPBE"
```


### `NPPBE`在`github`中用的`Personal access tokens`是`jenkins-token`  
### `ssh钥匙`统一用`fx67ll ifnxs`  
### 记得在`github`项目中设置`Webhooks` -> `Payload URL`统一配置`http://test.fx67ll.com/jenkins/github-webhook/` -> `Content type`统一配置`application/json` -> 其余使用默认配置  