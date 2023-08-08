:global country "India";
:global identity "Mikrotik";
:global myPassword;

# my subnet
# override the default 192.168.88.1 only if you use more than one MikroTik product
:global mySubnetCIDR "10.88.50.0/24";
:global dhcpServerIP "10.88.50.1";
:global dhcpPoolRange "10.88.50.88-10.88.50.100";
:global dhcpName "my-dhcp";
:global myBridgeAddress "10.88.50.1/24";

# override the default values here
:set identity "SXT LTE Kit";
:set myPassword [:pick ([/cert scep-server otp generate as-value minutes-valid=1]->"password") 0 20]
:put "Your new password is..."
:put $myPassword

### ------------------------------------------------------------------------------------ ###
#                                   Generic Tweaks                                         #
### ------------------------------------------------------------------------------------ ###

# find RouterOS version
:local rosVersion
:set rosVersion [:pick [/system/routerboard/get current-firmware] 0 1]

# Configure Identity
/system identity set name=$identity

# Minor Tweaks
/interface detect-internet
  set detect-interface-list=WAN
  set lan-interface-list=LAN
  set wan-interface-list=all
  set internet-interface-list=all

# install public SSH key
:put "Importing SSH key..."
:local result [ /tool fetch https://launchpad.net/~pothi/+sshkeys dst-path=pothi-ssh-key-rsa as-value];
:while ($result->"status" != "finished") do={ :delay 2s }
:delay 1s
/user ssh-keys import public-key-file=pothi-ssh-key-rsa;
:delay 1s
# removed automatically in RouterOS v7
/file remove pothi-ssh-key-rsa;
:put "Done importing SSH key."

# Reduce disk activity
/ip dhcp-server config set store-leases-disk=never;

# Configure NTP Client
:if ( $rosVersion = 7 ) do={
    /system ntp client servers
        add address=128.138.140.44 comment="NIST.gov"
        add address=[ :resolve pool.ntp.org ] comment="pool.ntp.org"
        add address=[ :resolve time.cloudflare.com ] comment="time.cloudflare.com"
        add address=time.google.com
        add address=0.in.pool.ntp.org
} else={
    /system ntp client
        set primary-ntp=128.138.140.44
        set secondary-ntp=[ :resolve time.cloudflare.com ]
        set server-dns-names=time.cloudflare.com,time.google.com,0.in.pool.ntp.org
}
/system ntp client set enabled=yes;

### ------------------------------------------------------------------------------------ ###
#                               Specific to LTE Products                                   #
### ------------------------------------------------------------------------------------ ###
# SMS Receive capability
/tool sms set auto-erase=yes receive-enabled=yes secret=0000 port=lte1;

# Logging
:local logTopics {"info"; "error"; "warning"; "critical"; "gsm"; "read"; "write"; "lte,!raw,!packet,!async,!debug"}
:foreach topic in=$logTopics do={ :system logging add topics=$topic action=disk }

# Useful when more than a SIM slot is present and the default SIM is in the other slot.
# :put "Changing the sim slot to 'b'."
# /system routerboard modem set sim-slot=b

# Change subnet
#change static DNS entry for router.lan
/ip dns static set numbers=[find name=router.lan] address=$dhcpServerIP;

/ip pool add name=$dhcpName ranges=$dhcpPoolRange;
/ip dhcp-server network add address=$mySubnetCIDR gateway=$dhcpServerIP dns-server=$dhcpServerIP;
/ip address add address=$myBridgeAddress interface=bridge;
/ip dhcp-server set [find interface=bridge] address-pool=my-dhcp
:put "Subnet changed."

:put "Removing old subnet."
:put "This will make the current SSH session unresponsive."
:put "Renew or release the IP in DHCP client in the router or disble & enable DHCP client to make everything work again."
/ip pool remove default-dhcp;
/ip dhcp-server network remove [find gateway=192.168.88.1];
/ip address remove [find address="192.168.88.1/24"]

