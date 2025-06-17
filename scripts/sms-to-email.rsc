# SMS to Email

# version: 2.0
# change log
#   - date: 2025-06-03
#   - replace deprecated do-on-error with onerror-do syntax

# Source: https://forum.mikrotik.com/viewtopic.php?f=9&t=61068#p312202

# Note: The SMS is removed from the inbox after sent by Email and forwarded
# even if email and forward fail! So, test it often!

# use the following if email is not sent due to dns failure
# see: https://forum.mikrotik.com/viewtopic.php?p=1146199
# /ip dns static add name=[/tool/e-mail/get server] address=[:put [:resolve [/tool/e-mail/get server]]] comment="email server"

:global adminEmail
:if ([:typeof $adminEmail] = "nothing" || $adminEmail = "") do={
  :log error "adminEmail is not defined or nil."; :error "Error: Check the log"; }

:local smsPhone
:local smsMessage
:local smsTimeStamp

/tool sms inbox

:foreach receivedSMS in=[find] do={
  :set smsPhone [get $receivedSMS phone]
  :set smsMessage [get $receivedSMS message]
  :set smsTimeStamp [get $receivedSMS timestamp]

  :log info "\nSMS Received From: $smsPhone on $smsTimeStamp Message: $smsMessage"

  # Send Email to $adminEmail
  :onerror errName {
    /tool e-mail send to="$adminEmail" body="$smsMessage" \
    subject="SMS from $smsPhone at $smsTimeStamp"
  } do={
    :log error "SMS to Email Failed."
    :error "SMS to Email Failed."
  }

  :delay 3s
  # Let's remove the SMS!
  remove $receivedSMS
}
