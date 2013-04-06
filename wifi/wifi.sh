
# Wifi access point!
# By David Guillen <david@davidgf.net>
# 
# This script creates an access point and shares your internet
# connection to all the clients
# Configure it first! And run as root ;)

# Specify the interface used for internet connection (such as ppp0, em1, ...)
INTERNET_IFACE="wlan1"
# Specify the wifi interface for access point
AP_IFACE="wlan0"
# Specify the /24 subnet to use for the AP
SUBNET_AP="192.168.5"
# ESSID name
MYESSID="testssid"
# WIFI password
WIFIPASS="mypassword"

# Here finishes the cfg

hostapdcfg=`mktemp`
cp hostapd.conf $hostapdcfg 
echo "interface=$AP_IFACE" >> $hostapdcfg
echo "ssid=$MYESSID" >> $hostapdcfg
echo "wpa_passphrase=$WIFIPASS" >> $hostapdcfg

dhcpdcfg=`mktemp`
echo "option domain-name-servers 8.8.8.8, 8.8.8.4;" > $dhcpdcfg
echo "subnet $SUBNET_AP.0 netmask 255.255.255.0 {" >> $dhcpdcfg
echo " range $SUBNET_AP.3 $SUBNET_AP.240;" >> $dhcpdcfg
echo " option routers $SUBNET_AP.1;" >> $dhcpdcfg 
echo " option ip-forwarding on;"  >> $dhcpdcfg 
echo " option subnet-mask 255.255.255.0;"  >> $dhcpdcfg 
echo " option broadcast-address $SUBNET_AP.255;"  >> $dhcpdcfg 
echo "}"  >> $dhcpdcfg 


iptables -t nat -A POSTROUTING -o $INTERNET_IFACE -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward

ifconfig $AP_IFACE $SUBNET_AP.1 up
sleep 1
dhcpd -cf $dhcpdcfg
hostapd -d $hostapdcfg


