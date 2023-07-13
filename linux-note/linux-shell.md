# Linux运维常用命令

### 常用命令记录（待整理补充）  
1. `top` 查看所有进程  
2. 运行`top`命令后，按大写的`M`，按内存使用率排序  
3. 运行`top`命令后，按大写的`P`，按CPU使用率排序  
4. 运行`top`命令后，按两下大写的`E`，将KiB转换成GiB展示，小写的`e`转换列表里的大小  
5. `top -u (需要查询的用户名)` 查看某个linux用户下所有进程的信息  
6. `top -p (需要查询的进程ID)` 查看某个特定ID进程的信息 
7. `kill -9 (需要杀死的进程ID)` 杀死执行进程  
8. `yum(Yellow dog Updater)` 命令的全程是是一个在 Fedora 和 RedHat 以及 SUSE 中的 Shell 前端软件包管理器  
9. `ps -ef | grep (需要查询的服务名)` 查询特定服务进程信息  

### top命令其他参数
[参考资料](https://www.cnblogs.com/wangzy-Zj/p/16869149.html)  
```
M： 根据驻留内存大小进行排序。
P ： 根据CPU使用百分比大小进行排序。
T：  根据时间/累计时间进行排序。
q：  退出程序。
l ：  切换显示平均负载和启动时间信息。
m ：切换显示内存信息。
t：　切换显示进程和CPU状态信息。
c ：  切换显示命令名称和完整命令行。
1：　数字“1”显示各个CPU使用情况
```

#### 参考资料
1. [top命令按内存/CPU进行排序](https://www.cnblogs.com/wangzy-Zj/p/16869149.html)  
2. [Linux kill命令详解：终止进程](http://c.biancheng.net/view/1068.html)  
3. [Linux下查看某一进程所占用内存和CPU的方法](https://baijiahao.baidu.com/s?id=1761262711357522677&wfr=spider&for=pc)  

*—————————————————————————————————————后期时间充裕了之后，可以写一些关于top、kill、查询进程等命令的详解博客—————————————————————————————————————*
