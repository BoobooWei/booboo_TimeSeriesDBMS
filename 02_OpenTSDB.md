<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [OpenTSDB](#opentsdb)
	- [开始之前](#开始之前)

<!-- /TOC -->
# OpenTSDB

[OpenTSDB docs](http://opentsdb.net/docs/build/html/index.html)

## 开始之前

OpenTSDB 是可扩展的分布式时序数据库，底层依赖 HBase。作为基于通用存储开发的时序数据库典型代表，起步比较早，在时序市场的认可度相对较高。

要深入理解 OpenTSDB，需要先了解 HBase ，而 Apache HBase™是 Hadoop 数据库，是一个分布式，可扩展的大数据存储，模仿了Google的Bigtable。

正如Bigtable利用Google文件系统提供的分布式数据存储一样，Apache HBase在Hadoop和HDFS之上提供类似Bigtable的功能。

从上述关系中，我们可以梳理出以下知识点：

* [Google的Bigtable](https://ai.google/research/pubs/pub27898)
* [Hadoop的起源](https://github.com/BoobooWei/booboo_hadoop/blob/master/01_theory/01_Introduction%20to%20the%20origin%20and%20system%20of%20hadoop.md)
* [HDFS的原理](http://hadoop.apache.org/)
* [HBase的原理](https://hbase.apache.org/)


因此在学习OpenTSDB之前，需要先将以上知识点理解清楚。

### 阅读Google的Bigtable论文

[Google的Bigtable论文](https://ai.google/research/pubs/pub27898)

### 了解Hadoop的起源

[Hadoop的起源](https://github.com/BoobooWei/booboo_hadoop/blob/master/01_theory/01_Introduction%20to%20the%20origin%20and%20system%20of%20hadoop.md)

### 理解HDFS的原理

[HDFS的原理](http://hadoop.apache.org/)

### 理解HBase的原理

[HBase的原理](https://hbase.apache.org/)
