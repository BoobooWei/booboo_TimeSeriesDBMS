<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [OpenTSDB](#opentsdb)
	- [开始之前](#开始之前)
		- [了解Hadoop的起源](#了解hadoop的起源)
		- [阅读Google的相关论文](#阅读google的相关论文)
		- [理解HDFS的原理](#理解hdfs的原理)
		- [理解HBase的原理](#理解hbase的原理)
		- [我的理解](#我的理解)
	- [HBase初体验](#hbase初体验)
	- [OpenTSDB初体验](#opentsdb初体验)
		- [1.  安装Hbase](#1-安装hbase)
		- [2. 下载opentsdb](#2-下载opentsdb)
		- [3. 安装opentsdb](#3-安装opentsdb)
		- [4. Hbase中执行初始化脚本](#4-hbase中执行初始化脚本)
		- [5. 修改配置文件`/etc/opentsdb/opentsdb.conf`](#5-修改配置文件etcopentsdbopentsdbconf)
		- [6. 启动tsd:](#6-启动tsd)
		- [7. 访问TSD的网页](#7-访问tsd的网页)
		- [8. 安装tcollector](#8-安装tcollector)
		- [9. 修改opentsdb配置文件自动创建uid的功能](#9-修改opentsdb配置文件自动创建uid的功能)
		- [10. 重新启动tsd](#10-重新启动tsd)
		- [11. 启动tcollector](#11-启动tcollector)
		- [12. 使用OpenTSDB的UI查询`iostat.disk.await`](#12-使用opentsdb的ui查询iostatdiskawait)
		- [13. 进入HBase查看OpenTSDB创建的表明细](#13-进入hbase查看opentsdb创建的表明细)
		- [14. 关闭测试环境](#14-关闭测试环境)
	- [Bash脚本自动安装hbase_opentsdb_tcollector](#bash脚本自动安装hbaseopentsdbtcollector)

<!-- /TOC -->
# OpenTSDB

[OpenTSDB docs](http://opentsdb.net/docs/build/html/index.html)

## 开始之前

OpenTSDB 是可扩展的分布式时序数据库，底层依赖 HBase。作为基于通用存储开发的时序数据库典型代表，起步比较早，在时序市场的认可度相对较高。

要深入理解 OpenTSDB，需要先了解 HBase ，而 Apache HBase™是 Hadoop 数据库，是一个分布式，可扩展的大数据存储，模仿了Google的Bigtable。

正如Bigtable利用Google文件系统提供的分布式数据存储一样，Apache HBase在Hadoop和HDFS之上提供类似Bigtable的功能。

从上述关系中，我们可以梳理出以下关键字：

* Google
* Hadoop
* BigTable
* HBase


因此在学习OpenTSDB之前，需要先将以上关键字理解清楚。



### 了解Hadoop的起源

[Hadoop的起源](https://github.com/BoobooWei/booboo_hadoop/blob/master/01_theory/01_Introduction%20to%20the%20origin%20and%20system%20of%20hadoop.md)

![](pic/006.png)

从Google、Hadoop、TSDB这三条时间线中，不难发现时序数据库与他们之间的关系。

![](pic/007.jpeg)


### 阅读Google的相关论文

- [2003@ai.google@The Google File System](https://ai.google/research/pubs/pub51)
- [2004@www.usenix.org@MapReduce: Simplified Data Processing on Large Clusters](https://www.usenix.org/legacy/events/osdi04/tech/full_papers/dean/dean.pdf)--
- [2004@ai.google@MapReduce: Simplified Data Processing on Large Clusters](https://ai.google/research/pubs/pub62)
- [2006@www.usenix.org@Bigtable: A Distributed Storage System for Structured Data](https://www.usenix.org/legacy/event/osdi06/tech/chang/chang_html/index.html)
- [2010@ai.google@MapReduce/Bigtable for Distributed Optimization](https://ai.google/research/pubs/pub36948)

国内中文翻译参考：

* [Google-GFS 中文](https://github.com/BoobooWei/booboo_hadoop/blob/master/hadoop_pdf/Google/Google-File-System%E4%B8%AD%E6%96%87%E7%89%88_1.0.pdf)
* [Google-MapReduce 中文](https://github.com/BoobooWei/booboo_hadoop/blob/master/hadoop_pdf/Google/Google-MapReduce%E4%B8%AD%E6%96%87%E7%89%88_1.0.pdf)
* [Google-Bigtable 中文](https://github.com/BoobooWei/booboo_hadoop/blob/master/hadoop_pdf/Google/Google-Bigtable%E4%B8%AD%E6%96%87%E7%89%88_1.0.pdf)

### 理解HDFS的原理

[HDFS的原理](http://hadoop.apache.org/)

### 理解HBase的原理

[HBase的原理](https://hbase.apache.org/)

### 我的理解

此处没有必要去将每一个技术都深入学习，在阅读文献的基础上，能够理解这些技术应用的场景和实现原理即可。因为理解这些技术的目的是为了学习时序数据库。

下图是我个人对HDFS、HBase从底层文件角度的关系理解：

![](pic/008_fs_mysql.jpeg)

![](pic/008_fs_hdfs.jpeg)

![](pic/008_fs_hbase.jpeg)

## HBase初体验

[hbase-2.1.4安装和使用](https://github.com/BoobooWei/booboo_hadoop/blob/master/02_operation/hbaseInstall.md)

## OpenTSDB初体验

### 1.  安装Hbase

```shell
[root@db install]# cat /etc/redhat-release
CentOS release 6.9 (Final)
[root@db hbase-2.1.4]# bin/start-hbase.sh
running master, logging to /alidata/install/hbase-2.1.4/bin/../logs/hbase-root-master-db.out
[root@db hbase-2.1.4]# ss -luntp|grep 2181
tcp    LISTEN     0      50                     *:2181                  *:*      users:(("java",31273,182))
```

### 2. 下载opentsdb

[OpenTSDB Github下载地址](https://github.com/OpenTSDB/opentsdb/releases)

```shell
[root@db install]# wget https://github.com/OpenTSDB/opentsdb/releases/download/v2.4.0/opentsdb-2.4.0.noarch.rpm
```

### 3. 安装opentsdb

```shell
[root@db install]# yum localinstall -y opentsdb-2.4.0.noarch.rpm
已安装:
  opentsdb.noarch 0:2.4.0-1

作为依赖被安装:
  gd.x86_64 0:2.0.35-11.el6           gnuplot.x86_64 0:4.2.6-2.el6        gnuplot-common.x86_64 0:4.2.6-2.el6
  libXpm.x86_64 0:3.5.10-2.el6

完毕！
[root@db install]# rpm -ql opentsdb
/usr/bin/tsdb
/usr/share/opentsdb
/usr/share/opentsdb/bin
/usr/share/opentsdb/bin/mygnuplot.bat
/usr/share/opentsdb/bin/mygnuplot.sh
/usr/share/opentsdb/bin/tsdb
/usr/share/opentsdb/etc
/usr/share/opentsdb/etc/init.d
/usr/share/opentsdb/etc/init.d/opentsdb
/usr/share/opentsdb/etc/opentsdb
/usr/share/opentsdb/etc/opentsdb/logback.xml
/usr/share/opentsdb/etc/opentsdb/opentsdb.conf
/usr/share/opentsdb/etc/systemd
/usr/share/opentsdb/etc/systemd/system
/usr/share/opentsdb/etc/systemd/system/opentsdb@.service
/usr/share/opentsdb/lib
/usr/share/opentsdb/lib/asm-4.0.jar
/usr/share/opentsdb/lib/async-1.4.0.jar
/usr/share/opentsdb/lib/asynchbase-1.8.2.jar
/usr/share/opentsdb/lib/commons-jexl-2.1.1.jar
/usr/share/opentsdb/lib/commons-logging-1.1.1.jar
/usr/share/opentsdb/lib/commons-math3-3.4.1.jar
/usr/share/opentsdb/lib/guava-18.0.jar
/usr/share/opentsdb/lib/jackson-annotations-2.9.5.jar
/usr/share/opentsdb/lib/jackson-core-2.9.5.jar
/usr/share/opentsdb/lib/jackson-databind-2.9.5.jar
/usr/share/opentsdb/lib/javacc-6.1.2.jar
/usr/share/opentsdb/lib/jgrapht-core-0.9.1.jar
/usr/share/opentsdb/lib/kryo-2.21.1.jar
/usr/share/opentsdb/lib/log4j-over-slf4j-1.7.7.jar
/usr/share/opentsdb/lib/logback-classic-1.0.13.jar
/usr/share/opentsdb/lib/logback-core-1.0.13.jar
/usr/share/opentsdb/lib/minlog-1.2.jar
/usr/share/opentsdb/lib/netty-3.10.6.Final.jar
/usr/share/opentsdb/lib/protobuf-java-2.5.0.jar
/usr/share/opentsdb/lib/reflectasm-1.07-shaded.jar
/usr/share/opentsdb/lib/slf4j-api-1.7.7.jar
/usr/share/opentsdb/lib/tsdb-2.4.0.jar
/usr/share/opentsdb/lib/zookeeper-3.4.6.jar
/usr/share/opentsdb/plugins
/usr/share/opentsdb/static
/usr/share/opentsdb/static/3FE8D2D31B2B8088AB5C3AAA904D7911.cache.html
/usr/share/opentsdb/static/508491AE9B85F1EF694B9D473E6DAD87.cache.html
/usr/share/opentsdb/static/5215AC11CF2E617D244E775B35EDD818.cache.html
/usr/share/opentsdb/static/72EAC0365EDAD7DE09D54C32270D37DC.cache.html
/usr/share/opentsdb/static/9F09E1D7F208BA0E3F5FFF35E4615599.cache.html
/usr/share/opentsdb/static/clear.cache.gif
/usr/share/opentsdb/static/favicon.ico
/usr/share/opentsdb/static/gwt
/usr/share/opentsdb/static/gwt/opentsdb
/usr/share/opentsdb/static/gwt/opentsdb/images
/usr/share/opentsdb/static/gwt/opentsdb/images/corner.png
/usr/share/opentsdb/static/gwt/opentsdb/images/hborder.png
/usr/share/opentsdb/static/gwt/opentsdb/images/ie6
/usr/share/opentsdb/static/gwt/opentsdb/images/ie6/corner_dialog_topleft.png
/usr/share/opentsdb/static/gwt/opentsdb/images/ie6/corner_dialog_topright.png
/usr/share/opentsdb/static/gwt/opentsdb/images/ie6/hborder_blue_shadow.png
/usr/share/opentsdb/static/gwt/opentsdb/images/ie6/hborder_gray_shadow.png
/usr/share/opentsdb/static/gwt/opentsdb/images/ie6/vborder_blue_shadow.png
/usr/share/opentsdb/static/gwt/opentsdb/images/ie6/vborder_gray_shadow.png
/usr/share/opentsdb/static/gwt/opentsdb/images/splitPanelThumb.png
/usr/share/opentsdb/static/gwt/opentsdb/images/vborder.png
/usr/share/opentsdb/static/gwt/opentsdb/opentsdb.css
/usr/share/opentsdb/static/gwt/opentsdb/opentsdb_rtl.css
/usr/share/opentsdb/static/hosted.html
/usr/share/opentsdb/static/opentsdb_header.jpg
/usr/share/opentsdb/static/queryui.nocache.js
/usr/share/opentsdb/tools
/usr/share/opentsdb/tools/check_tsd
/usr/share/opentsdb/tools/clean_cache.sh
/usr/share/opentsdb/tools/create_table.sh
/usr/share/opentsdb/tools/opentsdb_restart.py
/usr/share/opentsdb/tools/tsddrain.py
/usr/share/opentsdb/tools/upgrade_1to2.sh
/var/cache/opentsdb
/var/log/opentsdb
```

 启动服务名`opentsdb`

```
[root@db install]# ll /etc/init.d/opentsdb
lrwxrwxrwx 1 root root 39 5月   3 22:44 /etc/init.d/opentsdb -> /usr/share/opentsdb/etc/init.d/opentsdb
```

### 4. Hbase中执行初始化脚本

```sh l lsh l
[root@db install]# env COMPRESSION=NONE HBASE_HOME=/alidata/install/hbase-2.1.4/ /usr/share/opentsdb/tools/create_table.sh
2019-05-03 23:06:14,454 WARN  [main] util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
HBase Shell
Use "help" to get list of supported commands.
Use "exit" to quit this interactive shell.
For Reference, please visit: http://hbase.apache.org/2.0/book.html#shell
Version 2.1.4, r5b7722f8551bca783adb36a920ca77e417ca99d1, Tue Mar 19 19:05:06 UTC 2019
Took 0.0052 seconds
create 'tsdb-uid',
  {NAME => 'id', COMPRESSION => 'NONE', BLOOMFILTER => 'ROW', DATA_BLOCK_ENCODING => 'DIFF'},
  {NAME => 'name', COMPRESSION => 'NONE', BLOOMFILTER => 'ROW', DATA_BLOCK_ENCODING => 'DIFF'}
Created table tsdb-uid
Took 1.3271 seconds
Hbase::Table - tsdb-uid

create 'tsdb',
  {NAME => 't', VERSIONS => 1, COMPRESSION => 'NONE', BLOOMFILTER => 'ROW', DATA_BLOCK_ENCODING => 'DIFF', TTL => 'FOREVER'}
Created table tsdb
Took 0.7314 seconds
Hbase::Table - tsdb

create 'tsdb-tree',
  {NAME => 't', VERSIONS => 1, COMPRESSION => 'NONE', BLOOMFILTER => 'ROW', DATA_BLOCK_ENCODING => 'DIFF'}
Created table tsdb-tree
Took 0.7351 seconds
Hbase::Table - tsdb-tree

create 'tsdb-meta',
  {NAME => 'name', COMPRESSION => 'NONE', BLOOMFILTER => 'ROW', DATA_BLOCK_ENCODING => 'DIFF'}
Created table tsdb-meta
Took 0.7300 seconds
Hbase::Table - tsdb-meta

```

该脚本会新建四个表：`tsdb`, `tsdb-uid`, `tsdb-tree` 和 `tsdb-meta`。

### 5. 修改配置文件`/etc/opentsdb/opentsdb.conf`

```shell
[root@db install]# grep -v '^#\|^$' /etc/opentsdb/opentsdb.conf
tsd.network.port = 4242
tsd.http.staticroot = /usr/share/opentsdb/static/
tsd.http.cachedir = /tmp/opentsdb
tsd.core.plugin_path = /usr/share/opentsdb/plugins
```

### 6. 启动tsd:

```shell
tsdb tsd

[root@db ~]# ss -luntp|grep 4242
tcp    LISTEN     0      50                     *:4242                  *:*      users:(("java",732,60))
[root@db ~]# ps -ef|grep tsd
root       732 31176  0 23:12 pts/0    00:00:04 java -enableassertions -enablesystemassertions -classpath /usr/share/opentsdb/*.jar:/usr/share/opentsdb:/usr/share/opentsdb/bin:/usr/share/opentsdb/lib/asm-4.0.jar:/usr/share/opentsdb/lib/async-1.4.0.jar:/usr/share/opentsdb/lib/asynchbase-1.8.2.jar:/usr/share/opentsdb/lib/commons-jexl-2.1.1.jar:/usr/share/opentsdb/lib/commons-logging-1.1.1.jar:/usr/share/opentsdb/lib/commons-math3-3.4.1.jar:/usr/share/opentsdb/lib/guava-18.0.jar:/usr/share/opentsdb/lib/jackson-annotations-2.9.5.jar:/usr/share/opentsdb/lib/jackson-core-2.9.5.jar:/usr/share/opentsdb/lib/jackson-databind-2.9.5.jar:/usr/share/opentsdb/lib/javacc-6.1.2.jar:/usr/share/opentsdb/lib/jgrapht-core-0.9.1.jar:/usr/share/opentsdb/lib/kryo-2.21.1.jar:/usr/share/opentsdb/lib/log4j-over-slf4j-1.7.7.jar:/usr/share/opentsdb/lib/logback-classic-1.0.13.jar:/usr/share/opentsdb/lib/logback-core-1.0.13.jar:/usr/share/opentsdb/lib/minlog-1.2.jar:/usr/share/opentsdb/lib/netty-3.10.6.Final.jar:/usr/share/opentsdb/lib/protobuf-java-2.5.0.jar:/usr/share/opentsdb/lib/reflectasm-1.07-shaded.jar:/usr/share/opentsdb/lib/slf4j-api-1.7.7.jar:/usr/share/opentsdb/lib/tsdb-2.4.0.jar:/usr/share/opentsdb/lib/zookeeper-3.4.6.jar:/etc/opentsdb net.opentsdb.tools.TSDMain
```

### 7. 访问TSD的网页

访问 [http://127.0.0.1:4242](http://127.0.0.1:4242/)

![](pic/010.jpg)

### 8. 安装tcollector

```shell
[root@db install]# git clone https://github.com/OpenTSDB/tcollector.git
[root@db install]# cd tcollector/
[root@db tcollector]# ls
AUTHORS       COPYING         eos        rpm          tcollector.py
CHANGELOG.md  COPYING.LESSER  mocks.py   stumbleupon  tests.py
collectors    debian          README.md  tcollector   THANKS
```

### 9. 修改opentsdb配置文件自动创建uid的功能

`tsd.core.auto_create_metrics = true `

具体操作如下：

```shell
[root@db tcollector]# vim /etc/opentsdb/opentsdb.conf
[root@db tcollector]# grep -v '^#\|^$' /etc/opentsdb/opentsdb.conf
tsd.network.port = 4242
tsd.http.staticroot = /usr/share/opentsdb/static/
tsd.http.cachedir = /tmp/opentsdb
tsd.core.auto_create_metrics = true
tsd.core.plugin_path = /usr/share/opentsdb/plugins
```

### 10. 重新启动tsd

```shell
[root@db tcollector]# kill -9 31176
[root@db tcollector]# ps -ef|grep open
root      1890  1671  0 23:50 pts/7    00:00:00 grep open
[root@db tcollector]# tsdb tsd
```

### 11. 启动tcollector

```shell
[root@db tcollector]# ll /alidata/install/tcollector/tcollector
-rwxr-xr-x 1 root root 2554 5月   3 23:37 /alidata/install/tcollector/tcollector
[root@db tcollector]# /alidata/install/tcollector/tcollector start -H localhost -p 4242
Starting /alidata/install/tcollector/tcollector.py
[root@db tcollector]# tailf /var/log/tcollector.log
2019-05-03 23:53:28,275 tcollector[2052] WARNING: collector zabbix_bridge_cache.py terminated after 16 seconds with status code 1, marking dead
2019-05-03 23:53:28,275 tcollector[2052] INFO: removing postgresql.py from the list of collectors (by request)
2019-05-03 23:53:28,275 tcollector[2052] WARNING: collector zabbix_bridge.py terminated after 16 seconds with status code 1, marking dead
2019-05-03 23:53:28,275 tcollector[2052] INFO: removing riak.py from the list of collectors (by request)
2019-05-03 23:53:28,275 tcollector[2052] INFO: removing redis_stats.py from the list of collectors (by request)
2019-05-03 23:53:28,275 tcollector[2052] INFO: removing zookeeper.py from the list of collectors (by request)
2019-05-03 23:53:28,275 tcollector[2052] INFO: removing opentsdb.sh from the list of collectors (by request)
2019-05-03 23:53:28,275 tcollector[2052] WARNING: collector tcollector.py terminated after 15 seconds with status code 1, marking dead
2019-05-03 23:53:28,276 tcollector[2052] INFO: removing jolokia.py from the list of collectors (by request)
2019-05-03 23:53:28,276 tcollector[2052] INFO: removing postgresql_replication.py from the list of collectors (by request)
[root@db tcollector]# ps -ef|grep tcoll
root      2051     1  0 23:53 pts/0    00:00:00 /bin/sh /alidata/install/tcollector/tcollector start -H localhost -p 4242
root      2052  2051  0 23:53 pts/0    00:00:00 /usr/bin/python2.6 /alidata/install/tcollector/tcollector.py -H localhost -p 4242
nobody    2057  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/hbase_master.py
nobody    2060  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/udp_bridge.py
nobody    2067  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/procstats.py
nobody    2074  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/procnettcp.py
nobody    2076  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/tcp_bridge.py
root      2078  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/sysload.py
nobody    2089  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/hadoop_yarn_node_manager.py
nobody    2102  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/hadoop_namenode.py
nobody    2110  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/hadoop_yarn_resource_manager.py
nobody    2116  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/ifstat.py
nobody    2122  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/hbase_regionserver.py
nobody    2124  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/iostat.py
nobody    2126  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/netstat.py
nobody    2132  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/ntpstat.py
nobody    2133  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/dfstat.py
nobody    2141  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/hadoop_datanode.py
root      2146  2052  0 23:53 ?        00:00:00 python /alidata/install/tcollector/collectors/0/mountstats.py
```

### 12. 使用OpenTSDB的UI查询`iostat.disk.await`

![](pic/011.png)

### 13. 进入HBase查看OpenTSDB创建的表明细

```bash
[root@db hbase-2.1.4]# pwd
/alidata/install/hbase-2.1.4
[root@db hbase-2.1.4]# bin/hbase shell
2019-05-04 00:11:33,679 WARN  [main] util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
HBase Shell
Use "help" to get list of supported commands.
Use "exit" to quit this interactive shell.
For Reference, please visit: http://hbase.apache.org/2.0/book.html#shell
Version 2.1.4, r5b7722f8551bca783adb36a920ca77e417ca99d1, Tue Mar 19 19:05:06 UTC 2019
Took 0.0040 seconds
hbase(main):014:0> list_namespace_tables 'default'
TABLE
tsdb
tsdb-meta
tsdb-tree
tsdb-uid
4 row(s)
Took 0.0107 seconds
=> ["tsdb", "tsdb-meta", "tsdb-tree", "tsdb-uid"]

hbase(main):001:0> list
TABLE
tsdb
tsdb-meta
tsdb-tree
tsdb-uid
4 row(s)
Took 0.5340 seconds
=> ["tsdb", "tsdb-meta", "tsdb-tree", "tsdb-uid"]
```

* Hbase::Table - tsdb-uid::**存储name和uid的映射关系**
* Hbase::Table - tsdb::**存储数据点**
* Hbase::Table - tsdb-tree::**树形表**
* Hbase::Table - tsdb-meta::**元数据表**

具体解析[参考文章](https://www.jianshu.com/p/b7e3a33c71e9)

### 14. 关闭测试环境

```
[root@db ~]# /alidata/install/tcollector/tcollector stop
[root@db ~]# ps -ef|grep tsd
root      1899  1671  0 May03 pts/7    00:00:16 java -enableassertions -enablesystemassertions -classpath /usr/share/opentsdb/*.jar:/usr/share/opentsdb:/usr/share/opentsdb/bin:/usr/share/opentsdb/lib/asm-4.0.jar:/usr/share/opentsdb/lib/async-1.4.0.jar:/usr/share/opentsdb/lib/asynchbase-1.8.2.jar:/usr/share/opentsdb/lib/commons-jexl-2.1.1.jar:/usr/share/opentsdb/lib/commons-logging-1.1.1.jar:/usr/share/opentsdb/lib/commons-math3-3.4.1.jar:/usr/share/opentsdb/lib/guava-18.0.jar:/usr/share/opentsdb/lib/jackson-annotations-2.9.5.jar:/usr/share/opentsdb/lib/jackson-core-2.9.5.jar:/usr/share/opentsdb/lib/jackson-databind-2.9.5.jar:/usr/share/opentsdb/lib/javacc-6.1.2.jar:/usr/share/opentsdb/lib/jgrapht-core-0.9.1.jar:/usr/share/opentsdb/lib/kryo-2.21.1.jar:/usr/share/opentsdb/lib/log4j-over-slf4j-1.7.7.jar:/usr/share/opentsdb/lib/logback-classic-1.0.13.jar:/usr/share/opentsdb/lib/logback-core-1.0.13.jar:/usr/share/opentsdb/lib/minlog-1.2.jar:/usr/share/opentsdb/lib/netty-3.10.6.Final.jar:/usr/share/opentsdb/lib/protobuf-java-2.5.0.jar:/usr/share/opentsdb/lib/reflectasm-1.07-shaded.jar:/usr/share/opentsdb/lib/slf4j-api-1.7.7.jar:/usr/share/opentsdb/lib/tsdb-2.4.0.jar:/usr/share/opentsdb/lib/zookeeper-3.4.6.jar:/etc/opentsdb net.opentsdb.tools.TSDMain
root      4216  4196  0 00:19 pts/10   00:00:00 grep tsd
[root@db ~]# kill -9 1899
[root@db ~]# /alidata/install/hbase-2.1.4/bin/stop-hbase.sh
stopping hbase...........
```

## Bash脚本自动安装hbase_opentsdb_tcollector

[Bash脚本自动安装链接](scripts/auto_install_hbase_opentsdb_tcollector.sh)
