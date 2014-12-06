# Path Configuration
set bot(scripts) "/home/ircbot/IRCBot/resources/scripts"
set bot(resources) "/home/ircbot/IRCBot/resources/"

#If Eggdrop is not in same working directory, please define the directory here. This is often required!
#set bot(eggdrop) "/home/ircbot/IRCBot/eggdrop/"

# Loading scripts (Remove/Add scripts to the array to load them on start-up)
set scripts {
	"ansi.tcl"
    "iptools.tcl"
    "raw.tcl"
    "update.tcl"
}
foreach file $scripts {
	source "$bot(scripts)/$file"
}

# Send message to log to show file was loaded on start-up
putlog "scripts.tcl loaded"