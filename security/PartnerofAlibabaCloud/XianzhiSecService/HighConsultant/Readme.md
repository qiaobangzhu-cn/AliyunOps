# 说明

本脚本为“先知高防管家”服务，具体流程见[高防接入服务流程](https://confluence.jiagouyun.com/pages/viewpage.action?pageId=20517182)

# 使用方法

## 选择最优DNS服务器

如果不配置，所有的查询域名记录都请求DnsServer.txt里定义的DNS服务器，如果客户的域名解析刚刚修改过，可能存在缓存更新不及时，导致不准确的情况。

如果客户提交的域名由多家注册商解析的，使用默认推荐的DNS进行查询。因为有些域名注册商运行的DNS服务不解析自家以外的域名记录，会导致查询失败。

### 根据客户提交域名列表的信息，在以下情形选择一个最合适的

#### 一家注册商解析

运行 DecideNS.bat ，输入客户域名列表中的任意一个（子）域名，比如可以是sub.example.com、more.lvl.example.com，也可以是example.com。

#### 多家注册商解析

运行 SetDefaultDns.bat ，会使用默认推荐的DNS。

#### 使用系统当前的默认DNS服务器

确保DnsServer.txt文件不存在，或没有有效行。

## 进行批量查询

运行 CollectDnsInfo.bat，在弹出的notepad内粘贴域名列表，一行一个；保存并关闭notepad。

稍等片刻（取决于域名数量，网络质量，Dns服务器响应速度），会自动打开DomainListFile3.csv（打开程序取决于默认关联程序，默认为EXCEL[如果有]）。

* 如果有AAAA记录，提示客户当前高防IP不支持IPv6接入，讨论具体处理方案。
* 如果某域名的RRType为"-"，RRData为"(May be non-existent)"，表示该域名没有CNAME/A/AAAA记录，请客户确认是否笔误，提交错误的域名。

将相关信息复制(插入复制的单元格)回《高防IP接入所需要收集信息表.xlsx》中，“业务涉及到的域名”下方。

根据具体的单元格范围，修正下方“Domain、Source Site和Port的对应关系”中“Source Site”列里的公式。

# 其他信息

## DnsServer.txt

该文件保存了收集域名信息时，进行查询的DNS服务器。而不是使用系统当前的默认DNS服务器设置。

如果该文件不存在，则使用系统当前的默认DNS服务器设置。

分号(;)开头的行为注释。
