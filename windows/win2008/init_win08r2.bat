@echo off
color f0
cls
title  阿里Windows云主机初始化
if not %username%=="Administrator" echo 请右击并以管理员身份运行。

::进入脚本存放路径
cd /d "%~dp0"

:ActCnf
cls
color 09
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
for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo zyadmin密码已修改为：%%i
ping -n 5 127.0.0.1>nul
goto sethostname

:sethostname
cls
color 0a
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
color 0b
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
color 0c
title 初始化：正在初始化防火墙配置
::初始化Windows防火墙配置,本实例适用于Windows 6.X系列架构
::导出系统当前配置的防火墙规则
netsh advfirewall export "c:\advfirewall.wfw"
::还原防火墙默认规则
::netsh advfirewall reset
::启用防火墙
netsh advfirewall set allprofiles state on
::设置默认策略规则，禁止入站连接，允许出站连接
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowwoutbound
::设置默认策略规则，禁止入站连接，禁止出站连接
::netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
::允许指定的程序如mstsc通过防火墙
netsh advfirewall firewall add rule name="AllowRemoteDesktop" dir=in program="%systemroot%\system32\mstsc.exe" action=allow enable=yes 
netsh advfirewall firewall add rule name="AllowRemoteDesktop" dir=out program="%systemroot%\system32\mstsc.exe" action=allow enable=yes
netsh advfirewall firewall add rule name="AllowSysSrv" dir=in program="%systemroot%\system32\svchost.exe" action=allow enable=yes
netsh advfirewall firewall add rule name="AllowSysSrv" dir=out program="%systemroot%\system32\svchost.exe" action=allow enable=yes
::启用/禁用系统预定义的防火墙规则
netsh advfirewall firewall set rule name="远程桌面(TCP-In)" new enable=yes
netsh advfirewall firewall set rule name="远程桌面 - RemoteFX (TCP-In)" new enable=yes
netsh advfirewall firewall add rule name="远程桌面(TCP-Out)" description="用于远程桌面服务的出站规则，以允许 RDP 通信。[TCP 3389,40022]" dir=out program="System" protocol=tcp localport=3389,40022 action=allow enable=yes
netsh advfirewall firewall add rule name="远程桌面 - RemoteFX (TCP-Out)" description="用于远程桌面服务的出站规则，以允许 RDP 通信。[TCP 3389,40022]" dir=out program="%SystemRoot%\system32\svchost.exe" protocol=tcp localport=3389,40022 action=allow enable=yes
::设置堡垒机变量secure_machines并添加堡垒机规则
set secure_machines=114.215.208.149,42.96.130.182
netsh advfirewall firewall add rule name="SecurityAuditRules" dir=in protocol=tcp localport=20,21,3389,40022 remoteip=%secure_machines% action=allow enable=yes
netsh advfirewall firewall add rule name="SecurityAuditRules" dir=out protocol=tcp localport=20,21,3389,40022 remoteip=%secure_machines% action=allow enable=yes
::netsh advfirewall firewall add rule name="SecurityAuditRules" dir=in protocol=tcp localport=20,21,3389,40022 action=allow enable=yes
::netsh advfirewall firewall add rule name="SecurityAuditRules" dir=out protocol=tcp localport=20,21,3389,40022 action=allow enable=yes
::设置时间同步主机变量secure_machines并添加时间同步规则
netsh advfirewall firewall add rule name="NTPPort" dir=out protocol=udp remoteport=123 action=allow enable=yes
netsh advfirewall firewall add rule name="NTPPort" dir=in protocol=udp remoteport=123 action=allow enable=yes
::配置本主机需对Internet开放的服务和端口
netsh advfirewall firewall add rule name="OpenPorts" dir=in protocol=tcp localport=25,80,443,8080 action=allow enable=yes
netsh advfirewall firewall add rule name="OpenPorts" dir=out protocol=tcp localport=25,80,443,8080 action=allow enable=yes
netsh advfirewall firewall add rule name="OpenPorts" dir=in protocol=udp localport=53,161,162,514 action=allow enable=yes
netsh advfirewall firewall add rule name="OpenPorts" dir=out protocol=udp localport=53,161,162,514 action=allow enable=yes
echo 防火墙初始化完成。
ping -n 5 127.0.0.1>nul
goto CfgSysSrv

:CfgSysSrv
cls
color 0d
title 初始化：正在优化系统服务
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::名称：AeLookupSvc
::显示：Application Experience
::描述：在应用程序启动时为应用程序处理应用程序兼容性缓存请求
::建议：禁用
sc config AeLookupSvc start= DEMAND
sc stop AeLookupSvc

::名称：ALG
::显示：Application Layer Gateway Service
::描述：为 Internet 连接共享提供第三方协议插件的支持
::建议：禁用
sc config ALG start= DISABLED
sc stop ALG

::名称：AppMgmt
::显示：Application Management
::描述：为通过组策略部署的软件处理安装、删除以及枚举请求。如果该服务被禁用，则用户将不能安装、删除或枚举通过组策略部署的软件。如果此服务被禁用，则直接依赖于它的所有服务都将无法启动。
::建议：禁用
sc config AppMgmt start= DISABLED
sc stop AppMgmt

::名称：BITS
::显示：Background Intelligent Transfer Service
::描述：使用空闲网络带宽在后台传送文件。如果该服务被禁用，则依赖于 BITS 的任何应用程序(如 Windows Update 或 MSN Explorer)将无法自动下载程序和其他信息。
::建议：自动启动
sc config BITS start= Auto
sc start BITS


::名称：BFE
::显示：Base Filtering Engine
::描述：基本筛选引擎(BFE)是一种管理防火墙和 Internet 协议安全(IPsec)策略以及实施用户模式筛选的服务。停止或禁用 BFE 服务将大大降低系统的安全。还将造成 IPsec 管理和防火墙应用程序产生不可预知的行为。
::建议：自动启动
sc config BFE start= Auto
sc start BFE

::名称：Browser
::显示：Computer Browser
::描述：维护网络上计算机的更新列表，并将列表提供给计算机指定浏览。如果服务停止，列表不会被更新或维护。如果服务被禁用，任何直接依赖于此服务的服务将无法启动。
::建议：禁止
sc config Browser start= DISABLED
sc stop Browser

::名称：TrkWks
::显示：Distributed Link Tracking Client
::描述：维护某个计算机内或某个网络中的计算机的 NTFS 文件之间的链接。
::建议：禁止
sc config TrkWks start= DISABLED
sc stop TrkWks

::名称：hidserv
::显示：Human Interface Device Access
::描述：启用对智能界面设备(HID)的通用输入访问，它激活并保存键盘、远程控制和其它多媒体设备上的预先定义的热按钮。如果此服务被终止，由此服务控制的热按钮将不再运行。如果此服务被禁用，任何依赖它的服务将无法启动。
::建议：禁用
sc config hidserv start= DISABLED
sc stop hidserv

::名称：SharedAccess
::显示：Internet Connection Sharing (ICS)
::描述：为家庭和小型办公网络提供网络地址转换、寻址、名称解析和/或入侵保护服务。
::依存：Base Filtering Engine;Network Connections;Remote Access Connection Manager;Windows Management Instrumentation
::建议：自动启动
sc config SharedAccess start= Auto
sc start SharedAccess

::名称：iphlpsvc
::显示：IP Helper
::描述：使用 IPv6 转换技术(6to4、ISATAP、端口代理和 Teredo)和 IP-HTTPS 提供隧道连接。如果停止该服务，则计算机将不具备这些技术提供的增强连接优势。
::建议：禁用
sc config iphlpsvc start= DISABLED
sc stop iphlpsvc

::名称：PolicyAgent
::显示：IPsec Policy Agent
::描述：Internet 协议安全(IPSec)支持网络级别的对等身份验证、数据原始身份验证、数据完整性、数据机密性(加密)以及重播保护。此服务强制执行通过 IP 安全策略管理单元或命令行工具 "netsh ipsec" 创建的 IPSec 策略。停止此服务时，如果策略需要连接使用 IPSec，可能会遇到网络连接问题。同样，此服务停止时，Windows 防火墙的远程管理也不再可用。
::建议：自动启动
sc config PolicyAgent start= Auto
sc start PolicyAgent

::名称：WPDBusEnum
::显示：Portable Device Enumerator Service
::描述：强制可移动大容量存储设备的组策略。使应用程序(如 Windows Media Player 和图像导入向导)能够使用可移动大容量存储设备传输和同步内容。
::建议：禁用
sc config WPDBusEnum start= DISABLED
sc stop WPDBusEnum

::名称：Spooler
::显示：Print Spooler
::描述；将文件加载到内存供稍后打印
::建议：禁用
sc config Spooler start= DISABLED
sc stop Spooler

::名称：RemoteRegistry
::显示：Remote Registry
::描述：使远程用户能修改此计算机上的注册表设置。如果此服务被终止，只有此计算机上的用户才能修改注册表。如果此服务被禁用，任何依赖它的服务将无法启动。
::建议：安全风险，禁用
sc config RemoteRegistry start= DISABLED
sc stop RemoteRegistry

::名称：SessionEnv
::显示：Remote Desktop Configuration
::描述：远程桌面配置服务(RDCS)负责需要 SYSTEM 上下文的所有远程桌面服务和远程桌面相关的配置和会话维护活动。这些包括每会话临时文件夹、RD 主题和 RD 证书。
::建议：自动启动
sc config SessionEnv start= Auto
sc start SessionEnv

::名称：CertPropSvc
::显示：Certificate Propagation
::描述：将用户证书和根证书从智能卡复制到当前用户的证书存储，检测智能卡何时插入到智能卡读卡器中，并在需要时安装智能卡即插即用微型驱动器。
::建议：禁用
sc config CertPropSvc start= DISABLED
sc stop CertPropSvc

::名称：DPS
::显示：Diagnostic Policy Service
::诊断策略服务启用了 Windows 组件的问题检测、疑难解答和解决方案。如果该服务被停止，诊断将不再运行。
::建议：服务器禁用
sc config DPS start= DISABLED
sc stop DPS

::名称：WdiServiceHost
::显示：Diagnostic Service Host
::诊断服务主机被诊断策略服务用来承载需要在本地服务上下文中运行的诊断。如果停止该服务，则依赖于该服务的任何诊断将不再运行。
::建议：服务器禁用
sc config WdiServiceHost start= DISABLED
sc stop WdiServiceHost

::名称：fdPHost
::显示：Function Discovery Provider Host
::描述：FDPHOST 服务承载功能发现(FD)网络发现提供程序。这些 FD 提供程序为简单服务发现协议(SSDP)和 Web 服务发现(WS-D)协议提供网络发现服务。使用 FD 时停止或禁用 FDPHOST 服务将禁用这些协议的网络发现。当该服务不可用时，使用 FD 和依靠这些发现协议的网络服务将无法找到网络服务或资源。
::建议：虚拟机禁用
sc config fdPHost start= DISABLED
sc stop fdPHost

::名称：FDResPub
::显示：Function Discovery Resource Publication
::描述：发布该计算机以及连接到该计算机的资源，以便能够在网络上发现这些资源。如果该服务被停止，将不再发布网络资源，网络上的其他计算机将无法发现这些资源。
::建议：虚拟机禁用
sc config FDResPub start= DISABLED
sc stop FDResPub

::名称：swprv
::显示：Microsoft Software Shadow Copy Provider
::描述：管理卷影复制服务制作的基于软件的卷影副本。如果该服务被停止，将无法管理基于软件的卷影副本。如果该服务被禁用，任何依赖它的服务将无法启动。
::建议：禁用，一般不会用到
sc config swprv start= DISABLED
sc stop swprv

::名称：MMCSS
::显示：Multimedia Class Scheduler
::描述：基于系统范围内的任务优先级启用工作的相对优先级。这主要适用于多媒体应用程序。如果此服务停止，个别任务将使用其默认的优先级。
::建议：服务器一般无需用到声卡等
sc config MMCSS start= DISABLED
sc stop MMCSS

::名称：wercplsupport
::显示：Problem Reports and Solutions Control Panel Support
::描述：此服务为查看、发送和删除“问题报告和解决方案”控制面板的系统级问题报告提供支持。
::建议：服务器禁用
sc config wercplsupport start= DISABLED
sc stop wercplsupport

::名称：ShellHWDetection
::显示：Shell Hardware Detection
::描述：为自动播放硬件事件提供通知。
::建议：服务器禁用
sc config ShellHWDetection start= DISABLED
sc stop ShellHWDetection

::名称：SCardSvr
::显示：Smart Card
::描述：管理此计算机对智能卡的取读访问。如果此服务被终止，此计算机将无法取读智能卡。如果此服务被禁用，任何依赖它的服务将无法启动。
::建议：禁用
sc config SCardSvr start= DISABLED
sc stop SCardSvr

::名称：SCPolicySvc
::显示：Smart Card Removal Policy
::描述：允许系统配置为移除智能卡时锁定用户桌面
::建议：禁用
sc config SCPolicySvc start= DISABLED
sc stop SCPolicySvc

::名称：TBS
::显示：TPM Base Services
::描述：允许访问受信任的平台模块(TPM)，该模块向系统组件和应用程序提供基于硬件的加密服务。如果此服务已停止或禁用，则应用程序将无法使用 TPM 保护的密钥。
::建议：禁用
sc config TBS start= DISABLED
sc stop TBS

::名称：AudioSrv
::显示：Windows Audio
::描述：管理基于 Windows 的程序的音频。如果此服务被停止，音频设备和效果将不能正常工作。如果此服务被禁用，任何依赖它的服务将无法启动
::建议：禁用
sc config AudioSrv start= DISABLED
sc stop AudioSrv

::名称：AudioEndpointBuilder
::显示：Windows Audio Endpoint Builder
::描述：管理 Windows 音频服务的音频设备。如果此服务被停止，音频设备和效果将不能正常工作。如果此服务被禁用，任何依赖它的服务将无法启动
::建议：禁用
sc config AudioEndpointBuilder start= DISABLED
sc stop AudioEndpointBuilder

::名称：WerSvc
::显示：Windows Error Reporting Service
::描述：允许在程序停止运行或停止响应时报告错误，并允许提供现有解决方案。还允许为诊断和修复服务生成日志。如果此服务被停止，则错误报告将无法正确运行，而且可能不显示诊断服务和修复的结果。
::建议：禁用
sc config WerSvc start= DISABLED
sc stop WerSvc

::名称：Wecsvc
::显示：Windows Event Collector
::描述：此服务将管理对支持WS-Management 协议的远程源中事件的永久订阅。这包括Windows Vista事件日志、硬件以及启用IPMI 的事件源。该服务将转发的事件存储在本地活动日志中。如果停止或禁用此服务，将无法创建事件订阅，并且无法接受转发的事件。
::建议：禁用
sc config Wecsvc start= DISABLED
sc stop Wecsvc
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo 系统服务优化完成。
ping -n 5 127.0.0.1>nul
goto PrintInfo

:PrintInfo
cls
color 0e
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
