proc ansi {arg} {
	set split [split $arg ""]
	set return ""
 
	for {set i 0} {$i < [llength $split]} {incr i} {
		if {[lindex $split $i] == "\x1b"} {
			set codes ""
			incr i 2
			while {[lindex $split $i] != "m" && $i < [llength $split]} {
				set codes "$codes[lindex $split $i]"
				incr i
			}
			incr i
 
			set bold 0
			set italic 0
			set underline 0
			set negative 0
			set strikethrough 0
			set bg ""
			set fg 01
 
			foreach code [split $codes ";"] {
				if {($code >= 30 && $code <= 37)} {
					set result [ansi_setfg $code $bg]
					set fg [lindex $result 0]
					set return "$return[lindex $result 1]"
				} elseif {$code >= 40 && $code <= 47} {
					set result [ansi_getcolor $code]
					set bg $result
					if {$bg == "00"} {
						set bg ""
						set return "$return\003$fg"
					} else {
						set return "$return\003$fg,$bg"
					}
				} else {
					switch $code {
						0 {set return "$return\x0f"}
						1 {if {!$bold} {set return "$return\002"; set bold 1}}
						3 {if {!$italic} {set return "$return\x09"; set italic 1}}
						4 {if {!$underline} {set return "$return\x15"; set underline 1}}
						7 {if {!$negative} {set return "$return\x16"; set negative 1}}
						9 {if {$strikethrough} {set return "$return\x13"; set strikethrough 1}}
						21 {if {$bold} {set return "$return\002"; set bold 0}}
						22 {set fg 01; set bg ""; set return "$return\00301"}
						23 {if {$italic} {set return "$return\x09"; set italic 0}}
						24 {if {$underline} {set return "$return\x15"; set underline 0}}
						27 {if {$negative} {set return "$return\x16"; set negative 0}}
						29 {if {$strikethrough} {set return "$return\x13"; set strikethrough 0}}
						39 {set result [ansi_setfg 0 $bg]; set fg [lindex $result 0]; set return "$return[lindex $result 1]"}
						49 {set return "$return\003$fg,00"}
					}
				}
			}
		}
		set return "$return[lindex $split $i]"
	}
 
	return $return
}
 
proc ansi_setfg {color bg} {
	set col [ansi_getcolor $color]
	if {$bg != ""} {
		return "$col \003$col,$bg"
	} else {
		return "$col \003$col"
	}
}
 
proc ansi_getcolor {code} {
	set color [expr $code % 10]
 
	switch $color {
		0 {return 01}
		1 {return 04}
		2 {return 03}
		3 {return 08}
		4 {return 02}
		5 {return 13}
		6 {return 10}
		7 {return 00}
	}
}