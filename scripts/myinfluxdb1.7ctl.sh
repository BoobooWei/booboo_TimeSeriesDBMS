#!/bin/bash

# myinfluxdb1.7ctl all|influxdb|telegraf|chronograf|kapacitor start|stop
# booboowei
# 20190504
# redhat/centos 6/7


service_ctl(){
  for service in ${service_name[@]}
  do
    service ${service} $2
  done
}

service_name=(influxdb telegraf chronograf kapacitor)
if [ $1 == 'all' ]
then
  service_ctl all $2
else
  service $1 $2
fi
