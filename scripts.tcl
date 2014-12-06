# Path Configuration
set bot(scripts) "/home/ircbot/IRCBot/resources/scripts"
set bot(resources) "/home/ircbot/IRCBot/resources/"
# Loading scripts (Remove/Add scripts to the array to load them on start-up)
set scripts {
	"iptools.tcl"
    "update.tcl"
    "ansi.tcl"
}
foreach file $scripts {
	source "$bot(scripts)/$file"
}

# Send message to log to show file was loaded on start-up
putlog "scripts.tcl loaded"