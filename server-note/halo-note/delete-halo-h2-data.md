# 删除halo数据库H2中的同名图片

#### 修改配置文件
```shell
# 暂停 halo 运行
systemctl stop halo  

# 修改配置文件
cd /home/halo/.halo
vi application.yaml  
或
vi /home/halo/.halo/application.yaml  

# 修改一下内容
h2:
  console:
      enabled: true(这里从false 改为 true)

# 启动 halo 运行
systemctl start halo
```

#### 访问 h2 数据库操作界面
[h2-console](https://fx67ll.xyz/h2-console)  
**连接的相关参数请通过查看配置文件输入即可**

#### 查询图片位置
```SQL
SELECT * FROM ATTACHMENTS WHERE ORDER BY ID DESC;
```

*最后还是没有成功。。。待后续研究验证。。。*