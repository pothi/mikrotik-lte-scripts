# Toggle SIM Slot in LTE Modem.

# Applicable for RouterOS above 6.45.1
# see https://wiki.mikrotik.com/wiki/Dual_SIM_Application#Initial_settings
# see https://forum.mikrotik.com/viewtopic.php?f=13&t=159520&p=816964#p816964

:log info "\nSIM toggled by the script..."

/system routerboard modem

:local oldSlot [get sim-slot]
:local newSlot
:local oldOperator
:local newOperator

:if ( $oldSlot = "a" ) do={
  :set $newSlot "b"
  :set $oldOperator "BSNL"
  :set $newOperator "Airtel"
} else={
  :set $newSlot "a"
  :set $oldOperator "Airtel"
  :set $newOperator "BSNL"
}

set sim-slot=$newSlot

# Speed restrictions enable / disable
:if ( $newOperator = "Airtel" ) do={
  /queue simple enable Airtel
  /ip firewall filter disable [find action=fasttrack-connection]
} else={
  /queue simple disable Airtel
  /ip firewall filter enable [find action=fasttrack-connection]
}

:log warning "LTE SIM SLOT will change from $oldSlot to $newSlot";
:log warning "LTE SIM SLOT will change from $oldOperator to $newOperator";
:log info "Please hold on while switching SIM. Internet will come back in a few seconds."
:delay 2s
