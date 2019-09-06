<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [TICKscript Lambda表达式](#tickscript-lambda表达式)
	- [概述](#概述)
	- [内置函数](#内置函数)
		- [有状态函数](#有状态函数)
			- [`sigma`可用于定义强大的告警](#sigma可用于定义强大的告警)
				- [知识点-平均偏差](#知识点-平均偏差)
- [mean 平均值](#mean-平均值)
- [dev 方差](#dev-方差)
- [stdev 标准差](#stdev-标准差)
		- [无状态函数](#无状态函数)

<!-- /TOC -->

# TICKscript Lambda表达式

[Lambda表达式官方帮助](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/)

## 概述

TICKscript使用lambda表达式定义数据点的转换，并定义充当过滤器的布尔条件。

Lambda表达式包含：
* 数学运算
* 布尔运算
* 内部函数调用
* 或三者的组合

TICKscript尝试类似于InfluxQL，因为您在InfluxQL WHERE子句中使用的大多数表达式将作为TICKscript中的表达式使用，但具有自己的语法：

* lambda表达式都以关键字`lambda:`开头。
* 所有`字段Field`或`标记Tag` 的标识符必须加双引号。
* 相等的比较运算符为`==`不是`=`。

## 内置函数

内置函数分为：

| 内置函数                                                     |                                                              |                  | 数量 |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------- | ---- |
| [Stateful functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#stateful-functions) | 有状态函数                                                   |                  | 3    |
| [Stateless functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#stateless-functions) | 无状态函数                                                   |                  |      |
|                                                              | [Type conversion functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#type-conversion-functions) | 类型转换函数     |      |
|                                                              | [Existence](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#existence) | 存在函数         |      |
|                                                              | [Time functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#time-functions) | 时间函数         |      |
|                                                              | [Math functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#math-functions) | 数学函数         |      |
|                                                              | [String functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#string-functions) | 字符串函数       |      |
|                                                              | [Human string functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#human-string-functions) | 人性化字符串函数 |      |
|                                                              | [Conditional functions](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#conditional-functions) | 条件函数         | 1    |

### 有状态函数

|No.|函数|返回值|解释|
|:--|:--|:--|:--|
|1|`count()`|`int64`|返回表达式的计算次数|
|2|`sigma(value float64)`|`float64`|计算给定值远离运行平均值的标准偏差数。每次评估表达式时，都会更新运行平均值和标准差。|
|3|`spread(value float64)`|`float64`|计算传递给它的所有值的运行范围。范围是收到的最大值和最小值之间的差异。|

#### `sigma`可用于定义强大的告警

每次计算表达式时，它都会更新正在运行的统计信息，然后返回偏差。

`sigma("value") > 3.0 `表示评估收到的数据点流的平均值的标准偏差：
1. 如果小于等于 3.0，则返回 `False`；
2. 如果超过3.0，则返回`True`。

这样的表达式可以在TICKscript内部使用来定义强大的警报。

```js
stream
    |from()
    ...
    |alert()
        // use an expression to define when an alert should go critical.
        .crit(lambda: sigma("value") > 3.0)
```

##### 知识点-平均偏差

[什么是平均偏差？](https://baike.baidu.com/item/%E5%B9%B3%E5%9D%87%E5%81%8F%E5%B7%AE/11042506)

> 平均偏差是数列中各项数值与其算术平均数的离差绝对值的算术平均数。平均偏差是用来测定数列中各项数值对其平均数离势程度的一种尺度。平均偏差可分为简单平均偏差和加权平均偏差。

**定义**

在统计中，如果要反映出所有原数据间的差异，就要在各原数据之间进行差异比较，当原数据较多时，进行两两比较就很麻烦，因此需要找到一个共同的比较标准，取每个原数据值与标准值进行比较。这个标准值就是算数平均数。

平均偏差就是每个原数据值与算数平均数之差的绝对值的均值，用符号A.D.(average deviation)表示。平均偏差是一种平均离差。离差是总体各单位的标志值与算术平均数之差。因离差和为零，离差的平均数不能将离差和除以离差的个数求得，而必须将离差取绝对数来消除正负号。

平均偏差是反映各标志值与算术平均数之间的平均差异。平均偏差越大，表明各标志值与算术平均数的差异程度越大，该算术平均数的代表性就越小；平均偏差越小，表明各标志值与算术平均数的差异程度越小，该算术平均数的代表性就越大。

平均偏差又有简单平均偏差和加权平均偏差之分。

**计算**

1. 简单平均偏差
如果原数据未分组，则计算平均偏差的公式为：
$$
A.D. =  
\frac{\sum\mid x-\overline x  \mid}{n}
$$
该式称为简单平均偏差。

举例：计算cpu每个点的平均偏差值 `10 11 9 8 12 11`

* 第一个点的值为10，平均偏差为`0`
* 第二个点的值为11，平均偏差为`0.5`
* 第三个点的值为9，平均偏差为`0.82`
* 第四个点的值为8，平均偏差为`1.12`
* 第五个点的值为12，平均偏差为`1.41`
* 第六个点的值为11，平均偏差为`1.34`

```
* 计算平均值
* 计算每个点与平均值的差值的绝对值
* 计算差值的和
* 差值和除以总次数
```

**python计算脚本**

```python
import numpy

def cal_mean_std(sum_list_in):
    # type: (list) -> tuple
    N = sum_list_in.__len__()
    narray = numpy.array(sum_list_in)
    sum = narray.sum()
    mean = sum / N

    narray_dev = narray - mean
    narray_dev = narray_dev * narray_dev
    sum_dev = narray_dev.sum()
    DEV = float(sum_dev) / float(N)
    STDEV = numpy.math.sqrt(DEV)
    return round(mean,2), round(DEV,2), round(STDEV,2)


sum_list_in = [10,11,9,8,12,11]
mean, DEV, STDEV=cal_mean_std(sum_list_in)
print(mean, DEV, STDEV)

# mean 平均值
# dev 方差
# stdev 标准差
```


2. 加权平均偏差
在分组情况下，平均偏差的计算公式为：该式称为加权平均偏差。
$$
A.D. =  
\frac{\sum\mid x-\overline x  \mid f}{n f}
$$

### 无状态函数

#### 类型转换函数

|No.|函数|返回值|解释|
|:--|:--|:--|:--|
|1|`bool(value)`|`True/False`|将字符串和数字转换为布尔值|

#### [条件函数](https://docs.influxdata.com/kapacitor/v1.5/tick/expr/#conditional-functions)

##### 如果

根据第一个参数的值返回其操作数的结果。第二个和第三个参数必须返回相同的类型。

例：

```js

```

`value`上例中字段的值将是字符串，`true`或者`false`取决于作为第一个参数传递的条件。

该`if`函数的返回类型相同类型作为其第二个和第三个参数。

```js

```