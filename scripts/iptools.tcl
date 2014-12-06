#====================================================================================================#
#                                                Revisions
# 1. 3rd December [03/12/2014] - Initial upload of !port code.
# 2. 3rd December [03/12/2014] - Condense code.
# 3. 6th December [06/12/2014] - Initial upload of !host code.
# 4. 6th December [06/12/2014] - Adjust message rate to 2 lines per second.
#====================================================================================================#

# Define Binds (Alter the trigger commands here)
bind pub - "!port" IRCBOT:command:port
bind pub - "!host" IRCBOT:command:host

proc IRCBOT:command:port {nick host hand chan text} {
    # Define message rate
    set msg-rate 2

    #Define switches
    set isopen "0"
    set isfiltered "0"
    set isclosed "0"
    set isfailed "0"
    
    #Define replies
    set open "Open ports: "
    set filtered "Filtered ports: "
    set closed "Closed ports: "
    set failed "Failed. No Error Set."
    
    # Check for pipes (Used for injecting commands)
    if {[regexp {^.*(\|).*$} $text]} {
        putserv "PRIVMSG $chan :! = Error: Valid IPv4/IPv6 addresses only. (Detected PIPE)" 
    } elseif {[regexp {^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$} $text]} {
        putserv "PRIVMSG $chan :! = IPv4 Detected - Port scan results:"
        set arg "exec nmap $text --system-dns --host-timeout 60000ms"
    } elseif {[regexp {^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$} $text]} {
        putserv "PRIVMSG $chan :! = IPv6 Detected - Port scan results:"
        set arg "exec nmap $text -6 --system-dns --host-timeout 60000ms"        
    } elseif {[regexp {^[A-Za-z0-9 _.:-]*$} $text]} {
        putserv "PRIVMSG $chan :! = Hostname Detected - Port scan results:"
        set arg "exec nmap $text --system-dns --host-timeout 60000ms"
    }
    catch {eval $arg} result
    if {$result == ""} { set result "Return: NULL" }
    foreach sline [split $result \n] {
        if {[regexp {^([0-9]*)\/tcp[\s]*open[\s]*[A-z0-9\-\/]*$} $sline]} {
            lappend open [lindex [split [lindex $sline 0] /] 0],
            set isopen "1"
        } 
        if {[regexp {^([0-9]*)\/tcp[\s]*filtered[\s]*[A-z0-9\-\/]*$} $sline]} {
            lappend filtered [lindex [split [lindex $sline 0] /] 0],
            set isfiltered "1"
        }
        if {[regexp {^([0-9]*)\/tcp[\s]*closed[\s]*[A-z0-9\-\/]*$} $sline]} {
            lappend closed [lindex [split [lindex $sline 0] /] 0],
            set isclosed "1"
        }
        if {[regexp {^.*due to host timeout.*$} $sline]} {
            set isfailed "1"
            set failed "Unfortunately the IP/Hostname did not respond within 60s."
        }
        if {[regexp {^.*Failed to resolve.*$} $sline]} {
            set isfailed "1"
            set failed "This hostname does not seem to have any IP records."
        }
        if {[regexp {^.*Host seems down.*$} $sline]} {
            set isfailed "1"
            set failed "This host does not seem to be online. Is the host up or is it blocking our ping probes?"
        }
    }    
    
    # Remove final comma's
    set open [string trimright $open ,]
    set filtered [string trimright $filtered ,]
    set closed [string trimright $closed ,]
    
    # Print messages to channel
    if {$isopen == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $open]"
    }
    if {$isfiltered == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $filtered]"
    }
    if {$isclosed == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $closed]"
    }
    if {$isfailed == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $failed]"
    }
}

proc IRCBOT:command:host {nick host hand chan text} {
    # Define message rate
    set msg-rate 2
    
    #Define switches
    set isRecord "0"
    set isA "0"
    set isAAAA "0"
    set isMX "0"
    set isTXT "0"
    set isCNAME "0"
    set isPTR "0"
	
    # Define replies
    set A "A: "
    set AAAA "AAAA: "
    set MX "MX: "
    set TXT "TXT: "
    set CNAME "CNAME: "
    set PTR "PTR: "
	
    # Check for white-space characters
    if {[regexp {^\s*$} $text]} {
        putchan $chan "! = You must enter an IP address/domain name!"
    }
    if {[regexp {^.*(\|).*$} $text]} {
        putserv "PRIVMSG $chan :! = Error: Special characters are not permitted." 
    
	}
    # Check valid hostname/IP format
    if {![regexp {^[A-Za-z0-9 _.:-]*$} $text]} {
        putserv "PRIVMSG $chan :! = Error: Please use a valid hostname/IP format." 
    }
	
	# Set the command sent to terminal
	set arg "exec host $text"
    
	# Send the command to the terminal
    catch {eval $arg} result
    
    # Check for blank lines from the terminal. (And remove them)
	if {$result == ""} { set result "Return: NULL" }
    
    # Initiate checks each time new line is posted from the terminal
	foreach sline [split $result \n] {
        if {[regexp {^\s*$} $sline]} { set result "Blank Line" }
        # Check for A record's
        if {[regexp {^.* has address [A-Za-z0-9 _.:-]*$} $sline]} {
            lappend A [lindex [split [lindex $sline end] /] 0],
            set isA "1"          
        }
    
		# Check for AAAA record's
        if {[regexp {^.* has IPv6 address ((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$} $sline]} {
            lappend AAAA [lindex [split [lindex $sline end] /] 0],
            set isAAAA "1" 
            set isRecord "1"
        }
        
		# Check for MX record's
        if {[regexp {^.* mail is handled by [0-9]* [\.A-z0-9]*$} $sline]} {
            lappend MX [lindex [split [lindex $sline end] /] 0],
            set isMX "1"
            set isRecord "1"            
		}
        
		# Check for TXT record's
        if {[regexp {^.* descriptive text [A-z0-9.\s\"]*$} $sline]} {
            lappend TXT [lindex [split [lindex $sline end] /] 0],
            set isTXT "1"
            set isRecord "1"
        }
        
		# Check for CNAME record's
        if {[regexp {^.* is an alias for [A-z0-9\-\/\.]*$} $sline]} {
            lappend CNAME [lindex [split [lindex $sline end] /] 0],
            set isCNAME "1"
            set isRecord "1"            
        }
		
		# Check for PTR record's
        if {[regexp {^.* domain name pointer [A-z0-9\-\/\.]*$} $sline]} {
            lappend PTR [lindex [split [lindex $sline end] /] 0],
            set isPTR "1"   
            set isRecord "1"            
        }
    }
    
    # Remove final comma's from the output messages
    set A [string trimright $A ,]
    set AAAA [string trimright $AAAA ,]
    set MX [string trimright $MX ,]
    set TXT [string trimright $TXT ,]
    set CNAME [string trimright $CNAME ,]
    set PTR [string trimright $PTR ,]
	
	# Check to see which (if any) DNS values were present then send values to channel
    if {$isA == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $A]"
    }
    if {$isAAAA == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $AAAA]"
    }
    if {$isMX == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $MX]"
    }
    if {$isTXT == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $TXT]"
    }
    if {$isCNAME == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $CNAME]"
    }
	if {$isPTR == "1"} {
        putserv "PRIVMSG $chan :! = [ansi $PTR]"
    }
    
    # Check to see if there were no DNS values present
    if {$isRecord == "0"} {
        putserv "PRIVMSG $chan :! = There are no records for this hostname/IP."
    }
}

# Send message to log to show file was loaded on start-up
putlog "iptools.tcl loaded"