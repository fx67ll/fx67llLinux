# Bat 学习笔记

### 什么是bat文件
1. bat文件是dos下的批处理文件
2. 批处理文件是无格式的文本文件，它包含一条或多条命令，它的文件扩展名为 .bat 或 .cmd
3. 在命令提示下输入批处理文件的名称，或者双击该批处理文件，系统就会调用cmd.exe按照该文件中各个命令出现的顺序来逐个运行它们
4. 使用批处理文件（也被称为批处理程序或脚本），可以简化日常或重复性任务

### 创建bat文件
1. 先创建一个txt文件，并在其中写入bat命令
2. 修改`.txt`后缀为`.bat`即可

### call命令
1. 调用外部命令，之前直接写`npm run build`，就会一闪而过无法持续执行完，这时候就需要在前面加上`call npm run build`即可
2. 表示调用cmd之外的命令，npm依赖于node，属于外部命令

### pause命令
1. 如果想要执行完命令之后cmd窗口不去自动关闭，可以使用该命令
2. 他会提示你按下任意按键继续