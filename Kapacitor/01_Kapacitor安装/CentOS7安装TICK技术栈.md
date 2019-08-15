# CentOS 7 安装TICK技术栈


|No.|功能|应用|服务器|
|:--|:--|:--|:--|
|1|数据采集|Telegraf|ECS|
|2|时序数据库|InfluxDB|ECS|
|3|监控展示|Chronograf|ECS|
|4|告警通知|kapacitor|ECS|

## 通过安装脚本一键安装


```bash
wget https://raw.githubusercontent.com/BoobooWei/booboo_TimeSeriesDBMS/master/scripts/auto_install_influxdb1.7.sh
bash auto_install_influxdb1.7.sh
wget https://raw.githubusercontent.com/BoobooWei/booboo_TimeSeriesDBMS/master/scripts/myinfluxdb1.7ctl.sh
bash myinfluxdb1.7ctl.sh all start
```


## 通过yum源手动安装

 ```bash
 # set repo
 cat > /etc/yum.repos.d/influxdb.repo << ENDF
 [influxdb]
 name = InfluxDB Repository - RHEL \$releasever
 baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
 enabled = 1
 gpgcheck = 1
 gpgkey = https://repos.influxdata.com/influxdb.key
 ENDF

 yum install -y telegraf influxdb chronograf kapacitor
 chown telegraf. /var/log/telegraf -R
 ```

 ## Kapacitor文件

|文件|说明|
|:--|:--|
|`/etc/kapacitor/kapacitor.conf`|配置文件|
|`/etc/logrotate.d/kapacitor`|日志轮询配置|
|`/usr/bin/kapacitor`|客户端|
|`/usr/bin/tickfmt`|格式化TICKscript|
|`/usr/bin/kapacitord`|守护进程Daemon|
|`/usr/lib/kapacitor/scripts/kapacitor.service`|`Service`|
|`/var/lib/kapacitor`|数据目录|
|`/var/log/kapacitor`|日志目录|
