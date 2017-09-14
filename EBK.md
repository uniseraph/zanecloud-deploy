# 基于EBK的应用监控系统

对于一个软件或互联网公司来说，对计算资源和应用进行监控和告警是非常基础的需求。对于大公司或成熟公司，一个高度定制化的监控系统应该已经存在了很长时间
并且非常成熟了。而对于一个初创公司或小公司来说，如何利用现有开源工具快速搭建一套日志监控及分析平台是需要探索的事情。


## 监控系统的用户

运维，开发，产品

## 监控系统的基础功能
收集服务器的各项基础指标，比如memory,cpu,load,network等；
收集应用的状态，jvm状态，是否存活等； 
收集应用日志，并进行分析和统计。通过日志分析和统计可得到应用的访问统计，异常统计，业务统计。具有进行大规模日志数据的分析和处理能力。
可制定告警规则。各种监控数据进入系统后，可以根据条件触发告警，实时的将应用异常情况推送到运维、开发或业务人员的IM/SMS上。
可定制的看板。可以将各种实时统计或报表直观的显示出来。

## 什么是EBK

EBK= elasticsearch + beats (filebeat/metricbeat) + kibana



EBK是ELK的升级版，相对于logstash，beats功能更强大，性能更好，资源消耗小。beats分为filebeat/metricbeat/heartbeat/packetbeat/winlogbeat，其中最常用的是filebeat/metricbeat.

logstach与beat的源流关系请参考：https://logz.io/blog/filebeat-vs-logstash/

## EBK架构


beats 负责收集数据，包括性能数据／业务日志数据
elasticsearch 负责数据存储与搜索
kibana 负责数据展现




### 部署EK集群

zanecloud容器云已经默认集成EBK，部署时只需要加一个with-ebk参数

```
MASTER0_IP=ip0 MASTER1_IP=ip1 MASTER2_IP=ip2 PROVIDER=native API_SERVER=tcp://ip2:8080 \
    bash -x setup-master.sh --with-zlb --with-ebk
```

执行上述命令会生成一个zanecloud容器云，自带一个3节点的elasticsearch集群和kibana。


### 部署filebeat

filebeat是一个go appliation，特点是依赖少运行时资源消耗小，支持linux／windows。安装请参考：
https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html




### 部署metricbeat

### 与docker集成

### 日志深度分析

### 自定义beat

https://www.elastic.co/guide/en/beats/libbeat/master/community-beats.html

