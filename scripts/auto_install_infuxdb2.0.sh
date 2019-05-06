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

cd ${install_dir}
wget https://dl.influxdata.com/influxdb/releases/influxdb_2.0.0-alpha.9_linux_amd64.tar.gz
tar xvzf path/to/influxdb_2.0.0-alpha.9_linux_amd64.tar.gz
cp influxdb_2.0.0-alpha.9_linux_amd64/{influx,influxd} /usr/local/bin/

#===================================step2:install telegraf========================

yum install -y telegraf
service telegraf start

#===================================step3:start influxdb service========================
influxd &> /var/log/influd2.0.log &

# 启动InfluxDB后，访问http://localhost:9999，单击开始进行账户配置
