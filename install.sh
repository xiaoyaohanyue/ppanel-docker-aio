#!/bin/bash


git_resipository=""

# ===========================
# Color Definitions
# ===========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color

# ===========================
# Output Functions
# ===========================
log() {
    echo -e "$1"
}

error() {
    echo -e "${RED}$1${NC}"
}

prompt() {
    echo -ne "${BOLD}$1${NC}"
}

info() {
    echo -e "${GREEN}$1${NC}"
}

warning() {
    echo -e "${YELLOW}$1${NC}"
}

bold_echo() {
    echo -e "${BOLD}$1${NC}"
}

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

get_user_config_input(){
    prompt "请输入Cloudflare邮箱(用于SSL证书申请)："
    read cloudflare_email
    if [ -z "$cloudflare_email" ]; then
        error "Cloudflare邮箱不能为空"
        exit 1
    fi
    prompt "请输入Cloudflare Token(Global Token，用于SSL证书申请)："
    read cloudflare_token
    if [ -z "$cloudflare_token" ]; then
        error "Cloudflare Token不能为空"
        exit 1
    fi
    prompt "请输入API域名(服务端域名不带http/https)："
    read api_doamin
    if [ -z "$api_doamin" ]; then
        error "API域名不能为空"
        exit 1
    fi
    prompt "请输入管理端域名(管理端域名不带http/https)："
    read admin_doamin
    if [ -z "$admin_doamin" ]; then
        error "管理端域名不能为空"
        exit 1
    fi
    prompt "请输入用户端域名(用户端域名不带http/https)："
    read user_doamin
    if [ -z "$user_doamin" ]; then
        error "用户端域名不能为空"
        exit 1
    fi
    prompt "请输入管理员邮箱："
    read admin_email
    if [ -z "$admin_email" ]; then
        error "管理员邮箱不能为空"
        exit 1
    fi
    prompt "请输入管理员密码："
    read admin_passwd
    if [ -z "$admin_passwd" ]; then
        error "管理员密码不能为空"
        exit 1
    fi
}

init_config(){
    sed -i "s/ADMIN_DOMAIN/${admin_doamin}/g" admin/.env
    sed -i "s/API_DOMAIN/${api_doamin}/g" admin/.env
    sed -i "s/USER_DOMAIN/${user_doamin}/g" user/.env
    sed -i "s/API_DOMAIN/${api_doamin}/g" user/.env
    sed -i "s/Email_TMP/${admin_email}/g" server/ppanel.yaml
    sed -i "s/Password_TMP/${admin_passwd}/g" server/ppanel.yaml
    sed -i "s/EMAIL_TEM/${cloudflare_email}/g" docker-compose.yaml
    sed -i "s/API_DOMAIN_TEM/${api_doamin}/g" docker-compose.yaml
    sed -i "s/ADMIN_DOMAIN_TEM/${admin_doamin}/g" docker-compose.yaml
    sed -i "s/USER_DOMAIN_TEM/${user_doamin}/g" docker-compose.yaml
    sed -i "s/EMAIL_TEM/${cloudflare_email}/g" certbot/cloudflare.ini
    sed -i "s/exampleapikey/${cloudflare_token}/g" certbot/cloudflare.ini
    sed -i "s/CERTBOT_DOMAINS_TEM/${CERTBOT_DOMAINS}/g" docker-compose.yaml
    sed -i "s/admin.com/${admin_doamin}/g" nginx/sites/admin.conf
    sed -i "s/api.com/${api_doamin}/g" nginx/sites/api.conf
    sed -i "s/user.com/${user_doamin}/g" nginx/sites/user.conf
}

purge_old_ppanel_docker_data(){
    ppserver_docker_istatus=$(docker ps -a |grep ppanel-server|wc -l)
    ppadmin_docker_istatus=$(docker ps -a |grep ppanel-admin|wc -l)
    ppuser_docker_istatus=$(docker ps -a |grep ppanel-user|wc -l)
    ppsql_docker_istatus=$(docker ps -a |grep pp_mysql|wc -l)
    ppredis_docker_istatus=$(docker ps -a |grep pp_redis|wc -l)
    ppserver_image_name=$(docker ps -a |grep ppanel-server| awk '{print $2}')
    ppadmin_image_name=$(docker ps -a |grep ppanel-admin| awk '{print $2}')
    ppuser_image_name=$(docker ps -a |grep ppanel-user| awk '{print $2}')
    nginx_docker_istatus=$(docker ps -a |grep nginx|wc -l)
    certbot_docker_istatus=$(docker ps -a |grep certbot|wc -l)
    certbot_image_name=$(docker ps -a |grep certbot| awk '{print $2}')
    certbot_volume_name=$(docker volume ls |grep certbot| awk '{print $2}')
    mysql_volume_name=$(docker volume ls |grep mysql| awk '{print $2}')
    redis_volume_name=$(docker volume ls |grep redis| awk '{print $2}')
    webroot_volume_name=$(docker volume ls |grep webroot| awk '{print $2}')

    if [ $nginx_docker_istatus -eq 1 ]; then
        echo "nginx is already installed stop and remove it"
        docker rm -f nginx
    fi

    if [ $certbot_docker_istatus -eq 1 ]; then
        echo "certbot is already installed stop and remove it"
        docker rm -f certbot
        docker volume rm -f $certbot_volume_name
        docker rmi $certbot_image_name:latest
        docker volume rm -f $webroot_volume_name
    fi

    if [ $ppserver_docker_istatus -eq 1 ]; then
        echo "ppanel-server is already installed stop and remove it"
        docker rm -f ppanel-server
        docker rmi $ppserver_image_name:latest
    fi
    if [ $ppadmin_docker_istatus -eq 1 ]; then
        echo "ppanel-admin is already installed stop and remove it"
        docker rm -f ppanel-admin
        docker rmi $ppadmin_image_name:latest
    fi
    if [ $ppuser_docker_istatus -eq 1 ]; then
        echo "ppanel-user is already installed stop and remove it"
        docker rm -f ppanel-user
        docker rmi $ppuser_image_name:latest
    fi

    if [ $ppsql_docker_istatus -eq 1 ]; then
        echo "pp_mysql is already installed stop and remove it"
        docker rm -f pp_mysql
        docker volume rm -f $mysql_volume_name
    fi

    if [ $ppredis_docker_istatus -eq 1 ]; then
        echo "pp_redis is already installed stop and remove it"
        docker rm -f pp_redis
        docker volume rm -f $redis_volume_name
    fi

    docker volume prune -f
}

check_docker(){
    if check_ins docker; then
        echo "Docker has been installed"
        echo "清理旧数据"
        purge_old_ppanel_docker_data
    else
        echo "Docker is not installed"
        echo "Install Docker..."
        bash <(curl -fsSL https://get.docker.com)
        systemctl start docker
        systemctl enable docker
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
    check_docker
    disable_firewall
}

pp_start(){
    check_deps
    init_config
    docker-compose up -d
}

jjump(){
    workdir='/opt/dslr'
    if [ ! -d $workdir ]; then
        mkdir -p $workdir
    else 
        rm -rf $workdir
        mkdir -p $workdir
    fi
    cd /opt/dslr
    git clone $git_resipository .
    exit 1
}

OPTIONS="a:b:c:d:e:f:g:ij"
LONGOPTS="admin_email:,admin_passwd:,api_domain:,admin_domain:,user_domain:,cloudflare_email:,cloudflare_token:,interactive,jump"
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
        
        -a|--admin_email)
            admin_email="$2"
            shift 2
            ;;
        -b|--admin_passwd)
            admin_passwd="$2"
            shift 2
            ;;
        -c|--api_domain)
            api_doamin="$2"
            shift 2
            ;;
        -d|--admin_domain)
            admin_doamin="$2"
            shift 2
            ;;
        -e|--user_domain)
            user_doamin="$2"
            shift 2
            ;;
        -f|--cloudflare_email)
            cloudflare_email="$2"
            shift 2
            ;;
        -g|--cloudflare_token)
            cloudflare_token="$2"
            shift 2
            ;;
        -i|--interactive)
            get_user_config_input
            break
            ;;
        -j|--jump)
            jjump
            break
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

verify_user_config_input(){
    echo "请确认以下配置信息："
    echo "Cloudflare邮箱：$cloudflare_email"
    echo "Cloudflare Token：$cloudflare_token"
    echo "API域名：$api_doamin"
    echo "管理端域名：$admin_doamin"
    echo "用户端域名：$user_doamin"
    echo "管理员邮箱：$admin_email"
    echo "管理员密码：$admin_passwd"
    echo "是否确认以上配置信息？(y/n)"
    read confirm
    if [ "$confirm" != "y" ]; then
        echo "请重新输入配置信息"
        get_user_config_input
    fi
}
verify_user_config_input
pp_start




