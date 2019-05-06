#!/bin/bash

# auto_install_Hbase_Opentsdb_alone
# booboowei
# 20190504
# redhat/centos 6/7

install_dir=/alidata/install/
if [ ! -d "${install_dir}" ]
then
  mkdir ${install_dir}
fi
#===================================step1:install hbase========================
# install java
yum install -y java-1.8.0-openjdk.x86_64
# download hbase
mkdir ${install_dir} -p
cd ${instal_dir}
wget http://apache.claz.org/hbase/2.1.4/hbase-2.1.4-bin.tar.gz
tar -xf hbase-2.1.4-bin.tar.gz
cd hbase-2.1.4
# configuration
cat >> conf/hbase-env.sh << ENDF
export JAVA_HOME=/usr/
export HBASE_MANAGES_ZK=false
ENDF
useradd -s /sbin/nologin testuser
sed -i '3,$d' conf/hbase-site.xml
cat >> conf/hbase-site.xml << ENDF
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>file:///home/testuser/hbase</value>
  </property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/home/testuser/zookeeper</value>
  </property>
  <property>
    <name>hbase.unsafe.stream.capability.enforce</name>
    <value>false</value>
    <description>
      Controls whether HBase will check for stream capabilities (hflush/hsync).

      Disable this if you intend to run on LocalFileSystem, denoted by a rootdir
      with the 'file://' scheme, but be mindful of the NOTE below.

      WARNING: Setting this to false blinds you to potential data loss and
      inconsistent system state in the event of process and/or node failures. If
      HBase is complaining of an inability to use hsync or hflush it's most
      likely not a false positive.
    </description>
  </property>
</configuration>
ENDF

# start HBase
bin/start-hbase.sh

# checkout

ps -ef|grep hbase
ss -luntp|grep java


#===================================step2:install opentsdb========================
cd ${instal_dir}
wget https://github.com/OpenTSDB/opentsdb/releases/download/v2.4.0/opentsdb-2.4.0.noarch.rpm
yum localinstall -y opentsdb-2.4.0.noarch.rpm
env COMPRESSION=NONE HBASE_HOME=${install_dir}/hbase-2.1.4/ /usr/share/opentsdb/tools/create_table.sh

# start tsd
tsdb tsd &

# checkout
ps -ef|grep tsd
ss -luntp|grep 4242

#===================================step3:install tcollector========================
git clone https://github.com/OpenTSDB/tcollector.git
# configuration opentsdb
cat >> /etc/opentsdb/opentsdb.conf << ENDF
tsd.core.auto_create_metrics = true
ENDF

# restart opentsdb tsd
kill -9 `ps -ef|grep opentsdb|grep tsd|sed -n '1p'|awk '{print $2}'`
tsdb tsd &

# start tcollector
${install_dir}/tcollector/tcollector start -H localhost -p 4242

# checkout
ps -ef|grep tcoll

#===================================step4:UI========================
# Hbase UI
# http://localhost:4242
# OpenTSDB UI
# http://10.200.6.30:16010

#===================================step5:END========================
# ${install_dir}/tcollector/tcollector stop
# kill -9 `ps -ef|grep opentsdb|grep tsd|sed -n '1p'|awk '{print $2}'`
# ${install_dir}/hbase-2.1.4/bin/stop-hbase.sh
