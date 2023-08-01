# -*- coding: utf8 -*-
"""
cmd exp:
python CMonitor.py config --acid=id --ackey=key

python CMonitor.py QueryMetric --Project=acs_rds --Metric=MySQL_NetworkInNew --Dimensions='{"instanceId":"rm-wz9zkvp0y57a5l5t7"}' --RegionId=cn-shenzhen --ResourceOwnerAccount=labs00991@aliyun-inc.com

python CMonitor.py DescribeHealthStatus --LoadBalancerId=lbwz93t1ya8tnprzqaoh --ServerId=i-94umgcuje  --ResourceOwnerAccount=labs00991@aliyun-inc.com
"""
__author__ = 'Lu Wen Chang<lwc@jiagouyun.com>'

import sys
import os
import re
import urllib, urllib2
import base64
import hmac
from hashlib import sha1
import ConfigParser
import time
import uuid
import traceback
import json
import platform
import copy
#保存id和key的文本路径

is_Test=False

CONFIGFILE = '/etc/.rdsjm'
sysstr = platform.system()
if(sysstr =="Windows"):
    CONFIGFILE = 'c:/.rdsjm'
#默认连接阿里监控中心服务器地址
OBJ_HOST = "metrics.aliyuncs.com"


#配置中的默认config
DEFAULTCONFIG="config"

#保存id和key的文本中的section
CONFIGSECTION ='user'

DEFAUTL_Time_Info={
    'acs_ecs':{
        'puttime':60,
        'StatisticsCycle':[300,3600]
    },
    'acs_rds':{
        'puttime':300,
        'StatisticsCycle':[900,3600]
    },
    'acs_slb':{
        'puttime':60,
        'StatisticsCycle':[300,900,3600]
    },
    'acs_ocs':{
        'puttime':60,
        'StatisticsCycle':[300,900,3600]
    },
    'acs_oss':{
        'puttime':3600,
        'StatisticsCycle':[3600]
    },
    'acs_vpc_eip':{
        'puttime':60,
        'StatisticsCycle':[300,900,3600]
    },
    'acs_kvstore':{
        'puttime':60,
        'StatisticsCycle':[300,900,3600]
    },
    'acs_mns':{
        'puttime':300,
        'StatisticsCycle':[900,3600]
    },
    'acs_cdn':{
        'puttime':300,
        'StatisticsCycle':[300,900,3600]
    },
    'acs_ads':{
        'puttime':60,
        'StatisticsCycle':[300,900,3600]
    }
}

#AccessId
ID = ""

#AccessKey
KEY = ""

class Aliproducts(object):

    def __init__(self,**kwargs):
        self.__access_key_id = kwargs["id"]
        self.__access_key_secret = kwargs["key"]
        self._server_address = ""
        self._version = ""
        self._Timestamp = False
        self._TimeStamp = False


    def __percent_encode(self,str):
        #res = urllib.quote(str.decode(sys.stdin.encoding).encode('utf8'), '')
        #注意,因zabbix中sys.stdin.encoding无法获取到值,所以将值固定写死。
        res = urllib.quote(str.decode("UTF-8").encode('utf8'), '')
        res = res.replace('+', '%20')
        res = res.replace('*', '%2A')
        res = res.replace('%7E', '~')
        return res

    def __compute_signature(self,parameters, access_key_secret):
        sortedParameters = sorted(parameters.items(), key=lambda parameters: parameters[0])

        canonicalizedQueryString = ''
        for (k,v) in sortedParameters:
            canonicalizedQueryString += '&' + self.__percent_encode(k) + '=' + self.__percent_encode(v)

        stringToSign = 'GET&%2F&' + self.__percent_encode(canonicalizedQueryString[1:])

        h = hmac.new(access_key_secret + "&", stringToSign, sha1)
        signature = base64.encodestring(h.digest()).strip()
        return signature

    def __compose_url(self,user_params):
        timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())

        parameters = {
                'Format'        : 'JSON',
                'Version'       : self._version,
                'AccessKeyId'   : self.__access_key_id,
                'SignatureVersion'  : '1.0',
                'SignatureMethod'   : 'HMAC-SHA1',
                'SignatureNonce'    : str(uuid.uuid1()),
                'Timestamp'         : timestamp,
                'TimeStamp'         : timestamp,
        }

        for key in user_params.keys():
            parameters[key] = user_params[key]

        if not self._Timestamp:
            parameters.pop('Timestamp')
        else:
            parameters.pop('TimeStamp')

        signature = self.__compute_signature(parameters, self.__access_key_secret)
        parameters['Signature'] = signature
        if is_Test:
            print json.dumps(parameters,indent=4)
        url = self._server_address + "/?" + urllib.urlencode(parameters)
        return url

    def _get_utoken(self):
        return str(uuid.uuid1())

    #发送请求并返回请求结果
    def _make_request(self,user_params, quiet=False):

        url = self.__compose_url(user_params)
        if is_Test:
            print url
        request = urllib2.Request(url)
        try:
            conn = urllib2.urlopen(request)
            response = conn.read()
        except urllib2.HTTPError, e:
            print json.dumps(json.loads(e.read().strip()),indent=4)
            sys.exit()

        #make json output pretty, this code is copied from json.tool
        try:
            if response=="":
                print "API does not return data."
                sys.exit()
            obj = json.loads(response)
            if quiet:
                return obj
        except ValueError, e:
            print traceback.format_exc()
            sys.exit()


class SLB(Aliproducts):
    def __init__(self,**kwargs):
        Aliproducts.__init__(self,**kwargs)
        self._server_address = 'https://slb.aliyuncs.com'
        self._version = '2014-05-15'
        self.__access_key_id = kwargs["id"]
        self.__access_key_secret = kwargs["key"]
        self._TimeStamp = True

    def DescribeLoadBalancers(self,Parameter={}):
        user_params = {}
        user_params['Action'] = 'DescribeLoadBalancers'
        user_params['RegionId'] = Parameter['RegionId']
        if 'ResourceOwnerAccount' in Parameter.keys():
            user_params['ResourceOwnerAccount'] = Parameter['ResourceOwnerAccount']
        res = self._make_request(user_params, True)
        return res

    def DescribeHealthStatus(self,Parameter={}):
        user_params = {}
        user_params['Action'] = 'DescribeHealthStatus'
        user_params['LoadBalancerId'] = Parameter['LoadBalancerId']
        if Parameter.get('ListenerPort',None):
            user_params['ListenerPort'] = Parameter['ListenerPort']
        if 'ResourceOwnerAccount' in Parameter.keys():
            user_params['ResourceOwnerAccount'] = Parameter['ResourceOwnerAccount']
        res = self._make_request(user_params, True)
        return res


class CloudMonitor(Aliproducts):
    def __init__(self,**kwargs):
        Aliproducts.__init__(self,**kwargs)
        self._server_address = 'http://metrics.aliyuncs.com'
        self._version = '2015-10-20'
        self.__access_key_id = kwargs["id"]
        self.__access_key_secret = kwargs["key"]
        self._Timestamp = True

    def QueryMetric(self,Parameter={}):
        """
        查询监控
        :param Project:名字空间,表明监控数据所属产品,如 "acs_ecs","acs_rds"等,可用命名空间
        :param Metric:监控项名称,可用名称,参考Metric List
        :param Dimensions:定位监控项数据位置的维度 dimensions不支持批量传入
        :param StartTime: format数据，如2015-10-20 00:00:00
        :param EndTime:format数据，如2015-10-20 00:00:00
        :param Period:时间间隔，统一用秒数来计算,例如 60, 300, 900。 如果不填写,则按照注册监控项时申明的上报 周期来查询原始数据;如果填写统计周期,则 查询对应的统计数据
        :param Page:
        :param Length:
        :param ResourceOwnerAccount:
        :return:
        """
        user_params = {}
        user_params['Action'] = 'QueryMetric'
        user_params['Project'] = Parameter['Project']
        user_params['Metric'] = Parameter['Metric']
        user_params['StartTime'] = Parameter['StartTime']
        user_params['EndTime'] = Parameter['EndTime']
        user_params['Dimensions'] = Parameter['Dimensions']
        user_params['Page'] = Parameter['Page']
        user_params['Length'] = Parameter['Length']

        time_sec=DEFAUTL_Time_Info[Parameter['Project']]['puttime']
        user_params['Period']=Parameter.get('Period',str(time_sec))

        if 'ResourceOwnerAccount' in Parameter.keys():
            user_params['ResourceOwnerAccount'] = Parameter['ResourceOwnerAccount']

        res = self._make_request(user_params, True)
        lsList=res['Datapoints']['Datapoint']

        if is_Test:
            if len(lsList)!=0:
                for obj in lsList:
                    timestamp=obj['timestamp']
                    print time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(timestamp/1000))

        return res


class CMonitorPerformance():
    def __init__(self,**kwargs):
        self.cMonitor=CloudMonitor(**kwargs)
        self.CMD_LIST={}
        self.setup_cmdlist()

    def setup_cmdlist(self):
        #相关操作
        self.CMD_LIST['querymetric'] = self.QueryMetric

    def checkNone(self,param={},nameList=[]):
        """
        :param param:
        :param nameList:
        :param setType:
        :return:
        """
        for parName in nameList:
            if not parName in param.keys():
                print 'Missing parameter: %s.' % parName
                sys.exit(1)

    def CheckTime(self,Parameter={}):
        Project=Parameter.get('Project',None)
        time_sec=DEFAUTL_Time_Info[Project]['StatisticsCycle'][0]
        end_time_sec=int(time.time())
        start_time_sec=end_time_sec-int(time_sec)-60*10

        EndTime=Parameter.get('EndTime',time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(end_time_sec))).replace('T',' ')

        StartTime=Parameter.get('StartTime',time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(start_time_sec))).replace('T',' ')
        if is_Test:
            print "StartTime-->",type(StartTime),StartTime
            print "EndTime-->",type(EndTime),EndTime
        return (StartTime,EndTime)



    def QueryMetric(self,Parameter,Key=None):

        (StartTime,EndTime)=self.CheckTime(Parameter)

        self.checkNone(Parameter,['Project','Metric','Dimensions'])
        Parameter['StartTime']=StartTime
        Parameter['EndTime']=EndTime

        Page=Parameter.get('Page','1')
        Parameter['Page']=Page

        Length=Parameter.get('Length','1000')
        Parameter['Length']=Length



        res=self.cMonitor.QueryMetric(Parameter)
        if res['Success']==False:
            print json.dumps(res,indent=4)
            sys.exit()
        if Key:
            DatapointList=res['Datapoints']['Datapoint']
            if len(DatapointList)==0:
                print ""
                sys.exit()

            newData={}
            maxTime=0
            for obj in DatapointList:
                timestamp=obj['timestamp']
                newData[timestamp/1000]=obj
            maxTime=max(newData.keys())

            lastData=newData[maxTime]
            parmList=lastData.keys()
            if not Key in parmList:
                print "Does not exist Keywords: %s." % Key
                sys.exit()

            print lastData[Key]
            sys.exit()

        else:

            print json.dumps(res,indent=4)



class SLBPerformance():
    def __init__(self,**kwargs):
        self.slb=SLB(**kwargs)
        self.CMD_LIST={}
        self.setup_cmdlist()

    def setup_cmdlist(self):
        #相关操作
        self.CMD_LIST['describeloadbalancers'] = self.DescribeLoadBalancers
        self.CMD_LIST['describehealthstatus'] = self.DescribeHealthStatus

    def DescribeLoadBalancers(self,Parameter,Key=None):
        res=self.slb.DescribeLoadBalancers(Parameter)
        print json.dumps(res,indent=4)
        sys.exit()

    def DescribeHealthStatus(self,Parameter,Key=None):
        res=self.slb.DescribeHealthStatus(Parameter)
        newData = {}

        for x in res.get('BackendServers',{}).get('BackendServer',[]):
            ecs_id = x.get('ServerId',None)
            newData[ecs_id] = x.get('ServerHealthStatus',None)
        if Key:
            print newData.get(Key,None)
        else:
            print "{"
            print '    "data":['
            BackendServer = res.get('BackendServers',{}).get('BackendServer',[])
            for i in range(len(BackendServer)):
                x=BackendServer[i]
                if i+1==len(BackendServer):
       #             print "        %s" % json.dumps(x,ensure_ascii=False).replace('ServerId','{#ServerId}').replace('ServerHealthStatus','{#ServerHealthStatus}')
                    print "        %s" % json.dumps(x,ensure_ascii=False).replace('ServerId','{#ID}').replace('ServerHealthStatus','{#STATUS}')
                else:
      #              print "        %s," % json.dumps(x,ensure_ascii=False).replace('ServerId','{#ServerId}').replace('ServerHealthStatus','{#ServerHealthStatus}')
                    print "        %s," % json.dumps(x,ensure_ascii=False).replace('ServerId','{#ID}').replace('ServerHealthStatus','{#STATUS}')

            print "    ]"
            print "}"
            """
            newData = {
                'data':res.get('BackendServers',{}).get('BackendServer',[])
            }
            print json.dumps(newData,indent=4,ensure_ascii=False)
            """
        sys.exit()


class Configure():
    def __init__(self):
        pass

    #将id和key保存到文件
    def set_configure(self,options):
        try:
            parm={}
            boolPD=False
            curSec=""
            boolID=False
            sectionName=None
            parmList=options.keys()
            config = ConfigParser.RawConfigParser()
            if os.path.exists(CONFIGFILE):
                config.read(CONFIGFILE)
                #如果没有获取到【config】则表明配置文件中没有，需要添加
                section=config.sections()
                if DEFAULTCONFIG in section:
                    sectionName=config.get(DEFAULTCONFIG,DEFAULTCONFIG)
                else:
                    config.add_section(DEFAULTCONFIG)
                    #指定默认的【config】---->config指向
                    config.set(DEFAULTCONFIG, 'config',CONFIGSECTION)
                    #配置 日志路径
                    config.add_section(CONFIGSECTION)
                    sectionName=CONFIGSECTION
            else:
                config.add_section(DEFAULTCONFIG)
                #指定默认的【config】---->config指向
                config.set(DEFAULTCONFIG, 'config',CONFIGSECTION)
                #配置 日志路径
                config.add_section(CONFIGSECTION)
                sectionName=CONFIGSECTION


            if 'host' in parmList:
                config.set(sectionName, 'host', options['host'])
            if 'acid'  in parmList:
                config.set(sectionName, 'accessid', options['acid'])
            if 'ackey'  in parmList:
                jm_key='[h6T|#m}DyK!oc=HG%<-' + options['ackey']
                accesskey=jm_key.encode('base64')
                config.set(sectionName, 'accesskey', accesskey)
            if 'format' in parmList:
                options['format']=self.checkOutputType(options['format'])
                config.set(sectionName, 'output', options.Format)

            #配置 用户的输出文本路径
            if 'outputfile' in parmList:
                config.set(sectionName, 'outputfile', options['outputfile'])
                if options['outputfile']!="":
                    self.checkFile(options['outputfile'])
            #如果用户输入了RegionId，则需呀将该ID保存
            if 'RegionId' in parmList:
                config.set(sectionName, 'RegionId', options['RegionId'])

            #保存用户的showURL
            if 'showurl'  in parmList:
                config.set(sectionName, 'showurl', options['showurl'])
            self.checkFile(CONFIGFILE)
            cfgfile = open(CONFIGFILE, 'w')
            config.write(cfgfile)
            print "Your configuration is saved into %s." % CONFIGFILE


        except Exception:
            print traceback.format_exc()
            sys.exit(1)


    #如果id和key为空，则提取文本中的参数
    def get_configure(self,Parameter):
        config = ConfigParser.ConfigParser()
        try:
            config.read(CONFIGFILE)
            try:
                OBJ_HOST = config.get(CONFIGSECTION, 'host')
            except Exception:
                pass
            section=config.sections()
            if not 'config' in Parameter.keys():
                config_Section=config.get(DEFAULTCONFIG, 'config')
            else:
                config_Section=Parameter['config']
            ID = config.get(config_Section, 'accessid')
            jm_KEY = config.get(config_Section, 'accesskey').decode('base64')
            KEY = jm_KEY.replace('[h6T|#m}DyK!oc=HG%<-','')
            if not  'acid' in Parameter.keys():
                Parameter['acid']=ID
            if not  'ackey' in Parameter.keys():
                Parameter['ackey']=KEY
            """
            if not 'host'  in Parameter.keys():
                Parameter['host'] = config.get(config_Section, 'host')
            """
            try:
                if not 'outputfile' in Parameter.keys():
                    Parameter['outputfile']=config.get(config_Section, 'outputfile')
                    if Parameter['outputfile']==None or Parameter['outputfile']=="":
                        Parameter['outputfile']=None
            except:
                pass
            try:
                #如果用户没有输入了RegionId，则从配置中获取
                if Parameter['RegionId'] ==None:
                    Parameter['RegionId']=config.get(config_Section, 'RegionId')
            except:
                pass

            try:
                if not 'showurl' in Parameter.keys():
                    Parameter['showurl']='false'
            except:
                pass
        except Exception,e:
            errorInfo=traceback.format_exc()
            print errorInfo
            if "acid" not in Parameter.keys() or "ackey" not in Parameter.keys():
                print "can't get accessid/accesskey, setup use : config --acid=accessid --ackey=accesskey"
                sys.exit(1)
        return Parameter

    def checkOutputType(self,output=None):
        ls=['json','text','table','xml']
        if output==None:
            return "json"
        else:
            if output in ls:
                return output
            else:
                info="The input parameter 'output' value is not correct, output only ['json','text','table','xml']"
                print info
                sys.exit(1)

    def checkFile(self,filePath):
        """
        检查ecs的日志文件是否存在如果不存在则根据配置文件创建创建日志文件
        :return:
        """
        try:
            (ml,fileName)=os.path.split(filePath)
            if not os.path.isfile(filePath):
                if  ml!=None and ml!="":
                    if not os.path.exists(ml):
                        os.makedirs(ml)
                if fileName!=None:
                    file1= open(filePath,'w+')
                    file1.close()
                return
        except:
            info="Create a file or folder fail. Path: ",filePath
            print info
            sys.exit(1)



    def changeFilePath(self,filePath):
        #转换绝对路径为符合系统要求的路径格式
        try:
            a=filePath.split(os.path.sep)
            fp=a[0]
            for i in range(1,len(a)):
                fp=fp+os.path.sep+a[i]
            return fp
        except:
            info= "Conversion path format error, the original path format:",filePath
            print info
            sys.exit(1)


def getParm():

    PARAM_PTN = re.compile(r'([A-Za-z][A-Za-z\-]+)')
    OPT_PTN = re.compile(r'--([A-Za-z\-]+)=(.*)')

    argv=sys.argv
    argv.append('')
    opts = {}
    action=""
    for kv in argv[1:]:
        m = PARAM_PTN.match(kv)
        if m:
            val = m.groups()
            action=val[0]
            continue
        m = OPT_PTN.match(kv)
        if m:
            key, val = m.groups()
            opts[key] = val
    return action, opts


if __name__ == '__main__':
    action, opts=getParm()
    if action=="":
        print 'Please input Action!'
        sys.exit(1)

    config=Configure()
    if action.lower() == 'config':
        config.set_configure(opts)
        sys.exit(1)

    opts=config.get_configure(opts)

    if action == 'QueryMetric':
        CMPerformance=CMonitorPerformance(id=opts['acid'],key=opts['ackey'])
        if action.lower() not in CMPerformance.CMD_LIST.keys():
            message="unsupported command : %s " % action
            print message
            sys.exit(1)

        KeyList=[]
        if 'Metric' in opts.keys():
            KeyList=opts['Metric'].split(":")
            opts['Metric']=KeyList[0]

        Key=None
        if len(KeyList)>1:
            Key=KeyList[1]
        CMPerformance.CMD_LIST[action.lower()](opts,Key)


    elif action == 'DescribeHealthStatus':

        slbPerm=SLBPerformance(id=opts['acid'],key=opts['ackey'])

        slbPerm.CMD_LIST[action.lower()](opts,opts.get('ServerId',None))
