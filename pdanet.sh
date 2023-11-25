#Run this script as root.
#Tunnel interface setup
ip tuntap add mode tun dev tun0
ip add add 192.168.1.1/24 dev tun0
ip l set dev tun0 up
ip route del default
ip route add default via 192.168.1.1 dev tun0 metric 1
ip route add default via 192.168.49.1 dev wlp3s0b1 metric 10

#Disable rp_filter to receive packets from other interfaces
sysctl -w net.ipv4.conf.all.rp_filter=0

#Run tun2socks
pdanet/tun2socks-linux-amd64 -device tun://tun0 -interface wlp3s0b1 -proxy socks5://192.168.49.1:8000
