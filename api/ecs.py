# -*- coding:utf-8 -*-

##author : ruijie.qiao
##email  : ruijie.qiao@gmail.com
##date   : 2013-8-18
##modify : 2013-8-22

import sys
import os
import urllib, urllib2
import base64
import hmac
import hashlib
from hashlib import sha1
import ConfigParser
from optparse import OptionParser
from xml.dom import minidom
import time
import uuid
import StringIO

#保存id和key的文本路径
CONFIGFILE = os.path.expanduser('~') + '/.osscredentials'

#保存id和key的文本中的section
CONFIGSECTION = 'OSSCredentials'

#默认连接阿里云OSS的服务器地址
DEFAUL_HOST = "ecs.aliyuncs.com"
OSS_HOST = DEFAUL_HOST

#AccessId
ID = ""

#AccessKey
KEY = ""

#用于传入action调用哪个函数
CMD_LIST = {}

#标志位用于函数
mark = None

# ISO8601规范，注意使用GMT时间
timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
parameters = { \
        # 公共参数
        'Format'        : 'XML', \
        'Version'       : '2013-01-10', \
        'SignatureVersion'  : '1.0', \
        'SignatureMethod'   : 'HMAC-SHA1', \
        'SignatureNonce'    : str(uuid.uuid1()), \
        'TimeStamp'         : timestamp, \
\
        # 接口参数
        #'Action'            : 'DescribeZones', \
		'RegionId'          : 'cn-hangzhou-dg-a01', \
}

#如果id和key为空，则提取文本中的参数
def setup_crenditials():
    config = ConfigParser.ConfigParser()
    try:
        config.read(CONFIGFILE)
        global OSS_HOST
        global ID
        global KEY
        try:
            OSS_HOST = config.get(CONFIGSECTION, 'host')
        except Exception:
            OSS_HOST = DEFAUL_HOST 
        ID = config.get(CONFIGSECTION, 'accessid')
        KEY = config.get(CONFIGSECTION, 'accesskey')
        if options.accessid is not None:
            ID = options.accessid
        if options.accesskey is not None:
            KEY = options.accesskey
        if options.host is not None:
            OSS_HOST = options.host
    except Exception:
        if options.accessid is not None:
            ID = options.accessid
        if options.accesskey is not None:
            KEY = options.accesskey
        if options.host is not None:
            OSS_HOST = options.host

        if len(ID) == 0 or len(KEY) == 0:
            print "can't get accessid/accesskey, setup use : config --id=accessid --key=accesskey"
            sys.exit(1)

#将id和key保存到文件			
def cmd_configure():
    if options.accessid is None or options.accesskey is None:
        print "%s miss parameters, use --id=[accessid] --key=[accesskey] to specify id/key pair" % args[0]
        sys.exit(1) 
    config = ConfigParser.RawConfigParser()
    config.add_section(CONFIGSECTION)
    if options.host is not None:
        config.set(CONFIGSECTION, 'host', options.host)
    config.set(CONFIGSECTION, 'accessid', options.accessid)
    config.set(CONFIGSECTION, 'accesskey', options.accesskey)
    cfgfile = open(CONFIGFILE, 'w+')
    config.write(cfgfile)
    print "Your configuration is saved into %s ." % CONFIGFILE
    cfgfile.close()			
			
def percent_encode(str):
    # 使用urllib.quote编码后，将几个字符做替换即满足ECS API规定的编码规范
    res = urllib.quote(str.decode(sys.stdin.encoding).encode('utf8'), '')
    res = res.replace('+', '%20')
    res = res.replace('*', '%2A')
    res = res.replace('%7E', '~')
    return res

def compute_signature(parameters):
    # 将参数按Key的字典顺序排序
    sortedParameters = sorted(parameters.items(), key=lambda parameters: parameters[0])
	
    # 生成规范化请求字符串
    canonicalizedQueryString = ''
    for (k,v) in sortedParameters:
        canonicalizedQueryString += '&' + percent_encode(k) + '=' + percent_encode(v)

    # 生成用于计算签名的字符串 stringToSign
    stringToSign = 'GET&%2F&' + percent_encode(canonicalizedQueryString[1:])

    # 计算签名，注意accessKeySecret后面要加上字符'&'
    h = hmac.new(KEY + "&", stringToSign, sha1)
    signature = base64.encodestring(h.digest()).strip()
    return signature
	
def conServer(parameters):
    parameters['AccessKeyId'] = ID
    # 计算签名并把签名结果加入请求参数
    signature = compute_signature(parameters)
    parameters['Signature'] = signature
    # 发送请求
    url = "http://" + OSS_HOST + "/?" + urllib.urlencode(parameters)
    request = urllib2.Request(url)
    f = file('response.txt', 'w')
    try:
      conn = urllib2.urlopen(request)
      response = conn.read()
      print response
      f.write(response) 
      f.close()
    except urllib2.HTTPError, e:
      error_msg = e.read().strip()
      print error_msg
      f.write(error_msg) 
      f.close()
	  
def conServerXml(parameters):
    global mark
    parameters['AccessKeyId'] = ID
    # 计算签名并把签名结果加入请求参数
    signature = compute_signature(parameters)
    parameters['Signature'] = signature
    # 发送请求
    url = "http://" + OSS_HOST + "/?" + urllib.urlencode(parameters)
    request = urllib2.Request(url)
    response = None
    try:
      conn = urllib2.urlopen(request)
      response = conn.read()
      if mark is None:
        f = file('response.txt', 'w')
        f.write(response) 
        f.close()
        print response
      return response
    except urllib2.HTTPError, e:
      error_msg = e.read().strip()
      if mark is None:
        f = file('response.txt', 'w')
        f.write(error_msg) 
        f.close()
        print error_msg
      return error_msg
    
	
def setup_cmdlist():
 CMD_LIST['create'] = cmd_create
 CMD_LIST['CreateSecurityGroup'] = cmd_createSecurityGroup
 CMD_LIST['AuthorizeSecurityGroup'] = cmd_authorizeSecurityGroup
 CMD_LIST['DescribeSecurityGroupAttribute'] = cmd_describeSecurityGroupAttribute
 CMD_LIST['DescribeSecurityGroups'] = cmd_describeSecurityGroups
 CMD_LIST['RevokeSecurityGroup'] = cmd_revokeSecurityGroup
 CMD_LIST['DeleteSecurityGroup'] = cmd_deleteSecurityGroup
 
 CMD_LIST['ModifyInstanceAttribute'] = cmd_modifyInstanceAttribute
 CMD_LIST['DescribeInstanceStatus'] = cmd_describeInstanceStatus
 CMD_LIST['DescribeInstanceAttribute'] = cmd_describeInstanceAttribute

 CMD_LIST['FindSecurityGroupId'] = cmd_findSecurityGroupId
 CMD_LIST['FindSecurityGroupIdS'] = cmd_findSecurityGroupIdS
 
 CMD_LIST['DescribeRegions'] = cmd_describeRegions
 CMD_LIST['DescribeZones'] = cmd_describeZones
 
 CMD_LIST['CreateImage'] = cmd_createImage
 CMD_LIST['DeleteImage'] = cmd_deleteImage
 CMD_LIST['DescribeImages'] = cmd_describeImages
 
 CMD_LIST['DescribeInstanceDisks'] = cmd_describeInstanceDisks
 CMD_LIST['DeleteDisk'] = cmd_deleteDisk
 CMD_LIST['AddDisk'] = cmd_addDisk
 CMD_LIST['AllocatePublicIpAddress'] = cmd_allocatePublicIpAddress
 CMD_LIST['ReleasePublicIpAddress'] = cmd_releasePublicIpAddress
 
 CMD_LIST['CreateInstance'] = cmd_createInstance
 CMD_LIST['StartInstance'] = cmd_startInstance
 CMD_LIST['StopInstance'] = cmd_stopInstance
 CMD_LIST['RebootInstance'] = cmd_rebootInstance
 CMD_LIST['ResetInstance'] = cmd_resetInstance
 CMD_LIST['DeleteInstance'] = cmd_deleteInstance
 CMD_LIST['ModifyInstanceSpec'] = cmd_modifyInstanceSpec
 
 CMD_LIST['CreateSnapshot'] = cmd_createSnapshot
 CMD_LIST['DeleteSnapshot'] = cmd_deleteSnapshot
 CMD_LIST['DescribeSnapshots'] = cmd_describeSnapshots
 CMD_LIST['DescribeSnapshotAttribute'] = cmd_describeSnapshotAttribute
 CMD_LIST['RollbackSnapshot'] = cmd_rollbackSnapshot
 
 CMD_LIST['DescribeInstanceTypes'] = cmd_describeInstanceTypes
 
 CMD_LIST['config'] = cmd_configure
 
#测试
def cmd_create():
 global parameters
 parameters['AccessKeyId'] = '2yoyclq6bgptwDww'
 parameters['Action'] = 'DescribeZones'
 parameters['RegionId'] = 'cn-hangzhou-dg-a01'

#验证为空，则退出程序。不为空，则赋值参数。 
def checkNone(p,name):
 global parameters
 if p is None:
   print 'Please input '+ name + '!'
   sys.exit(1)
 else:
   parameters[name] = p

#验证不为空，则赋值参数。为空，则不处理什么。
def checkNotNone(p,name):
  global parameters
  if p is not None:
    parameters[name] = p

#CreateSecurityGroup (创建安全组)
def cmd_createSecurityGroup():
 global parameters
 parameters['Action'] = 'CreateSecurityGroup'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.Description , 'Description')
 conServer(parameters)

#AuthorizeSecurityGroup (授权安全组权限)
def cmd_authorizeSecurityGroup():
 global parameters
 parameters['Action'] = 'AuthorizeSecurityGroup'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.SecurityGroupId , 'SecurityGroupId')
 checkNone(options.IpProtocol , 'IpProtocol')
 checkNone(options.PortRange , 'PortRange')
 if options.SourceCidrIp is None and options.SourceGroupId is None:
  print 'Please input SourceCidrIp or SourceGroupId!'
  sys.exit(1)
 checkNotNone(options.SourceCidrIp , 'SourceCidrIp')
 checkNotNone(options.SourceGroupId , 'SourceGroupId')
 checkNotNone(options.NicType , 'NicType')
 conServer(parameters)

#DescribeSecurityGroupAttribute (查询安全组规则)
def cmd_describeSecurityGroupAttribute():
 global parameters
 parameters['Action'] = 'DescribeSecurityGroupAttribute'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.SecurityGroupId , 'SecurityGroupId')
 checkNotNone(options.NicType , 'NicType')
 conServer(parameters)
 
#DescribeSecurityGroups (查询安全组列表)
def cmd_describeSecurityGroups():
 global parameters
 parameters['Action'] = 'DescribeSecurityGroups'
 checkNotNone(options.RegionId , 'RegionId')
 checkNotNone(options.PageNumber , 'PageNumber')
 checkNotNone(options.PageSize , 'PageSize')
 conServer(parameters)

#RevokeSecurityGroup (撤销安全组规则)
def cmd_revokeSecurityGroup():
 global parameters
 parameters['Action'] = 'RevokeSecurityGroup'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.SecurityGroupId , 'SecurityGroupId')
 checkNone(options.IpProtocol , 'IpProtocol')
 checkNone(options.PortRange , 'PortRange')
 if options.SourceCidrIp is None and options.SourceGroupId is None:
  print 'Please input SourceCidrIp or SourceGroupId!'
  sys.exit(1)
 checkNotNone(options.SourceCidrIp , 'SourceCidrIp')
 checkNotNone(options.SourceGroupId , 'SourceGroupId')
 checkNotNone(options.Policy , 'Policy')
 checkNotNone(options.NicType , 'NicType')
 conServer(parameters)

#DeleteSecurityGroup (删除安全组) 
def cmd_deleteSecurityGroup():
 global parameters
 parameters['Action'] = 'DeleteSecurityGroup'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.SecurityGroupId , 'SecurityGroupId')
 conServer(parameters)
 
#ModifyInstanceAttribute 修改实例属性(可修改主机名、密码、所属安全组)
def cmd_modifyInstanceAttribute():
 global parameters
 parameters['Action'] = 'ModifyInstanceAttribute'
 checkNone(options.InstanceId , 'InstanceId')
 checkNotNone(options.SecurityGroupId , 'SecurityGroupId')
 checkNotNone(options.HostName , 'HostName')
 checkNotNone(options.Password , 'Password')
 conServer(parameters)

#DescribeInstanceStatus 查询实例状态(查询实例列表)
def cmd_describeInstanceStatus():
 global parameters
 parameters['Action'] = 'DescribeInstanceStatus'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.ZoneId , 'ZoneId')
 checkNotNone(options.PageNumber , 'PageNumber')
 checkNotNone(options.PageSize , 'PageSize')
 conServer(parameters)
 
#DescribeInstanceAttribute查询实例信息
def cmd_describeInstanceAttribute():
 global parameters
 parameters['Action'] = 'DescribeInstanceAttribute'
 checkNone(options.InstanceId , 'InstanceId')
 conServer(parameters)

#FindSecurityGroupId根据InstanceId返回SecurityGroupId
def cmd_findSecurityGroupId():
 global parameters
 parameters['Action'] = 'DescribeInstanceAttribute'
 checkNone(options.InstanceId , 'InstanceId')
 responseXml = conServerXml(parameters)
 doc = minidom.parseString(responseXml)
 #doc = minidom.parse("qiao1.xml")
 root = doc.documentElement
 if root.nodeName == "Error":
  print "\n Error!"
 else:
  nodes = root.getElementsByTagName("SecurityGroupId")
  v = nodes[0].childNodes[0].nodeValue
  print 'SecurityGroupId:',v
  f = file('response.txt', 'a')
  f.write('\nSecurityGroupId:'+v) 
  f.close()

#FindSecurityGroupId根据InstanceId返回SecurityGroupId---用户函数间调用
def findSecurityGroupId(InstanceId,options):
 global mark
 # ISO8601规范，注意使用GMT时间
 timestamp = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
 #此处的parameters必须要重新定义，否则证书重复
 parameters = { \
        # 公共参数
        'Format'        : 'XML', \
        'Version'       : '2013-01-10', \
        #'AccessKeyId'   : 'you access key id', \
        'SignatureVersion'  : '1.0', \
        'SignatureMethod'   : 'HMAC-SHA1', \
        'SignatureNonce'    : str(uuid.uuid1()), \
        'TimeStamp'         : timestamp, \
 }
 mark = "findSecurityGroupId"
 #parameters['AccessKeyId'] = options.accessid
 parameters['Action'] = 'DescribeInstanceAttribute'
 parameters['InstanceId'] = InstanceId
 responseXml = conServerXml(parameters)
 doc = minidom.parseString(responseXml)
 #doc = minidom.parse("qiao.xml")
 root = doc.documentElement
 v = "None"
 if root.nodeName == "Error":
  print "\n Error!"
 else:
  nodes = root.getElementsByTagName("SecurityGroupId")
  v = nodes[0].childNodes[0].nodeValue
 return v  
  
#FindSecurityGroupIdS返回实例列表(包含实例的SecurityGroupId)
def cmd_findSecurityGroupIdS():
 global parameters
 global mark
 parameters['Action'] = 'DescribeInstanceStatus'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.ZoneId , 'ZoneId')
 checkNotNone(options.PageNumber , 'PageNumber')
 checkNotNone(options.PageSize , 'PageSize')
 responseXml = conServerXml(parameters)
 doc = minidom.parseString(responseXml)
 #doc = minidom.parse("q.txt")
 root = doc.documentElement
 nodes = root.getElementsByTagName("TotalCount")
 totalCount = nodes[0].childNodes[0].nodeValue
 
 if root.nodeName == "Error":
  print "\n Error!"
 else:
  nodes = root.getElementsByTagName("TotalCount")
  totalCount = nodes[0].childNodes[0].nodeValue
  if totalCount >= 1:
    nodes = root.getElementsByTagName("InstanceId")
    f = file('response.txt', 'a')
    ii = None
    for n in nodes:
     ii = "mark"
     instanceId = n.childNodes[0].nodeValue
     sg = findSecurityGroupId(instanceId,options)
     mark = None
     print 'instanceId:',instanceId,' , ','SecurityGroupId:', sg
     f.write('\ninstanceId:'+instanceId+' , '+'SecurityGroupId:'+sg) 
    if ii is not None:
	 f.close()
	 
#DescribeRegions查询可用数据中心
def cmd_describeRegions():
 global parameters
 parameters['Action'] = 'DescribeRegions'
 del parameters['RegionId']
 conServer(parameters)
 
#DescribeZones查询指定Region下的Zone列表
def cmd_describeZones():
 global parameters
 parameters['Action'] = 'DescribeZones'
 checkNotNone(options.RegionId , 'RegionId')
 conServer(parameters)
	  
#CreateInstance创建实例
def cmd_createInstance():
 global parameters
 parameters['Action'] = 'CreateInstance'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.ImageId , 'ImageId')
 checkNone(options.InstanceType , 'InstanceType')
 checkNone(options.SecurityGroupId , 'SecurityGroupId')
 checkNotNone(options.InternetMaxBandwidthIn , 'InternetMaxBandwidthIn')
 checkNotNone(options.InternetMaxBandwidthOut , 'InternetMaxBandwidthOut')
 checkNotNone(options.HostName , 'HostName')
 checkNotNone(options.Password , 'Password')
 checkNotNone(options.ZoneId , 'ZoneId')
 checkNotNone(options.ClientToken , 'ClientToken')
 conServer(parameters)

#StartInstance启动实例
def cmd_startInstance():
 global parameters
 parameters['Action'] = 'StartInstance'
 del parameters['RegionId']
 checkNone(options.InstanceId , 'InstanceId')
 conServer(parameters)

#StopInstance停止实例
def cmd_stopInstance():
 global parameters
 parameters['Action'] = 'StopInstance'
 del parameters['RegionId']
 checkNone(options.InstanceId , 'InstanceId')
 checkNotNone(options.ForceStop , 'ForceStop')
 conServer(parameters)

#RebootInstance重启实例 
def cmd_rebootInstance():
 global parameters
 parameters['Action'] = 'RebootInstance'
 del parameters['RegionId']
 checkNone(options.InstanceId , 'InstanceId')
 checkNotNone(options.ForceStop , 'ForceStop')
 conServer(parameters)

#ResetInstance重置实例 
def cmd_resetInstance():
 global parameters
 parameters['Action'] = 'ResetInstance'
 del parameters['RegionId']
 checkNone(options.InstanceId , 'InstanceId')
 checkNotNone(options.ImageId , 'ImageId')
 checkNotNone(options.DiskType , 'DiskType')
 conServer(parameters)
 
#DeleteInstance删除实例
def cmd_deleteInstance():
 global parameters
 parameters['Action'] = 'DeleteInstance'
 del parameters['RegionId']
 checkNone(options.InstanceId , 'InstanceId')
 conServer(parameters)

#CreateSnapshot创建快照
def cmd_createSnapshot():
 global parameters
 parameters['Action'] = 'CreateSnapshot'
 checkNone(options.InstanceId , 'InstanceId')
 checkNone(options.DiskId , 'DiskId')
 checkNone(options.SnapshotName , 'SnapshotName')
 conServer(parameters)

#DeleteSnapshot删除快照
def cmd_deleteSnapshot():
 global parameters
 parameters['Action'] = 'DeleteSnapshot'
 del parameters['RegionId']
 checkNone(options.DiskId , 'DiskId')
 checkNone(options.InstanceId , 'InstanceId')
 checkNone(options.SnapshotId , 'SnapshotId')
 conServer(parameters)

#DescribeSnapshots查询磁盘设备的快照列表 
def cmd_describeSnapshots():
 global parameters
 parameters['Action'] = 'DescribeSnapshots'
 del parameters['RegionId']
 checkNone(options.InstanceId , 'InstanceId')
 checkNone(options.DiskId , 'DiskId')
 conServer(parameters)

#DescribeSnapshotAttribute查询快照详情
def cmd_describeSnapshotAttribute():
 global parameters
 parameters['Action'] = 'DescribeSnapshotAttribute'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.SnapshotId , 'SnapshotId')
 conServer(parameters)

#RollbackSnapshot回滚快照
def cmd_rollbackSnapshot():
 global parameters
 parameters['Action'] = 'RollbackSnapshot'
 del parameters['RegionId']
 checkNone(options.InstanceId , 'InstanceId')
 checkNone(options.DiskId , 'DiskId')
 checkNone(options.SnapshotId , 'SnapshotId')
 conServer(parameters)

#DescribeImages查询可用镜像
def cmd_describeImages():
 global parameters
 parameters['Action'] = 'DescribeImages'
 checkNotNone(options.RegionId , 'RegionId')
 checkNotNone(options.PageNumber , 'PageNumber')
 checkNotNone(options.PageSize , 'PageSize')
 conServer(parameters)
 
#CreateImage创建自定义镜像
def cmd_createImage():
 global parameters
 parameters['Action'] = 'CreateImage'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.SnapshotId , 'SnapshotId')
 checkNotNone(options.ImageVersion , 'ImageVersion')
 checkNotNone(options.Description , 'Description')
 checkNotNone(options.Visibility , 'Visibility')
 conServer(parameters)

#DeleteImage删除自定义镜像 
def cmd_deleteImage():
 global parameters
 parameters['Action'] = 'DeleteImage'
 checkNotNone(options.RegionId , 'RegionId')
 checkNone(options.ImageId , 'ImageId')
 conServer(parameters) 
 
#DescribeInstanceDisks查询实例磁盘列表
def cmd_describeInstanceDisks():
 global parameters
 parameters['Action'] = 'DescribeInstanceDisks'
 del parameters['RegionId'] 
 checkNone(options.InstanceId , 'InstanceId')
 conServer(parameters)
 
#DeleteDisk删除磁盘
def cmd_deleteDisk():
 global parameters
 parameters['Action'] = 'DeleteDisk'
 del parameters['RegionId'] 
 checkNone(options.InstanceId , 'InstanceId')
 checkNone(options.DiskId , 'DiskId')
 conServer(parameters)
 
#AddDisk为实例增加磁盘设备 
def cmd_addDisk():
 global parameters
 parameters['Action'] = 'AddDisk'
 del parameters['RegionId'] 
 checkNone(options.InstanceId , 'InstanceId')
 checkNone(options.Size , 'Size')
 checkNotNone(options.SnapshotId , 'SnapshotId')
 conServer(parameters)

#AllocatePublicIpAddress分配公网ip地址
def cmd_allocatePublicIpAddress():
 global parameters
 parameters['Action'] = 'AllocatePublicIpAddress'
 del parameters['RegionId'] 
 checkNone(options.InstanceId , 'InstanceId')
 conServer(parameters)
 
#ReleasePublicIpAddress释放公网IP地址
def cmd_releasePublicIpAddress():
 global parameters
 parameters['Action'] = 'ReleasePublicIpAddress'
 del parameters['RegionId']
 checkNone(options.PublicIpAddress , 'PublicIpAddress')
 conServer(parameters) 

#ModifyInstanceSpec修改实例规格(实例升级)
def cmd_modifyInstanceSpec():
 global parameters
 parameters['Action'] = 'ModifyInstanceSpec'
 del parameters['RegionId'] 
 checkNone(options.InstanceId , 'InstanceId')
 checkNotNone(options.InstanceType , 'InstanceType')
 checkNotNone(options.InternetMaxBandwidthIn , 'InternetMaxBandwidthIn')
 checkNotNone(options.InternetMaxBandwidthOut , 'InternetMaxBandwidthOut')
 conServer(parameters)

def cmd_describeInstanceTypes():
 global parameters
 parameters['Action'] = 'DescribeInstanceTypes'
 del parameters['RegionId']
 conServer(parameters)
 
if __name__ == '__main__':
 parser = OptionParser()
 parser.add_option("", "--host", dest="host", help="specify")
 parser.add_option("", "--id", dest="accessid", help="specify access id")
 parser.add_option("", "--key", dest="accesskey", help="specify access key")
 parser.add_option("", "--RegionId", dest="RegionId", help="")
 parser.add_option("", "--Description", dest="Description", help="")
 
 parser.add_option("", "--IpProtocol", dest="IpProtocol", help="")
 parser.add_option("", "--PortRange", dest="PortRange", help="")
 parser.add_option("", "--SourceGroupId", dest="SourceGroupId", help="")
 parser.add_option("", "--SourceCidrIp", dest="SourceCidrIp", help="")
 parser.add_option("", "--SecurityGroupId", dest="SecurityGroupId", help="")
 parser.add_option("", "--Policy", dest="Policy", help="")
 parser.add_option("", "--NicType", dest="NicType", help="")
 
 parser.add_option("", "--PageNumber", dest="PageNumber", help="")
 parser.add_option("", "--PageSize", dest="PageSize", help="")
 
 parser.add_option("", "--InstanceId", dest="InstanceId", help="")
 parser.add_option("", "--ZoneId", dest="ZoneId", help="")
 parser.add_option("", "--ImageId", dest="ImageId", help="")
 parser.add_option("", "--InstanceType", dest="InstanceType", help="")
 parser.add_option("", "--InternetMaxBandwidthIn", dest="InternetMaxBandwidthIn", help="")
 parser.add_option("", "--InternetMaxBandwidthOut", dest="InternetMaxBandwidthOut", help="")
 parser.add_option("", "--HostName", dest="HostName", help="")
 parser.add_option("", "--Password", dest="Password", help="")
 parser.add_option("", "--ClientToken", dest="ClientToken", help="")
 parser.add_option("", "--DiskId", dest="DiskId", help="")
 parser.add_option("", "--Size", dest="Size", help="")
 parser.add_option("", "--SnapshotId", dest="SnapshotId", help="")
 parser.add_option("", "--PublicIpAddress", dest="PublicIpAddress", help="")
 parser.add_option("", "--DiskType", dest="DiskType", help="")
 parser.add_option("", "--ForceStop", dest="ForceStop", help="")
 parser.add_option("", "--SnapshotName", dest="SnapshotName", help="")
 parser.add_option("", "--ImageVersion", dest="ImageVersion", help="")
 parser.add_option("", "--Visibility", dest="Visibility", help="")
 parser.add_option("", "--config_file", dest="config_file", help="the file which stores id-key pair")
 
 setup_cmdlist()
 (options, args) = parser.parse_args()
 
 if options.config_file is not None:
   CONFIGFILE = options.config_file
   
 if len(args) < 1:
   print 'Please input Action!'
   sys.exit(1) 

 if args[0] != 'config':
   setup_crenditials()
 else:
   CMD_LIST['config']()
   sys.exit(1)

 if args[0] not in CMD_LIST.keys():
   print "unsupported command : %s " % args[0]
   sys.exit(1)   
   
 cmd = args[0]
 res = CMD_LIST[cmd]()



