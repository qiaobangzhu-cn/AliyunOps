# -*- coding:utf-8 -*-
import rdsServer

import re
import json
import sys

ACTION = "DescribeDBInstancePerformance"
# Key = "all"
# DBInstanceId = "rm-2zezm24r7p176s6rq"
# RegionId = "cn-beijing"
# CONFIGFILE = '/etc/.rdsjm'


def getSysParm():

    OPT_PTN = re.compile(r'--([A-Za-z\-]+)=(.*)')

    argv = sys.argv
    argv.append('')
    opts = {}
    action = ""
    for kv in argv[1:]:
        m = OPT_PTN.match(kv)
        if m:
            key, val = m.groups()
            opts[key] = val
    return opts


def getParm(args):
    OPT_PTN = re.compile(r'--([A-Za-z\-]+)=(.*)')

    args = args.split(" ")
    opts = {}
    for kv in args:
        m = OPT_PTN.match(kv)
        if m:
            key, val = m.groups()
            opts[key] = val
    return opts

if __name__ == '__main__':
    action = ACTION

    opts = getSysParm()

    Key = "all"
    DBInstanceId = opts["DBInstanceId"]
    RegionId = opts["RegionId"]
    CONFIGFILE = opts["CONFIGFILE"]

    args = "--key=%s --DBInstanceId=%s --RegionId=%s --CONFIGFILE=%s" % (Key, DBInstanceId, RegionId, CONFIGFILE)

    opts = getParm(args)
    Parameter = rdsServer.reParameter(opts)

    config = rdsServer.Configure()
    Parameter = config.get_configure(Parameter)

    if not "ResourceOwnerAccount" in Parameter.keys():
        Parameter["ResourceOwnerAccount"] = None
    rdsPerformance = rdsServer.RDSPerformance(id=Parameter['acid'], key=Parameter['ackey'])

    if action.lower() not in rdsPerformance.CMD_LIST.keys():
        message = "unsupported command : %s " % action
        print message
        sys.exit(1)

    # print json.dumps(Parameter,indent=4)
    rdsPerformance.CMD_LIST[action.lower()](Parameter)
    rdsPerformance.CMD_LIST["DescribeDBInstanceAttribute".lower()](Parameter)
    # redata = globals()
    # del(redata['__builtins__'])
    perfomance = rdsServer.varDescribeDBInstancePerformance
    attribute = rdsServer.varDescribeDBInstanceAttribute
    # print json.dumps(perfomance, indent=4)

    data = {}
    data["Engine"] = perfomance["Engine"]
    data["DBInstanceId"] = perfomance["DBInstanceId"]

    for PerformanceKey in perfomance["PerformanceKeys"]["PerformanceKey"]:
        titleList = PerformanceKey["ValueFormat"].split("&")
        if len(PerformanceKey["Values"]["PerformanceValue"]) > 0:
            valueList = PerformanceKey["Values"]["PerformanceValue"][0]["Value"].split("&")
            for i, title in enumerate(titleList):
                data[PerformanceKey["Key"]+"_"+title] = valueList[i]
    for key, value in attribute.items():
        data[key] = value
    print json.dumps(data, indent=4)