<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [TICKscript节点](#tickscript节点)
	- [节点分类](#节点分类)

<!-- /TOC -->
# TICKscript节点

## 节点分类

* A 定义数据获取方式：批、流
* B、C 确定待处理的数据集
* D、E 用于处理数据

![](pic/dag_03.jpg)

|NO.|节点分类|节点|含义|
|:--|:--|:--|:--|
|A|数据源定义节点|**顶级节点定义数据来源**||
|A|数据源定义节点|`BatchNode`|顶级节点，定义了：批处理模式|
|A|数据源定义节点|`StreamNode`|顶级节点，定义了：流处理模式|
|B|数据定义节点|**定义待处理的数据帧或数据流**||
|B|数据定义节点|`FromNode`|只能跟着`BatchNode`|
|B|数据定义节点|`QueryNode`|只能跟着`StreamNode`|
|C|数据操作节点|**更改或生成数据集内的值**||
|C|数据操作节点|`DefaultNode`|用于为数据系列中的tag和field设置默认值|
|C|数据操作节点|`ShiftNode`|用于移动数据点时间戳|
|C|数据操作节点|`WhereNode`|用于过滤|
|C|数据操作节点|`WindowNode`|用于在移动时间范围内缓存数据|
|D|处理节点|**用于更改数据结构**||
|D|处理节点|`CombineNode`|用于将来自单个节点的数据与自身组合在一起|
|D|处理节点|`EvalNode`|用于对表达式命名|
|D|处理节点|`GroupByNode`|按照标签`Tag`对传如数据进行分组|
|D|处理节点|`JoinNode`|根据匹配的`时间戳`连接来自任意数量管道的数据|
|D|处理节点|`UnionNode`|可以将任意数量的管道进行联合|
|D|处理节点|**用于转换或处理数据集中数据点**||
|D|处理节点|`DeleteNode`|从数据点删除字段Field和标记Tag|
|D|处理节点|`DerivativeNode`|求导数|
|D|处理节点|`FattenNode`|在特定维度上展平一组点|
|D|处理节点|`InfluxQLNode`|提供对InfluxQL功能的访问|
|D|处理节点|`StateDurationNode`|计算给定状态持续时间|
|D|处理节点|`StatsNode`|给定时间间隔发出有关另一个节点内部统计信息|
|D|处理节点|**用于触发事件**||
|D|处理节点|`AlertNode`|配置警报发射|
|D|处理节点|`DeadmanNode`|实际上是辅助函数，它是alert当数据流低于指定阈值时触发的别名|
|D|处理节点|`HTTPOutNode`|为其收到的每个组缓存最新数据，使用字符串参数作为最终定位器上下文，使其可通过Kapicator http服务器使用|
|D|处理节点|`HTTPPostNode`|将数据发布到字符串数组中指定的HTTP端点|
|D|处理节点|`InfluxDBNode`|在收到数据时将数据写入InfluxDB|
|D|处理节点|`K8sAutoscaleNode`|触发Kubernetes™资源的自动缩放|
|D|处理节点|`KapacitorLoopback`|将数据写回kapacitor流|
|D|处理节点|`log`|记录通过它的所有数据|
|E|用户自定义的函数UDF|**用于实现由用户或脚本定义的功能**||
|F|内部使用节点|**不要用**|
