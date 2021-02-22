# Linux 学习笔记

### Linux 服务器初始化配置步骤
1. 下载Xshell和Xftp家庭中文版
2. 用服务器提供商提供的账号密码创建连接
3. 艹，太几把坑了，添加一个用户组的命令是groupadd而不是addgroup，教程有误请注意
	> `groupadd admin`
4. 添加一个用户名
	> `useradd -d /home/fx67ll -s /bin/bash -m fx67ll`  
	> 上面命令中，参数d指定用户的主目录，参数s指定用户的shell，参数m表示如果该目录不存在，则创建该目录  
5. 设置用户密码，注意在xshell中密码输入的时候是不显示的
	> `passwd fx67ll`  
	> 然后根据提示输入两次修改的密码即可
6. 将新用户（fx67ll）添加到用户组（admin）
	> `usermod -a -G admin fx67ll `  
7. 接着，为新用户设定sudo权限
	> `visudo`  
	> 按`a`进入编辑模式，按`: -> wq`退出并保存，[进入退出vim编辑器详见](https://www.cnblogs.com/crazylqy/p/5649860.html "linux系统中如何进入退出vim编辑器，方法及区别")  
	> [Linux下的vim常用操作详见](https://www.cnblogs.com/bjphp/p/8468330.html "Linux下的vim常用操作")
8. 设置SSH免密登录，不会弄，后面有空再弄吧