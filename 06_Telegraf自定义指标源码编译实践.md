# Telegraf自定义指标源码编译实践

> 实践过程中最难的不是改代码，而是如何让命令行也能够科学上网。
>
> 所以，如果你第一步科学上网搞不定，就不用继续了！！！！

[Go入门帮助](https://github.com/johntoms/study-go)

## 自定义指标说明

### 指标概览

| 对象    | 明细                                                         |
| ------- | ------------------------------------------------------------ |
| git仓库 | [telegraf](https://github.com/influxdata/telegraf)           |
| 插件    | [inputs](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/) |
| 应用    | [mysql](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/mysql/) |
| 文件    | [mysql.go](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/mysql/mysql.go) |

### 指标明细

#### mysql_metadatalock_session

| 指标名`measuerment`                      | `mysql_metadatalock_session`                       | MetadataLock元锁会话明细        |
| ------------------------- | ------------------------------------------------------ | ------------------------- |
| Tags | `server` | `数据库url地址或主机名` |
| Fields                | `id`                                         | `会话id`                                    |
|  | `user` | `会话的登录用户名` |
|  | `host` | `会话的来源地址` |
|  | `db` | `会话访问的数据库名` |
|  | `command` | `会话执行的语句类型` |
|  | `conn_time` | `会话持续时间` |
|  | `state` | `会话状态` |
|  | `info` | `会话执行的具体SQL语句` |

#### mysql_metadatalock_count

| 指标名`measuerment` | `mysql_metadatalock_count` | `MetadataLock元锁会话总数` |
| ------------------- | -------------------------- | -------------------------- |
| Tags                | `server`                   | `数据库url地址或主机名`    |
| Fields              | `count`                    | `会话总数`                 |

#### mysql_metadatalock_trx_id

| 指标名`measuerment` | `mysql_metadatalock_trx_id` | `导致元锁冲突的长时间未提交的事务会话id` |
| ------------------- | --------------------------- | ---------------------------------------- |
| Tags                | `server`                    | `数据库url地址或主机名`                  |
| Fields              | `id`                        | `会话id`                                 |

在原有指标的基础上添加`inputs`中的`mysql`相关的`MetadatLock`指标信息：

* 元锁会话明细；
* 元锁会话总数；
* 导致元锁冲突的长时间未提交的事务会话id。

提前准备好SQL语句：

```sql
# 元锁会话明细
select * from information_schema.processlist where State='Waiting for table metadata lock';
# 元锁会话总数
select count(*) count from information_schema.processlist where State='Waiting for table metadata lock';
# 查询 information_schema.innodb_trx 看到有长时间未完成的事务， 使用 kill 命令终止该查询。
select i.trx_mysql_thread_id from information_schema.innodb_trx i,
  (select 
         id, time
     from
         information_schema.processlist
     where
         time = (select 
                 max(time)
             from
                 information_schema.processlist
             where
                 state = 'Waiting for table metadata lock'
                     and substring(info, 1, 5) in ('alter' , 'optim', 'repai', 'lock ', 'drop ', 'creat'))) p
  where timestampdiff(second, i.trx_started, now()) > p.time
  and i.trx_mysql_thread_id  not in (connection_id(),p.id);
```

执行结果如下：

```sql
root@SH_MySQL-01 17:36:  [(none)]> select * from information_schema.processlist where State='Waiting for table metadata lock';
+-------+------+-----------+------+---------+------+---------------------------------+--------------------------------------+
| ID    | USER | HOST      | DB   | COMMAND | TIME | STATE                           | INFO                                 |
+-------+------+-----------+------+---------+------+---------------------------------+--------------------------------------+
| 47474 | root | localhost | test | Query   | 2609 | Waiting for table metadata lock | alter table t1 add column xxxxxx int |
+-------+------+-----------+------+---------+------+---------------------------------+--------------------------------------+

root@SH_MySQL-01 18:07:  [(none)]> select count(*) from information_schema.processlist where State='Waiting for table metadata lock';
+----------+
| count(*) |
+----------+
|        1 |
+----------+

root@SH_MySQL-01 17:34:  [(none)]> select i.trx_mysql_thread_id from information_schema.innodb_trx i,                                                        ->   (select 
    ->          id, time
    ->      from
    ->          information_schema.processlist
    ->      where
    ->          time = (select 
    ->                  max(time)
    ->              from
    ->                  information_schema.processlist
    ->              where
    ->                  state = 'Waiting for table metadata lock'
    ->                      and substring(info, 1, 5) in ('alter' , 'optim', 'repai', 'lock ', 'drop ', 'creat'))) p
    ->   where timestampdiff(second, i.trx_started, now()) > p.time
    ->   and i.trx_mysql_thread_id  not in (connection_id(),p.id);
+---------------------+
| trx_mysql_thread_id |
+---------------------+
|               47473 |
+---------------------+
1 row in set (0.01 sec)
```

## 详细步骤

### 1. 安装科学上网工具

[MAC 科学上网](https://github.com/johntoms/study-go/blob/master/docs/%E5%85%B3%E4%BA%8E%E7%BB%88%E7%AB%AF%E5%A6%82%E4%BD%95%E4%BD%BF%E7%94%A8%E4%BB%A3%E7%90%86.md)

### 2. 安装telegraf编译环境

[帮助文档](https://github.com/influxdata/telegraf)

Telegraf requires golang version 1.9 or newer, the Makefile requires GNU make.

1. [Install Go](https://golang.org/doc/install) >=1.9 (1.11 recommended)

2. [Install dep](https://golang.github.io/dep/docs/installation.html) ==v0.5.0

3. Download Telegraf source:

   ```
   go get -d github.com/influxdata/telegraf
   ```

### 3. 修改mysql.go代码

打开到`834`行，添加以下代码：

```go
	////////////////////
	// get MetaDataLock of connections
	// select * from information_schema.processlist where State='Waiting for table metadata lock';
    //+-------+------+-----------+------+---------+------+---------------------------------+----------------------------------+
    //| ID    | USER | HOST      | DB   | COMMAND | TIME | STATE                           | INFO                             |
    //+-------+------+-----------+------+---------+------+---------------------------------+----------------------------------+
    //| 46435 | root | localhost | test | Query   |  222 | Waiting for table metadata lock | alter table t1 add column xx int |
    //+-------+------+-----------+------+---------+------+---------------------------------+----------------------------------+

	metadata_rows, err := db.Query("select * from information_schema.processlist where State='Waiting for table metadata lock'")
	if err != nil {
		return err
	}

	for metadata_rows.Next() {
	    var     id      int64
	    var     user    string
	    var     host    string
	    var     db      string
		var     command string
		var     conn_time    int64
		var     state   string
		var     info    string

		err = metadata_rows.Scan(&id, &user, &host, &db, &command, &conn_time, &state, &info)
		if err != nil {
			return err
		}

		tags := map[string]string{"server": servtag}
		fields := make(map[string]interface{})

		fields["id"] = id
		fields["user"] = user
		fields["host"] = host
		fields["db"] = db
		fields["command"] = command
		fields["time"] = conn_time
		fields["state"] = state
        fields["info"] = info

		acc.AddFields("mysql_metadatalock_session", fields, tags)
	}

	////////////////////
	// get MetaDataLock count
	// select count(*) count from information_schema.processlist where State='Waiting for table metadata lock';
    //+----------+
    //| count    |
    //+----------+
    //|        1 |
    //+----------+

	metadatalockcount_rows, err := db.Query("select count(*) from information_schema.processlist where State='Waiting for table metadata lock'")
	if err != nil {
		return err
	}

	for metadatalockcount_rows.Next() {
	    count     id      int64


		err = metadatalockcount_rows.Scan(&count)
		if err != nil {
			return err
		}

		tags := map[string]string{"server": servtag}
		fields := make(map[string]interface{})

		fields["count"] = count

		acc.AddFields("mysql_metadatalock_count", fields, tags)
	}


	////////////////////
	// A long unfinished trx_mysql_thread_id
    //select i.trx_mysql_thread_id from information_schema.innodb_trx i,
    //  (select
    //         id, time
    //     from
    //         information_schema.processlist
    //     where
    //         time = (select
    //                 max(time)
    //             from
    //                 information_schema.processlist
    //             where
    //                 state = 'Waiting for table metadata lock'
    //                     and substring(info, 1, 5) in ('alter' , 'optim', 'repai', 'lock ', 'drop ', 'creat'))) p
    //  where timestampdiff(second, i.trx_started, now()) > p.time
    //  and i.trx_mysql_thread_id  not in (connection_id(),p.id);
    //+---------------------+
    //| trx_mysql_thread_id |
    //+---------------------+
    //|               47473 |
    //+---------------------+

	metadatalock_trx_rows, err := db.Query(`select i.trx_mysql_thread_id from information_schema.innodb_trx i,
  (select
         id, time
     from
         information_schema.processlist
     where
         time = (select
                 max(time)
             from
                 information_schema.processlist
             where
                 state = 'Waiting for table metadata lock'
                     and substring(info, 1, 5) in ('alter' , 'optim', 'repai', 'lock ', 'drop ', 'creat'))) p
  where timestampdiff(second, i.trx_started, now()) > p.time
  and i.trx_mysql_thread_id  not in (connection_id(),p.id)`)

	if err != nil {
		return err
	}

	for metadatalock_trx_rows.Next() {
	    trx_mysql_thread_id     id      int64


		err = metadatalock_trx_rows.Scan(&trx_mysql_thread_id)
		if err != nil {
			return err
		}

		tags := map[string]string{"server": servtag}
		fields := make(map[string]interface{})

		fields["id"] = trx_mysql_thread_id

		acc.AddFields("mysql_metadatalock_trx_id", fields, tags)
	}
```



### 4. 编译

Run make from the source directory

```
cd "$HOME/go/src/github.com/influxdata/telegraf"
make -d
```

 编译结果如下：（执行`make -d`查看debug信息）

```
Must remake target `telegraf'.
go build -ldflags " -X main.commit=3b915429 -X main.branch=master" ./cmd/telegraf
Putting child 0x7fee6dd00a30 (telegraf) PID 95608 on the chain.
Live child 0x7fee6dd00a30 (telegraf) PID 95608
Reaping winning child 0x7fee6dd00a30 PID 95608
Removing child 0x7fee6dd00a30 PID 95608 from chain.
Successfully remade target file `telegraf'.
Reaping winning child 0x7f8327600970 PID 95602
Removing child 0x7f8327600970 PID 95602 from chain.
Successfully remade target file `all'.
```

到此编译成功，如果有报错说明代码改写有问题。

```
MacBook-Pro-4:telegraf booboo$ ll telegraf
-rwxr-xr-x  1 booboo  staff  103489088  5 15 18:39 telegraf
MacBook-Pro-4:telegraf booboo$ file telegraf
telegraf: Mach-O 64-bit executable x86_64
```

编译目录下新增了一个可执行文件`telegraf`。

### 5. 测试运行

> 请先安装influxdb并启动服务

准备一个测试用的telegraf配置文件`telegraf.conf`

```
[global_tags]
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  debug = false
  quiet = false
  logfile = ""
  hostname = ""
  omit_hostname = false
[[outputs.influxdb]]
  urls = ["https://ts-xxxxx.influxdata.rds.aliyuncs.com:3242"]
  database = "telegraf"
  retention_policy = "autogen"
  username = "zyadmin"
  password = "Zyadmin123"
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "overlay", "aufs", "squashfs"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.mysql]]
  servers = ["root:uplooking@tcp(10.200.6.30:3306)/?tls=false"]
  metric_version = 2
  perf_events_statements_digest_text_limit  = 120
  perf_events_statements_limit              = 250
  perf_events_statements_time_limit         = 86400
  table_schema_databases                    = []
  gather_table_schema                       = false
  gather_process_list                       = true
  gather_user_statistics                    = true
  gather_info_schema_auto_inc               = true
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
[[inputs.procstat]]
  pattern = ".*"
  pid_finder = "native"
```

执行`./telegraf --config telegraf.conf`启动telegraf

```
MacBook-Pro-4:telegraf booboo$ ./telegraf --config telegraf.conf
2019-05-15T10:42:39Z I! Starting Telegraf
2019-05-15T10:42:39Z I! Loaded inputs: kernel mem system procstat cpu disk diskio processes swap mysql
2019-05-15T10:42:39Z I! Loaded aggregators:
2019-05-15T10:42:39Z I! Loaded processors:
2019-05-15T10:42:39Z I! Loaded outputs: influxdb
2019-05-15T10:42:39Z I! Tags enabled: host=MacBook-Pro-4.local
2019-05-15T10:42:39Z I! [agent] Config: Interval:10s, Quiet:false, Hostname:"MacBook-Pro-4.local", Flush Interval:10s
2019-05-15T10:42:41Z W! [outputs.influxdb] when writing to [https://ts-uf6bt1li49153g2g8.influxdata.rds.aliyuncs.com:3242]: database "telegraf" creation failed: 403 Forbidden
2019-05-15T10:42:50Z E! [inputs.mysql]: Error in plugin: Error 1109: Unknown table 'user_statistics' in information_schema
2019-05-15T10:43:01Z E! [outputs.influxdb]: when writing to [https://ts-uf6bt1li49153g2g8.influxdata.rds.aliyuncs.com:3242]: received error partial write: field type conflict: input field "myisam_recover_options" on measurement "mysql_variables" is type integer, already exists as type string dropped=2; discarding points
```

有些报错可以忽略，和我们本次添加的指标无关。

### 6. 查看结果

登录到influxdb查看结果

```
> use telegraf
Using database telegraf
> show measurements
name: measurements
name
----
cpu
disk
diskio
kernel
mem
mysql
mysql_innodb
mysql_metadatalock_count
mysql_metadatalock_session
mysql_metadatalock_trx_id
mysql_process_list
mysql_table_schema
mysql_users
mysql_variables
processes
procstat
procstat_lookup
swap
system
> select * from mysql_metadatalock_count order by time desc limit 1
name: mysql_metadatalock_count
time                count host                server
----                ----- ----                ------
1557917100000000000 1     MacBook-Pro-4.local 10.200.6.30:3306
> select * from mysql_metadatalock_session order by time desc limit 1
name: mysql_metadatalock_session
time                command db   host      host_1              id    info                                 server           state                           user
----                ------- --   ----      ------              --    ----                                 ------           -----                           ----
1557917100000000000 Query   test localhost MacBook-Pro-4.local 47474 alter table t1 add column xxxxxx int 10.200.6.30:3306 Waiting for table metadata lock root
> select * from mysql_metadatalock_trx_id order by time desc limit 1
name: mysql_metadatalock_trx_id
time                host                id    server
----                ----                --    ------
1557917130000000000 MacBook-Pro-4.local 47473 10.200.6.30:3306
```

到此成功添加三个`measurement`。