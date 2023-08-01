@echo off
color f0
cls
title  阿里Windows云主机初始化
if not %username%=="Administrator" echo 请以管理员账号运行。

::进入脚本存放路径
cd /d "%~dp0"

:ActCnf
cls
color 90
title 初始化：正在初始化账号
::重命名Administrator账户为zyadmin
wmic useraccount where name="Administrator" call rename zyadmin
::为zyadmin用户生成随机密码并记录在当前文件夹下的tmp.txt文件内
net user zyadmin /random > tmp.txt
::获取当前系统的配置信息
::systeminfo >> C:\account.txt
::获取当前设备的IP地址信息
::ipconfig >> C:\account.txt
::也可使用如下的命令修改zyadmin的密码
::net user zyadmin zy@SH2014
::将zyadmin加入到本地Administrators组
::net localgroup Administrators zyadmin /add
::为Guest用户设置随机密码
net user Guest /random >nul
::禁用guest账户
net user Guest /active:no
::重命名Guest账户为admin
::wmic useraccount where name="Guest" call rename admin
::密码修改屏幕提示
for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo 请记录下zyadmin密码：%%i以备稍后输入凭据。
::for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo zyadmin密码已修改为：%%i
pause>nul
::ping -n 5 127.0.0.1>nul
goto sethostname

:sethostname
cls
color a0
title 初始化：更改计算机名
set /p "cmpy=请键入设备所属的公司名(限制5个字符)："
if not defined cmpy (echo,公司名不能为空.任意键返回重试&&pause>nul&&goto :sethostname)
set /p "usag=请键入设备的用途(限制5个字符)：" 
if not defined usag (echo,设备用途不能为空.任意键返回重试&&pause>nul&&goto :sethostname)
set "name=srv-%cmpy%-%usag%"
set "srvnm=%cmpy%%usag%"
if "%srvnm:~10%" neq "" (echo,大于15字符.任意键返回重试&&pause>nul&&goto :sethostname) else echo "新设备名为：%name%，重启生效。"

echo 正在重命名计算机...
reg add "HKLM\System\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t reg_sz /d %name% /f >nul 2>nul 
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t reg_sz /d %name% /f >nul 2>nul 
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v Hostname /t reg_sz /d %name% /f >nul 2>nul
echo 主机名初始化完成，重启后生效。
ping -n 5 127.0.0.1>nul
goto RmtDskCnf

:RmtDskCnf
cls
color b0
title 初始化：正在初始化远程桌面配置
::更改默认的远程桌面端口3389为40022
set rdp_port=40022
::修改注册表启用远程桌面。
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD  /d  0  /f
::修改远程桌面端口的注册表，共两个
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp" /v PortNumber /t REG_DWORD  /d %rdp_port% /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD  /d %rdp_port% /f
echo 远程桌面初始化配置完成，重启后生效。
ping -n 5 127.0.0.1>nul
goto FrwCnf

:FrwCnf
cls
color c0
title 初始化：正在初始化防火墙配置
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::初始化Windows防火墙配置,本实例适用于Windows 5.x系列架构
::还原防火墙默认规则
netsh firewall reset
::配置防火墙默认规则，即开启防火墙但允许例外
netsh firewall set opmode mode = ENABLE exceptions = ENABLE
::配置ICMP即ping测试
netsh firewall set icmpsetting 8
::添加远程桌面端口及IP至例外
::set secure_machines=114.215.208.149,42.96.130.182,10.0.0.1/255.0.0.0,172.16.0.1/255.224.0.0,192.168.0.0/255.255.0.0
set secure_machines=114.215.208.149,42.96.130.182
netsh firewall add portopening protocol = TCP port = 20 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM address = %secure_machines%
netsh firewall add portopening protocol = TCP port = 21 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM address = %secure_machines%
netsh firewall add portopening protocol = TCP port = 3389 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM address = %secure_machines%
netsh firewall add portopening protocol = TCP port = 40022 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM address = %secure_machines%
::netsh firewall add portopening protocol = TCP port = 20 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM
::netsh firewall add portopening protocol = TCP port = 21 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM
::netsh firewall add portopening protocol = TCP port = 3389 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM
::netsh firewall add portopening protocol = TCP port = 40022 name = "SecurityAuditRules" mode = ENABLE scope = CUSTOM
::添加时间同步端口及IP至例外
::set ntp_servers=110.75.186.247,110.75.186.248,110.75.186.249
::netsh firewall add portopening protocol = tcp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM address = %ntp_servers%
::netsh firewall add portopening protocol = udp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM address = %ntp_servers%
netsh firewall add portopening protocol = tcp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM
netsh firewall add portopening protocol = udp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM
::配置本主机需对Internet开放的服务和端口
netsh firewall add portopening TCP 25 "OpenPorts"
netsh firewall add portopening TCP 80 "OpenPorts"
netsh firewall add portopening TCP 443 "OpenPorts"
netsh firewall add portopening TCP 8080 "OpenPorts"
netsh firewall add portopening UDP 53 "OpenPorts"
netsh firewall add portopening UDP 161 "OpenPorts"
netsh firewall add portopening UDP 162 "OpenPorts"
netsh firewall add portopening UDP 514 "OpenPorts"
::允许指定的程序如mstsc通过防火墙
netsh firewall add AllowRemoteDesktop %systemroot%\system32\mstsc.exe WhiteListProgram ENABLE
::netsh firewall add allowedprogram %ProgramFiles%\Internet Explorer\iexplore.exe WhiteMenuProgram ENABLE
::netsh firewall add allowedprogram %ProgramFiles(x86)%\Internet Explorer\iexplore.exe WhiteMenuProgram ENABLE
::IIS6.0配置开始
::cd /d c:\Inetpub\AdminScripts
::cscript adsutil.vbs set /MSFTPSVC/PassivePortRange "30000-30010"
::IIS6.0配置结束
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo 防火墙初始化完成。
ping -n 5 127.0.0.1>nul
goto StsCnf

:StsCnf
cls
color d0
title 初始化：正在优化系统服务
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::名称：TermService
::显示：Terminal Services
::描述：允许用户以交互方式连接到远程计算机。远程桌面、快速用户切换、远程协助和终端服务器依赖此服务 - 停止或禁用此服务会使您的计算机变得不可靠。要阻止远程使用此计算机，请在“系统”属性控制面板项目上清除“远程”选项卡上的复选框。
::建议：自动启动 
sc config TermService start= Auto
sc start TermService

::名称：Tssdis
::显示：Terminal Services Session Directory
::描述：允许用户连接请求路由到群集中合适的终端服务器。如果这个服务被停止，连接请求会被路由到第一个可用服务器。
::建议：自动启动 
sc config Tssdis start= Auto
sc start Tssdis

::名称：RemoteRegistry
::显示：Remote Registry 
::描述：使远程用户能修改此计算机上的注册表设置。如果此服务被终止，只有此计算机上的用户才能修改注册表。如果此服务被禁用，任何依赖它的服务将无法启动。 
::建议：禁用 
sc config RemoteRegistry start= DISABLED
sc stop RemoteRegistry

::名称：SharedAccess
::显示：Windows Firewall/Internet Connection Sharing (ICS)
::描述：为家庭或小型办公网络提供网络地址转换，定址以及名称解析和/或防止入侵服务。
::补充：Windows防火墙。建议：自动启动 
sc config SharedAccess start= Auto
sc start SharedAccess

::名称：lanmanserver
::显示：server
::描述：支持此计算机通过网络的文件、打印、和命名管道共享。如果服务停止，这些功能不可用。如果服务被禁用，任何直接依赖于此服务的服务将无法启动。
::补充：文件共享。建议：禁用
sc config lanmanserver start= Disabled
sc stop lanmanserver

::名称：Alerter
::显示：Alerter
::描述：通知选定的用户和计算机管理警报。如果服务停止，使用管理警报的程序将不会收到它们。如果此服务被禁用，任何直接依赖它的服务都将不能启动。
::补充：Windows警报服务，由Messenger（信使）服务发送消息。建议：禁用
sc config Alerter start= Disabled
sc stop Alerter

::名称：Messenger
::显示：Messenger
::描述：传输客户端和服务器之间的 NET SEND 和 警报器服务消息。此服务与 Windows Messenger 无关。如果服务停止，警报器消息不会被传输。如果服务被禁用，任何直接依赖于此服务的服务将无法启动。
::补充：Windows信使服务。建议：禁用
sc config Messenger start= Disabled
sc stop Messenger

::名称：AppMgmt
::显示：Application Management
::描述：为 Active Directory 智能映像组策略程序处理安装、删除和枚举请求。如果此服务被停用，用户将无法安装、删除或枚举任何智能映像程序。如果此服务被禁用，任何依赖于它的服务将无法启动。
::建议：非域环境用户禁用
sc config AppMgmt start= Disabled
sc stop AppMgmt

::名称：wuauserv
::显示：Automatic Updates
::描述：允许下载并安装 Windows 更新。如果此服务被禁用，计算机将不能使用 Windows Update 网站的自动更新功能。
::Windows自动更新。建议：自动启动
sc config wuauserv start= Auto
sc start wuauserv

::名称：BITS
::显示：Background Intelligent Transfer Service
::描述：在后台传输客户端和服务器之间的数据。如果禁用了 BITS，一些功能，如 Windows Update，就无法正常运行。
::建议：启用
sc config BITS start= Auto
sc start BITS

::名称：AeLookupSvc
::显示：Application Experience Lookup Service 
::描述：在应用程序启动时为应用程序处理应用程序兼容性查找请求。 
::建议：禁用 
sc config AeLookupSvc start= DISABLED
sc stop AeLookupSvc

::名称：ClipSrv
::显示：ClipBook
::描述：启用“剪贴簿查看器”储存信息并与远程计算机共享。如果此服务终止，“剪贴簿查看器” 将无法与远程计算机共享信息。如果此服务被禁用，任何依赖它的服务将无法启动。
::建议：禁用
sc config ClipSrv start= DISABLED
sc stop ClipSrv

::名称：Browser
::显示：Computer Browser
::描述：维护网络上计算机的更新列表，并将列表提供给计算机指定浏览。如果服务停止，列表不会被更新或维护。如果服务被禁用，任何直接依赖于此服务的服务将无法启动。
::建议：服务器禁用
sc config Browser start= DISABLED
sc stop Browser

::名称：Dhcp
::显示：DHCP Client 
::描述：为此计算机注册并更新 IP 地址。如果此服务停止，计算机将不能接收动态 IP 地址和 DNS 更新。如果此服务被禁用，所有明确依赖它的服务都将不能启动。 
::建议：服务器禁用 
sc config Dhcp start= DISABLED
sc stop Dhcp

::名称：ERSvc
::显示：Error Reporting Service
::描述：收集、存储和向 Microsoft 报告异常应用程序崩溃。如果此服务被停用，那么错误报告仅在内核错误和某些类型用户模式错误时发生。如果此服务被禁用，任何依赖于它的服务将无法启用。
::错误报告。建议：禁用
sc config ERSvc start= DISABLED
sc stop ERSvc

::名称：helpsvc
::显示：Help and Support
::描述：启用在此计算机上运行帮助和支持中心。如果停止服务，帮助和支持中心将不可用。如果禁用服务，任何直接依赖于此服务的服务将无法启动。
::帮助和支持中心。建议：禁用
sc config helpsvc start= DISABLED
sc stop helpsvc

::名称：HidServ
::显示：Human Interface Device Access
::描述：启用对人体学接口设备(HID)的通用输入访问，它激活并保存键盘、远程控制和其它多媒体设备上的预先定义的热按钮。如果此服务被终止，由此服务控制的热按钮将不再运行。如果此服务被禁用，任何依赖它的服务将无法启动。
::人体工程学设备。建议：服务器禁用
sc config HidServ start= DISABLED
sc stop HidServ

::名称：ImapiService
::显示：IMAPI CD-Burning COM Service
::描述：用Image Mastering Applications Programming Interface(IMAPI)管理CD录制。如果停止该服务，这台计算机将无法录制CD。如果该服务被禁用，任何依靠它的服务都无法启动。
::CD录制管理服务。建议：服务器禁用
sc config ImapiService start= DISABLED
sc stop ImapiService

::名称：PolicyAgent
::显示：IPSEC Services
::描述：提供 TCP/IP 网络上客户端和服务器之间端对端的安全。如果此服务被停用，网络上客户端和服务器之间的 TCP/IP 安全将不稳定。如果此服务被禁用，任何依赖它的服务将无法启动。
::IPSec服务。建议：自动开启
sc config PolicyAgent start= Auto
sc start PolicyAgent

::名称：Spooler
::显示：Print Spooler
::描述：管理所有本地和网络打印队列及控制所有打印工作。如果此服务被停用，本地计算机上的打印将不可用。如果此服务被禁用，任何依赖于它的服务将无法启用。
::打印机对了服务。建议：服务器禁用
sc config Spooler start= DISABLED
sc stop Spooler

::名称：SCardSvr
::显示：Smart Card
::描述：管理此计算机对智能卡的取读访问。如果此服务被终止，此计算机将无法取读智能卡。如果此服务被禁用，任何依赖它的服务将无法启动。
::补充： 如果你不使用 Smart Card ，那就可以关了 
::依存： Plug and Play 
::智能卡服务。建议：服务器禁用
sc config SCardSvr start= DISABLED
sc stop SCardSvr

::名称：TapiSrv
::显示：Telephony
::描述：提供客户端的 TAPI 支持，以便程序控制电话设备和基于 IP 的语音连接。如果此服务被停用，所有依赖于此的程序功能将削弱。如果此服务被禁用，任何依赖于它的服务将无法启用。 
::补充：一般的拨号调制解调器或是一些 DSL/Cable 可能用到 
::依存：Plug and Play、remote Procedure Call (RPC)、remote Access Connection Manager、remote Access Auto Connection Manager 
::建议：手动 
sc config TapiSrv start= DEMAND
sc stop TapiSrv

::名称：TlntSvr
::显示：Telnet
::描述：允许远程用户登录到此计算机并运行程序，并支持多种 TCP/IP Telnet 客户端，包括基于 UNIX 和 Windows 的计算机。如果此服务停止，远程用户就不能访问程序，任何直接依赖于它的服务将会启动失败。
::Telnet服务。建议：服务器禁用（仅需要时开启）
sc config TlntSvr start= DISABLED
sc stop TlntSvr

::名称：stisvc
::显示：Windows Image Acquisition (WIA)
::描述：为扫描仪和照相机提供图像捕获服务。 
::补充：如果扫描仪和数字相机内部具有支持WIA功能的话，那就可以直接看到图档，不需要其它的驱动程序，所以没有扫描仪和数字相机的使用者大可关了 
::依存：remote Procedure Call (RPC) 
::Windows图像捕获服务。建议：禁用
sc config stisvc start= DISABLED
sc stop stisvc

::名称：WZCSVC
::显示：Wireless Configuration
::描述：启用 IEEE 802.11 适配器的自动配置。如果此服务停止，自动配置将不可用。如果此服务被禁用，所有明确依赖它的服务都将不能启动。
::无线网络自动配置。建议：禁用
sc config WZCSVC start= DISABLED
sc stop WZCSVC

::名称：Nla
::显示：Network Location Awareness (NLA) 
::描述：收集并保存网络配置和位置信息，并在信息改动时通知应用程序。 
::建议：手动 
sc config Nla start= DEMAND
sc stop Nla

::名称：seclogon
::显示：Secondary Logon 
::描述：启用替换凭据下的启用进程。如果此服务被终止，此类型登录访问将不可用。如果此服务被禁用，任何依赖它的服务将无法启动。 
::建议：手动 
sc config seclogon start= DEMAND
::sc start seclogon

::名称：LmHosts
::显示：TCP/IP NetBIOS Helper 
::描述：提供TCP/IP (NetBT)服务上的NetBIOS和网络上客户端的 NetBIOS 名称解析的支持，从而使用户能够共享文件、打印和登录到网络。如果此服务被停用，这些功能可能不可用。如果此服务被禁用，任何依赖它的服务将无法启动。 
::建议：禁用 
sc config LmHosts start= DISABLED
sc stop LmHosts

::名称：swprv
::显示：Microsoft Software Shadow Copy Provider
::描述：管理磁盘区阴影复制服务所取得的以软件为主的磁盘区阴影复制。如果停止这个服务，就无法管理以软件为主的磁盘区阴影复制。 
::补充：如上所说的，用来备份的东西，如 MS Backup 程序就需要这个服务 
::依存：remote Procedure Call (RPC) 
::建议：禁用 
sc config swprv start= DISABLED
sc stop swprv

::名称：SysmonLog
::显示：Performance Logs and Alerts (效能记录文件及警示) 
::描述：收集本地或远程计算机基于预先配置的计划参数的性能数据，然后将此数据写入日志或触发警报。如果此服务被终止，将不会收集性能信息。如果此服务被禁用，任何依赖它的服务将无法启动。 
::补充：没什么价值的服务 
::建议：禁用 
sc config SysmonLog start= DISABLED
sc stop SysmonLog

::名称：TapiSrv
::显示：Telephony 
::描述：为本机计算机上及经由局域网络连接到正在执行此服务的服务器上，控制电话语音装置和 IP 为主语音联机的程序，提供电话语音 API (TAPI) 支持。 
::补充：一般的拨号调制解调器或是一些 DSL/Cable 可能用到 
::依存：Plug and Play、remote Procedure Call (RPC)、remote Access Connection Manager、remote Access Auto Connection Manager 
::建议：手动 
sc config TapiSrv start= DISABLED
sc stop TapiSrv

::名称：TrkWks
::显示：Distributed Link Tracking Client (分布式连结追踪客户端) 
::描述：启用客户端程序跟踪链接文件的移动，包括在同一 NTFS 卷内移动，移动到同一台计算机上的另一 NTFS、或另一台计算机上的 NTFS。如果此服务被停用，这台计算机上的链接将不会维护或跟踪。如果此服务被禁用，任何依赖于它的服务将无法启用。 
::补充：维护区网内不同计算机之间的档案连结 
::依存：remote Procedure Call (RPC) 
::建议：禁用 
sc config TrkWks start= DISABLED
sc stop TrkWks

::名称：WmdmPmSN
::显示：Portable Media Serial Number Service
::描述：Retrieves the serial number of any portable media player connected to this computer. If this service is stopped, protected content might not be down loaded to the device.
::补充：透过联机计算机重新取得任何音乐拨放序号？没什么价值的服务 
::建议：禁用 
sc config WmdmPmSN start= DISABLED
sc stop WmdmPmSN

::名称：WmiApSrv
::显示：WMI Performance Adapter 
::描述：从 Windows Management Instrumentation (WMI) 提供程序向网络上的客户端提供性能库信息。此服务只有在性能数据助手被激活时才运行。 
::补充：如上所提 
::依存：remote Procedure Call (RPC) 
::建议：禁用 
sc config WmiApSrv start= DISABLED
sc stop WmiApSrv

::名称：SENS
::显示：System Event Notification
::描述：监视系统事件并通知 COM+ 事件系统“订阅者(subscriber)”。如果此服务被停用，COM+ 事件系统“订阅者”将接收不到系统事件通知。如果此服务被禁用，任何依赖于它的服务将无法启用。 
::建议：禁用 
sc config SENS start= DISABLED
sc stop SENS

::名称：EventSystem
::显示：COM+ Event System 
::描述：支持系统事件通知服务 (SENS)，此服务为订阅的组件对象模型 (COM) 组件提供自动分布事件功能。如果停止此服务，SENS 将关闭，而且不能提供登录和注销通知。如果禁用此服务，显式依赖此服务的其他服务都将无法启动。
::建议：禁用 
sc config EventSystem start= DISABLED
sc stop EventSystem

::名称：AudioSrv
::显示：Windows Audio 
::描述：管理基于 Windows 的程序的音频设备。如果此服务被终止，音频设备及其音效将不能正常工作。如果此服务被禁用，任何依赖它的服务将无法启动。 
::补充：服务器上用什么声卡呀，去掉了! 
::建议：禁用 
sc config AudioSrv start= DISABLED
sc stop AudioSrv

::名称：Schedule
::显示：Task Scheduler
::描述：使用户能在此计算机上配置和计划自动任务。如果此服务被终止，这些任务将无法在计划时间里运行。如果此服务被禁用，任何依赖它的服务将无法启动。
::建议：手动 
sc config Schedule start= DEMAND
sc stop Schedule

::名称：RemoteAccess
::显示：Routing and Remote Access 
::描述：在局域网以及广域网环境中为企业提供路由服务。 
::建议：禁用 
sc config RemoteAccess start= DISABLED
sc stop RemoteAccess

::名称：NtmsSvc
::显示：Removable Storage 
::描述：管理和编录可移动媒体并操作自动化可移动媒体设备。如果这个服务被停止，依赖可移动存储的程序，如备份和远程存储将放慢速度。如果禁用这个服务，所有专依赖这个服务的服务将无法启动。
::建议：禁用 
sc config NtmsSvc start= DISABLED
sc stop NtmsSvc
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo 系统服务优化完成。
ping -n 5 127.0.0.1>nul
goto PrintInfo

:PrintInfo
cls
color e0
title 初始化：完成
echo,----SYSTEM INFORMATION---- > C:\account.txt
::打印本机IP信息：
for /f "tokens=2 delims=:" %%a in ('ipconfig^|findstr /i "ipv4"^|findstr /v "自动配置"') do echo 本地连接：%%a >> C:\account.txt
echo,hostname is %name% >> C:\account.txt
echo,username is zyadmin >> C:\account.txt
echo,port is %rdp_port% >> C:\account.txt
::获取zyadmin的密码
for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo password is %%i >> C:\account.txt
echo,-----------END----------- >> C:\account.txt
del /q tmp.txt
::以下打印屏幕提示信息
echo 设备初始化完成。稍后可在C:\account.txt文件中查看该设备信息。
echo 该设备信息如下：
echo.
type "C:\account.txt"
echo.
echo 初始化配置完成。请记录以上信息后执行“shutdown -r -t 0”重启以使初始化配置生效。
::echo System starts in 30 seconds.
::shutdown -r -t 30
pause & exit
