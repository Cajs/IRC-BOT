# Path Configuration
set bot(scripts) "/home/ircbot/IRCBot/resources/scripts"
# Loading scripts (Remove/Add scripts to the array to load them on start-up)
set scripts {
	"iptools.tcl"
    "update.tcl"
}
foreach file $scripts {
	source "$bot(scripts)/$file"
}