# SMS Forward and Email

# Requirements:
#   policy: read, write, policy, test
#   active internet
#   adminEmail - to forward the full details of the received SMS
#   adminPh - to forward only the received SMS message

# ToDo: Shorten the timestamp.

# Source: https://forum.mikrotik.com/viewtopic.php?f=9&t=61068#p312202

# Note: The SMS is removed from the inbox after sent by Email and forwarded
# even if email and forward fail! So, test it often!

:global adminEmail
:if ([:typeof $adminEmail] = "nothing" || $adminEmail = "") do={
  :log error "adminEmail is not defined or nil."; :error "Error: Check the log"; }
:global adminPh
:if ([:typeof $adminPh] = "nothing" || $adminPh = "") do={
  :log error "adminPh is not defined or nil."; :error "Error: Check the log"; }

:local smsForwardPh $adminPh

:local smsPhone
:local smsMessage
:local smsTimeStamp

/tool sms inbox

:foreach i in=[find] do={
  :set smsPhone [get $i phone]
  :set smsMessage [get $i message]
  :set smsTimeStamp [get $i timestamp]

  :log info "\nSMS Received From: $smsPhone on $smsTimeStamp Message: $smsMessage"

  # Forward the SMS to $smsForwardPh
  :do {
    /tool sms send lte1 phone-number=$smsForwardPh message=$smsMessage
  } on-error={ /tool e-mail send to="$adminEmail" subject="Sending SMS Failed" body="Check the log" }
  :delay 2s

  # Send Email to $adminEmail
  /tool e-mail send to="$adminEmail" body="$smsMessage" \
    subject="SMS from $smsPhone at $smsTimeStamp"
  :delay 3s

  remove $i
}
