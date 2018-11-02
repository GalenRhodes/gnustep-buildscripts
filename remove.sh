#!/bin/bash

_ETC="/etc"
_USR="/usr"
_USRDIR="${_USR}/local"
_GSDIR="${_USRDIR}/gnustep"
_PRJDIR="${HOME}/Projects"

sudo rm -fr "${HOME}/.bash.d/bash04gnustep.sh"       2>/dev/null
sudo rm -fr "${HOME}/GNUstep"                        2>/dev/null
sudo rm -fr "${_ETC}/GNUstep"                        2>/dev/null
sudo rm -fr "${_ETC}/ld.so.conf.d/gnustep-make.conf" 2>/dev/null
sudo rm -fr "${_GSDIR}"                              2>/dev/null
sudo rm -fr "${_PRJDIR}/GNUstep-build"               2>/dev/null
sudo rm -fr "${_PRJDIR}/GNUstep"                     2>/dev/null
sudo rm -fr "${_USRDIR}/include/Block.h"             2>/dev/null
sudo rm -fr "${_USRDIR}/include/Block_private.h"     2>/dev/null
sudo rm -fr "${_USRDIR}/include/dispatch"            2>/dev/null
sudo rm -fr "${_USRDIR}/include/objc"                2>/dev/null
sudo rm -fr "${_USRDIR}/include/os"                  2>/dev/null
sudo rm -fr "${_USRDIR}/lib"/libdispatch*            2>/dev/null
sudo rm -fr "${_USRDIR}/lib"/libobjc*                2>/dev/null
sudo rm -fr "${_USR}/GNUstep"                        2>/dev/null
sudo rm -fr "${_USR}/gnustep"                        2>/dev/null

if [ -e "${_USRDIR}/lib/libBlocksRuntime.so" ]; then
    mv "${_USRDIR}/lib/libBlocksRuntime.so" "${_USRDIR}/lib/libBlocksRuntime.`date +%Y%m%d%H%M%S`"
fi

unset GNUSTEP_MAKEFILES
unset GUILE_LOAD_PATH
sudo ldconfig

exit 0
