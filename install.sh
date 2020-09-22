#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi
SCRIPTS='/opt/vpnscripts'
DIRECTORY=$(cd $(dirname $0) && pwd)
if ! [ -d $SCRIPTS ]; then
mkdir $SCRIPTS
fi
CONFIG=$(find $DIRECTORY -name '*.ovpn' | grep 'pik' | awk -F '/' '{print $NF;}')
if [[ -z $CONFIG ]]
then
   echo "No pik*.ovpn file found!!!"
   exit 1
fi
cp $(realpath $(find $DIRECTORY -name '*.ovpn')) $SCRIPTS


cat_str='$(cat /etc/resolv.conf)'
cat <<EOF > $SCRIPTS/start.sh
#!/bin/bash
echo -e "nameserver 192.168.128.1\n"$cat_str > /etc/resolv.conf
EOF



cat_str='$(cat /etc/resolv.conf | grep -v '192.168.128.1')'
cat <<EOF > $SCRIPTS/stop.sh
#!/bin/bash
echo $cat_str > /etc/resolv.conf
EOF

cat <<EOF > $SCRIPTS/connect.sh
#!/bin/bash
sudo openvpn --script-security 2 --up $SCRIPTS/start.sh --down $SCRIPTS/stop.sh  --config  $SCRIPTS/$CONFIG
EOF

chmod +x $SCRIPTS/*.sh

exit 0
