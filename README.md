


## 新建开发测试集群

开发测试集群采用1master + N worker 模式（N可以为0），用于开发测试环境，不建议在生产环境使用。

## 新建集群

在阿里云上创建两台centos7u2/7u3的虚拟机，一台都是master兼作worker，一台是纯worker。



### 准备工作

在所有机器上执行如下命令，安装zanecloud-deploy

```
cd /opt && \
wget http://zanecloud-deploy.oss-cn-beijing.aliyuncs.com/zanecloud-deploy-1.0.0-single-5d286e2.tar.gz && \
tar zxvf zanecloud-deploy-1.0.0-single-18ddf1e.tar.gz
```

注意，GITCOMMIT会发生变化


### 初始化flannel网络端

如果是阿里VPC网络，并且VM的内网ip在192.168.0.0/16网段，则需设置环境变量FLANNEL_NETWORK=172.16.0.0/12，否则可以忽略。

```
export FLANNEL_NETWORK=172.16.0.0/12
```


### 初始化 master 相关服务

```
cd /opt/zanecloud-deploy &&  PROVIDER=native API_SERVER=tcp://xxxx:8080 bash -x setup-master.sh  --type=swarm --with-zlb
```

API_SERVER的IP是公网IP（如果Docker集群与API服务器在同一个集群，则也可以使用私网IP）。


### 初始化 worker 相关服务
```
cd /opt/zanecloud-deploy && MASTER_IP=xxxx  PROVIDER=native API_SERVER=tcp://xxxx:8080 bash -x setup-worker.sh  --type=swarm --with-zlb
```
注意，这里需要输入master ip，这样才能组成集群。




## 安全策略

### 出方向

节点需要访问公网，有两种方式配置节点出公网：

（1）如果节点数较少，建议每个节点直接分配一个公网IP；

（2）如果节点数很多，不能做到每个节点一个公网IP，建议配置SNAT网关；

### 入方向

入方向需要严格的权限控制，以免发生安全事故。

#### 定向给API服务器授权

（1）2375端口：管理API端口；

（2）6400端口：元数据管理端口；

如果API服务器与master节点在同一个集群，则不需要做API定向授权。

#### 特定服务定向授权

（1）2022端口：SSH服务端口。建议只给指定IP（比如跳板机）授权。



## 其他

### bridge container ping host
在阿里云经典网络中，阿里云会对VM发出的icmp包进行源mac/源ip校验，所以如果是以bridge模式启动的容器ping宿主机不通。

VPC不存在类似问题。
