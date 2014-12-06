bind pub - "!rehash" IRCBOT:command:rehash
bind pub - "!restart" IRCBOT:command:restart

# Rehash
proc IRCBOT:command:rehash {n u h c t} {
	if {![matchattr $h o|o]} {noauth $n; return "No access"}
	rehash
	putnotc $n "Rehashed!"
}
# Restart
proc IRCBOT:command:restart {n u h c t} {
	if {![matchattr $h o|o]} {noauth $n; return "No access"}
	restart
}

# Update from git
bind pub - "!pull" IRCBOT:command:gitpull
bind pub - "!push" IRCBOT:command:gitpush

proc IRCBOT:command:gitpush {n u h c t} {
	if {![matchattr $h o|o $n]} {noauth $n; return "No access"}
	upload "Requested by $n."
}
proc upload {msg} {
	gitcommit $msg
	set ret [gitpush]
	if {[regexp -nocase -- {^ ! \[rejected\]        \S+ -> \S+ \(fetch first\)$} [lindex [split $ret "\n"] 1] str]} {
		gitfetch
		gitpull
		gitpush
		return 1
	}
}
proc gitpush {} {
    global bot
	catch {[cd /home/ircbot/IRCBot/resources; exec git push origin master]} push
	return $push
}
proc gitpull {} {
    global bot
	catch {[cd $bot(resources); exec git pull origin master]} pull
	return $pull
}
proc gitcommit {msg} {
    global bot
	catch {[cd $bot(resources); exec git commit --all --message=$msg]} commit
	return $commit
}
proc gitfetch {} {
    global bot
	catch {[cd $bot(resources); exec git fetch origin master]} fetch
	return $fetch
}
proc gitpushonly {file msg} {
    global bot
	catch {[cd $bot(resources); exec git commit -m $msg $file]} commit
	if {"no changes added to commit" ni [split $commit "\n"]} {
		gitpush
	}
}
proc IRCBOT:command:gitpull {n u h c t} {
	if {![matchattr $h o|o $c]} {noauth $n; return "No access"}
	set return [gitfetch]
	putnotc $n "-- Fetch --"
	foreach line [split $return "\n"] {
		putnotc $n $line
	}
	set ret [gitpull]
	putnotc $n "-- Pull --"
	foreach line [split $return "\n"] {
		putnotc $n $line
	}
}

# Send message to log to show file was loaded on start-up
putlog "update.tcl loaded"
