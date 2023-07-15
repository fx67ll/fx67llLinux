# Linux运维常用命令

#### 先说些废话
因为笔者有着大量运维部署站点的需求，所以之前一直在陆陆续续学习并实践各种`Linux`的`Shell`命令，在此记录一些高频命令的使用的说明，方便自己回顾加深记忆  
后期如果有用到一些新的命令，也会继续保持更新，如果写的有不对的地方，也请各位看官指出，非常感谢~


### 系统信息查询的相关命令  
1. `df` 获取有关系统磁盘空间使用情况的报告  
	+ `-h / -hg`  以 GB 为单位显示  
	+ `-m / -hm`  以 MB 为单位显示  
	+ `-k / -hk`  以 KB 为单位显示，默认单位  
2. `du` 显示指定的目录或文件所占用的磁盘空间  
	+ 同上
3. `jobs` 显示所有当前作业及其状态  
4. `hostname` 显示主机/网络的名称  
5. `hostname -i` 显示主机/网络的IP  
6. `uname` 显示系统名称  
7. `ping` 检查与服务器的连接状态  


### 进程查询以及操作的相关命令  
1. `top` 查看所有进程  
	+ 以下是一些常用的高频操作
	+ 运行`top`命令后，按大写的`M`，按内存使用率排序  
	+ 运行`top`命令后，按大写的`P`，按CPU使用率排序  
	+ 运行`top`命令后，按两下大写的`E`，将上方明细里的`KiB`转换成`GiB`展示，小写的`e`转换列表里的大小单位  
2. `top -u (需要查询的用户名)` 查看某个linux用户下所有进程的信息  
3. `top -p (需要查询的进程ID)` 查看某个特定ID进程的信息 
4. `kill -9 (需要杀死的进程ID)` 杀死执行进程  
5. `yum(Yellow dog Updater)` 命令的全程是是一个在 Fedora 和 RedHat 以及 SUSE 中的 Shell 前端软件包管理器  
6. `ps -ef | grep (需要查询的服务名)` 查询特定服务进程信息  
#### 关于top命令其他可选参数
```
M： 根据驻留内存大小进行排序  
P： 根据CPU使用百分比大小进行排序  
T： 根据时间/累计时间进行排序  
q： 退出程序  
l： 切换显示平均负载和启动时间信息  
m： 切换显示内存信息  
t： 切换显示进程和CPU状态信息  
c： 切换显示命令名称和完整命令行  
1： 数字 1 显示各个CPU使用情况  
```


### 进入查看目录的相关命令
1. `pwd` 该命令将返回一个绝对路径  
2. `cd` 浏览指定目录（*Linux 的 Shell 是区分大小写的。因此，您必须准确输入名称的目录*）  
3. `cd ..` 返回上一级  
4. `ls` 查看当前目录的内容
5. `ls 目录路径` 查看指定目录的内容  


### 权限操作的相关命令
1. `sudo` 该命令是**SuperUser Do**的缩写，使您能够执行需要管理或超级用户权限的任务（*建议不要将此命令用于日常使用，因为如果您做错了一些事情，很容易发生错误*）  
2. `chmod` 更改文件和目录的读取，写入和执行权限（*请仔细阅读*[教程](https://www.runoob.com/linux/linux-comm-chmod.html)*后使用*）  
3. `chown` 更改文件的所有权转让给指定的用户名  


### 文件操作的相关命令
*笔者更习惯在 xftp 中可视化操作文件，更加安全方便直观，对于一些无法显示的配置文件才会用到相关操作命令*
1. `cp` 将文件从当前目录复制到另一个目录  
2. `mv` 将文件从当前目录移动到另一个目录  
3. `tar` 归档多个文件到一个压缩包（*注意！！！此命令需要配合其他参数使用，请仔细阅读*[教程](https://blog.csdn.net/lmjssjj/article/details/129275081)*后使用*）  
4. `mkdir` 创建一个新目录  
5. `rmdir` 删除目录，仅允许删除空目录  
6. `rm` 删除目录以及其中的内容（*注意：使用此命令时要格外小心，并仔细检查您所在的目录，这将删除所有内容，并且没有撤消操作*）
7. `rm -r` 删除目录，作为`rmdir`的替代方法，但是目录还有目录的话用`-r`是删除不了的  
8. `rm -R` 删除目录以及其子目录  
9. `rm -rf` 无提示地强制递归删除文件，`-f`的作用是不再询问确定删除（*注意：使用此命令时要格外小心，并仔细检查您所在的目录，这将删除所有内容，并且没有撤消操作*）
10. `touch` 创建新的空白文件  
11. `locate` 定位文件  
12. `locate -i` 不区分大小写定位文件  
13. `find` 类似定位命令，能搜索文件和目录。区别在于，您可以使用`find`命令在给定目录中查找文件  



## 参考资料
1. [Linux 命令大全](https://www.runoob.com/linux/linux-command-manual.html)  
2. [Linux 常用命令有哪些](https://www.wangan.com/wenda/4462)  
3. [Linux chmod命令](https://www.runoob.com/linux/linux-comm-chmod.html)  
4. [Linux操作系统之rm命令详解](https://www.cnblogs.com/hls-code/p/16692397.html)  
5. [tar命令详解](https://blog.csdn.net/ATTAIN__/article/details/124730900)  
6. [tar命令的讲解与使用](https://blog.csdn.net/ATTAIN__/article/details/124730900)  
7. [top命令按内存/CPU进行排序](https://www.cnblogs.com/wangzy-Zj/p/16869149.html)  
8. [Linux kill命令详解：终止进程](http://c.biancheng.net/view/1068.html)  
9. [Linux下查看某一进程所占用内存和CPU的方法](https://baijiahao.baidu.com/s?id=1761262711357522677&wfr=spider&for=pc)   


我是 [fx67ll.com](https://fx67ll.com)，如果您发现本文有什么错误，欢迎在评论区讨论指正，感谢您的阅读！  
如果您喜欢这篇文章，欢迎访问我的 [本文github仓库地址](https://github.com/fx67ll/fx67llLinux/blob/master/serve-blog/2023/2023-07/linux-shell.md)，为我点一颗Star，Thanks~ :)  
***转发请注明参考文章地址，非常感谢！！！***