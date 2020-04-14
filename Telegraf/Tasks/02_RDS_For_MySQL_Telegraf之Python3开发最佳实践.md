# 02_RDS_For_MySQL_Telegraf之Python3开发最佳实践




# 时序数据库建模

## Feature Request



- Gets the metalock session details and the long uncommitted transaction session ID that Used to quickly resolve metalock conflicts
- Get the session details of InnoDB transaction lock conflicts and how many transactions have been blocked to quickly resolve innodb row lock conflicts
- Get deadlock information to analyze the deadlock reason
- 获取元锁会话明细和导致元锁冲突的长时间未提交的事务会话id，用于快速解决元锁冲突
- 获取innodb事务锁冲突的会话明细,以及一共阻塞了多少事务，用于快速解决行锁冲突
- 获取死锁信息,用于分析行死锁原因



### Proposal:



#### mysql_metadatalock_session



> 元锁会话明细

```sql
select * from information_schema.processlist where State='Waiting for table metadata lock';
    //+-------+------+-----------+------+---------+------+---------------------------------+----------------------------------+
    //| ID    | USER | HOST      | DB   | COMMAND | TIME | STATE                           | INFO                             |
    //+-------+------+-----------+------+---------+------+---------------------------------+----------------------------------+
    //| 46435 | root | localhost | test | Query   |  222 | Waiting for table metadata lock | alter table t1 add column xx int |
    //+-------+------+-----------+------+---------+------+---------------------------------+----------------------------------+
```



| mysql_metadatalock_session | key         | 数据类型 | 说明                            |
| :------------------------- | :---------- | :------- | :------------------------------ |
| `Tags`                     | `server`    | `string` | url:3306                        |
|                            | instanceId  | string   | 实例唯一标识符                  |
|                            | host        | string   | 实例描述信息                    |
|                            | product     | string   | rds                             |
|                            | subproduct  | string   | 【可选】idc机房的资产导入模板id |
| `Fields`                   | `id`        | `int64`  | `会话id`                        |
|                            | `user`      | `string` | `会话的登录用户名`              |
|                            | `host`      | `string` | `会话的来源地址`                |
|                            | `db`        | `string` | `会话访问的数据库名`            |
|                            | `command`   | `string` | `会话执行的语句类型`            |
|                            | `conn_time` | `int64`  | `会话持续时间`                  |
|                            | `state`     | `string` | `会话状态`                      |
|                            | `info`      | `string` | `会话执行的具体SQL语句`         |



#### mysql_metadatalock_info



> 元锁个数

```
select a.count, b.id
from
(select count(*) count from information_schema.processlist where State='Waiting for table metadata lock') a
join
(
select max(id) id from
  (select i.trx_mysql_thread_id id from information_schema.innodb_trx i,
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
  and i.trx_mysql_thread_id  not in (connection_id(),p.id)
  union select 0 id) t1
  )b;
 
 
+-------+------+
| count | id   |
+-------+------+
|     0 |    0 |
+-------+------+
```



| mysql_metadatalock_info | key        | 数据类型 | 说明                                   |
| :---------------------- | :--------- | :------- | :------------------------------------- |
| Tags                    | `server`   | `string` | `数据库url地址或主机名`                |
|                         | host       | string   | 实例的描述信息                         |
|                         | instanceId | string   | 实例的唯一标识符                       |
|                         | product    | string   | rds                                    |
|                         | subproduct | string   | idc机房的资产导入模板id                |
| `Fields`                | `count`    | `int64`  | `会话总数`                             |
|                         | `id`       | `int64`  | 导致元锁冲突的长时间未提交的事务会话id |







#### mysql_metadatalock_trx_id



> 导致元锁冲突的长时间未提交的事务会话id

```
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
+---------------------+
| trx_mysql_thread_id |
+---------------------+
|               47473 |
+---------------------+
```



| mysql_metadatalock_trx_id | key        | 数据类型 | 说明                    |
| :------------------------ | :--------- | :------- | :---------------------- |
| `Tags`                    | `server`   | `string` | `数据库url地址或主机名` |
|                           | host       | string   | 实例的描述信息          |
|                           | instanceId | string   | 实例的唯一标识符        |
|                           | product    | string   | rds                     |
|                           | subproduct | string   | idc机房的资产导入模板id |
| `Fields`                  | `id`       | `int64`  | `会话id`                |



#### mysql_innodb_blocking_trx_id



> 获取到innodb事务锁冲突的会话明细,以及一共阻塞了多少事务，用于快速解决行锁冲突

```
SELECT
    a1.ID,
    a1.USER,
    a1.HOST,
    a1.DB,
    a1.COMMAND,
    a1.TIME,
    a1.STATE,
    IFNULL(a1.INFO, '') INFO,
    a3.trx_id,
    a3.trx_state,
    unix_timestamp(a3.trx_started) trx_started,
    IFNULL(a3.trx_requested_lock_id, '') trx_requested_lock_id,
    IFNULL(a3.trx_wait_started, '') trx_wait_started,
    a3.trx_weight,
    a3.trx_mysql_thread_id,
    IFNULL(a3.trx_query, '') trx_query,
    IFNULL(a3.trx_operation_state, '') trx_operation_state,
    a3.trx_tables_in_use,
    a3.trx_tables_locked,
    a3.trx_lock_structs,
    a3.trx_lock_memory_bytes,
    a3.trx_rows_locked,
    a3.trx_rows_modified,
    a3.trx_concurrency_tickets,
    a3.trx_isolation_level,
    a3.trx_unique_checks,
    IFNULL(a3.trx_foreign_key_checks, '') trx_foreign_key_checks,
    IFNULL(a3.trx_last_foreign_key_error, '') trx_last_foreign_key_error,
    a3.trx_adaptive_hash_latched,
    a3.trx_adaptive_hash_timeout,
    a3.trx_is_read_only,
    a3.trx_autocommit_non_locking,
    a2.countnum
FROM
    (SELECT
        min_blocking_trx_id AS blocking_trx_id,
            COUNT(trx_mysql_thread_id) countnum
    FROM
        (SELECT
        trx_mysql_thread_id,
            MIN(blocking_trx_id) AS min_blocking_trx_id
    FROM
        (SELECT
        a.trx_id,
            a.trx_state,
            b.requesting_trx_id,
            b.blocking_trx_id,
            a.trx_mysql_thread_id
    FROM
        information_schema.innodb_lock_waits AS b
    LEFT JOIN information_schema.innodb_trx AS a ON a.trx_id = b.requesting_trx_id) AS t1
    GROUP BY trx_mysql_thread_id
    ORDER BY min_blocking_trx_id) c
    GROUP BY min_blocking_trx_id) a2
        JOIN
    information_schema.innodb_trx a3 ON a2.blocking_trx_id = a3.trx_id
        JOIN
    information_schema.processlist a1 ON a1.id = a3.trx_mysql_thread_id;
```





| mysql_innodb_blocking_trx_id | key                          | 数据类型 | 说明                                                         |
| :--------------------------- | :--------------------------- | :------- | :----------------------------------------------------------- |
| `Tags`                       | `server`                     | `string` | `数据库url地址或主机名`                                      |
|                              | host                         | string   | 实例的描述信息                                               |
|                              | instanceId                   | string   | 实例的唯一标识符                                             |
|                              | product                      | string   | rds                                                          |
|                              | subproduct                   | string   | idc机房的资产导入模板id                                      |
| `Fields`                     | `id`                         | `int64`  | `会话id`                                                     |
|                              | `user`                       | `string` | `会话的登录用户名`                                           |
|                              | `host`                       | `string` | `会话的来源地址`                                             |
|                              | `db`                         | `string` | `会话访问的数据库名`                                         |
|                              | `command`                    | `string` | `会话执行的语句类型`                                         |
|                              | `time`                       | `int64`  | `会话持续时间`                                               |
|                              | `state`                      | `string` | `会话状态`                                                   |
|                              | `info`                       | `string` | `会话执行的具体SQL语句`                                      |
|                              | `trx_id`                     | `int64`  | `事务id`                                                     |
|                              | `trx_state string`           | `string` | `事务状态`                                                   |
|                              | `trx_started`                | `string` | `事务开始时间`                                               |
|                              | `trx_requested_lock_id`      | `string` | `等待事务的锁id`                                             |
|                              | `trx_wait_started`           | `string` | `事务等待开始的事件`                                         |
|                              | `trx_weight`                 | `int64`  | `事务的权重`                                                 |
|                              | `trx_mysql_thread_id`        | `int64`  | `事务线程id`                                                 |
|                              | `trx_query`                  | `string` | `事务运行的SQL`                                              |
|                              | `trx_operation_state`        | `string` | `事务的操作轧辊台`                                           |
|                              | `trx_tables_in_use`          | `int64`  | `事务使用的表`                                               |
|                              | `trx_tables_locked`          | `int64`  | `被锁住的表`                                                 |
|                              | `trx_lock_structs`           | `int64`  | `事务保留的锁`                                               |
|                              | `trx_lock_memory_bytes`      | `int64`  | `事务锁定的内存大小`                                         |
|                              | `trx_rows_locked`            | `int64`  | `事物锁定的最大行树`                                         |
|                              | `trx_rows_modified`          | `int64`  | `事务修改的行数`                                             |
|                              | `trx_concurrency_tickets`    | `int64`  | ``                                                           |
|                              | `trx_isolation_level`        | `string` | `事务隔离级别`                                               |
|                              | `trx_unique_checks`          | `int64`  | `事务的唯一键检查是打开还是关闭`                             |
|                              | `trx_foreign_key_checks`     | `int64`  | `事务的外键检查是否开启`                                     |
|                              | `trx_last_foreign_key_error` | `string` | `事务最近一次外键错误`                                       |
|                              | `trx_adaptive_hash_latched`  | `int64`  | `自适应哈希索引是否被当前事务锁定`                           |
|                              | `trx_adaptive_hash_timeout`  | `int64`  | ``                                                           |
|                              | `trx_is_read_only`           | `int64`  | `1表示事务是只读的`                                          |
|                              | `trx_autocommit_non_locking` | `int64`  | `值1表示事务是不使用for update或lock in shared mode子句的select语句，并且在启用autocommit设置的情况下执行，因此事务将只包含此语句。（5.6.4及更高版本。）当此列和trx_均为只读时，innodb会优化事务，以减少与更改表数据的事务相关的开销。` |
|                              | `countnum`                   | `int64`  | `该事务阻塞了多少其他事务`                                   |



#### mysql_innodb_lock_waits



> 获取到innodb事务锁冲突锁信息,用于分析行所锁原因

```
select * from information_schema.innodb_locks;
 +-------------+-------------+-----------+-----------+-------------+------------+------------+-----------+----------+-----------+
 | lock_id     | lock_trx_id | lock_mode | lock_type | lock_table  | lock_index | lock_space | lock_page | lock_rec | lock_data |
 +-------------+-------------+-----------+-----------+-------------+------------+------------+-----------+----------+-----------+
 | 7397:54:3:2 | 7397        | X         | RECORD    | `test`.`t1` | PRIMARY    |         54 |         3 |        2 | 1         |
 | 7396:54:3:2 | 7396        | X         | RECORD    | `test`.`t1` | PRIMARY    |         54 |         3 |        2 | 1         |
 +-------------+-------------+-----------+-----------+-------------+------------+------------+-----------+----------+-----------+
```



| mysql_innodb_lock_waits | key           | 数据类型 | 说明                    |
| :---------------------- | :------------ | :------- | :---------------------- |
| `Tags`                  | `server`      | `string` | `数据库url地址或主机名` |
|                         | host          | string   | 实例的描述信息          |
|                         | instanceId    | string   | 实例的唯一标识符        |
|                         | product       | string   | rds                     |
|                         | subproduct    | string   | idc机房的资产导入模板id |
| `Fields`                | `lock_id`     | `string` | `锁id`                  |
|                         | `lock_trx_id` | `int64`  | `事务id`                |
|                         | `lock_mode`   | `string` | `锁的模式`              |
|                         | `lock_type`   | `string` | `锁的类型`              |
|                         | `lock_table`  | `string` | `申请锁的表`            |
|                         | `lock_index`  | `string` | `锁住的索引`            |
|                         | `lock_space`  | `int64`  | `锁对象的space id`      |
|                         | `lock_page`   | `int64`  | `事务锁定页的数量`      |
|                         | `lock_rec`    | `int64`  | `事务锁定行的数量`      |
|                         | `lock_data`   | `int64`  | `事务锁定记录的主键值`  |

### Use case:



Once a lock alarm occurs, the cause and solution can be obtained immediately. It can be applied to fault detection and self-healing.
一旦出现锁的告警，能够立刻获取到原因，以及解决方法。可以应用于故障发现和自愈。


