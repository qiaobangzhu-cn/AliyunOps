# -*- coding:utf-8 -*-

# author : ruijie.qiao
# email  : ruijie.qiao@gmail.com
# date   : 2013-8-18
# modify : 2015-7-30

import sys
import os
import re
import urllib
import urllib2
import base64
import hmac
import hashlib
from hashlib import sha1
import ConfigParser
from optparse import OptionParser
from xml.dom import minidom
import time
import datetime
import uuid
import traceback
import json
import StringIO
import platform
# 性能参数表
PERFORMANCELIST = "MySQL_NetworkTraffic,MySQL_QPSTPS,MySQL_Sessions,MySQL_InnoDBBufferRatio,\
MySQL_InnoDBDataReadWriten,MySQL_InnoDBLogRequests,MySQL_InnoDBLogWrites,MySQL_TempDiskTableCreates,\
MySQL_MyISAMKeyBufferRatio,MySQL_MyISAMKeyReadWrites,MySQL_COMDML,MySQL_RowDML,MySQL_MemCpuUsage,\
MySQL_IOPS,MySQL_DetailedSpaceUsage,slavestat,SQLServer_Transactions,SQLServer_Sessions,\
SQLServer_BufferHit,SQLServer_FullScans,SQLServer_SQLCompilations,SQLServer_CheckPoint,\
SQLServer_Logins,SQLServer_LockTimeout,SQLServer_Deadlock,SQLServer_LockWaits,SQLServer_NetworkTraffic,\
SQLServer_QPS,SQLServer_InstanceCPUUsage,SQLServer_IOPS,SQLServer_DetailedSpaceUsage"

# 监控宝全局变量
varDescribeDBInstanceAttribute = {}
varDescribeDBInstancePerformance = {}
varDescribeDBInstances = {}

# 保存id和key的文本路径

CONFIGFILE = '/etc/.rdsjm'
sysstr = platform.system()
if(sysstr == "Windows"):
    CONFIGFILE = 'c:/.rdsjm'

# 默认连接阿里云RDS的服务器地址
OBJ_HOST = "rds.aliyuncs.com"


# 配置中的默认config
DEFAULTCONFIG = "config"

# 保存id和key的文本中的section
CONFIGSECTION = 'user'

# AccessId
ID = ""

# AccessKey
KEY = ""


class Aliproducts(object):

    def __init__(self, **kwargs):
        self.__access_key_id = kwargs["id"]
        self.__access_key_secret = kwargs["key"]
        self._server_address = ""
        self._version = ""

    def __percent_encode(self, str):
        #res = urllib.quote(str.decode(sys.stdin.encoding).encode('utf8'), '')
        # 注意,因zabbix中sys.stdin.encoding无法获取到值,所以将值固定写死。
        res = urllib.quote(str.decode("UTF-8").encode('utf8'), '')
        res = res.replace('+', '%20')
        res = res.replace('*', '%2A')
        res = res.replace('%7E', '~')
        return res

    def __compute_signature(self, parameters, access_key_secret):
        sortedParameters = sorted(parameters.items(), key=lambda parameters: parameters[0])

        canonicalizedQueryString = ''
        for (k, v) in sortedParameters:
            canonicalizedQueryString += '&' + self.__percent_encode(k) + '=' + self.__percent_encode(v)

        stringToSign = 'GET&%2F&' + self.__percent_encode(canonicalizedQueryString[1:])

        h = hmac.new(access_key_secret + "&", stringToSign, sha1)
        signature = base64.encodestring(h.digest()).strip()
        return signature

    def __compose_url(self, user_params):
        timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

        parameters = {
            'Format': 'JSON',
            'Version': self._version,
            'AccessKeyId': self.__access_key_id,
            'SignatureVersion': '1.0',
            'SignatureMethod': 'HMAC-SHA1',
            'SignatureNonce': str(uuid.uuid1()),
            'TimeStamp': timestamp,
        }

        for key in user_params.keys():
            parameters[key] = user_params[key]

        signature = self.__compute_signature(parameters, self.__access_key_secret)
        parameters['Signature'] = signature
        # print json.dumps(parameters,indent=4)
        url = self._server_address + "/?" + urllib.urlencode(parameters)
        return url

    def _get_utoken(self):
        return str(uuid.uuid1())

    # 发送请求并返回请求结果
    def _make_request(self, user_params, quiet=False):

        url = self.__compose_url(user_params)
        request = urllib2.Request(url)
        try:
            conn = urllib2.urlopen(request)
            response = conn.read()
        except urllib2.HTTPError, e:
            print json.dumps(json.loads(e.read().strip()), indent=4)
            sys.exit()

        # make json output pretty, this code is copied from json.tool
        try:
            if response == "":
                print "API does not return data."
                sys.exit()
            obj = json.loads(response)
            if quiet:
                return obj
        except ValueError, e:
            print traceback.format_exc()
            sys.exit()


class Rds(Aliproducts):

    def __init__(self, **kwargs):
        Aliproducts.__init__(self, **kwargs)
        self._server_address = 'https://rds.aliyuncs.com'
        self._version = '2014-08-15'
        self.__access_key_id = kwargs["id"]
        self.__access_key_secret = kwargs["key"]

    def get_DescribeDBInstances(self, RegionId, PageNumber="1", ResourceOwnerAccount=None):
        """
        查询RDS实例列表
        :return:
        """
        user_params = {}
        user_params['Action'] = 'DescribeDBInstances'
        user_params['RegionId'] = RegionId
        user_params['PageSize'] = "100"
        user_params['PageNumber'] = PageNumber
        if ResourceOwnerAccount:
            user_params['ResourceOwnerAccount'] = ResourceOwnerAccount
        res = self._make_request(user_params, True)
        return res

    def get_DescribeDBInstanceAttribute(self, DBInstanceId, ResourceOwnerAccount=None):
        """
        查询RDS实例详情获
        :return:
        """
        user_params = {}
        user_params['Action'] = 'DescribeDBInstanceAttribute'
        user_params['DBInstanceId'] = DBInstanceId
        if ResourceOwnerAccount:
            user_params['ResourceOwnerAccount'] = ResourceOwnerAccount
        res = self._make_request(user_params, True)
        return res

    def get_DescribeDBInstancePerformance(self, DBInstanceId, Key, StartTime, EndTime, ResourceOwnerAccount=None):
        """
        查询RDS性能
        :return:
        """
        user_params = {}
        user_params['Action'] = 'DescribeDBInstancePerformance'
        user_params['DBInstanceId'] = DBInstanceId
        if Key == "all":
            Key = PERFORMANCELIST
        user_params['Key'] = Key
        user_params['StartTime'] = StartTime
        user_params['EndTime'] = EndTime
        if ResourceOwnerAccount:
            user_params['ResourceOwnerAccount'] = ResourceOwnerAccount
        res = self._make_request(user_params, True)
        return res


class RDSPerformance():

    def __init__(self, **kwargs):
        self.rds = Rds(**kwargs)
        self.CMD_LIST = {}
        self.setup_cmdlist()
        self.KEYLIST = {
            'MySQL': {
                'MySQL_NetworkTraffic': [
                    [u'MySQL 实例平均每秒钟的输入流量', 'KB'],
                    [u'MySQL 实例平均每秒钟的输出流量。单位为 KB', 'KB']
                ],
                'MySQL_QPSTPS': [
                    [u'平均每秒 SQL 语句执行次数', ''],
                    [u'平均每秒事务数', '']
                ],
                'MySQL_Sessions': [
                    [u'当前活跃连接数', ''],
                    [u'当前总连接数', '']
                ],
                'MySQL_InnoDBBufferRatio': [
                    [u'InnoDB 缓冲池的读命中率', ''],
                    [u'InnoDB 缓冲池的利用率', ''],
                    [u'InnoDB 缓冲池脏块的百分率', '']
                ],
                'MySQL_InnoDBDataReadWriten': [
                    [u'InnoDB 平均每秒钟读取的数据量.单位为 KB.', 'KB'],
                    [u'InnoDB 平均每秒钟写入的数据量.单位为 KB.', 'KB']
                ],
                'MySQL_InnoDBLogRequests': [
                    [u'平均每秒向 InnoDB 缓冲池的读次数', ''],
                    [u'平均每秒向 InnoDB 缓冲池的写次数', '']
                ],
                'MySQL_InnoDBLogWrites': [
                    [u'平均每秒日志写请求数', ''],
                    [u'平均每秒向日志文件的物理写次数', ''],
                    [u'平均每秒向日志文件完成的 fsync()写数量', '']
                ],
                'MySQL_TempDiskTableCreates': [
                    [u'MySQL 执行语句时在硬盘上自动创建的临时表的数量.', '']
                ],
                'MySQL_MyISAMKeyBufferRatio': [
                    [u'MyISAM 平均每秒 Key Buffer 利用率', ''],
                    [u'MyISAM 平均每秒 Key Buffer 读命中率', ''],
                    [u'MyISAM 平均每秒 Key Buffer 写命中率', '']
                ],
                'MySQL_MyISAMKeyReadWrites': [
                    [u'MyISAM 平均每秒钟从缓冲池中的读取次数', ''],
                    [u'MyISAM 平均每秒钟从缓冲池中的写入次数', ''],
                    [u'MyISAM 平均每秒钟从硬盘上读取的次数', ''],
                    [u'MyISAM 平均每秒钟从硬盘上写入的次数', '']
                ],
                'MySQL_COMDML': [
                    [u'平均每秒 Delete 语句执行次数', ''],
                    [u'平均每秒 Insert 语句执行次数', ''],
                    [u'平均每秒 Insert_Select 语句执行次数', ''],
                    [u'平均每秒 Replace 语句执行次数', ''],
                    [u'平均每秒 Replace_Select 语句执行次数', ''],
                    [u'平均每秒 Select 语句执行次数', ''],
                    [u'平均每秒 Update 语句执行次数', '']
                ],
                'MySQL_RowDML': [
                    [u'平均每秒从 InnoDB 表读取的行数', ''],
                    [u'平均每秒从 InnoDB 表更新的行数', ''],
                    [u'平均每秒从 InnoDB 表删除的行数', ''],
                    [u'平均每秒从 InnoDB 表插入的行数', ''],
                    [u'平均每秒向日志文件的物理写次数', '']
                ],
                'MySQL_MemCpuUsage': [
                    [u'MySQL 实例 CPU 使用率(占操作系统总数)', ''],
                    [u'MySQL 实例内存使用率(占操作系统总数)', '']
                ],
                'MySQL_IOPS': [
                    [u'MySQL 实例的 IOPS(每秒 IO 请求次数)', '']
                ],
                'MySQL_DetailedSpaceUsage': [
                    [u'MySQL 实例空间占用', '']
                ]
            },

            'SQLServer': {
                'SQLServer_Transactions': [
                    [u'平均每秒事务数', '']
                ],
                'SQLServer_Sessions': [
                    [u'当前总连接数', '']
                ],
                'SQLServer_BufferHit': [
                    [u'缓存命中率', '']
                ],
                'SQLServer_FullScans': [
                    [u'平均每秒全表扫􏰀次数', '']
                ],
                'SQLServer_SQLCompilations': [
                    [u'每秒 SQL 编译', '']
                ],
                'SQLServer_CheckPoint': [
                    [u'每秒检查点写入 Page 数', '']
                ],
                'SQLServer_Logins': [
                    [u'每秒登录次数', '']
                ],
                'SQLServer_LockTimeout': [
                    [u'每秒锁超时次数', '']
                ],
                'SQLServer_Deadlock': [
                    [u'每秒死锁次数', '']
                ],
                'SQLServer_LockWaits': [
                    [u'每秒锁等待次数', '']
                ],
                'SQLServer_NetworkTraffic': [
                    [u'SQLServer 实例平均每秒钟的输入流量。单位为 KB', 'KB'],
                    [u'SQLServer 实例平均每秒钟的输出流量。单位为 KB。', 'KB']
                ],
                'SQLServer_QPS': [
                    [u'平均每秒 SQL 语句执行次数', '']
                ],
                'SQLServer_InstanceCPUUsage': [
                    [u'MSSQL 实例 CPU 使用率(占操作系统总数)', '']
                ],
                'SQLServer_IOPS': [
                    [u'MSSQL 实例的 IOPS(每秒 IO 请求次数)', '']
                ],
                'SQLServer_SpaceUsage': [
                    [u'MSSQL 实例空间占用', '']
                ]
            }
        }

    def setup_cmdlist(self):

        # 相关操作
        self.CMD_LIST['describedbinstanceattribute'] = self.DescribeDBInstanceAttribute
        self.CMD_LIST['describedbinstanceperformance'] = self.DescribeDBInstancePerformance
        # self.CMD_LIST['describedbinstances'] = self.DescribeDBInstances

    def DescribeDBInstances(self, Parameter):
        RegionId = Parameter['RegionId']
        PageNumber = "1"
        if 'PageNumber' in Parameter.keys():
            PageNumber = Parameter['PageNumber']
        res = self.rds.get_DescribeDBInstances(RegionId, PageNumber, Parameter["ResourceOwnerAccount"])
        global varDescribeDBInstances
        varDescribeDBInstances = json.dumps(res, indent=4)
        print varDescribeDBInstances

    def getTime(self, StartTime, EndTime):

        s1 = ""
        s2 = ""
        timeStampE = 0
        timeStampS = 0
        ST = 0
        ET = 0
        if EndTime != None:
            tE = EndTime[0:len(EndTime)-1]+":00"
            timeArrayE = time.strptime(tE.replace('T', ' '), "%Y-%m-%d %H:%M:%S")
            timeStampE = int(time.mktime(timeArrayE))
            timeStampE = timeStampE-60*60*8

        if StartTime != None:
            tS = tE = StartTime[0:len(StartTime)-1]+":00"
            timeArrayS = time.strptime(tS.replace('T', ' '), "%Y-%m-%d %H:%M:%S")
            timeStampS = int(time.mktime(timeArrayS))
            timeStampS = timeStampS-60*60*8

        if timeStampE == 0:
            ET = time.time()
        else:
            ET = timeStampE
        if timeStampS == 0:
            ST = ET-60*5  # 取间隔 5 分钟，即最新一条监控数据
        else:
            ST = timeStampS
        dateE = time.gmtime(ET)
        dateS = time.gmtime(ST)

        yearE = str(dateE.tm_year)
        if dateE.tm_mon > 9:
            monE = str(dateE.tm_mon)
        else:
            monE = "0"+str(dateE.tm_mon)

        if dateE.tm_mday > 9:
            mdayE = str(dateE.tm_mday)
        else:
            mdayE = "0"+str(dateE.tm_mday)

        if dateE.tm_hour > 9:
            hourE = str(dateE.tm_hour)
        else:
            hourE = "0"+str(dateE.tm_hour)

        if dateE.tm_min > 9:
            minE = str(dateE.tm_min)
        else:
            minE = "0"+str(dateE.tm_min)

        if dateE.tm_sec > 9:
            secE = str(dateE.tm_sec)
        else:
            secE = "0"+str(dateE.tm_sec)

        yearS = str(dateS.tm_year)
        if dateS.tm_mon > 9:
            monS = str(dateS.tm_mon)
        else:
            monS = "0"+str(dateS.tm_mon)

        if dateS.tm_mday > 9:
            mdayS = str(dateS.tm_mday)
        else:
            mdayS = "0"+str(dateS.tm_mday)

        if dateS.tm_hour > 9:
            hourS = str(dateS.tm_hour)
        else:
            hourS = "0"+str(dateS.tm_hour)
        if dateS.tm_min > 9:
            minS = str(dateS.tm_min)
        else:
            minS = "0"+str(dateS.tm_min)
        if dateS.tm_sec > 9:
            secS = str(dateS.tm_sec)
        else:
            secS = "0"+str(dateS.tm_sec)

        StartTime = yearS+"-"+monS+"-"+mdayS+"T"+hourS+":"+minS+"Z"
        EndTime = yearE+"-"+monE+"-"+mdayE+"T"+hourE+":"+minE+"Z"

        return (StartTime, EndTime)

    def DescribeDBInstanceAttribute(self, Parameter):
        # key = Parameter['Key']
        data = self.rds.get_DescribeDBInstanceAttribute(Parameter['DBInstanceId'], Parameter["ResourceOwnerAccount"])
        if len(data["Items"]["DBInstanceAttribute"]) == 0:
            print "There is no instance ID:%s" % Parameter['DBInstanceId']
            sys.exit()
        newData = data["Items"]["DBInstanceAttribute"][0]
        # if not key in newData.keys():
        #     print "Keywords not exist"
        #     sys.exit()
        global varDescribeDBInstanceAttribute
        varDescribeDBInstanceAttribute = newData
        # print varDescribeDBInstanceAttribute

    def checkNone(self, param={}, nameList=[]):
        """
        :param param:
        :param nameList:
        :param setType:
        :return:
        """
        for parName in nameList:
            if not parName in param.keys():
                print 'Please input ' + parName + '!'
                sys.exit(1)

    def getCLParm(self, keyStr):
        if keyStr == "all":
            return "all", None
        strList = keyStr.split('_')
        fKey = strList[0]+"_"+strList[1]
        if len(strList) > 2:
            subKey = ""
            for n in range(2, len(strList)):
                subKey = subKey+strList[n]+"_"
            subKey = subKey[0:len(subKey)-1]
        else:
            subKey = None
        return fKey, subKey

    def DescribeDBInstancePerformance(self, Parameter):
        self.checkNone(Parameter, ['DBInstanceId', 'Key'])

        if not 'StartTime' in Parameter.keys():
            Parameter['StartTime'] = None
        if not 'EndTime' in Parameter.keys():
            Parameter['EndTime'] = None

        (StartTime, EndTime) = self.getTime(Parameter['StartTime'], Parameter['EndTime'])
        (fKey, subKey) = self.getCLParm(Parameter['Key'])
        data = self.rds.get_DescribeDBInstancePerformance(Parameter['DBInstanceId'], fKey, StartTime, EndTime, Parameter["ResourceOwnerAccount"])
        global varDescribeDBInstancePerformance
        varDescribeDBInstancePerformance = data
        # if subKey != None:
        #     response = self.getRecentlyData(data, subKey, Parameter['Key'])
        #     # print response
        # else:
        #     pass
        #     # print json.dumps(data, indent=4)

    def getRecentlyData(self, lsDict, subKey, requestKey):
        if 'PerformanceKeys' in lsDict:
            if len(lsDict['PerformanceKeys']['PerformanceKey']) > 0:
                PerformanceKeyDict = lsDict['PerformanceKeys']['PerformanceKey'][0]
                Unit = PerformanceKeyDict['Unit']
                ValueFormat = PerformanceKeyDict['ValueFormat']
                PerformanceValue = PerformanceKeyDict['Values']['PerformanceValue']
                zjValue = PerformanceValue[len(PerformanceValue)-1]['Value']
                titleList = ValueFormat.split("&")
                valueList = zjValue.split("&")

                reDict = {}
                for n in range(0, len(titleList)):
                    reDict[titleList[n]] = valueList[n]
                reDict['Unit'] = Unit
                reDict['Key'] = requestKey

                jsonStr = json.dumps(reDict)
                # return jsonStr
                if subKey in reDict.keys():
                    return reDict[subKey]
                else:
                    return None
            else:
                print 'Error: The empty list'
        else:
            print'ErrorInfo---->', lsDict
        return None


class Configure():

    def __init__(self):
        pass

    # 将id和key保存到文件
    def set_configure(self, options):
        global CONFIGFILE
        try:
            parm = {}
            boolPD = False
            curSec = ""
            boolID = False
            sectionName = None
            parmList = options.keys()
            config = ConfigParser.RawConfigParser()
            if "configfile" in options:
                CONFIGFILE = options["configfile"]
            if os.path.exists(CONFIGFILE):
                config.read(CONFIGFILE)
                # 如果没有获取到【config】则表明配置文件中没有，需要添加
                section = config.sections()
                if DEFAULTCONFIG in section:
                    sectionName = config.get(DEFAULTCONFIG, DEFAULTCONFIG)
                else:
                    config.add_section(DEFAULTCONFIG)
                    # 指定默认的【config】---->config指向
                    config.set(DEFAULTCONFIG, 'config', CONFIGSECTION)
                    # 配置 日志路径
                    config.add_section(CONFIGSECTION)
                    sectionName = CONFIGSECTION
            else:
                config.add_section(DEFAULTCONFIG)
                # 指定默认的【config】---->config指向
                config.set(DEFAULTCONFIG, 'config', CONFIGSECTION)
                # 配置 日志路径
                config.add_section(CONFIGSECTION)
                sectionName = CONFIGSECTION

            if 'host' in parmList:
                config.set(sectionName, 'host', options['host'])
            if 'acid' in parmList:
                config.set(sectionName, 'accessid', options['acid'])
            if 'ackey' in parmList:
                jm_key = '[h6T|#m}DyK!oc=HG%<-' + options['ackey']
                accesskey = jm_key.encode('base64')
                config.set(sectionName, 'accesskey', accesskey)
            if 'format' in parmList:
                options['format'] = self.checkOutputType(options['format'])
                config.set(sectionName, 'output', options.Format)

            # 配置 用户的输出文本路径
            if 'outputfile' in parmList:
                config.set(sectionName, 'outputfile', options['outputfile'])
                if options['outputfile'] != "":
                    self.checkFile(options['outputfile'])
            # 如果用户输入了RegionId，则需呀将该ID保存
            if 'RegionId' in parmList:
                config.set(sectionName, 'RegionId', options['RegionId'])

            # 保存用户的showURL
            if 'showurl' in parmList:
                config.set(sectionName, 'showurl', options['showurl'])
            self.checkFile(CONFIGFILE)
            cfgfile = open(CONFIGFILE, 'w')
            config.write(cfgfile)
            print "Your configuration is saved into %s." % CONFIGFILE

        except Exception:
            print traceback.format_exc()
            sys.exit(1)

    # 如果id和key为空，则提取文本中的参数
    def get_configure(self, Parameter):
        config = ConfigParser.ConfigParser()
        try:
            if "configfile" in Parameter:
                CONFIGFILE = Parameter["configfile"]
            config.read(CONFIGFILE)
            try:
                OBJ_HOST = config.get(CONFIGSECTION, 'host')
            except Exception:
                pass
            section = config.sections()
            if not 'config' in Parameter.keys():
                config_Section = config.get(DEFAULTCONFIG, 'config')
            else:
                config_Section = Parameter['config']
            ID = config.get(config_Section, 'accessid')
            jm_KEY = config.get(config_Section, 'accesskey').decode('base64')
            KEY = jm_KEY.replace('[h6T|#m}DyK!oc=HG%<-', '')
            if not 'acid' in Parameter.keys():
                Parameter['acid'] = ID
            if not 'ackey' in Parameter.keys():
                Parameter['ackey'] = KEY
            """
            if not 'host'  in Parameter.keys():
                Parameter['host'] = config.get(config_Section, 'host')
            """
            try:
                if not 'outputfile' in Parameter.keys():
                    Parameter['outputfile'] = config.get(config_Section, 'outputfile')
                    if Parameter['outputfile'] == None or Parameter['outputfile'] == "":
                        Parameter['outputfile'] = None
            except:
                pass
            try:
                # 如果用户没有输入了RegionId，则从配置中获取
                if Parameter['RegionId'] == None:
                    Parameter['RegionId'] = config.get(config_Section, 'RegionId')
            except:
                pass

            try:
                pass
            except:
                if not 'showurl' in Parameter.keys():
                    Parameter['showurl'] = 'false'
        except Exception, e:
            errorInfo = traceback.format_exc()
            print errorInfo
            if "acid" not in Parameter.keys() or "ackey" not in Parameter.keys():
                print "can't get accessid/accesskey, setup use : config --id=accessid --key=accesskey"
                sys.exit(1)
        return Parameter

    def checkOutputType(self, output=None):
        ls = ['json', 'text', 'table', 'xml']
        if output == None:
            return "json"
        else:
            if output in ls:
                return output
            else:
                info = "The input parameter 'output' value is not correct, output only ['json','text','table','xml']"
                print info
                sys.exit(1)

    def checkFile(self, filePath):
        """
        检查ecs的日志文件是否存在如果不存在则根据配置文件创建创建日志文件
        :return:
        """
        try:
            (ml, fileName) = os.path.split(filePath)
            if not os.path.isfile(filePath):
                if ml != None and ml != "":
                    if not os.path.exists(ml):
                        os.makedirs(ml)
                if fileName != None:
                    file1 = open(filePath, 'w+')
                    file1.close()
                return
        except:
            info = "Create a file or folder fail. Path: ", filePath
            print info
            sys.exit(1)

    def changeFilePath(self, filePath):
        # 转换绝对路径为符合系统要求的路径格式
        try:
            a = filePath.split(os.path.sep)
            fp = a[0]
            for i in range(1, len(a)):
                fp = fp+os.path.sep+a[i]
            return fp
        except:
            info = "Conversion path format error, the original path format:", filePath
            print info
            sys.exit(1)


def reParameter(opts):
    try:
        # 存储Parameters信息
        parm = {}
        parm["acid"] = 'The user ID'
        parm["ackey"] = 'The user key'
        parm["Key"] = 'Key'
        parm["host"] = 'The host'
        parm["showurl"] = 'Whether to display the URL submission'
        parm["RegionId"] = 'Instance belongs to region ID'
        parm["Actions"] = 'List of authorized operation'
        parm["config"] = 'Save ID and KEY'
        parm["ZoneId"] = ''
        parm["outputfile"] = 'Returns the data output path'
        parm["configfile"] = 'Configuration file path'
        parm["DBInstanceId"] = ''
        parm["output"] = 'Control the format of the data returned:xml/json/table/text'
        parm["StartTime"] = 'Specify a start time'
        parm["EndTime"] = 'The specified end time'
        parm["PageNumber"] = 'PageNumber'
        parm["ResourceOwnerAccount"] = "Resource Owner Account"
        parmKeyList = parm.keys()
        parmKeyList.sort()

        # API中所有参数的小写
        lowerParm = {}
        for o in parmKeyList:
            lowerParm[o.lower()] = o

        # 最终参数
        Parameter = {}

        for o in opts.keys():
            lowerKey = o.lower()
            if lowerKey in lowerParm.keys():
                # 代码内部参数名
                zkey = lowerParm[lowerKey]
                # 参数值
                zValue = opts[o]
            else:
                # 代码内部参数名
                zkey = o
                # 参数值
                zValue = opts[o]
            Parameter[zkey] = zValue
        return Parameter
    except:
        info = traceback.format_exc()
        print info
        sys.exit(1)


def getCsParm(defaultStr, csDict):
    strParm = defaultStr[2:].lower()
    if strParm in csDict.keys():
        return "--"+csDict[strParm]
    else:
        return defaultStr


def getParm():

    PARAM_PTN = re.compile(r'([A-Za-z][A-Za-z\-]+)')
    OPT_PTN = re.compile(r'--([A-Za-z\-]+)=(.*)')

    argv = sys.argv
    argv.append('')
    opts = {}
    action = ""
    for kv in argv[1:]:
        m = PARAM_PTN.match(kv)
        if m:
            val = m.groups()
            action = val[0]
            continue
        m = OPT_PTN.match(kv)
        if m:
            key, val = m.groups()
            opts[key] = val
    return action, opts


if __name__ == '__main__':
    parser = OptionParser()
    action, opts = getParm()
    Parameter = reParameter(opts)
    if action == "":
        print 'Please input Action!'
        sys.exit(1)

    config = Configure()
    if action.lower() != 'config':
        Parameter = config.get_configure(Parameter)
    else:
        config.set_configure(Parameter)
        sys.exit(1)

    if not "ResourceOwnerAccount" in Parameter.keys():
        Parameter["ResourceOwnerAccount"] = None

    rdsPerformance = RDSPerformance(id=Parameter['acid'], key=Parameter['ackey'])

    if action.lower() not in rdsPerformance.CMD_LIST.keys():
        message = "unsupported command : %s " % action
        print message
        sys.exit(1)

    # print json.dumps(Parameter,indent=4)
    rdsPerformance.CMD_LIST[action.lower()](Parameter)