<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [OpenTSDB](#opentsdb)
	- [开始之前](#开始之前)
		- [了解Hadoop的起源](#了解hadoop的起源)
		- [阅读Google的相关论文](#阅读google的相关论文)
		- [理解HDFS的原理](#理解hdfs的原理)
		- [理解HBase的原理](#理解hbase的原理)
		- [我的理解](#我的理解)
	- [OpenTSDB初体验](#opentsdb初体验)

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