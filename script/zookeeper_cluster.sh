#!/usr/bin/env bash



#[使用设置]

#主目录，相当于/usr/local
#install_dir=

#日志主目录，相当于/var/log
#log_dir=

#服务目录名
zookeeper_cluster_dir=zookeeper

#集群所有节点的ip
cluster_ip=(192.168.2.108 192.168.2.109)



get_zookeeper_cluster() {
    test_package zookeeper-3.5.2-alpha.tar.gz http://shell-auto-install.oss-cn-zhangjiakou.aliyuncs.com/package/zookeeper-3.5.2-alpha.tar.gz
}

install_zookeeper_cluster() {
    test_dir_master
    test_dir ${zookeeper_cluster_dir}
    test_install java-1.8.0-openjdk
    
    get_zookeeper_cluster
    tar -xf   package/zookeeper-3.5.2-alpha.tar.gz
    mv zookeeper-3.5.2-alpha ${install_dir}/${zookeeper_cluster_dir}
    
    echo "clientPort=2181
dataDir=${install_dir}/${zookeeper_cluster_dir}/data
syncLimit=5
tickTime=2000
initLimit=10
dataLogDir=${install_dir}/${zookeeper_cluster_dir}
dynamicConfigFile=${install_dir}/${zookeeper_cluster_dir}/conf/zoo.cfg.dynamic" > ${install_dir}/${zookeeper_cluster_dir}/conf/zoo.cfg

    d=1
    for i in `echo ${cluster_ip[*]}`
    do
        echo "server.${d}=${i}:2888:3888" >> ${install_dir}/${zookeeper_cluster_dir}/conf/zoo.cfg.dynamic
        let d++
    done

    mkdir ${install_dir}/${zookeeper_cluster_dir}/data
    id=`test_id`
    echo "$id" > ${install_dir}/${zookeeper_cluster_dir}/data/myid
    
    #监听ipv4，默认ipv6
    sed -i '150c "-Dzookeeper.log.file=${ZOO_LOG_FILE}" "-Djava.net.preferIPv4Stack=true"  "-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" \/' ${install_dir}/${zookeeper_cluster_dir}/bin/zkSserver.sh

    
    echo "#!/bin/bash
${install_dir}/${zookeeper_cluster_dir}/bin/zkServer.sh" '$1' > /usr/local/bin/man-zookeeper
    chmod +x /usr/local/bin/man-zookeeper

    clear
    [ $language -eq 1 ] && echo "zookeeper-cluster安装完毕，使用man-zookeeper 管理" || ehco "zookeeper_cluster installation is completed, Man-zookeeper management"
}

remove_zookeeper_cluster() {
    man-zookeeper stop
    rm -rf /usr/local/bin/man-zookeeper
    rm -rf ${install_dir}/${zookeeper_cluster_dir}
    
    [ $language -eq 1 ] && echo "zookeeper_cluster已卸载" || ehco "zookeeper_cluster Uninstalled"
}


info_zookeeper_cluster() {
    if [ $language -eq 1 ];then
        echo "名字：zookeeper-cluster
        
版本：3.5.2

作者：book

介绍：安装zookeeper集群

提示：只需要写上集群ip即可，id号将会自动创建

使用：使用man-zookeeper 管理"
    else
        echo "Name：zookeeper-cluster

version：3.5.2

Author：book

Introduction：Install zookeeper cluster

Prompt：Just need to write the cluster ip can, id number will be created automatically

use：Man-zookeeper management"
    fi
}
