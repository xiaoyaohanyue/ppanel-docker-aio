#!/bin/bash

git_resipository="https://github.com/xiaoyaohanyue/ppanel-docker-aio.git"


check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ];then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ];then
            return 0
        else
            return 1
        fi
    fi
}
#check environment
check_ins(){
    if type $1 >/dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

install_app(){
    if check_sys packageManager yum; then
        yum install -y $1
    elif check_sys packageManager apt; then
        apt-get update
        apt-get install -y $1
    fi
}

check_app(){
    if check_ins $1; then
        echo "$1 has been installed"
    else
        echo "$1 is not installed"
        echo "Install $1..."
        install_app $1
    fi
}

disable_firewall(){
    if check_sys sysRelease centos; then
        systemctl stop firewalld
        systemctl disable firewalld
    elif check_sys sysRelease ubuntu; then
        ufw disable
    fi
}

check_deps(){
    check_app curl
    check_app git
    disable_firewall
}

prepare(){
    check_deps
    workdir='/opt/dslr'
    if [ ! -d $workdir ]; then
        mkdir -p $workdir
    else 
        rm -rf $workdir
        mkdir -p $workdir
    fi
    cd /opt/dslr
    git clone $git_resipository .
}
prepare
OPTIONS="i"
LONGOPTS="interactive"
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1
fi

if [[ $# -eq 0 ]]; then
    echo "错误：未提供任何参数。请使用正确的命令行参数。"
    exit 1
fi

eval set -- "$PARSED"

while true;do
    case "$1" in
        -i|--interactive)
            bash /opt/dslr/install.sh -i
            exit 1
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "未知参数: $1"
            exit 1
            ;;
    esac

done
