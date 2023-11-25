# Posi+ive's script for connecting to a PDANet hotspot in Linux

## Backstory
(skip if you don't want to hear about the history)

At the time of making this script, I am just a little student taking courses and such in my college. Since I am a student, I do not have the money to buy hotspot quota everytime my hotspot quota is finished. So I used pdanet. There's no official clients for connecting to pdanet in linux, so I googled on how to connect to a proxy in linux, systemwide.

I'll be honest, there are no good solutions for connecting to pdanet in linux. There's proxyman, but that looks hacky and it just sets some proxy options in some apps and sets the http_proxy variable, which doesn't work for every programs. Then there's proxychains-ng, which works for every program, but I don't want to open up a terminal and launch every program in there. So I googled abit more and found out that I can route my traffic to a proxy server, systemwide with iptables and tun2socks. Then, this script was born. I studied hard about iptables and such to get this working lol.

TL;DR: Got frustrated about the state of connecting to pdanet in Linux, decided to make a script for it.

## Dependencies
- A shell. I think any shell will work.
- [tun2socks](https://github.com/xjasonlyu/tun2socks)
- iptables
- iproute2

## Usage
Put this script and the tun2socks binary in ~/pdanet. Run the script from your home directory. I'll improve the script when I have time. For now just do that.
You must run this script as root since iptables and tun2socks needs those root permissions to setup the routing in your system.

## How it works

In a nutshell, this script just makes a tunnel interface and then routes all of your traffic to a socks5 proxy (in this case it's a PDANet hotspot). All of the heavy lifting is done by tun2socks.

## TODO:
- add function to download tun2socks if the user didn't have it already

