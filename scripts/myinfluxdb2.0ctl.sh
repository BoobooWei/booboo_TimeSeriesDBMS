#!/bin/bash

# myinfluxdb2.0ctl all|influxdb|telegraf start|stop
# booboowei
# 20190504
# redhat/centos 6/7

influx_token='6cl933dkax36vEuCPSU6WVIL4nkKsp4WZ8SuFahQUBbUbR8h_n0bktZAUClpgObcxzBvmDnXKTLo4G5V6m-_3w=='
telegraf_config='http://101.132.37.118:9999/api/v2/telegrafs/03cd7af520a78000'

start_influxdb(){
    /usr/local/bin/influxd &> /var/log/influx2.log &
}

stop_influxdb(){
  kill -9 `ps -ef|grep influxd|head -n 1|awk '{print $2}'`
}

status_influxdb(){
  ps -ef|grep influxd|head -n 1
}

start_telegraf(){
  export INFLUX_TOKEN=${influx_token}
  telegraf --config ${telegraf_config} &
}

stop_telegraf(){
  kill -9 `ps -ef|grep "telegraf --config"|head -n 1|awk '{print $2}'`
}

status_telegraf(){
  ps -ef|grep "telegraf --config"|head -n 1
}

start_all(){
  start_influxdb
  sleep 5
  start_telegraf
}

stop_all(){
  stop_influxdb
  stop_telegraf
}

status_all(){
  status_influxdb
  status_telegraf
}

"$2_$1"
