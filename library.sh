
CONF="${CONF:-/etc/default/epics-softioc}"

requireroot() {
	return 0
	[ "`id -u`" -eq 0 ] || die "This action requires root access"
}

# Must run this before calling any of the below
# Sets: $IOCPATH
iocinit() {
	CONF=/etc/default/epics-softioc
	[ -f "$CONF" ] || die "Missing $CONF"
	. "$CONF"
	[ -z "$SOFTBASE" ] && die "SOFTBASE not set in $CONF"
	IOCPATH=/etc/iocs
	if [ -n "$SOFTBASE" ]
	then
		# Search in system locations first then user locations
		IOCPATH="$IOCPATH:$SOFTBASE"
	fi
}

#   Run command $1 on IOC all instances
# $1 - A shell command
# $2 - IOC name (empty for all IOCs)
visit() {
	[ -z "$1" ] && die "visitall: missing argument"

	save_IFS="$IFS"
	IFS=':'
	for ent in $IOCPATH
	do
		IFS="$save_IFS"
		[ -z "$ent" ] && continue

		for iocconf in "$ent"/*/config
		do
			ioc="`dirname "$iocconf"`"
			name="`basename "$ioc"`"
			[ "$name" = '*' ] && continue

			if [ -z "$2" -o "$name" = "$2" ]; then
				$1 $ioc
			fi
		done
	done
}

#   Find the location of an IOC
#   prints a single line which is a directory
#   which contains '$IOC/config'
# $1 - IOC name
findbase() {
	[ -z "$1" ] && die "visitall: missing argument"
	IOC="$1"

	save_IFS="$IFS"
	IFS=':'
	for ent in $IOCPATH
	do
		IFS="$save_IFS"
		[ -z "$ent" ] && continue

		if [ -f "$ent/$IOC/config" ]; then
			printf "$ent"
			return 0
		fi
	done
	return 1
}