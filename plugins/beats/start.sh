#!/usr/bin/env bash
BASE_DIR=$(cd `dirname $0` && pwd -P)


MASTER_IP=${MASTER_IP:-${LOCAL_IP}}
mkdir -p binary
if type dpkg >/dev/null 2>&1; then

    if [[  ! -f binary/metricbeat-5.5.1-amd64.deb ]] ; then
        wget  http://zanecloud-others.oss-cn-beijing.aliyuncs.com/metricbeat-5.5.1-amd64.deb -P bingetary
    fi
    sudo dpkg -i binary/metricbeat-5.5.1-amd64.deb

    if [[  ! -f binary/filebeat-5.5.1-amd64.deb ]] ; then
        wget  http://zanecloud-others.oss-cn-beijing.aliyuncs.com/filebeat-5.5.1-amd64.deb  -P binary
    fi
    sudo dpkg -i binary/filebeat-5.5.1-amd64.deb
elif type rpm >/dev/null 2>&1; then

    if [[ ! -f binary/metricbeat-5.5.1-x86_64.rpm  ]] ; then
        wget http://zanecloud-others.oss-cn-beijing.aliyuncs.com/metricbeat-5.5.1-x86_64.rpm -P binary
    fi
    sudo rpm -vi binary/metricbeat-5.5.1-x86_64.rpm
    if [[ ! -f binary/filebeat-5.4.0-x86_64.rpm ]] ; then
        wget http://zanecloud-others.oss-cn-beijing.aliyuncs.com/filebeat-5.4.0-x86_64.rpm -P binary
    fi
    rpm -vi binary/filebeat-5.4.0-x86_64.rpm
else
    echo "no dpkg and no yum"
    exit
fi

cp ${BASE_DIR}/filebeat/config/filebeat.yml /etc/filebeat/filebeat.yml
sed -i -e "s#master#${MASTER_IP}#g" /etc/filebeat/filebeat.yml
systemctl restart filebeat
systemctl enable filebeat
systemctl status filebeat
/usr/share/filebeat/scripts/import_dashboards -es http://${MASTER_IP}:9200 -user elastic -url http://zanecloud-others.oss-cn-beijing.aliyuncs.com/beats-dashboards-5.4.0.zip



cp ${BASE_DIR}/metricbeat/config/metricbeat.yml /etc/metricbeat/metricbeat.yml
sed -i -e "s#master#${MASTER_IP}#g" /etc/metricbeat/metricbeat.yml
systemctl restart metricbeat
systemctl enable metricbeat
systemctl status metricbeat
/usr/share/metricbeat/scripts/import_dashboards -es http://${MASTER_IP}:9200 -user elastic -url http://zanecloud-others.oss-cn-beijing.aliyuncs.com/beats-dashboards-5.5.1.zip
