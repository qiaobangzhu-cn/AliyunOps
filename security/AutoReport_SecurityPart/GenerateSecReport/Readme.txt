如何阅读漏洞报告

文件为.csv格式（逗号分隔符）

Microsoft Office 会自动关联此格式，推荐使用excel打开

第一列Vulnerability
表示漏洞,具体信息参见<记录_安全巡检>电子表格，"最重要漏洞"列对应。

第二列OsType
表示Windows还是Linux

第三列Hostname
表示系统主机名

第四列eth0
表示第一块网卡的ip，windows系统可能为loop卡的169.254.0.0/16的地址

第五列
表示第二块网卡的ip，或者收集信息的日期

可以使用excel的数据筛选功能
操作方法，选中第一行，第一格，使用组合键 Ctrl + Shift + l
然后根据你的需求对，Vulnerability Hostname 进行筛选，或者你有兴趣的其他列
