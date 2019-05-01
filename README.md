<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [booboo_TimeSeriesDBMS](#boobootimeseriesdbms)
	- [开始之前](#开始之前)
	- [REFERENCES](#references)
		- [时序数据其他门户](#时序数据其他门户)
		- [时序数据库文章](#时序数据库文章)
		- [influxData](#influxdata)
		- [RRDtool](#rrdtool)
		- [KDB+](#kdb)
		- [Graphite](#graphite)
		- [OpenTSDB](#opentsdb)
		- [Prometheus](#prometheus)
		- [Beringei](#beringei)
		- [TimescaleDB](#timescaledb)
		- [AliyunTSDB](#aliyuntsdb)
		- [AzureTimeSeriesInsight](#azuretimeseriesinsight)
		- [python时序数据分析](#python时序数据分析)

<!-- /TOC -->
# booboo_TimeSeriesDBMS

## 开始之前


```bash
阅读的目的：为获取资讯而读，以及为求得理解而读。                                  
只有一种方式是真正地在阅读。
没有任何外力的帮助，你就是要读这本书。
你什么都没有，只凭着内心的力量，玩味着眼前的字句，慢慢地提升自己，从只有模糊的概念到更清楚地理解为止。
这样的一种提升，是在阅读时的一种脑力活动，也是更高的阅读技巧。
这种阅读就是让一本书向你既有的理解力做挑战。
                                                              ————《如何阅读一本书》

学会用一个技术只是第一步，最重要的是要追问自己：
1. 这个技术解决了哪些痛点？ 
2. 别的技术为什么不能解决？ 	
3. 这个技术用怎样的方法解决问题？
4. 采用这个技术真的是最好的方法吗？
如果没有这些深层次的思考，你就永远只是在赶技术的时髦而已，不会拥有影响他人的技术领导力。
                                                              ———— 蔡元楠Google Brain资深工程师
```

从1999年RRDTool第一个时序数据库产品出现到现在（2019.04）已经20年，关于时序数据库技术和架构演变在网络上有非常多优秀的文章，对于初学者，或者想了解时序数据库的人来说，缺少的应该就是“理解”了。

该仓库用于记录优秀的时序数据库文章，以及我的理解过程。

* 开源时序数据库重点研究InfluxDB和OpenTSDB；
* 云上时序数据库重点研究阿里云的TSDB。



## REFERENCES

### 时序数据其他门户

- [时序数据库DB-Engine排名](https://db-engines.com/en/ranking/time+series+dbms)
- [code.facebook.com](https://code.facebook.com/)
- [Facebook Code - Facebook Engineering Blog](https://code.fb.com/)
- [VLDB Endowment Inc.](http://www.vldb.org/)
- [CSC343 Fall 2018](https://www.teach.cs.toronto.edu//~csc343h/winter/fall/)
- [0368345801 - 数据库系统](https://moodle.tau.ac.il/enrol/index.php?id=368345801&lang=en)
- [Tova Milo的课程](http://www.cs.tau.ac.il/~milo/courses/)
- [玛格达的教学| 计算机科学与工程](https://www.cs.washington.edu/people/faculty/magda/teaching)

### 时序数据库文章

- [时序数据库技术和架构演进-云栖社区-阿里云](https://yq.aliyun.com/articles/692580?spm=a2c4e.11153959.teamhomeleft.68.15f75f72VWCFDU)
- [时序数据库连载系列：当SQL遇到时序 TimescaleDB-云栖社区-阿里云](https://yq.aliyun.com/articles/690676?spm=a2c4e.11153959.teamhomeleft.145.15f75f72VWCFDU)
- [Facebook TSDB论文翻译-云栖社区-阿里云](https://yq.aliyun.com/articles/174535?spm=a2c4e.11153959.teamhomeleft.212.15f75f72VWCFDU)
- [零距离接触阿里云时序时空数据库TSDB-云栖社区-阿里云](https://yq.aliyun.com/articles/679428?spm=a2c4e.11153940.blogrightarea174535.14.39767346N2eXi7)
- [时序数据库InfluxDB使用详解 - 简书](https://www.jianshu.com/p/a1344ca86e9b)
- [Facebook开源内存数据库Beringei，追求极致压缩率_Linux新闻_Linux公社-Linux系统门户网站](https://www.linuxidc.com/Linux/2017-02/140563.htm)
- [深度解读Facebook刚开源的beringei时序数据库-云栖社区-阿里云](https://yq.aliyun.com/articles/69354?spm=5176.8278999.602941.2)
- [时序数据库连载系列：时序数据库那些事 - 简书](https://www.jianshu.com/p/75f892a85a03)



### influxData

- [Telegraf入门| InfluxData文档](https://docs.influxdata.com/telegraf/v1.10/introduction/getting-started/)
- [Understanding InfluxDB & the TICK Stack | InfluxData](https://www.influxdata.com/time-series-platform/influxdb/)
- [InfluxDB 1.7 documentation | InfluxData Documentation](https://docs.influxdata.com/influxdb/v1.7/)
- [InfluxDB架构设计和数据布局| InfluxData文档](https://docs.influxdata.com/influxdb/v1.7/concepts/schema_and_data_layout/)
- [使用InfluxQL进行数据库管理| InfluxData文档](https://docs.influxdata.com/influxdb/v1.7/query_language/database_management/)

### RRDtool

- [RRDtool - 关于RRDtool](https://oss.oetiker.ch/rrdtool/index.en.html)
- [Tobi Oetiker - Tobi Oetiker's Toolbox](https://tobi.oetiker.ch/hp/)[RRDtool - About RRDtool](https://oss.oetiker.ch/rrdtool/)

### KDB+

- [Kx kdb+ q documentation](https://code.kx.com/v2/)

### Graphite

- [Graphite Documentation — Graphite 1.1.5 documentation](https://graphite.readthedocs.io/en/latest/)

### OpenTSDB

- [OpenTSDB - A Distributed, Scalable Monitoring System](http://opentsdb.net/)
- [OpenTSDB](https://github.com/OpenTSDB)
- [Plugin:OpenTSDB - collectd Wiki](https://collectd.org/wiki/index.php/Plugin:OpenTSDB)
- [apache/incubator-druid: Apache Druid (Incubating) - Column oriented distributed data store ideal for powering interactive applications](https://github.com/apache/incubator-druid/)
- [apache/incubator-druid: Apache Druid (Incubating) - Column oriented distributed data store ideal for powering interactive applications](https://github.com/apache/incubator-druid)

### Prometheus

- [Documentation | Prometheus](https://prometheus.io/docs/)
- [prometheus / docs：Prometheus文档：内容和静态站点生成器](https://github.com/prometheus/docs#contributing-changes)

### Beringei

- [Beringei: A high-performance time series storage engine - Facebook Code](https://code.fb.com/core-data/beringei-a-high-performance-time-series-storage-engine/?utm_source=tuicool&utm_medium=referral)
- [Beringei：高性能时间序列存储引擎 - Facebook Code](https://code.fb.com/core-data/beringei-a-high-performance-time-series-storage-engine/?s=Beringei)
- [facebookarchive/beringei: Beringei is a high performance, in-memory storage engine for time series data.](https://github.com/facebookarchive/beringei)

### TimescaleDB

- [TimescaleDB Docs | Main](https://docs.timescale.com/v1.2/main)[时间序列数据简化| 时间刻度](https://www.timescale.com/)

### AliyunTSDB

- [云产品动态-阿里云](https://cn.aliyun.com/product/new?spm=5176.149792.1266089.211view.36a534e2nTftt4&category=203&product=167)
- [数据库_数据库_阿里云 vs AWS_阿里云竞品分析-阿里云](https://help.aliyun.com/knowledge_detail/74270.html)

### AzureTimeSeriesInsight

- [微软发布Azure Time Series Insight正式版_Linux新闻_Linux公社-Linux系统门户网站](https://www.linuxidc.com/Linux/2017-11/148929.htm)
- [Time Series Insights | Microsoft Azure](https://azure.microsoft.com/en-us/services/time-series-insights/)


### python时序数据分析

- [python时序数据分析--以示例说明 - geek精神 - 博客园](https://www.cnblogs.com/bradleon/p/6832867.html)
