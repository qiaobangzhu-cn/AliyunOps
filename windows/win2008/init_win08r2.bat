@echo off
color f0
cls
title  ����Windows��������ʼ��
if not %username%=="Administrator" echo ���һ����Թ���Ա������С�

::����ű����·��
cd /d "%~dp0"

:ActCnf
cls
color 09
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
for /f "tokens=2 delims=:" %%i in (tmp.txt) do echo zyadmin�������޸�Ϊ��%%i
ping -n 5 127.0.0.1>nul
goto sethostname

:sethostname
cls
color 0a
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
color 0b
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
color 0c
title ��ʼ�������ڳ�ʼ������ǽ����
::��ʼ��Windows����ǽ����,��ʵ��������Windows 6.Xϵ�мܹ�
::����ϵͳ��ǰ���õķ���ǽ����
netsh advfirewall export "c:\advfirewall.wfw"
::��ԭ����ǽĬ�Ϲ���
::netsh advfirewall reset
::���÷���ǽ
netsh advfirewall set allprofiles state on
::����Ĭ�ϲ��Թ��򣬽�ֹ��վ���ӣ������վ����
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowwoutbound
::����Ĭ�ϲ��Թ��򣬽�ֹ��վ���ӣ���ֹ��վ����
::netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
::����ָ���ĳ�����mstscͨ������ǽ
netsh advfirewall firewall add rule name="AllowRemoteDesktop" dir=in program="%systemroot%\system32\mstsc.exe" action=allow enable=yes 
netsh advfirewall firewall add rule name="AllowRemoteDesktop" dir=out program="%systemroot%\system32\mstsc.exe" action=allow enable=yes
netsh advfirewall firewall add rule name="AllowSysSrv" dir=in program="%systemroot%\system32\svchost.exe" action=allow enable=yes
netsh advfirewall firewall add rule name="AllowSysSrv" dir=out program="%systemroot%\system32\svchost.exe" action=allow enable=yes
::����/����ϵͳԤ����ķ���ǽ����
netsh advfirewall firewall set rule name="Զ������(TCP-In)" new enable=yes
netsh advfirewall firewall set rule name="Զ������ - RemoteFX (TCP-In)" new enable=yes
netsh advfirewall firewall add rule name="Զ������(TCP-Out)" description="����Զ���������ĳ�վ���������� RDP ͨ�š�[TCP 3389,40022]" dir=out program="System" protocol=tcp localport=3389,40022 action=allow enable=yes
netsh advfirewall firewall add rule name="Զ������ - RemoteFX (TCP-Out)" description="����Զ���������ĳ�վ���������� RDP ͨ�š�[TCP 3389,40022]" dir=out program="%SystemRoot%\system32\svchost.exe" protocol=tcp localport=3389,40022 action=allow enable=yes
::���ñ��ݻ�����secure_machines����ӱ��ݻ�����
set secure_machines=114.215.208.149,42.96.130.182
netsh advfirewall firewall add rule name="SecurityAuditRules" dir=in protocol=tcp localport=20,21,3389,40022 remoteip=%secure_machines% action=allow enable=yes
netsh advfirewall firewall add rule name="SecurityAuditRules" dir=out protocol=tcp localport=20,21,3389,40022 remoteip=%secure_machines% action=allow enable=yes
::netsh advfirewall firewall add rule name="SecurityAuditRules" dir=in protocol=tcp localport=20,21,3389,40022 action=allow enable=yes
::netsh advfirewall firewall add rule name="SecurityAuditRules" dir=out protocol=tcp localport=20,21,3389,40022 action=allow enable=yes
::����ʱ��ͬ����������secure_machines�����ʱ��ͬ������
netsh advfirewall firewall add rule name="NTPPort" dir=out protocol=udp remoteport=123 action=allow enable=yes
netsh advfirewall firewall add rule name="NTPPort" dir=in protocol=udp remoteport=123 action=allow enable=yes
::���ñ��������Internet���ŵķ���Ͷ˿�
netsh advfirewall firewall add rule name="OpenPorts" dir=in protocol=tcp localport=25,80,443,8080 action=allow enable=yes
netsh advfirewall firewall add rule name="OpenPorts" dir=out protocol=tcp localport=25,80,443,8080 action=allow enable=yes
netsh advfirewall firewall add rule name="OpenPorts" dir=in protocol=udp localport=53,161,162,514 action=allow enable=yes
netsh advfirewall firewall add rule name="OpenPorts" dir=out protocol=udp localport=53,161,162,514 action=allow enable=yes
echo ����ǽ��ʼ����ɡ�
ping -n 5 127.0.0.1>nul
goto CfgSysSrv

:CfgSysSrv
cls
color 0d
title ��ʼ���������Ż�ϵͳ����
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::���ƣ�AeLookupSvc
::��ʾ��Application Experience
::��������Ӧ�ó�������ʱΪӦ�ó�����Ӧ�ó�������Ի�������
::���飺����
sc config AeLookupSvc start= DEMAND
sc stop AeLookupSvc

::���ƣ�ALG
::��ʾ��Application Layer Gateway Service
::������Ϊ Internet ���ӹ����ṩ������Э������֧��
::���飺����
sc config ALG start= DISABLED
sc stop ALG

::���ƣ�AppMgmt
::��ʾ��Application Management
::������Ϊͨ������Բ�����������װ��ɾ���Լ�ö����������÷��񱻽��ã����û������ܰ�װ��ɾ����ö��ͨ������Բ�������������˷��񱻽��ã���ֱ���������������з��񶼽��޷�������
::���飺����
sc config AppMgmt start= DISABLED
sc stop AppMgmt

::���ƣ�BITS
::��ʾ��Background Intelligent Transfer Service
::������ʹ�ÿ�����������ں�̨�����ļ�������÷��񱻽��ã��������� BITS ���κ�Ӧ�ó���(�� Windows Update �� MSN Explorer)���޷��Զ����س����������Ϣ��
::���飺�Զ�����
sc config BITS start= Auto
sc start BITS


::���ƣ�BFE
::��ʾ��Base Filtering Engine
::����������ɸѡ����(BFE)��һ�ֹ������ǽ�� Internet Э�鰲ȫ(IPsec)�����Լ�ʵʩ�û�ģʽɸѡ�ķ���ֹͣ����� BFE ���񽫴�󽵵�ϵͳ�İ�ȫ��������� IPsec ����ͷ���ǽӦ�ó����������Ԥ֪����Ϊ��
::���飺�Զ�����
sc config BFE start= Auto
sc start BFE

::���ƣ�Browser
::��ʾ��Computer Browser
::������ά�������ϼ�����ĸ����б������б��ṩ�������ָ��������������ֹͣ���б��ᱻ���»�ά����������񱻽��ã��κ�ֱ�������ڴ˷���ķ����޷�������
::���飺��ֹ
sc config Browser start= DISABLED
sc stop Browser

::���ƣ�TrkWks
::��ʾ��Distributed Link Tracking Client
::������ά��ĳ��������ڻ�ĳ�������еļ������ NTFS �ļ�֮������ӡ�
::���飺��ֹ
sc config TrkWks start= DISABLED
sc stop TrkWks

::���ƣ�hidserv
::��ʾ��Human Interface Device Access
::���������ö����ܽ����豸(HID)��ͨ��������ʣ������������̡�Զ�̿��ƺ�������ý���豸�ϵ�Ԥ�ȶ�����Ȱ�ť������˷�����ֹ���ɴ˷�����Ƶ��Ȱ�ť���������С�����˷��񱻽��ã��κ��������ķ����޷�������
::���飺����
sc config hidserv start= DISABLED
sc stop hidserv

::���ƣ�SharedAccess
::��ʾ��Internet Connection Sharing (ICS)
::������Ϊ��ͥ��С�Ͱ칫�����ṩ�����ַת����Ѱַ�����ƽ�����/�����ֱ�������
::���棺Base Filtering Engine;Network Connections;Remote Access Connection Manager;Windows Management Instrumentation
::���飺�Զ�����
sc config SharedAccess start= Auto
sc start SharedAccess

::���ƣ�iphlpsvc
::��ʾ��IP Helper
::������ʹ�� IPv6 ת������(6to4��ISATAP���˿ڴ���� Teredo)�� IP-HTTPS �ṩ������ӡ����ֹͣ�÷��������������߱���Щ�����ṩ����ǿ�������ơ�
::���飺����
sc config iphlpsvc start= DISABLED
sc stop iphlpsvc

::���ƣ�PolicyAgent
::��ʾ��IPsec Policy Agent
::������Internet Э�鰲ȫ(IPSec)֧�����缶��ĶԵ������֤������ԭʼ�����֤�����������ԡ����ݻ�����(����)�Լ��ز��������˷���ǿ��ִ��ͨ�� IP ��ȫ���Թ���Ԫ�������й��� "netsh ipsec" ������ IPSec ���ԡ�ֹͣ�˷���ʱ�����������Ҫ����ʹ�� IPSec�����ܻ����������������⡣ͬ�����˷���ֹͣʱ��Windows ����ǽ��Զ�̹���Ҳ���ٿ��á�
::���飺�Զ�����
sc config PolicyAgent start= Auto
sc start PolicyAgent

::���ƣ�WPDBusEnum
::��ʾ��Portable Device Enumerator Service
::������ǿ�ƿ��ƶ��������洢�豸������ԡ�ʹӦ�ó���(�� Windows Media Player ��ͼ������)�ܹ�ʹ�ÿ��ƶ��������洢�豸�����ͬ�����ݡ�
::���飺����
sc config WPDBusEnum start= DISABLED
sc stop WPDBusEnum

::���ƣ�Spooler
::��ʾ��Print Spooler
::���������ļ����ص��ڴ湩�Ժ��ӡ
::���飺����
sc config Spooler start= DISABLED
sc stop Spooler

::���ƣ�RemoteRegistry
::��ʾ��Remote Registry
::������ʹԶ���û����޸Ĵ˼�����ϵ�ע������á�����˷�����ֹ��ֻ�д˼�����ϵ��û������޸�ע�������˷��񱻽��ã��κ��������ķ����޷�������
::���飺��ȫ���գ�����
sc config RemoteRegistry start= DISABLED
sc stop RemoteRegistry

::���ƣ�SessionEnv
::��ʾ��Remote Desktop Configuration
::������Զ���������÷���(RDCS)������Ҫ SYSTEM �����ĵ�����Զ����������Զ��������ص����úͻỰά�������Щ����ÿ�Ự��ʱ�ļ��С�RD ����� RD ֤�顣
::���飺�Զ�����
sc config SessionEnv start= Auto
sc start SessionEnv

::���ƣ�CertPropSvc
::��ʾ��Certificate Propagation
::���������û�֤��͸�֤������ܿ����Ƶ���ǰ�û���֤��洢��������ܿ���ʱ���뵽���ܿ��������У�������Ҫʱ��װ���ܿ����弴��΢����������
::���飺����
sc config CertPropSvc start= DISABLED
sc stop CertPropSvc

::���ƣ�DPS
::��ʾ��Diagnostic Policy Service
::��ϲ��Է��������� Windows ����������⡢���ѽ��ͽ������������÷���ֹͣ����Ͻ��������С�
::���飺����������
sc config DPS start= DISABLED
sc stop DPS

::���ƣ�WdiServiceHost
::��ʾ��Diagnostic Service Host
::��Ϸ�����������ϲ��Է�������������Ҫ�ڱ��ط��������������е���ϡ����ֹͣ�÷����������ڸ÷�����κ���Ͻ��������С�
::���飺����������
sc config WdiServiceHost start= DISABLED
sc stop WdiServiceHost

::���ƣ�fdPHost
::��ʾ��Function Discovery Provider Host
::������FDPHOST ������ع��ܷ���(FD)���緢���ṩ������Щ FD �ṩ����Ϊ�򵥷�����Э��(SSDP)�� Web ������(WS-D)Э���ṩ���緢�ַ���ʹ�� FD ʱֹͣ����� FDPHOST ���񽫽�����ЩЭ������緢�֡����÷��񲻿���ʱ��ʹ�� FD ��������Щ����Э�����������޷��ҵ�����������Դ��
::���飺���������
sc config fdPHost start= DISABLED
sc stop fdPHost

::���ƣ�FDResPub
::��ʾ��Function Discovery Resource Publication
::�����������ü�����Լ����ӵ��ü��������Դ���Ա��ܹ��������Ϸ�����Щ��Դ������÷���ֹͣ�������ٷ���������Դ�������ϵ�������������޷�������Щ��Դ��
::���飺���������
sc config FDResPub start= DISABLED
sc stop FDResPub

::���ƣ�swprv
::��ʾ��Microsoft Software Shadow Copy Provider
::�����������Ӱ���Ʒ��������Ļ�������ľ�Ӱ����������÷���ֹͣ�����޷������������ľ�Ӱ����������÷��񱻽��ã��κ��������ķ����޷�������
::���飺���ã�һ�㲻���õ�
sc config swprv start= DISABLED
sc stop swprv

::���ƣ�MMCSS
::��ʾ��Multimedia Class Scheduler
::����������ϵͳ��Χ�ڵ��������ȼ����ù�����������ȼ�������Ҫ�����ڶ�ý��Ӧ�ó�������˷���ֹͣ����������ʹ����Ĭ�ϵ����ȼ���
::���飺������һ�������õ�������
sc config MMCSS start= DISABLED
sc stop MMCSS

::���ƣ�wercplsupport
::��ʾ��Problem Reports and Solutions Control Panel Support
::�������˷���Ϊ�鿴�����ͺ�ɾ�������ⱨ��ͽ����������������ϵͳ�����ⱨ���ṩ֧�֡�
::���飺����������
sc config wercplsupport start= DISABLED
sc stop wercplsupport

::���ƣ�ShellHWDetection
::��ʾ��Shell Hardware Detection
::������Ϊ�Զ�����Ӳ���¼��ṩ֪ͨ��
::���飺����������
sc config ShellHWDetection start= DISABLED
sc stop ShellHWDetection

::���ƣ�SCardSvr
::��ʾ��Smart Card
::����������˼���������ܿ���ȡ�����ʡ�����˷�����ֹ���˼�������޷�ȡ�����ܿ�������˷��񱻽��ã��κ��������ķ����޷�������
::���飺����
sc config SCardSvr start= DISABLED
sc stop SCardSvr

::���ƣ�SCPolicySvc
::��ʾ��Smart Card Removal Policy
::����������ϵͳ����Ϊ�Ƴ����ܿ�ʱ�����û�����
::���飺����
sc config SCPolicySvc start= DISABLED
sc stop SCPolicySvc

::���ƣ�TBS
::��ʾ��TPM Base Services
::������������������ε�ƽ̨ģ��(TPM)����ģ����ϵͳ�����Ӧ�ó����ṩ����Ӳ���ļ��ܷ�������˷�����ֹͣ����ã���Ӧ�ó����޷�ʹ�� TPM ��������Կ��
::���飺����
sc config TBS start= DISABLED
sc stop TBS

::���ƣ�AudioSrv
::��ʾ��Windows Audio
::������������� Windows �ĳ������Ƶ������˷���ֹͣ����Ƶ�豸��Ч����������������������˷��񱻽��ã��κ��������ķ����޷�����
::���飺����
sc config AudioSrv start= DISABLED
sc stop AudioSrv

::���ƣ�AudioEndpointBuilder
::��ʾ��Windows Audio Endpoint Builder
::���������� Windows ��Ƶ�������Ƶ�豸������˷���ֹͣ����Ƶ�豸��Ч����������������������˷��񱻽��ã��κ��������ķ����޷�����
::���飺����
sc config AudioEndpointBuilder start= DISABLED
sc stop AudioEndpointBuilder

::���ƣ�WerSvc
::��ʾ��Windows Error Reporting Service
::�����������ڳ���ֹͣ���л�ֹͣ��Ӧʱ������󣬲������ṩ���н��������������Ϊ��Ϻ��޸�����������־������˷���ֹͣ������󱨸潫�޷���ȷ���У����ҿ��ܲ���ʾ��Ϸ�����޸��Ľ����
::���飺����
sc config WerSvc start= DISABLED
sc stop WerSvc

::���ƣ�Wecsvc
::��ʾ��Windows Event Collector
::�������˷��񽫹����֧��WS-Management Э���Զ��Դ���¼������ö��ġ������Windows Vista�¼���־��Ӳ���Լ�����IPMI ���¼�Դ���÷���ת�����¼��洢�ڱ��ػ��־�С����ֹͣ����ô˷��񣬽��޷������¼����ģ������޷�����ת�����¼���
::���飺����
sc config Wecsvc start= DISABLED
sc stop Wecsvc
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo ϵͳ�����Ż���ɡ�
ping -n 5 127.0.0.1>nul
goto PrintInfo

:PrintInfo
cls
color 0e
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
