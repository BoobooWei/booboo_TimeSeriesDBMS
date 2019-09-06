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
