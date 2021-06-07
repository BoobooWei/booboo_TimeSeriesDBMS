# Readme

## Install Docker

```bash
sudo su - root
# 安装docker
yum install -y docker
systemctl start docker
systemctl enable docker
Running mysql5.7 on Docker
docker network create db_network
docker run -d \
--name mysql57 \
--publish 3306 \
--network db_network \
--restart unless-stopped \
--env MYSQL_ROOT_PASSWORD=mypassword \
--volume mysql57-datadir:/var/lib/mysql \
mysql:5.7

docker exec -it mysql57 mysql -uroot -pmypassword
show binary logs;

CREATE USER 'exporter'@'%' IDENTIFIED BY 'exporterpassword' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
exit
```

## Running mysqld-exporter on Docker

```bash
docker run -d \
--name mysql57-exporter \
-p 9104:9104 \
--network db_network \
--restart always \
-e DATA_SOURCE_NAME="exporter:exporterpassword@(mysql57:3306)/" \
prom/mysqld-exporter:latest \
--collect.binlog_size 

--collect.info_schema.tables


curl http://localhost:9104/metrics
```

## Running Prometheus on Docker

```bash
# 编辑配置文件prometheus.yml
mkdir rds_monitor
cd rds_monitor
cat > prometheus.yml << ENDF
global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.
 
  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'rds-monitor'
 
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
 
    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
 
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'mysql'
 
    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
 
    static_configs:
      - targets: ["mysql57-exporter:9104"]

ENDF
# 获取 prometheus image
docker pull prom/prometheus
# 启动 prometheus
docker run  -d \
  -p 9090:9090 \
  --network db_network \
  -v /Users/user/Desktop/2021/Today/rds_monitor/:/etc/prometheus/  \
  --restart=always \
  --name prometheus \
  prom/prometheus
# 查看
docker ps -a
```

## Running Grafana on Docker

```bash
# 安装 grafana
mkdir grafana-storage
chmod 777 -R /Users/user/Desktop/2021/Today/rds_monitor/grafana-storage
docker pull grafana/grafana
docker run -d \
  -p 3000:3000 \
  --network db_network \
  --name=grafana \
  -v /Users/user/Desktop/2021/Today/rds_monitor/grafana-storage:/var/lib/grafana \
  --restart=always \
  --name grafana \
  grafana/grafana
```

## 访问Prometheus web

http://localhost:9090/targets

看到state为 UP 代表已经成功获取mysql的metrics。



## 访问Grafana web

登陆 http://127.0.0.1:3000/ 默认密码 admin/admin
添加数据源--prometheus
