#!/bin/bash

# auto_install_influxdb1.7
# booboowei
# 20190504
# redhat/centos 6/7

#===================================step0:========================
which telegraf
is_telegraf=$?
which influx
is_influxdb=$?

if [[  ${is_telegraf} -eq 0 && ${influxdb} -eq 0 ]]
then
    exit
fi


install_dir=/alidata/install/
if [ ! -d "${install_dir}" ]
then
  mkdir ${install_dir} -p
fi

username=admin
password=Admin123
IP=`ip a| grep inet | grep -v 'inet6\|127.0.0.1' | awk '{print $2}' | awk -F / '{print $1}'`
edition=`cat /etc/redhat-release | awk '{print $4}' | awk -F . '{print $1}'`

#===================================step1:install telegraf influxdb chronograf kapacitor========================
# # set repo
# cat <<EOF | tee /etc/yum.repos.d/influxdb.repo
# [influxdb]
# name = InfluxDB Repository - RHEL \$releasever
# baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
# enabled = 1
# gpgcheck = 1
# gpgkey = https://repos.influxdata.com/influxdb.key
# EOF
# # install influxdb
# yum install influxdb -y
# yum install -y telegraf chronograf kapacitor
# chown telegraf. /var/log/telegraf -R

mkdir /alidata/install -p
cd /alidata/install

wget https://zy-res.oss-cn-hangzhou.aliyuncs.com/influxdata/influxdb-1.7.7.x86_64.rpm
wget https://zy-res.oss-cn-hangzhou.aliyuncs.com/influxdata/chronograf-1.7.10.x86_64.rpm
wget https://zy-res.oss-cn-hangzhou.aliyuncs.com/influxdata/kapacitor-1.5.2.x86_64.rpm
wget https://zy-res.oss-cn-hangzhou.aliyuncs.com/influxdata/telegraf-1.11.1-1.x86_64.rpm

yum localinstall -y influxdb-1.7.7.x86_64.rpm
yum localinstall -y telegraf-1.11.1-1.x86_64.rpm
yum localinstall -y chronograf-1.7.10.x86_64.rpm
yum localinstall -y kapacitor-1.5.2.x86_64.rpm

#=======================step2:Configure Telegraf===============
mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.bac
cat > /etc/telegraf/telegraf.conf << END

[global_tags]
[agent]
  logfile = "/var/log/telegraf/telegraf.log"
  logfile_rotation_interval = "7d"
  logfile_rotation_max_size = "100MB"
  logfile_rotation_max_archives = 5
  interval = "60s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  hostname = "influxdb"
  omit_hostname = false
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.influxdb]]
  urls = ["http://$IP:8086/debug/vars"]

[[outputs.influxdb]]
  urls = ["http://$IP:8086"]
  database = "telegraf"
  skip_database_creation = false
  timeout = "5s"
  username = "admin"
  password = "Admin123"

[[outputs.prometheus_client]]
   listen = ":9273"
END

#===================================step3:InfluxDB Configure And Authentication========================
mkdir /alidata/influxdb -p
chown influxdb. /alidata/influxdb
cp /etc/influxdb/influxdb.conf /etc/influxdb/influxdb.conf.bac
sed -i 's/\/var\/lib\/influxdb/\/alidata\/influxdb/' /etc/influxdb/influxdb.conf

if [ "$edition" == 7 ]
then
    systemctl start influxdb
    systemctl start telegraf
    systemctl start chronograf
    systemctl start kapacitor
else
    service influxdb start
    service telegraf start
    service chronograf start
    service kapacitor start
fi

sleep 2

influx -execute "CREATE USER admin WITH PASSWORD 'Admin123' WITH ALL PRIVILEGES"
sed -i '/^\[http/a auth-enabled = true' /etc/influxdb/influxdb.conf

if [ "$edition" == 7 ]
then
  systemctl stop influxdb
  systemctl start influxdb
else
  service influxdb stop
  service influxdb start
fi


influx -username admin -password Admin123 -execute "create database telegraf"
influx -username admin -password Admin123 -database telegraf -execute "ALTER RETENTION POLICY autogen ON telegraf DURATION 30d DEFAULT"
influx -username admin -password Admin123 -database telegraf -execute "SHOW RETENTION POLICIES ON telegraf"

#===================================step5: Profile ========================
cat >> ~/.bash_profile << ENDF
alias zy_influx="influx -username admin -password Admin123"
ENDF

# 可以通过 http://server_ip:8888 访问 chronograf
