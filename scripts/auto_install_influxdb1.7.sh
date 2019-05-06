#!/bin/bash

# auto_install_influxdb1.7
# booboowei
# 20190504
# redhat/centos 6/7

install_dir=/alidata/install/
if [ ! -d "${install_dir}" ]
then
  mkdir ${install_dir} -p
fi
#===================================step1:install influxdb========================
# set repo
cat <<EOF | tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF
# install influxdb
yum install influxdb -y

#=======================step2:install telegraf chronograf kapacitor===============
yum install -y telegraf chronograf kapacitor
chown telegraf. /var/log/telegraf -R


#===================================step3:start service========================
service influxdb start
service telegraf start
service chronograf start
service kapacitor start

# 可以通过 http://server_ip:8888 访问 chronograf
