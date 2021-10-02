#!/bin/bash
set -x
set -e
mkdir /root_tmp
export HOME=/root_tmp
export DEBIAN_FRONTEND=noninteractive
function get_cpu_architecture()
{
    local cpuarch=$(uname -m)
    case $cpuarch in
         x86_64)
              echo "amd64";
              ;;
         aarch64)
              echo "arm64";
              ;;
         *)
              echo "Not supported cpu architecture: ${cpuarch}"  >&2
              exit 1
              ;;
    esac
}
cpu_arch=$(get_cpu_architecture)
. /etc/lsb-release
echo "Install & update"
apt-get -y update
apt-get -y install software-properties-common
add-apt-repository universe
add-apt-repository ppa:longsleep/golang-backports
apt-get -y update
apt-get -y dist-upgrade
apt-get -y install apt-utils runit locales openssh-server autossh cron vim git sudo rsync nginx-extras jq gettext build-essential tcptraceroute jq
apt-get -y install mysql-client mysql-server unzip \
 php-fpm php-common php-mbstring php-xmlrpc php-soap  php-gd php-xml php-intl php-mysql php-cli php-zip php-curl \
 fish zsh tmux htop thefuck wget curl aria2 lsof tree ncdu \
 golang-go default-jre-headless python3-setuptools python3 python3-pip python3-dev g++ gcc \
 net-tools iputils-\* p7zip-full p7zip-rar mongodb shellcheck\
 autoconf bison llvm gawk gdb git-core gnupg2 lftp libsqlite3-dev libssl-dev libtool \
 netcat netpipes nmap nnn parallel postgresql \
 qalc ranger rsyncrypto dnsutils \
 sl socat sqlite3 tig tor tor-geoipdb torsocks ttyrec vifm zlib1g-dev zlib1g-dev
curl https://rclone.org/install.sh | sudo bash
pip3       install --upgrade git+https://github.com/arthaud/python3-pwntools.git speedtest-cli tornado flask django jupyterlab jupyterhub
wget -qO- https://deb.nodesource.com/setup_current.x | bash
apt-get -y install nodejs
cd /tmp
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf ;  ~/.fzf/install
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
rm -rf /var/lib/apt/lists/* ; localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 ; locale-gen en_US.UTF-8
npm install -g configurable-http-proxy
wget http://www.vdberg.org/~richard/tcpping -O /usr/bin/tcping
chmod 755 /usr/bin/tcping
echo "Patch runit"
gcc -shared -std=c99 -Wall -O2 -fPIC -D_POSIX_SOURCE -D_GNU_SOURCE  -Wl,--no-as-needed -ldl -o /lib/runit-docker.so /tmp/runit-docker.c

wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cpu_arch}.deb
dpkg -i cloudflared-linux-${cpu_arch}.deb
rm      cloudflared-linux-${cpu_arch}.deb

echo "###doenload latest frp###"
curl -s https://api.github.com/repos/fatedier/frp/releases/latest \
| grep "browser_download_url.*linux_${cpu_arch}.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i - -O frp.tar.gz

echo "###unzip frp.tar.gz###"
mkdir frp
tar xzvf frp.tar.gz -C frp
mv frp/*/* frp/
mv frp/frps /bin/frps
mv frp/frpc /bin/frpc
chmod 755 /bin/frps
chmod 755 /bin/frpc
rm -rf frp
rm -rf frp.tar.gz

echo "### install latest v2ray###"
mkdir -p /etc/v2ray/
wget https://raw.githubusercontent.com/v2fly/docker/master/v2ray.sh -O v2ray.sh
v2ray_latest_tag=$(curl -sSL --retry 5 "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" | jq .tag_name | awk -F '"' '{print $2}')
chmod 755 v2ray.sh
./v2ray.sh linux/$cpu_arch $v2ray_latest_tag
exit 0
