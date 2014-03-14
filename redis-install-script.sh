#!/bin/bash
# From here: http://www.codingsteps.com/install-redis-2-6-on-amazon-ec2-linux-ami-or-centos/
# Thanks to https://raw.github.com/gist/2776679/b4f5f5ff85bddfa9e07664de4e8ccf0e115e7b83/install-redis.sh
# Uses redis-server init script from https://raw.github.com/saxenap/install-redis-amazon-linux-centos/master/redis-server
###############################################
# To use: (with root user) 
# git clone https://github.com/balsagoth/install-redis-amazon-linux-centos.git
# cd install-redis-amazon-linux-centos
# chmod 777 redis-install-script.sh
# ./redis-install-script.sh
###############################################
PORT=6379
DATADIR="/var/lib/redis-$PORT"

echo "*****************************************"
echo " 1. Prerequisites: Install updates, set time zones, install GCC and make"
echo "*****************************************"
yum -y update
yum -y install gcc gcc-c++ make 
echo "*****************************************"
echo " 2. Download, Untar and Make latest Redis"
echo "*****************************************"
wget http://download.redis.io/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
rm redis-stable.tar.gz -f
cd redis-stable
make
make install
echo "*****************************************"
echo " 3. Create Directories and Copy Redis Files"
echo "*****************************************"
mkdir /etc/redis $DATADIR
cp redis.conf /etc/redis/$PORT.conf
echo "*****************************************"
echo " 4. Configure Redis.Conf"
echo "*****************************************"
echo " Edit redis.conf as follows:"
echo " 1: ... daemonize yes"
echo " 2: ... bind 127.0.0.1"
echo " 3: ... dir /var/lib/redis-$PORT # change later if you need"
echo " 4: ... loglevel notice"
echo " 5: ... logfile /var/log/redis-$PORT.log"
echo "*****************************************"
sed -e "s/^daemonize no$/daemonize yes/" -e "s/^# bind 127.0.0.1$/bind 127.0.0.1/" -e "s/^dir \.\//dir \/var\/lib\/redis-$PORT\//" -e "s/^loglevel verbose$/loglevel notice/" -e "s/^logfile stdout$/logfile \/var\/log\/redis-$PORT.log/" redis.conf > /etc/redis/redis-$PORT.conf
echo "*****************************************"
echo " 6. Move and Configure Redis-Server"
echo "*****************************************"
cd ../
sed -e "s#^REDIS_CONF_FILE=\"/etc/redis/redis\.conf\"#REDIS_CONF_FILE=\"/etc/redis/redis-$PORT\.conf\"#g" redis-server > /etc/init.d/redis-$PORT
chmod 755 /etc/init.d/redis-$PORT
echo "*****************************************"
echo " 7. Auto-Enable Redis-Server"
echo "*****************************************"
chkconfig --add redis-$PORT
chkconfig --level 345 redis-$PORT on
echo "*****************************************"
echo " 8. Start Redis Server"
echo "*****************************************"
service redis-$PORT start
echo "*****************************************"
echo " Installation Complete!"
echo " You can test your redis installation using the redis console:"
echo "   $ redis-cli"
echo "   redis> ping"
echo "   PONG"
echo "*****************************************"
echo " Following changes have been made in redis.config:"
echo " 1: ... daemonize yes"
echo " 2: ... bind 127.0.0.1"
echo " 3: ... dir /var/lib/redis-$PORT"
echo " 4: ... loglevel notice"
echo " 5: ... logfile /var/log/redis-PORT.log"
echo "*****************************************"
read -p "Press [Enter] to continue..."
