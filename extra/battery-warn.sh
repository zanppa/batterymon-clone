#!/bin/sh

# ask the user if they would like to shut down
# TODO	: internationalization?

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS]
Prompt the user to hibernate/shutdown.

  -h		Show this help message.
  -t SECONDS	Set the dialog timeout to SECONDS (default is 60).
  -S		Shutdown instead of hibernate.
  -W		Only warn, do not take any action.

For best results:
* Make sure the user this runs as is able to run programs via sudo(8), or run
  this program as root.
* Install either Xdialog or xmessage and make sure they're in the PATH.

Copyright (C) 2012 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"
}

TIMEOUT=60
ACTION='h'
while getopts 't:SWh' flag; do
	case "$flag" in
		't')
			TIMEOUT="$OPTARG"
			;;
		'S')
			ACTION='s'
			;;
		'W')
			ACTION='n'
			;;
		'h')
			HELP_MESSAGE 0
			;;
		*)
			HELP_MESSAGE 1
			;;
	esac
done

shift "$((OPTIND-1))"

# (for debugging)
#sudo() {
#	echo sudo "$@" >&2
#}

do_hibernate() {
	if [ -w /sys/power/state ]; then
		# we can write it just fine (we *might* be root :-) ), no need
		# to sudo
		echo 'disk' >/sys/power/state
	elif sudo [ -w /sys/power/state ]; then
		# we can sudo
		echo 'disk' |sudo tee /sys/power/state >/dev/null
	else
		echo 'Unable to hibernate.' >&2
		return 2
	fi
}

do_shutdown() {
	if [ -x /sbin/shutdown ]; then
		if [ "$UID" -eq 0 ]; then
			/sbin/shutdown -h now
		else
			sudo /sbin/shutdown -h now
		fi
	elif [ -x /sbin/halt ]; then
		if [ "$UID" -eq 0 ]; then
			/sbin/halt
		else
			sudo /sbin/halt
		fi
	elif [ -x /sbin/poweroff ]; then
		if [ "$UID" -eq 0 ]; then
			/sbin/poweroff
		else
			sudo /sbin/poweroff
		fi
	elif [ -x /sbin/telinit ]; then
		if [ "$UID" -eq 0 ]; then
			/sbin/telinit 0
		else
			sudo /sbin/telinit 0
		fi
	else
		echo 'Unable to shutdown.' >&2
		return 2
	fi
}

##### display dialog

# define grammar for dialog box
case "$ACTION" in
	'h')
		# hibernation
		syntax_1='hibernation'
		syntax_2='Hibernate'
		;;
	's')
		# shutdown
		syntax_1='shutting down'
		syntax_2='Shut down'
		;;
	'n')
		go_ahead=0
		;;
esac

message="*** BATTERY LEVEL CRITICAL ***"

if [ "x$ACTION" != 'xn' ]; then
	message="$message
You have ${TIMEOUT} seconds before ${syntax_1}.
${syntax_2} now?"
else
	message="$message
Powering down is recommended."
fi

if [ -n "$(type -Pt Xdialog)" ]; then
	# we have the fancier Xdialog, so use it

	# unfortunately, there doesn't appear to be a way to update the timer
	# within an already-displaying Xdialog window

	# Xdialog exit codes:
	# 255 : timed out or closed
	# 1   : cancel
	# 0   : ok

	if [ "x$ACTION" != 'xn' ]; then
		Xdialog \
			--center \
			--title	'WARNING' \
			$([ "$TIMEOUT" -gt 0 ] && echo "--timeout $TIMEOUT") \
			--cancel-label "$syntax_2" \
			--ok-label 'Stay on' \
			--no-close \
			--yesno "$message" 10 45

		# we can do this because a non-zero exit status indicates
		# hibernate/shutdown condition
		go_ahead="$?"
	else
		# no action (`-W' flag)
		Xdialog \
			--center \
			--title	'WARNING' \
			$([ "$TIMEOUT" -gt 0 ] && echo "--timeout $TIMEOUT") \
			--cancel-label "$syntax_2" \
			--msgbox "$message" 8 45
	fi


elif [ -n "$(type -Pt xmessage)" ]; then
	# we have the crappier-looking xmessage, but that will work too

	# xmessage exit codes:
	# 0: timed out (or our action button)
	# 1: closed (or our non-action button)
	# ^ this means we're going to have to negate the return code

	if [ "x$ACTION" != 'xn' ]; then
		! xmessage \
			-center \
			$([ "$TIMEOUT" -gt 0 ] && echo "-timeout $TIMEOUT") \
			-default 'Stay on' \
			-buttons "Stay on:1,${syntax_2}:0" \
			"$message"

		go_ahead="$?"
	else
		# no action (`-W' flag)
		xmessage \
			-center \
			$([ "$TIMEOUT" -gt 0 ] && echo "-timeout $TIMEOUT") \
			-default 'OK' \
			-buttons "OK:0" \
			"$message"

	fi
else
	echo 'No windowed dialog program. Please install Xdialog or xmessage.' >&2
	# assume we want to shut down anyway, as this script is intended to be
	# run when a critical battery level is detected
	go_ahead=1
fi

##### perform action

if [ "$go_ahead" -ne 0 ]; then
	case "$ACTION" in
		's')
			do_shutdown
			;;
		'h')
			do_hibernate
			;;
		#*)
		#no action (`-W' switch)
	esac
fi
