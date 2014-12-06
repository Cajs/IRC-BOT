#====================================================================================================#
#                                                Revisions
# 1. 6th December [06/12/2014] - Initial upload of ~ <command> code.
#====================================================================================================#

# Define Binds (Alter the trigger commands here)
bind pub n&- ~ stcl

proc stcl {nick host hand chan arg} {
	catch {eval $arg} result
	if {$result == ""} { set result "Return: NULL" }
	foreach sline [split $result \n] {
        if {[regexp {^\s*$} $sline]} { set result "Blank Line" } else {
		putserv "PRIVMSG $chan :~ = [ansi $sline]" }
    }
}

# Send message to log to show file was loaded on start-up
putlog "raw.tcl loaded"