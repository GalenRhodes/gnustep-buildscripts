#############################################################################
# Find out what flavor of Linux we're working with.
#
# export BOARD_NAME="APPLE"
export BOARD_NAME="INTEL"
export DISTRO_NAME=`lsb_release -is`
export DISTRO_VERSION=`lsb_release -rs`

function TestOSVersion() {
	local __v

	for __v in "$@"; do
		if [ "${DISTRO_VERSION}" = "${__v}" ]; then
			return 0
		fi
	done

	return 1
}

function TestBoardName() {
	local __b

	for __b in "$@"; do
		if [ "${BOARD_NAME}" = "${__b}" ]; then
			return 0
		fi
	done

	return 1
}

function TestOdroidXU4() {
	TestBoardName "ODROID-XU3" && TestOSVersion "15.10" "15.04" && return 0
	return 1
}

function TestOdroidC2() {
	TestBoardName "ODROID-C2" && TestOSVersion "16.04" && return 0
	return 1
}

function TestOdroidU3() {
	TestBoardName "ODROID-U3" && TestOSVersion "14.04" "14.04.2" && return 0
	return 1
}

##################################################################
# Raspberry Pi Foundation have tried to make things very straight
# forward by keeping all models software compatible with previous
# models.  But, we're going to insist that the later models that
# use the Cortex-* family be running Ubuntu versions 15.04 and
# newer.
#
# Models A, B and B+ use the ARM1176JZFS processor (armv6-a)
# Model B-2 uses Cortex-A7 (armv7-a)
# Model B-3 uses Cortex-A53 (armv8-a)
##################################################################
function TestRPI() {
	return 0
}

function zprint() {
	local x=1

	if [ "$1" = "-n" ]; then
		shift
		x=0
	fi

	if [ $# -ge 2 ]; then
		printf "\e[0J\e[0m\e[1;37m[%s\e[1;37m]\e[1;36m" "$1"
		shift
		printf " %s" "$@"
	elif [ $# -eq 1 ]; then
		printf "\e[0J\e[0m\e[1;37m[%s\e[1;37m]" "$1"
	fi

	if [ ${x} -eq 0 ]; then
		printf "\e[0m"
	else
		printf "\e[0m\n"
	fi

	return 0
}

function zecho() {
	local c=$'\e[1;32m'

	if [ "$1" = "-n" ]; then
		local x="$1"
		local t="$2"
		shift 2
		zprint "${x}" "${c}${t}" "$@"
	else
		local t="$1"
		shift
		zprint "${c}${t}" "$@"
	fi

	return 0
}

function zwarn() {
	local r="$1"
	local c=$'\e[33m'
	shift
	zecho "${c}WARNING" "$@"
	return ${r}
}

function zfail() {
	local r="$1"
	local a=$'\e[31m'
	local b=$'\e[33m'
	local c=$'\e[0m'
	shift
	zecho "${a}ERROR" "${b}$@${c}"
	exit ${r}
}

function GrepPath() {
	if [ -n "$1" -a -n "$2" ]; then
		if eval "echo \"\${$1}\" | grep -Ee \"^$2:|:$2:|:$2\$|^$2\$\" >/dev/null"; then
			return 1
		fi
	fi
	return 0
}

function AddToAnyPath() {
	if [ "$#" -gt 1 -a -n "$1" ]; then
		local __p="$1"
		shift

		while [ "$#" -gt 0 ]; do
			local __a="$1"
			local __q=`eval "echo \"\\\${${__p}}\""`
			shift

			if [ -z "${__q}" ]; then

				eval "export ${__p}=\"${__a}\""

			elif [ -n "${__a}" -a -d "${__a}" ]; then
				if GrepPath "${__p}" "${__a}"; then

					eval "export ${__p}=\"${__a}:\${${__p}}\""

				fi
			fi
		done

		return 0
	fi
	return 1
}

function AddToPath() {
	if [ "$#" -gt 0 -a -n "$1" ]; then
		if AddToAnyPath "PATH" "$@"; then
			return 0
		fi
	fi
	return 1
}

function PushDir() { pushd "$1" >/dev/null 2>&1; return "$?"; }
function PopDir()  { popd >/dev/null 2>&1; return "$?"; }


export TestOSVersion
export TestBoardName
export TestOdroidXU4
export TestOdroidC2
export TestOdroidU3
export TestRPI
export zprint
export zecho
export zwarn
export zfail
export GrepPath
export AddToAnyPath
export AddToPath
export PushDir
export PopDir

AddToPath "${HOME}/bin"
#
#############################################################################
