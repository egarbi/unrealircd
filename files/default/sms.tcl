# sms.tcl
# copyright (c) 2011 - Inspired by nXistence <ethilic@clix.pt>
# nXistence page - http://planeta.clix.pt/ethilic/

bind msg * sms msg.sms

bind pub * !sms pub.sms

proc pub.sms {nick uhost hand chan text} {
puthelp "PRIVMSG $nick :Short Message Sender by Juan Morete"
puthelp "PRIVMSG $nick :Usage: sms <number> <message>"
puthelp "PRIVMSG $nick :Ex: sms +31646406530  hi there!! wanna go to the beach? give me a call"}

proc msg.sms {nick uhost hand text} {
    if {[lindex $text 1] != ""} {
        exec /srv/noc/scripts/send_sms.pl [lindex $text 0] "From $nick: [lrange $text 1 end]"
	#exec wget "http://sms.example.com/sms/send.sms?message=From+$nick:+[lrange $text 1 end]&recipient=[lindex $text 0]&type=ALERT"
        putlog "SMS sent to [lindex $text 0] by $nick - [lrange $text 1 end]"
        puthelp "PRIVMSG $nick :Your message has been sent to [lindex $text 0]"
    } else { puthelp "PRIVMSG $nick :correct usage: sms <number> <message>" }
}

putlog "SMS Sender by nXistence (modified by Juan Morete) loaded"
