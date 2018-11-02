##########################################################################
# Set environment variables for compiling with clang instead of gcc...
#
if [ ! -d "${HOME}/include" ]; then
	mkdir -p "${HOME}/include"
fi
if [ ! -d "${HOME}/lib" ]; then
	mkdir -p "${HOME}/lib"
fi

PROCESSORS=`cat /proc/cpuinfo | grep -E '^processor' | nl | awk '{print $1}' | tail -n1`

CC=`which clang`
CXX=`which clang++`

LD="/usr/bin/ld.gold"
if [ ! -e "${LD}" ]; then
	LD=`which ld`
fi

LDFLAGS="-Wl,--strip-all -L${HOME}/lib"

CFLAGS="-I${HOME}/include ${LDFLAGS} -Ofast -g0 -w"

if [ -n "${CC}" -a -n "${CXX}" ]; then
	CFLAGS="-integrated-as -Qunused-arguments ${CFLAGS}"
else
	CC=`which cc`
	CXX=`which c++`
	CFLAGS="-std=c99 ${CFLAGS}"
fi

case "${BOARD_NAME}" in
	"BCM2708")                   CFLAGS="-march=armv6   -mcpu=arm1176jzf-s -mtune=arm1176jzf-s -mfpu=vfp   -mfloat-abi=hard ${CFLAGS}";;
	"BCM2709")                   CFLAGS="-march=armv7-a -mcpu=cortex-a7    -mtune=cortex-a7    -mfpu=vfpv4 -mfloat-abi=hard ${CFLAGS}";;
	"ODROID-U2/U3" | "ODROIDU2") CFLAGS="-march=armv7-a -mcpu=cortex-a9    -mtune=cortex-a9    -mfpu=vfpv3 -mfloat-abi=hard ${CFLAGS}";;
	"ODROID-XU3")                CFLAGS="-march=armv7-a -mcpu=cortex-a15   -mtune=cortex-a15   -mfpu=vfpv4 -mfloat-abi=hard ${CFLAGS}";;
	"ODROID-C2")                 CFLAGS="-march=armv8-a -mcpu=cortex-a53  ${CFLAGS}";;
esac

export CXXFLAGS="${CFLAGS}"
export CC CXX LD CFLAGS LDFLAGS PROCESSORS
#
##########################################################################
