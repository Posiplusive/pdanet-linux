![Screenshot_20250107_161030](https://github.com/user-attachments/assets/c8d871d5-9342-4446-b405-a347c527a15c)

# Features

!! Achieves 200mbps down && 15mbps up on 5g networks !!

+ Detects CPU architecture
+ Incorporated superuser root check
+ Fetches a more efficient tun2socks fork ([hev-socks5-tunnel](https://github.com/heiher/hev-socks5-tunnel))
+ Can route packets via UDP & TCP
+ Grouped commands into their respective functions
+ No hard coded paths
+ Detects package managers 
+ Currently only sets proxy for apt/pacman/git/wget
+ Cleans up upon exit

++ various other additions

tested on x86_64 Arch Linux with a paid version of pdanet+ running on Android 14.

# How to use

Simply run script as superuser:

`git clone https://github.com/1ndev-ui/pdanet-linux/ ; sudo ./pdanet-linux/pdanet.sh`

# To-do

* Choose specific tun2socks binary fork
* Implement non-interactive state
* Add some flags
* Auto reconnect network interface in case of disconnect
* Change logo

