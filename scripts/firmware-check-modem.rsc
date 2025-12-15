# Alert upon new firmware for LTE Modem

# Ref: https://help.mikrotik.com/docs/spaces/ROS/pages/30146563/LTE+5G#LTE/5G-Modemfirmware-upgradecommand

# requirement/s:
#   policy: read, write, policy, test
#   active internet
#   $adminEmail

:global adminEmail
:if ([:typeof $adminEmail] = "nothing" || $adminEmail = "") do={
  :log error "adminEmail is not defined or nil."; :error "Error: Check the log"; }

:log info "\nChecking for new firmware for LTE Modem..."

:local lteFirmwareInfo [/interface lte firmware-upgrade lte1 as-value];

:local lteInstalledVer ($lteFirmwareInfo->"installed");
:local lteLatestVer ($lteFirmwareInfo->"latest");

:if ( $lteInstalledVer != $lteLatestVer ) do={
  /tool e-mail send to="$adminEmail" subject="A new FIRMWARE update is available for (SXT) LTE." \
    body="       LTE Installed Firmware Version: $lteInstalledVer
          LTE Latest Firmware Version: $lteLatestVer"
  :log info "A new firmware is available for LTE modem and an email is sent to '$adminEmail'."
} else={
  :log info "No new firmware update for LTE Modem."
  :log info "LTE Installed Firmware Ver: $lteInstalledVer"
  :log info "   LTE Latest Firmware Ver: $lteLatestVer"
}
