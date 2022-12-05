# Introduction
This repository will host the framework necessary to build board support packages (BSPs). It will
use buildroot to build the BSPs, so a familiarity or understanding of buildroot will be helpful,
though I intend to try and set things up so that one can run a build with a single command and most
everything should be taken care of.

Make sure to initialize the buildroot git submodule (in `externals/buildroot`), or the build won't
work correctly.

Further information on buildroot can be read in its manual:<br>
https://buildroot.org/downloads/manual/manual.html

# Requirements
See the buildroot manual for a list of the software that will be necessary on the machine you are
building on.

# Building
```
./build.sh [boardname]
```

Add `-h` or `--help` (or inspect the script itself) to get further information and some additional
options. The "boardname" is any file contained within the `configs/` folder, excluding the
"\_defconfig" suffix.

# List of BSPs
The list of BSPs that one can build is anything within the `configs/` folder. Here is a description
of those BSPs, with detailed information for each BSP in its own section.

* rpi4_64_router: This builds a BSP for the Raspberry Pi 4 (64-bit) along with necessary software
  and configuration to run a router (both wired and wireless) on the RPi4.

# rpi4_64_router
This BSP turns the Raspberry Pi 4 into a wired and wireless router. One can plug the main ethernet
port into their modem to get IPv4 and IPv6 information from their ISP. One can plug in
USB3-to-Ethernet adapters into the two USB3 ports to get two wired interfaces that you can plug a
desktop or other wired device into. The wifi chip on the RPi4 is configured to function as a
wireless access point (AP).

## Important Security Information

### BEFORE BUILDING - Necessary Configuration
Before building, one MUST do the following things:

* Edit `configs/rpi4_64_router_defconfig` to change the `BR2_TARGET_GENERIC_ROOT_PASSWD` to a more
  secure value you desire, or use the buildroot menuconfig to disable root password login entirely.

* Edit `board/rpi4_64_router/rootfs_overlay/root/.ssh/authorized_keys` to add a public key of a key
  you have generated yourself if you want to allow root login over SSH.

* Edit `board/rpi4_64_router/rootfs_overlay/etc/hostapd.conf` and change the `ssid` and
  `wpa_passphrase` settings to values you desire.

One can either edit these files directly and save the changes in their own local repo, or one can
create a file `board/rpi4_64_router/private_config.sh` which will be called by a post-build script
and can fix up these settings so one can keep the repo files more similar to what is in this
original repository.

Optionally, one can also add keys to `board/rpi4_64_router/rootfs_overlay/etc/ssh` by running:<br>
```
ssh-keygen -A -f /path/to/bsp-repo/board/raspberrypi4_router/rootfs_overlay
```
The sshd init script will generate these keys if they are missing, but if one ends up reloading
one's SD card multiple times it may be convenient to have static keys that aren't changing on each
reload.

### Additional security information
* SSH: currently configured to only allow public key login. Root login with a key is allowed. See
  `board/rpi4_64_router/rootfs_overlay/etc/ssh/sshd_config`

* Firewall: at boot, `board/rpi4_64_router/rootfs_overlay/etc/iptables.rules` (IPv4) and
`board/rpi4_64_router/rootfs_overlay/etc/ip6tables.rules` (IPv6) are loaded. Traffic from LAN-side
interfaces is open. Incoming traffic from the WAN-side (eth0) is restricted to already established
connections, ICMP, ICMPv6, and DHCPv6 traffic. If you have further needs you will need to modify the
firewall rules.

## Build Output and Loading SD Card
Look in the buildroot repository in `externals/buildroot/board/raspberrypi4-64/readme.txt` for
additional information about the build output and loading the output onto an SD card.

## Additional Configuration and Information

### USB3-to-Ethernet Adapters
The `board/rpi4_64_router/rootfs_overlay/etc/init.d/S35usbeth` init script loads the necessary
kernel module for the adapters I am using. If you have adapters requiring a different module you
will have to edit this script to load the module you need (and may need to modify the Linux kernel
config to make sure the modules you need are built).

### DHCP and DNS
The BSP uses isc-dhcp-client (dhclient command) to get IPv4 and IPv6 information from the ISP. At
the time I developed this BSP, my ISP was Comcast and they give me both an IPv4 address via DHCP,
and I can request an IPv6 prefix via DHCPv6. Comcast is presently allowing me to receive a /60 IPv6
prefix, which the `board/rpi4_64_router/rootfs_overlay/etc/dhclient-exit-hooks` script takes and
then assigns a /64 prefix to the LAN-side interfaces (eth1, eth2, wlan0) as well as the WAN-side
eth0. The logic applying the /64 prefixes is fragile and may fail depending on what IPv6 addresses
you receive from your ISP. Making this more robust is a future improvement.

The 'dnsmasq' software is used to provide a DHCP and DNS server on the LAN-side interfaces.

If your ISP only provides IPv4 or only IPv6, then you may need to remove the one you do not have
from various points in the BSP configuration. Additionally, if your ISP supports IPv6 but does not
allow you to receive a prefix length less than /64, then routing IPv6 traffic between the multiple
LAN-side interfaces will fail.

### WiFi
The BSP uses wpa-supplicant and hostapd to turn the wifi chip on the RPi4 into a wireless access
point. The current configuration is setup to allow 802.11n and 802.11ac connections on the 5GHz
band. It uses the "US" country code. Running the WiFi as an access point in another country will
require changing the country code and may require changing the selected channels.
