# Initialize the router with default values, run backup scripts and check for updates!

:global adminEmail "noreply@example.com"
:global adminPh 9894998949
:global genericLogFileName "genericLog"
:global cloudPass ""

:local waitForDNS do={
  :local pingIP 1
  :while ( $pingIP = 1 ) do={ :do { :set pingIP [:resolve g.co] } on-error={ :delay 60s } }
}
$waitForDNS

# /system ntp client set enabled=yes
:delay 3s

:log info "\nInit script has started..."

/system script

:local commonScripts {"backup-cron"; "backup-scripts"; "cloud-backup"; "firmware-check-rb"; "firmware-check-ros";}
:local initScripts ($commonScripts, "firmware-check-lte")

:foreach scriptName in $initScripts do={ 
  :do { run $scriptName } on-error={ :log error "Error running the script $scriptName\n" }
  :delay 30s
}

:log info "Init script finished execution!\n"
