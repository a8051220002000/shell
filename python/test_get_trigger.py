#!/usr/bin/python3
#--encoding=utf-8
from pyzabbix import ZabbixAPI
import time 

#login zabbix
ZABBIX_SERVER = 'http://zabbix.holdingfull.com/zabbix/api_jsonrpc.php'
 
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login('grafana-api', 'cy@1688!')


# 获取主机
host_list = zapi.host.get(
    output="extend",
)
 
'''
# 获取触发器
triggers = zapi.trigger.get(
    output="extend",
    selectHosts=['host'],
)
'''
# Get a list of all issues (AKA tripped triggers)
triggers = zapi.trigger.get(only_true=1,
			    skipDependent=1,
                            monitored=1,
                            active=1,
                            output='extend',
                            expandDescription=1,
                            selectHosts=['host'],
                            )
# Do another query to find out which issues are Unacknowledged
unack_triggers = zapi.trigger.get(only_true=1,
                                  skipDependent=1,
                                  monitored=1,
                                  active=1,
                                  output='extend',
                                  expandDescription=1,
                                  selectHosts=['host'],
                                  #withLastEventUnacknowledged=1,
                                  )
unack_trigger_ids = [t['triggerid'] for t in unack_triggers]
for t in triggers:
    t['unacknowledged'] = True if t['triggerid'] in unack_trigger_ids \
        else False

# Print a list containing only "tripped" triggers
for t in triggers:
    if int(t['value']) == 1:
        print("{0} - {1} {2}".format(t['hosts'][0]['host'],
                                     t['description'],
                                     '(Unack)' if t['unacknowledged'] else '')
              )

