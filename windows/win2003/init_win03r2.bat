@echo off
color f0
cls
title  ����Windows��������ʼ��
if not %username%=="Administrator" echo ���Թ���Ա�˺����С�

::����ű����·��
cd /d "%~dp0"

:ActCnf
cls
color 90
title ��ʼ�������ڳ�ʼ���˺�
::������Administrator�˻�Ϊzyadmin
wmic useraccount where name="Administrator" call rename zyadmin
::Ϊzyadmin�û�����������벢��¼�ڵ�ǰ�ļ����µ�tmp.txt�ļ���
net user zyadmin /random > tmp.txt
::��ȡ��ǰϵͳ��������Ϣ
::systeminfo >> C:\account.txt
::��ȡ��ǰ�豸��IP��ַ��Ϣ
::ipconfig >> C:\account.txt
::Ҳ��ʹ�����µ������޸�zyadmin������
::net user zyadmin zy@SH2014
::��zyadmin���뵽����Administrators��
::net localgroup Administrators zyadmin /add
::ΪGuest�û������������
net user Guest /random >nul
::����guest�˻�
net user Guest /active:no
::������Guest�˻�Ϊadmin
::wmic useraccount where name="Guest" call rename admin
::�����޸���Ļ��ʾ
for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo ���¼��zyadmin���룺%%i�Ա��Ժ�����ƾ�ݡ�
::for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo zyadmin�������޸�Ϊ��%%i
pause>nul
::ping -n 5 127.0.0.1>nul
goto sethostname

:sethostname
cls
color a0
title ��ʼ�������ļ������
set /p "cmpy=������豸�����Ĺ�˾��(����5���ַ�)��"
if not defined cmpy (echo,��˾������Ϊ��.�������������&&pause>nul&&goto :sethostname)
set /p "usag=������豸����;(����5���ַ�)��" 
if not defined usag (echo,�豸��;����Ϊ��.�������������&&pause>nul&&goto :sethostname)
set "name=srv-%cmpy%-%usag%"
set "srvnm=%cmpy%%usag%"
if "%srvnm:~10%" neq "" (echo,����15�ַ�.�������������&&pause>nul&&goto :sethostname) else echo "���豸��Ϊ��%name%��������Ч��"

echo ���������������...
reg add "HKLM\System\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v ComputerName /t reg_sz /d %name% /f >nul 2>nul 
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t reg_sz /d %name% /f >nul 2>nul 
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v Hostname /t reg_sz /d %name% /f >nul 2>nul
echo ��������ʼ����ɣ���������Ч��
ping -n 5 127.0.0.1>nul
goto RmtDskCnf

:RmtDskCnf
cls
color b0
title ��ʼ�������ڳ�ʼ��Զ����������
::����Ĭ�ϵ�Զ������˿�3389Ϊ40022
set rdp_port=40022
::�޸�ע�������Զ�����档
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD  /d  0  /f
::�޸�Զ������˿ڵ�ע���������
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp" /v PortNumber /t REG_DWORD  /d %rdp_port% /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD  /d %rdp_port% /f
echo Զ�������ʼ��������ɣ���������Ч��
ping -n 5 127.0.0.1>nul
goto FrwCnf

:FrwCnf
cls
color c0
title ��ʼ�������ڳ�ʼ������ǽ����
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::��ʼ��Windows����ǽ����,��ʵ��������Windows 5.xϵ�мܹ�
::��ԭ����ǽĬ�Ϲ���
netsh firewall reset
::���÷���ǽĬ�Ϲ��򣬼���������ǽ����������
netsh firewall set opmode mode = ENABLE exceptions = ENABLE
::����ICMP��ping����
netsh firewall set icmpsetting 8
::���Զ������˿ڼ�IP������
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
::���ʱ��ͬ���˿ڼ�IP������
::set ntp_servers=110.75.186.247,110.75.186.248,110.75.186.249
::netsh firewall add portopening protocol = tcp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM address = %ntp_servers%
::netsh firewall add portopening protocol = udp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM address = %ntp_servers%
netsh firewall add portopening protocol = tcp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM
netsh firewall add portopening protocol = udp port = 123 name = "NTPPort" mode = ENABLE scope = CUSTOM
::���ñ��������Internet���ŵķ���Ͷ˿�
netsh firewall add portopening TCP 25 "OpenPorts"
netsh firewall add portopening TCP 80 "OpenPorts"
netsh firewall add portopening TCP 443 "OpenPorts"
netsh firewall add portopening TCP 8080 "OpenPorts"
netsh firewall add portopening UDP 53 "OpenPorts"
netsh firewall add portopening UDP 161 "OpenPorts"
netsh firewall add portopening UDP 162 "OpenPorts"
netsh firewall add portopening UDP 514 "OpenPorts"
::����ָ���ĳ�����mstscͨ������ǽ
netsh firewall add AllowRemoteDesktop %systemroot%\system32\mstsc.exe WhiteListProgram ENABLE
::netsh firewall add allowedprogram %ProgramFiles%\Internet Explorer\iexplore.exe WhiteMenuProgram ENABLE
::netsh firewall add allowedprogram %ProgramFiles(x86)%\Internet Explorer\iexplore.exe WhiteMenuProgram ENABLE
::IIS6.0���ÿ�ʼ
::cd /d c:\Inetpub\AdminScripts
::cscript adsutil.vbs set /MSFTPSVC/PassivePortRange "30000-30010"
::IIS6.0���ý���
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo ����ǽ��ʼ����ɡ�
ping -n 5 127.0.0.1>nul
goto StsCnf

:StsCnf
cls
color d0
title ��ʼ���������Ż�ϵͳ����
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::���ƣ�TermService
::��ʾ��Terminal Services
::�����������û��Խ�����ʽ���ӵ�Զ�̼������Զ�����桢�����û��л���Զ��Э�����ն˷����������˷��� - ֹͣ����ô˷����ʹ���ļ������ò��ɿ���Ҫ��ֹԶ��ʹ�ô˼���������ڡ�ϵͳ�����Կ��������Ŀ�������Զ�̡�ѡ��ϵĸ�ѡ��
::���飺�Զ����� 
sc config TermService start= Auto
sc start TermService

::���ƣ�Tssdis
::��ʾ��Terminal Services Session Directory
::�����������û���������·�ɵ�Ⱥ���к��ʵ��ն˷�����������������ֹͣ����������ᱻ·�ɵ���һ�����÷�������
::���飺�Զ����� 
sc config Tssdis start= Auto
sc start Tssdis

::���ƣ�RemoteRegistry
::��ʾ��Remote Registry 
::������ʹԶ���û����޸Ĵ˼�����ϵ�ע������á�����˷�����ֹ��ֻ�д˼�����ϵ��û������޸�ע�������˷��񱻽��ã��κ��������ķ����޷������� 
::���飺���� 
sc config RemoteRegistry start= DISABLED
sc stop RemoteRegistry

::���ƣ�SharedAccess
::��ʾ��Windows Firewall/Internet Connection Sharing (ICS)
::������Ϊ��ͥ��С�Ͱ칫�����ṩ�����ַת������ַ�Լ����ƽ�����/���ֹ���ַ���
::���䣺Windows����ǽ�����飺�Զ����� 
sc config SharedAccess start= Auto
sc start SharedAccess

::���ƣ�lanmanserver
::��ʾ��server
::������֧�ִ˼����ͨ��������ļ�����ӡ���������ܵ������������ֹͣ����Щ���ܲ����á�������񱻽��ã��κ�ֱ�������ڴ˷���ķ����޷�������
::���䣺�ļ��������飺����
sc config lanmanserver start= Disabled
sc stop lanmanserver

::���ƣ�Alerter
::��ʾ��Alerter
::������֪ͨѡ�����û��ͼ�������������������ֹͣ��ʹ�ù������ĳ��򽫲����յ����ǡ�����˷��񱻽��ã��κ�ֱ���������ķ��񶼽�����������
::���䣺Windows����������Messenger����ʹ����������Ϣ�����飺����
sc config Alerter start= Disabled
sc stop Alerter

::���ƣ�Messenger
::��ʾ��Messenger
::����������ͻ��˺ͷ�����֮��� NET SEND �� ������������Ϣ���˷����� Windows Messenger �޹ء��������ֹͣ����������Ϣ���ᱻ���䡣������񱻽��ã��κ�ֱ�������ڴ˷���ķ����޷�������
::���䣺Windows��ʹ���񡣽��飺����
sc config Messenger start= Disabled
sc stop Messenger

::���ƣ�AppMgmt
::��ʾ��Application Management
::������Ϊ Active Directory ����ӳ������Գ�����װ��ɾ����ö����������˷���ͣ�ã��û����޷���װ��ɾ����ö���κ�����ӳ���������˷��񱻽��ã��κ����������ķ����޷�������
::���飺���򻷾��û�����
sc config AppMgmt start= Disabled
sc stop AppMgmt

::���ƣ�wuauserv
::��ʾ��Automatic Updates
::�������������ز���װ Windows ���¡�����˷��񱻽��ã������������ʹ�� Windows Update ��վ���Զ����¹��ܡ�
::Windows�Զ����¡����飺�Զ�����
sc config wuauserv start= Auto
sc start wuauserv

::���ƣ�BITS
::��ʾ��Background Intelligent Transfer Service
::�������ں�̨����ͻ��˺ͷ�����֮������ݡ���������� BITS��һЩ���ܣ��� Windows Update�����޷��������С�
::���飺����
sc config BITS start= Auto
sc start BITS

::���ƣ�AeLookupSvc
::��ʾ��Application Experience Lookup Service 
::��������Ӧ�ó�������ʱΪӦ�ó�����Ӧ�ó�������Բ������� 
::���飺���� 
sc config AeLookupSvc start= DISABLED
sc stop AeLookupSvc

::���ƣ�ClipSrv
::��ʾ��ClipBook
::���������á��������鿴����������Ϣ����Զ�̼������������˷�����ֹ�����������鿴���� ���޷���Զ�̼����������Ϣ������˷��񱻽��ã��κ��������ķ����޷�������
::���飺����
sc config ClipSrv start= DISABLED
sc stop ClipSrv

::���ƣ�Browser
::��ʾ��Computer Browser
::������ά�������ϼ�����ĸ����б������б��ṩ�������ָ��������������ֹͣ���б��ᱻ���»�ά����������񱻽��ã��κ�ֱ�������ڴ˷���ķ����޷�������
::���飺����������
sc config Browser start= DISABLED
sc stop Browser

::���ƣ�Dhcp
::��ʾ��DHCP Client 
::������Ϊ�˼����ע�Ტ���� IP ��ַ������˷���ֹͣ������������ܽ��ն�̬ IP ��ַ�� DNS ���¡�����˷��񱻽��ã�������ȷ�������ķ��񶼽����������� 
::���飺���������� 
sc config Dhcp start= DISABLED
sc stop Dhcp

::���ƣ�ERSvc
::��ʾ��Error Reporting Service
::�������ռ����洢���� Microsoft �����쳣Ӧ�ó������������˷���ͣ�ã���ô���󱨸�����ں˴����ĳЩ�����û�ģʽ����ʱ����������˷��񱻽��ã��κ����������ķ����޷����á�
::���󱨸档���飺����
sc config ERSvc start= DISABLED
sc stop ERSvc

::���ƣ�helpsvc
::��ʾ��Help and Support
::�����������ڴ˼���������а�����֧�����ġ����ֹͣ���񣬰�����֧�����Ľ������á�������÷����κ�ֱ�������ڴ˷���ķ����޷�������
::������֧�����ġ����飺����
sc config helpsvc start= DISABLED
sc stop helpsvc

::���ƣ�HidServ
::��ʾ��Human Interface Device Access
::���������ö�����ѧ�ӿ��豸(HID)��ͨ��������ʣ������������̡�Զ�̿��ƺ�������ý���豸�ϵ�Ԥ�ȶ�����Ȱ�ť������˷�����ֹ���ɴ˷�����Ƶ��Ȱ�ť���������С�����˷��񱻽��ã��κ��������ķ����޷�������
::���幤��ѧ�豸�����飺����������
sc config HidServ start= DISABLED
sc stop HidServ

::���ƣ�ImapiService
::��ʾ��IMAPI CD-Burning COM Service
::��������Image Mastering Applications Programming Interface(IMAPI)����CD¼�ơ����ֹͣ�÷�����̨��������޷�¼��CD������÷��񱻽��ã��κ��������ķ����޷�������
::CD¼�ƹ�����񡣽��飺����������
sc config ImapiService start= DISABLED
sc stop ImapiService

::���ƣ�PolicyAgent
::��ʾ��IPSEC Services
::�������ṩ TCP/IP �����Ͽͻ��˺ͷ�����֮��˶Զ˵İ�ȫ������˷���ͣ�ã������Ͽͻ��˺ͷ�����֮��� TCP/IP ��ȫ�����ȶ�������˷��񱻽��ã��κ��������ķ����޷�������
::IPSec���񡣽��飺�Զ�����
sc config PolicyAgent start= Auto
sc start PolicyAgent

::���ƣ�Spooler
::��ʾ��Print Spooler
::�������������б��غ������ӡ���м��������д�ӡ����������˷���ͣ�ã����ؼ�����ϵĴ�ӡ�������á�����˷��񱻽��ã��κ����������ķ����޷����á�
::��ӡ�����˷��񡣽��飺����������
sc config Spooler start= DISABLED
sc stop Spooler

::���ƣ�SCardSvr
::��ʾ��Smart Card
::����������˼���������ܿ���ȡ�����ʡ�����˷�����ֹ���˼�������޷�ȡ�����ܿ�������˷��񱻽��ã��κ��������ķ����޷�������
::���䣺 ����㲻ʹ�� Smart Card ���ǾͿ��Թ��� 
::���棺 Plug and Play 
::���ܿ����񡣽��飺����������
sc config SCardSvr start= DISABLED
sc stop SCardSvr

::���ƣ�TapiSrv
::��ʾ��Telephony
::�������ṩ�ͻ��˵� TAPI ֧�֣��Ա������Ƶ绰�豸�ͻ��� IP ���������ӡ�����˷���ͣ�ã����������ڴ˵ĳ����ܽ�����������˷��񱻽��ã��κ����������ķ����޷����á� 
::���䣺һ��Ĳ��ŵ��ƽ��������һЩ DSL/Cable �����õ� 
::���棺Plug and Play��remote Procedure Call (RPC)��remote Access Connection Manager��remote Access Auto Connection Manager 
::���飺�ֶ� 
sc config TapiSrv start= DEMAND
sc stop TapiSrv

::���ƣ�TlntSvr
::��ʾ��Telnet
::����������Զ���û���¼���˼���������г��򣬲�֧�ֶ��� TCP/IP Telnet �ͻ��ˣ��������� UNIX �� Windows �ļ����������˷���ֹͣ��Զ���û��Ͳ��ܷ��ʳ����κ�ֱ�����������ķ��񽫻�����ʧ�ܡ�
::Telnet���񡣽��飺���������ã�����Ҫʱ������
sc config TlntSvr start= DISABLED
sc stop TlntSvr

::���ƣ�stisvc
::��ʾ��Windows Image Acquisition (WIA)
::������Ϊɨ���Ǻ�������ṩͼ�񲶻���� 
::���䣺���ɨ���Ǻ���������ڲ�����֧��WIA���ܵĻ����ǾͿ���ֱ�ӿ���ͼ��������Ҫ������������������û��ɨ���Ǻ����������ʹ���ߴ�ɹ��� 
::���棺remote Procedure Call (RPC) 
::Windowsͼ�񲶻���񡣽��飺����
sc config stisvc start= DISABLED
sc stop stisvc

::���ƣ�WZCSVC
::��ʾ��Wireless Configuration
::���������� IEEE 802.11 ���������Զ����á�����˷���ֹͣ���Զ����ý������á�����˷��񱻽��ã�������ȷ�������ķ��񶼽�����������
::���������Զ����á����飺����
sc config WZCSVC start= DISABLED
sc stop WZCSVC

::���ƣ�Nla
::��ʾ��Network Location Awareness (NLA) 
::�������ռ��������������ú�λ����Ϣ��������Ϣ�Ķ�ʱ֪ͨӦ�ó��� 
::���飺�ֶ� 
sc config Nla start= DEMAND
sc stop Nla

::���ƣ�seclogon
::��ʾ��Secondary Logon 
::�����������滻ƾ���µ����ý��̡�����˷�����ֹ�������͵�¼���ʽ������á�����˷��񱻽��ã��κ��������ķ����޷������� 
::���飺�ֶ� 
sc config seclogon start= DEMAND
::sc start seclogon

::���ƣ�LmHosts
::��ʾ��TCP/IP NetBIOS Helper 
::�������ṩTCP/IP (NetBT)�����ϵ�NetBIOS�������Ͽͻ��˵� NetBIOS ���ƽ�����֧�֣��Ӷ�ʹ�û��ܹ������ļ�����ӡ�͵�¼�����硣����˷���ͣ�ã���Щ���ܿ��ܲ����á�����˷��񱻽��ã��κ��������ķ����޷������� 
::���飺���� 
sc config LmHosts start= DISABLED
sc stop LmHosts

::���ƣ�swprv
::��ʾ��Microsoft Software Shadow Copy Provider
::�����������������Ӱ���Ʒ�����ȡ�õ������Ϊ���Ĵ�������Ӱ���ơ����ֹͣ������񣬾��޷����������Ϊ���Ĵ�������Ӱ���ơ� 
::���䣺������˵�ģ��������ݵĶ������� MS Backup �������Ҫ������� 
::���棺remote Procedure Call (RPC) 
::���飺���� 
sc config swprv start= DISABLED
sc stop swprv

::���ƣ�SysmonLog
::��ʾ��Performance Logs and Alerts (Ч�ܼ�¼�ļ�����ʾ) 
::�������ռ����ػ�Զ�̼��������Ԥ�����õļƻ��������������ݣ�Ȼ�󽫴�����д����־�򴥷�����������˷�����ֹ���������ռ�������Ϣ������˷��񱻽��ã��κ��������ķ����޷������� 
::���䣺ûʲô��ֵ�ķ��� 
::���飺���� 
sc config SysmonLog start= DISABLED
sc stop SysmonLog

::���ƣ�TapiSrv
::��ʾ��Telephony 
::������Ϊ����������ϼ����ɾ����������ӵ�����ִ�д˷���ķ������ϣ����Ƶ绰����װ�ú� IP Ϊ�����������ĳ����ṩ�绰���� API (TAPI) ֧�֡� 
::���䣺һ��Ĳ��ŵ��ƽ��������һЩ DSL/Cable �����õ� 
::���棺Plug and Play��remote Procedure Call (RPC)��remote Access Connection Manager��remote Access Auto Connection Manager 
::���飺�ֶ� 
sc config TapiSrv start= DISABLED
sc stop TapiSrv

::���ƣ�TrkWks
::��ʾ��Distributed Link Tracking Client (�ֲ�ʽ����׷�ٿͻ���) 
::���������ÿͻ��˳�����������ļ����ƶ���������ͬһ NTFS �����ƶ����ƶ���ͬһ̨������ϵ���һ NTFS������һ̨������ϵ� NTFS������˷���ͣ�ã���̨������ϵ����ӽ�����ά������١�����˷��񱻽��ã��κ����������ķ����޷����á� 
::���䣺ά�������ڲ�ͬ�����֮��ĵ������� 
::���棺remote Procedure Call (RPC) 
::���飺���� 
sc config TrkWks start= DISABLED
sc stop TrkWks

::���ƣ�WmdmPmSN
::��ʾ��Portable Media Serial Number Service
::������Retrieves the serial number of any portable media player connected to this computer. If this service is stopped, protected content might not be down loaded to the device.
::���䣺͸���������������ȡ���κ����ֲ�����ţ�ûʲô��ֵ�ķ��� 
::���飺���� 
sc config WmdmPmSN start= DISABLED
sc stop WmdmPmSN

::���ƣ�WmiApSrv
::��ʾ��WMI Performance Adapter 
::�������� Windows Management Instrumentation (WMI) �ṩ�����������ϵĿͻ����ṩ���ܿ���Ϣ���˷���ֻ���������������ֱ�����ʱ�����С� 
::���䣺�������� 
::���棺remote Procedure Call (RPC) 
::���飺���� 
sc config WmiApSrv start= DISABLED
sc stop WmiApSrv

::���ƣ�SENS
::��ʾ��System Event Notification
::����������ϵͳ�¼���֪ͨ COM+ �¼�ϵͳ��������(subscriber)��������˷���ͣ�ã�COM+ �¼�ϵͳ�������ߡ������ղ���ϵͳ�¼�֪ͨ������˷��񱻽��ã��κ����������ķ����޷����á� 
::���飺���� 
sc config SENS start= DISABLED
sc stop SENS

::���ƣ�EventSystem
::��ʾ��COM+ Event System 
::������֧��ϵͳ�¼�֪ͨ���� (SENS)���˷���Ϊ���ĵ��������ģ�� (COM) ����ṩ�Զ��ֲ��¼����ܡ����ֹͣ�˷���SENS ���رգ����Ҳ����ṩ��¼��ע��֪ͨ��������ô˷�����ʽ�����˷�����������񶼽��޷�������
::���飺���� 
sc config EventSystem start= DISABLED
sc stop EventSystem

::���ƣ�AudioSrv
::��ʾ��Windows Audio 
::������������� Windows �ĳ������Ƶ�豸������˷�����ֹ����Ƶ�豸������Ч��������������������˷��񱻽��ã��κ��������ķ����޷������� 
::���䣺����������ʲô����ѽ��ȥ����! 
::���飺���� 
sc config AudioSrv start= DISABLED
sc stop AudioSrv

::���ƣ�Schedule
::��ʾ��Task Scheduler
::������ʹ�û����ڴ˼���������úͼƻ��Զ���������˷�����ֹ����Щ�����޷��ڼƻ�ʱ�������С�����˷��񱻽��ã��κ��������ķ����޷�������
::���飺�ֶ� 
sc config Schedule start= DEMAND
sc stop Schedule

::���ƣ�RemoteAccess
::��ʾ��Routing and Remote Access 
::�������ھ������Լ�������������Ϊ��ҵ�ṩ·�ɷ��� 
::���飺���� 
sc config RemoteAccess start= DISABLED
sc stop RemoteAccess

::���ƣ�NtmsSvc
::��ʾ��Removable Storage 
::����������ͱ�¼���ƶ�ý�岢�����Զ������ƶ�ý���豸������������ֹͣ���������ƶ��洢�ĳ����籸�ݺ�Զ�̴洢�������ٶȡ�������������������ר�����������ķ����޷�������
::���飺���� 
sc config NtmsSvc start= DISABLED
sc stop NtmsSvc
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo ϵͳ�����Ż���ɡ�
ping -n 5 127.0.0.1>nul
goto PrintInfo

:PrintInfo
cls
color e0
title ��ʼ�������
echo,----SYSTEM INFORMATION---- > C:\account.txt
::��ӡ����IP��Ϣ��
for /f "tokens=2 delims=:" %%a in ('ipconfig^|findstr /i "ipv4"^|findstr /v "�Զ�����"') do echo �������ӣ�%%a >> C:\account.txt
echo,hostname is %name% >> C:\account.txt
echo,username is zyadmin >> C:\account.txt
echo,port is %rdp_port% >> C:\account.txt
::��ȡzyadmin������
for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo password is %%i >> C:\account.txt
echo,-----------END----------- >> C:\account.txt
del /q tmp.txt
::���´�ӡ��Ļ��ʾ��Ϣ
echo �豸��ʼ����ɡ��Ժ����C:\account.txt�ļ��в鿴���豸��Ϣ��
echo ���豸��Ϣ���£�
echo.
type "C:\account.txt"
echo.
echo ��ʼ��������ɡ����¼������Ϣ��ִ�С�shutdown -r -t 0��������ʹ��ʼ��������Ч��
::echo System starts in 30 seconds.
::shutdown -r -t 30
pause & exit
