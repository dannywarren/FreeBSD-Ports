#!/bin/sh
#
# Copyright (c) 2008  Peter Pentchev
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

set -e

LOCALBASE='/usr/local'
S5_DIR="${LOCALBASE}/share/s5"
S5_TEMPLATE="${S5_DIR}/s5-blank"
NOOP=''
VERBOSE=''

CKSUM='cksum'
CKSUM_ARGS=''

SHADOWDIR=''

# s5 blank path
# Create a new S5 presentation at the specified path
#
s5_blank()
{
	[ -z "$VERBOSE" ] || echo "s5_blank: path $1" 1>&2
	if [ -z "$1" ]; then
		echo 'Usage: s5 blank path' 1>&2
		exit 1
	fi

	if [ -e "$1" ] && ! [ -d "$1/" ]; then
		echo "Not a directory: $1" 1>&2
		exit 1
	fi

	[ -z "$VERBOSE" ] || echo "- creating the directory" 1>&2
	[ -e "$1" ] || ${NOOP} mkdir -p "$1"
	[ -z "$VERBOSE" ] || echo "- copying files from ${S5_TEMPLATE}" 1>&2
	${NOOP} cp -Rp ${VERBOSE:+'-v'} "${S5_TEMPLATE}"/ "$1"/
	[ -z "$VERBOSE" ] || echo "- s5_mksum for the initial checksums" 1>&2
	s5_mksum "$1"
}

# s5_cksum path
# Calculate the checksums of the actual files in path and compare them
# to the ones recorded when the presentation was created
#
s5_cksum()
{
	[ -z "$VERBOSE" ] || echo "s5_cksum: path $1" 1>&2
	if [ -z "$1" ]; then
		echo 'Usage: s5 cksum path' 1>&2
		exit 1
	fi

	if ! [ -d "$1/" ]; then
		echo "Not a directory: $1" 1>&2
		exit 1
	fi
	cksumfile="$1/s5-checksums.txt"
	if [ ! -f "$cksumfile" ] || [ ! -r "$cksumfile" ]; then
		echo "Invalid checksum file $cksumfile" 1>&2
		exit 1
	fi

	file=''
	nofile=''
	cksumbad=''
	while read cmd args; do
		[ -z "$VERBOSE" ] || echo "- read cmd $cmd args $args" 1>&2
		case "$cmd" in
			CKSUM_CMD)
				[ -z "$VERBOSE" ] || echo "  - comparing current command '$CKSUM' with '$args'" 1>&2
				if [ "$CKSUM" != "$args" ]; then
					echo "Checksum command mismatch: current '$CKSUM', file recorded with '$args'" 1>&2
					exit 1
				fi
				;;

			CKSUM_ARGS)
				[ -z "$VERBOSE" ] || echo "  - comparing current args '$CKSUM_ARGS' with '$args'" 1>&2
				if [ "$CKSUM_ARGS" != "$args" ]; then
					echo "Checksum arguments mismatch: current '$CKSUM_ARGS', file recorded with '$args'" 1>&2
					exit 1
				fi
				;;

			FILE)
				[ -z "$VERBOSE" ] || echo "  - handling file $args" 1>&2
				if [ ! -f "$1/$args" ]; then
					echo "Missing file described in the checksum records: $args" 1>&2
					nofile=1
					cksumbad=1
				else
					file="$args"
					nofile=''
				fi
				;;

			CKSUM)
				if [ -z "$nofile" ]; then
					if [ -z "$file" ]; then
						echo "Checksum without filename" 1>&2
						exit 1
					fi
					[ -z "$VERBOSE" ] || echo "  - about to check $file for $args" 1>&2
					o=`cd "$1" && $CKSUM $CKSUM_ARGS "$file"`
					[ -z "$VERBOSE" ] || echo "  - got checksum $o" 1>&2
					if [ "$o" != "$args" ]; then
						echo "Bad checksum for file $file" 1>&2
						cksumbad=1
					else
						if [ -n "$SHADOWDIR" ]; then
							d=`dirname "$file"`
							mkdir -p "$SHADOWDIR"/t/"$d"
							touch "$SHADOWDIR"/t/"$file"
						fi
					fi
				else
					[ -z "$VERBOSE" ] || echo "  - skipping checksum $args" 1>&2
				fi
				;;

			*)
				echo "Unsupported checksum keyword $cmd" 1>&2
				exit 1
				;;
		esac
	done < "$cksumfile"

	if [ -n "$cksumbad" ]; then
		echo "Some files failed the checksum check" 1>&2
		exit 1
	fi
	[ -z "$VERBOSE" ] || echo "- all fine!" 1>&2
}

# s5 mksum path
# Calculate the checksums of the stock S5 template files and record
# them into the S5 presentation at path
#
s5_mksum()
{
	[ -z "$VERBOSE" ] || echo "s5_mksum: path $1" 1>&2
	if [ -z "$1" ]; then
		echo 'Usage: s5 mksum path' 1>&2
		exit 1
	fi

	if [ -z "$NOOP" ] && ! [ -d "$1/" ]; then
		echo "Not a directory: $1" 1>&2
		exit 1
	fi

	cksumfile="$1/s5-checksums.txt"
	[ -z "$VERBOSE" ] || echo "- from ${S5_TEMPLATE} to $cksumfile" 1>&2
	(cd "${S5_TEMPLATE}" && \
	echo "CKSUM_CMD $CKSUM" && \
	echo "CKSUM_ARGS $CKSUM_ARGS" && \
	find . -type f | sed -e 's,^\./,,' | while read f; do
		s5_mksum_single "$f"
	done) | if [ -z "$NOOP" ]; then
		cat > "$cksumfile"
		if [ -n "$VERBOSE" ]; then
			cnt=`egrep -ce '^CKSUM ' "$cksumfile"`
			echo "- $cnt checksums recorded into $cksumfile" 1>&2
		fi
	else
		${NOOP} "Would write checksums to $cksumfile"
		cnt=0
		while read line; do
			[ -z "$VERBOSE" ] || ${NOOP} "$line"
			if expr "$line" : 'CKSUM ' > /dev/null; then
				cnt=`expr "$cnt" + 1`
			fi
		done
		${NOOP} "Would record checksums for $cnt files"
	fi
}

# Internal routine for calculating the checksum of a single file
s5_mksum_single()
{
	o=`$CKSUM $CKSUM_ARGS "$1"`
	echo "FILE $1"
	echo "CKSUM $o"
}

# s5 help
# Display the help message and exit
#
s5_help()
{
	cat << EOF
Usage:	s5 [-hNv] [-T template] command [args...]

The available command-line options are:
	-h	display this help message and exit
	-N	no-op mode, just display the commands without executing them
	-T	template directory, default /usr/local/share/s5/s5-blank
	-v	verbose operation, display diagnostic information

The available commands are:
	blank path
		Create a new S5 presentation at the specified path

	check path
		Alias for cksum

	cksum path
		Verify the checksums of the S5 presentation at path

	create path
		Alias for blank

	help
		Display this help message and exit

	mksum path
		Store the template checksums at the specified path

	new path
		Alias for blank

	update path
		Update an S5 presentation with the new S5 template files

	usage
		Alias for help
	
	verify path
		Alias for cksum
EOF
}

# Internal routine: create a temporary directory for tracking checksum files
s5_shadowdir_create()
{
	d=`mktemp -d -t s5tool`
	if [ ! -d "$d" ]; then
		echo "Could not create a shadow directory using mktemp" 1>&2
		exit 1
	fi
	chmod 700 "$d"
	trap s5_shadowdir_cleanup EXIT HUP INT QUIT TERM PIPE
	SHADOWDIR="$d"
}

# Internal routine: clean up the temporary directory at exit time
s5_shadowdir_cleanup()
{
	if [ -n "$SHADOWDIR" ] && [ -d "$SHADOWDIR" ] && [ -w "$SHADOWDIR" ]; then
		rm -rf "$SHADOWDIR"/t
		rmdir "$SHADOWDIR"
	fi
}

# s5_update path
# Update the S5 presentation at the specified path with files from
# the template directory, but only if the S5 presentation has not
# been modified in the meantime
#
s5_update()
{
	[ -z "$VERBOSE" ] || echo "s5_update: path $1" 1>&2
	s5_shadowdir_create
	s5_cksum "$1"

	[ -z "$VERBOSE" ] || echo "s5_update: checking for new files" 1>&2
	(cd "$S5_TEMPLATE" && find . -type f) | (
	noupdate=''
	while read f; do
		[ -z "$VERBOSE" ] || echo "- $f" 1>&2
		if [ -f "$1/$f" ]; then
			[ -z "$VERBOSE" ] || echo "  - exists in the working directory" 1>&2
			if cmp -s "$S5_TEMPLATE/$f" "$1/$f"; then
				[ -z "$VERBOSE" ] || echo "  - the files are the same :)" 1>&2
			else
				if [ ! -f "$SHADOWDIR"/t/"$f" ]; then
					echo "File in template and working dir, but not part of the previous template: $f" 1>&2
					noupdate=1
				fi
			fi
		fi
	done
	if [ -n "$noupdate" ]; then
		echo "Not proceeding with the update" 1>&2
		exit 1
	fi
	)

	[ -z "$VERBOSE" ] || echo "s5_update: about to delete files" 1>&2
	(cd "$SHADOWDIR"/t && find . -type f) | while read f; do
		if [ ! -f "$S5_TEMPLATE/$f" ]; then
			${NOOP} rm ${VERBOSE:+'-v'} "$1/$f"
		fi
	done

	[ -z "$VERBOSE" ] || echo "s5_update: about to copy files" 1>&2
	(cd "$S5_TEMPLATE" && find . -mindepth 1 -type d) | while read d; do
		if [ ! -d "$1/$d" ]; then
			${NOOP} mkdir -p ${VERBOSE:+'-v'} "$1/$d"
		else
			[ -z "$VERBOSE" ] || echo "- existing dir $d" 1>&2
		fi
	done
	(cd "$S5_TEMPLATE" && find . -type f) | while read f; do
		${NOOP} cp -p ${VERBOSE:+'-v'} "$S5_TEMPLATE/$f" "$1/$f"
	done

	[ -z "$VERBOSE" ] || echo "s5_update: invoking s5_mksum" 1>&2
	s5_mksum "$1"
}

# Process the command-line options
while getopts 'hNT:v' o; do
	case "$o" in
		h)
			s5_help
			exit 0
			;;

		N)
			NOOP='echo'
			;;

		T)
			S5_TEMPLATE="$OPTARG"
			;;

		v)
			VERBOSE="${VERBOSE}v"
			;;

		*)
			[ "$o" = '?' ] || echo "Unrecognized option '$o'" 1>&2
			s5_help
			exit 1
			;;
	esac
done
shift `expr "$OPTIND" - 1`

# Treat a simple "s5" invocation as a usage request
if [ -z "$1" ]; then
	s5_help
	exit
fi

# Okay, we have some a command...
[ -z "$VERBOSE" ] || echo "Parsing a command: $1" 1>&2
case "$1" in
	# b(lank), cr(eate), n(ew)
	b|bl|bla|blan|blank|cr|cre|crea|creat|create|n|ne|new)
		shift
		s5_blank "$1"
		;;
	
	# ch(eck), ck(sum), v(erify)
	ch|che|chec|check|ck|cks|cksu|cksum|v|ve|ver|verify)
		shift
		s5_cksum "$1"
		;;

	# h(elp), us(age)
	h|he|hel|help|us|usa|usag|usage)
		shift
		s5_help
		;;
	
	# m(ksum)
	m|mk|mks|mksu|mksum)
		shift
		s5_mksum "$1"
		;;
	
	# up(date)
	up|upd|upda|updat|update)
		shift
		s5_update "$1"
		;;

	*)
		echo "Unrecognized s5 command $1" 1>&2
		s5_help 1>&2
		exit 1
		;;
esac
