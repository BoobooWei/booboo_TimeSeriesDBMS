# TICK技术栈实现对MySQL双机热备监控告警

[toc]

> Telegraf + Influxdb + Chranograf + Kapacitor + Dingding

## MySQL双机热备监控告警规则

| 告警规则（6项）                                | 监控间隔 | 连续N次触发 | 等级 |
| ---------------------------------------------- | -------- | ----------- | ---- |
| MySQL 数据库主从I/O线程异常                    | 3min     | 1次         | 严重 |
| MySQL 数据库主从SQL线程异常                    | 3min     | 1次         | 严重 |
| MySQL 数据库半同步复制状态异常                 | 3min     | 1次         | 严重 |
| MySQL 数据库主从延迟（超过5秒）                | 3min     | 1次         | 严重 |
| MySQL 数据库有未提交的长事务（超过60秒）       | 3min     | 1次         | 严重 |
| Keepalived状态变化（Master/Backup/Stop/Fault） | 10s      | 1次         | 严重 |


## 监控告警技术栈

### 基础安装TICK

|No.|功能|应用|服务器|
|:--|:--|:--|:--|
|1|数据采集|Telegraf|ECS|
|2|时序数据库|InfluxDB|ECS|
|3|监控展示|Chronograf|ECS|
|4|告警通知|kapacitor|ECS|
|5|钉钉通知	|Flask	|ECS|

```bash
wget https://raw.githubusercontent.com/BoobooWei/booboo_TimeSeriesDBMS/master/scripts/auto_install_influxdb1.7.sh
bash auto_install_influxdb1.7.sh
wget https://raw.githubusercontent.com/BoobooWei/booboo_TimeSeriesDBMS/master/scripts/myinfluxdb1.7ctl.sh
bash myinfluxdb1.7ctl.sh all start
```

### 采集MySQL指标配置文件

```bash
[[inputs.mysql]]
  servers = ["username:passowrd@tcp(url:port)/?tls=false"]
  metric_version = 2
  perf_events_statements_digest_text_limit  = 120
  perf_events_statements_limit              = 250
  perf_events_statements_time_limit         = 86400
  table_schema_databases                    = []
  gather_table_schema                       = false
  gather_process_list                       = true
  gather_user_statistics                    = false
  gather_info_schema_auto_inc               = false
  gather_innodb_metrics                     = true
  gather_slave_status                       = true
  gather_binary_logs                        = false
  gather_table_io_waits                     = false
  gather_table_lock_waits                   = false
  gather_index_io_waits                     = false
  gather_event_waits                        = false
  gather_file_events_stats                  = false
  gather_perf_events_statements             = false
  interval_slow                   = "30m"
```
