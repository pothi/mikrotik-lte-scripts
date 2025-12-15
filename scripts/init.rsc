# Initialize the router with default values, run backup scripts and check for updates!

# Note: The policy of the script should match the policy of the scheduler that calls this script.

# Version: 4

# change log
# version: 4
#  - date: 2025-05-31
#. - do not execute backup scripts after 12 noon.
# version: 3
#   - date: 2023-08-20
#   - use NTP client to test for internet.
#   - No more timeout for stable internet. Wait indefinitely until stable internet.
# version: 2
#   - date: 2022-11-18
#   - introduction of timeout to check internet

:global adminEmail "noreply@example.com"
:global adminPh 9894998949
:global cloudPass ""
:global minSpeed 0

:while ( ([/system/ntp/client print as-value])->"status" != "synchronized" ) do={
  :delay 60s;
  # :log info "No internet, yet."
}
:log info "Init script execution has started."
:log info "Connected to internet. Time synced."

:local commonScripts {"firmware-check-rb"; "firmware-check-ros";}
:local initScripts ($commonScripts, "firmware-check-modem")

/system script
:foreach scriptName in $initScripts do={
  :do { run $scriptName } on-error={ :log error "Error running the script $scriptName\n" }
  :delay 30s
}

:local currentHour [:tonum [:pick [/system clock get time] 0 2]]

:local backupScripts {"backup-cron"; "backup-scripts"}
:if ($currentHour < 7) do={
    :foreach scriptName in $backupScripts do={
      :do { run $scriptName } on-error={:log error "Error running $scriptName"}
      :delay 30s
    }
} else={
    :log info "Automated backups aren't taken after 7am."
}

:log info "Init script execution is completed."
