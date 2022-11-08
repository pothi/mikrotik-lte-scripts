# SMS to SMS

# Limitation: It doesn't forward the full SMS message. It forwards the actual message, but doesn't forward the senderPhoneNumber or timestamp of received SMS. So, it doesn't remove the SMS and the SMS is removed only by the other script (sms-to-email).

# Source: https://forum.mikrotik.com/viewtopic.php?f=9&t=61068#p312202

:global adminPh
:if ([:typeof $adminPh] = "nothing" || $adminPh = "") do={
  :log error "adminPh is not defined or nil."; :error "Error: Check the log"; }

:local smsForwardPh $adminPh

:local smsPhone
:local smsMessage
:local smsTimeStamp

/tool sms inbox

:foreach receivedSMS in=[find] do={
  :set smsPhone [get $receivedSMS phone]
  :set smsMessage [get $receivedSMS message]
  :set smsTimeStamp [get $receivedSMS timestamp]

  :log info "\nSMS Received From: $smsPhone on $smsTimeStamp Message: $smsMessage"

  # Forward the SMS to $smsForwardPh, without $smsPhone and smsTimeStamp
  :do {
    /tool sms send lte1 phone-number=$smsForwardPh message=$smsMessage
  } on-error={ :log error "SMS to SMS Failed." }
  :delay 2s

  # *** Let's NOT remove the SMS! ***
  # Let the other script (SMS to Email) remove it, after sending the message with *full details*.
  # remove $receivedSMS
}
