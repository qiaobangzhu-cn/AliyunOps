# 获取项目对应的 project_id

对应关系请看此文件 [Readme.md](security/AutoReport_SecurityPart/Database/Table/Readme.md)

第二列 sub_system_name 里就是常用的项目名称，对应的第一列  sub_system_id 就是后文需要用到的 project_id

# Linux

## 收集方法：

将以下所有文件上传至(任意的)同一目录内：

[SecAgent.sh](../../raw/master/security/AutoReport_SecurityPart/RunOnHost/SecAgent.sh) (右键，另存为)

[RunOnHost.tar](../../raw/master/security/AutoReport_SecurityPart/RunOnHost/RunOnHost.tar)

使用sudo或root权限，在上传的目录下执行

    sudo sh SecAgent.sh <project_id>

如：

    sudo sh SecAgent.sh 50

提交产生的tar文件即可；执行完毕后，上传的2个文件会被自行删除。

## 产生的文件命名规则：

&lt;project\_id&gt;\_&lt;hostname&gt;.tar

如：50_srv-zy-ssh1.tar

# Windows

## 收集方法：

将以下文件上传至(任意的)一目录内：

[Windows.exe](../../raw/master/security/AutoReport_SecurityPart/RunOnHost/Windows/Windows.exe)

运行这个可执行文件，当命令提示符出现一下提示时：

    Input project_id:

输入本项目的project_id，按回车键继续；

等待弹出资源管理器窗口后，提交产生的rar文件即可；

然后关闭资源管理器窗口，在命令提示符中按任意键继续，包括压缩包在内的临时文件都会自动删除，exe本身不会删除。

## 产生的文件命名规则：

&lt;project\_id&gt;\_&lt;hostname&gt;.rar

如：50_SRV-ZY-RDP1.rar

# 提交文件规范

把所有机器产生的文件放入到，以前文提及的project_id命名的目录中，用常用格式压缩后提交即可。

提交目录样例（假定 project_id = 50,52）：

    50
    ├─50_name-ad1.rar
    ├─50_name-db1.tar
    ├─50_name-web2.tar
    └─50_name-web4.rar
    52
    ├─52_name-ad1.rar
    ├─52_name-db1.tar
    ├─52_name-web2.tar
    └─52_name-web4.rar
