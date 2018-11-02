#!/bin/bash

_PROMPT="Y"
_BASH_HELPERS="N"
_DOWNLOAD_ONLY="N"
_BUILD_APPS="N"
_BUILD_CLANG="N"
_CLANG_VER="tags/RELEASE_700/final/"
_BUILD_DISPATCH_FIRST="Y"
_BUILD_INITIAL_MAKE="N"
_INSTALL_LIBKQUEUE="Y"
_OLDABI_COMPAT="ON"
_NO_MIXED_ABI="Y"
_USE_APPLE_DISPATCH="N"
_USE_NONFRAGILE_ABI_FLAG="N"
_INSTALL_PREREQS="Y"
_INSTALL_PATH="/usr/local"
_OBJC_NAME="objc2"
_GNU_VER="1.9"
_PROCS="${PROCESSORS}"

if [ -z "${_PROCS}" ]; then
    _PROCS="2"
fi

_TIMESTAMP=`date +%Y-%m-%d`
#_BEFORE_DATE="2017-01-01"
#_OBJC2_DATE="2017-01-01"
_BEFORE_DATE="${_TIMESTAMP}"
_OBJC2_DATE="${_TIMESTAMP}"

_GITHUB="https://github.com"
_LLVMSVN="http://llvm.org/svn/llvm-project"

_GSDIR="${_INSTALL_PATH}/gnustep"
_PDIR="${HOME}/Projects"
_PRJDIR="${_PDIR}/GNUstep"
_COREDIR="${_PRJDIR}/core"
_GTEST_BDIR="/usr/src/gtest/build"

_GNUSTEP="${_GSDIR}/System/Library/Makefiles/GNUstep.sh"
_GNUVER="-fobjc-runtime=gnustep-${_GNU_VER}"

_CC=`which clang`
_CXX=`which clang++`
_LD="/usr/bin/ld"

function MkdirCD() {
	local _lastDir=""
	local _cmd="mkdir"
	
	if [ "$#" -gt 0 -a "$1" = "-s" ]; then
		_cmd="sudo -E ${_cmd}"
		shift
	fi
	if [ "$#" -gt 0 ]; then
		for _f in "$@"; do
			${_cmd} -p "${_f}" || return "$?"
			_lastDir="${_f}"
		done
		cd "${_lastDir}" || return "$?"
	fi
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

# Show prompt function
function showPrompt() {
	local c=$'\e[33m'
	if [ "${_PROMPT}" = "Y" ]; then
		echo -e "\n"
		zecho -n "${c}ALERT" "PRESS ANY KEY TO CONTINUE..."
		read -p ""
		echo -e "\n"
	fi
}

function gitFiles() {
    local _description="$1"
    local _url="$2"
    local _path=""
    local _branch=""
	local _before="N"
	local _before_date="${_BEFORE_DATE}"
    local _r=""
    local _l=""

    shift 2

    if [ "$1" = "--branch" ]; then
        _branch="$2"
        shift 2
    fi

    _path="$1"

	if [ $# -ge 2 -a "$2" = "Y" ]; then
		_before="Y"
		if [ $# -ge 3 -a -n "$3" ]; then
			_before_date="$3"
		fi
	fi

	zecho "DOWNLOADING" "${_description}..."
	if [ -n "${_branch}" ]; then
	    git clone "${_url}" --branch "${_branch}" --single-branch "${_path}"
	else
	    git clone "${_url}" "${_path}"
	fi
    _r="$?"

	if [ "${_before}" = "Y" ]; then
		if [ "${_before_date}" != "${_TIMESTAMP}" ]; then
			pushd "${_path}" >>/dev/null
			zecho "CHECKOUT" "Checking out image dated before ${_before_date}..."
			_l=`git rev-list -n 1 --first-parent --before="${_before_date}" master`
			zecho "CHECKOUT" "Checking out label ${_l}..."
#			git checkout "${_l}" 2>> "${_PRJDIR}/SVNLogs.log"
			git checkout "${_l}"
        	_r="$?"
			popd >>/dev/null
			showPrompt
		fi
	fi

	return "${_r}"
}

function svnFiles() {
	zecho "DOWNLOADING" "$1..."
	svn co "$2" "$3" >> "${_PRJDIR}/SVNLogs.log" || return "$?"
	svn upgrade "$3"
	return "$?"
}

function buildGTEST() {
	zecho "INSTALLING" "Making sure libgtest.so is up-to-date..."
	sudo apt-get -y install libgtest-dev || return "$?"
	MkdirCD -s "${_GTEST_BDIR}" || return "$?"
	sudo -E rm -fr "${_GTEST_BDIR}"/* 2>>/dev/null
	
	sudo -E cmake -G "Unix Makefiles" -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_COMPILER="${_CXX}" -DCMAKE_CXX_FLAGS= -DCMAKE_CXX_FLAGS_RELEASE="${CFLAGS}" \
		-DCMAKE_C_COMPILER="${_CC}" -DCMAKE_C_FLAGS= -DCMAKE_C_FLAGS_RELEASE="${CFLAGS}" \
		-DCMAKE_LINKER="${LD}" -DCMAKE_MODULE_LINKER_FLAGS= .. || return "$?"
		
	sudo -E make "-j${_PROCS}" || return "$?" "Build Failed!"
	
	sudo -E rm /usr/lib/libgtest*.so* 2>>/dev/null
	for _t in libgtest*.so; do
		sudo -E ln -s "${_GTEST_BDIR}/${_t}" "/usr/lib/${_t}"
	done

	return 0
}

function printCompilerInfo() {
    zecho "INFO" "        C compiler: ${CC}"
    zecho "INFO" "      C++ compiler: ${CXX}"
    zecho "INFO" "  C compiler flags: ${CFLAGS}"
    zecho "INFO" "C++ compiler flags: ${CXXFLAGS}"
    zecho "INFO" "                LD: ${LD}"
    zecho "INFO" "          LD flags: ${LDFLAGS}"
    showPrompt
	return 0
}

function pe() {
	printenv | grep --color=auto -v "^LS_COLORS=" | sort | grep -Ee "^[^=]+="
	return 0
}

function ldv() {
	ld --verbose | grep SEARCH_DIR | tr -s ' ;' \\012
	return 0
}

function buildLibDispatch() {
	local bsys="Unix Makefiles"
	local bexe="make"
	local cmd="-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=${_CXX}"
	cmd="${cmd} -DCMAKE_CXX_FLAGS= -DCMAKE_CXX_FLAGS_RELEASE=${CFLAGS}"
	cmd="${cmd} -DCMAKE_C_COMPILER=${_CC} -DCMAKE_C_FLAGS="
	cmd="${cmd} -DCMAKE_C_FLAGS_RELEASE=${CFLAGS}"
	cmd="${cmd} -DCMAKE_INSTALL_PREFIX=${_INSTALL_PATH}"
	cmd="${cmd} -DCMAKE_LINKER=${LD} -DCMAKE_MODULE_LINKER_FLAGS="

	if [ "${_USE_APPLE_DISPATCH}" = "Y" ]; then
		bsys="Ninja"
		bexe="ninja"
	fi
	
	MkdirCD "${_PRJDIR}/libdispatch/build"
	zecho "CONFIGURING" "libdispatch"
	cmake -G "${bsys}" ${cmd} .. || zfail  "$?" "CMAKE Failed!"
	zecho "BUILDING" "libdispatch"
	"${bexe}" "-j${_PROCS}" || zfail "$?" "Build Failed!"
	sudo -E "${bexe}" install || zfail "$?" "Install Failed!"	
	sudo ldconfig
}

function buildLibObjc2() {
	local oldabi=""
	
	MkdirCD "${_PRJDIR}/libobjc2/build"
	zecho "CONFIGURING" "libobjc"

	if [ "${_OLDABI_COMPAT}" != "ON" ]; then
		oldapi="-DOLDABI_COMPAT=OFF"
	fi
	
	cmake -G "Unix Makefiles"  -DBUILD_STATIC_LIBOBJC=ON -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_COMPILER="${_CXX}" -DCMAKE_CXX_FLAGS_RELEASE="${CFLAGS}" \
		-DCMAKE_C_COMPILER="${_CC}" -DCMAKE_C_FLAGS= -DCMAKE_CXX_FLAGS= \
		-DCMAKE_C_FLAGS_RELEASE="${CFLAGS}" -DCMAKE_INSTALL_PREFIX="${_INSTALL_PATH}" \
		-DCMAKE_LINKER="${LD}" -DLIBOBJC_NAME="${_OBJC_NAME}" -DTESTS=OFF \
		-DTYPE_DEPENDENT_DISPATCH=ON "${oldapi}" .. || zfail  "$?" "CMAKE Failed!"

	showPrompt
	zecho "BUILDING" "libobjc"
	#cmake --build . || zfail "$?" "CMAKE BUILD failed!"
	make "-j${_PROCS}" || zfail "$?" "Build Failed!"
	sudo -E make install || zfail "$?" "Install Failed!"
	
	###################################################################
	# Because the Makefile sometimes failes to create these links...
	#
	pushd "${_INSTALL_PATH}/include" >> /dev/null
	
	if [ -e "objc/blocks_runtime.h" ]; then
        sudo rm "Block.h" 2>>/dev/null
        sudo ln -s "objc/blocks_runtime.h" "Block.h"
    fi
    
    if [ -e "objc/blocks_private.h" ]; then
        sudo rm "Block_private.h" 2>>/dev/null
        sudo ln -s "objc/blocks_private.h" "Block_private.h"
    fi
    
    popd >>/dev/null
    #
	###################################################################

	sudo ldconfig
}

function buildGNUstepMake() {
	local nfabi=""
	local bashpath="${HOME}/.bash.d/bash04gnustep.sh"
	local bashrcpath="${HOME}/.bashrc"

	if [ "${_USE_NONFRAGILE_ABI_FLAG}" = "Y" ]; then
		nfabi="--enable-objc-nonfragile-abi"
	fi

	cd "${_COREDIR}/make"
	zecho "CONFIGURING" "GNUstep Make"

	./configure --prefix="${_GSDIR}" "${nfabi}" --with-library-combo=ng-gnu-gnu --enable-objc-arc \
		--enable-native-objc-exceptions --enable-debug-by-default --with-layout=gnustep \
		--enable-install-ld-so-conf --with-objc-lib-flag="-l${_OBJC_NAME}" || return "$?"
		
	zecho "BUILDING" "GNUstep Make"
	make "-j${_PROCS}"
	sudo -E make install
	if [ "${_BASH_HELPERS}" = "Y" ]; then
		rm "${bashpath}" 2>/dev/null
		ln -s "${_GNUSTEP}" "${bashpath}"
	else
		echo ". ${_GNUSTEP}" >> "${bashrcpath}"
	fi
	showPrompt
	return "$?"
}

#############################################################################################
# Export some of the environment for child-scripts...
#
export CC="${_CC}"
export CXX="${_CXX}"
export CFLAGS="-integrated-as -Qunused-arguments -Ofast -fblocks -w"
export CXXFLAGS="-integrated-as -Qunused-arguments -Ofast -fblocks -w"
export LDFLAGS="-Wl,--strip-all -fblocks"
export LD="${_LD}"
export zprint zecho zwarn zfail showPrompt

#############################################################################################
# Create the work directory if it's not there already...
#
MkdirCD "${_PRJDIR}"

#############################################################################################
# Clear the logs...
#
rm -f "${_PRJDIR}/SVNLogs.log" 2>>/dev/null
sudo ldconfig

#############################################################################################
# Make sure we have the required software and that it is up-to-date...
#
if [ "${_INSTALL_PREREQS}" = "Y" ]; then
	sudo apt-get update

	sudo apt-get -y install git build-essential subversion libffi-dev libxml2-dev libgnutls28-dev \
		libicu-dev libblocksruntime-dev autoconf libgtest-dev libtool curl auto-apt libjpeg-dev \
		libtiff-dev libpng12-dev libcups2-dev libfreetype6-dev libcairo2-dev libxt-dev \
		libgl1-mesa-dev cmake ninja-build systemtap-sdt-dev libbsd-dev linux-libc-dev libx11-dev \
		libxft-dev

	if [ "${_INSTALL_LIBKQUEUE}" = "Y" ]; then
		sudo apt-get -y install libkqueue-dev libpthread-workqueue-dev
	fi
fi

#############################################################################################
# Get and build latest CLANG from source...
#
if [ "${_BUILD_CLANG}" = "Y" ]; then
	buildGTEST || zfail "$?"

	svnFiles "LLVM Source"          "${_LLVMSVN}/llvm/${_CLANG_VER}"              "${_PRJDIR}/llvm"                                           || zfail  "$?" "SVN Request Failed!"
	svnFiles "CLANG Source"         "${_LLVMSVN}/cfe/${_CLANG_VER}"               "${_PRJDIR}/llvm/tools/clang"                               || zfail  "$?" "SVN Request Failed!"
	svnFiles "CLANG Runtime Source" "${_LLVMSVN}/compiler-rt/${_CLANG_VER}"       "${_PRJDIR}/llvm/projects/compiler-rt"                      || zfail  "$?" "SVN Request Failed!"
	svnFiles "CLANG Tools Source"   "${_LLVMSVN}/clang-tools-extra/${_CLANG_VER}" "${_PRJDIR}/llvm/tools/clang/tools/extra/clang-tools-extra" || zfail  "$?" "SVN Request Failed!"

	if [ "${_DOWNLOAD_ONLY}" != "Y" ]; then
		MkdirCD "${_PRJDIR}/llvm/build"
		zecho "CONFIGURING" "LLVM/CLANG"
		cmake -G "Unix Makefiles" -Wno-dev \
			"-DBUILD_SHARED_LIBS=ON" \
			"-DCLANG_INCLUDE_DOCS=OFF" \
			"-DCLANG_INCLUDE_TESTS=OFF" \
			"-DCMAKE_BUILD_TYPE=Release" \
			"-DCMAKE_CXX_COMPILER=${_CXX}" \
			"-DCMAKE_CXX_FLAGS=" \
			"-DCMAKE_CXX_FLAGS_RELEASE=${CFLAGS}" \
			"-DCMAKE_C_COMPILER=${_CC}" \
			"-DCMAKE_C_FLAGS=" \
			"-DCMAKE_C_FLAGS_RELEASE=${CFLAGS}" \
			"-DCMAKE_INSTALL_PREFIX=${_INSTALL_PATH}" \
			"-DCMAKE_LINKER=${LD}" \
			"-DCMAKE_MODULE_LINKER_FLAGS=" \
			"-DCOMPILER_RT_CAN_EXECUTE_TESTS=OFF" \
			"-DCOMPILER_RT_INCLUDE_TESTS=OFF" \
			"-DFFI_INCLUDE_DIR=`dirname $(find /usr -name "libffi.so") 2>/dev/null`" \
			"-DFFI_LIBRARY_DIR=`dirname $(find /usr -name "libffi.h") 2>/dev/null`" \
			"-DLLVM_BINUTILS_INCDIR=`dirname $(find /usr -name "plugin-api.h") 2>/dev/null`" \
			"-DLLVM_BUILD_DOCS=OFF" \
			"-DLLVM_ENABLE_EH=ON" \
			"-DLLVM_ENABLE_FFI=ON" \
			"-DLLVM_ENABLE_RTTI=ON" \
			"-DLLVM_INCLUDE_BENCHMARKS=OFF" \
			"-DLLVM_INCLUDE_DOCS=OFF" \
			"-DLLVM_INCLUDE_EXAMPLES=OFF" \
			"-DLLVM_INCLUDE_GO_TESTS=OFF" \
			"-DLLVM_INCLUDE_TESTS=OFF" \
			"-DLLVM_INCLUDE_TOOLS=ON" \
			"-DLLVM_INCLUDE_UTILS=ON" \
			"-DLLVM_INSTALL_UTILS=ON" \
			"-DLLVM_TARGETS_TO_BUILD=X86" \
			"-DLLVM_TOOL_CLANG_TOOLS_EXTRA_BUILD=ON" \
			.. || zfail  "$?" "CMAKE Failed!"
		# cmake-gui .. || zfail  "$?" "CMAKE Failed!"
		zecho "BUILDING" "LLVM/CLANG"
		make "-j${_PROCS}" || zfail "$?" "Build Failed!"
		sudo -E make install || zfail "$?" "Install Failed!"
		sudo ldconfig
		zecho "SUCCESS" "LLVM/CLANG built and installed."
		_CC="${_INSTALL_PATH}/bin/clang"
		_CXX="${_INSTALL_PATH}/bin/clang++"
		_LD=`which ld.gold`

		export CC="${_CC}"
		export CXX="${_CXX}"
		printCompilerInfo
	fi
fi

#############################################################################################
# Get the software source straight from the repository...
#
# Apple's implementation of libdispatch for Linux is better but does not compile on all
# platforms.
#
if [ "${_USE_APPLE_DISPATCH}" = "Y" ]; then
	gitFiles "libdispatch from Swift Project"   "${_GITHUB}/apple/swift-corelibs-libdispatch.git" "${_PRJDIR}/libdispatch" "N" || zfail  "$?" "GIT request failed!"
else
	gitFiles "libdispatch from Nick Hutchinson" "${_GITHUB}/nickhutchinson/libdispatch.git"       "${_PRJDIR}/libdispatch" "N" || zfail  "$?" "GIT request failed!"
fi

gitFiles "libobjc"                "${_GITHUB}/gnustep/libobjc2.git" --branch "1.9" "${_PRJDIR}/libobjc2"  "Y" "${_OBJC2_DATE}"  || zfail  "$?" "GIT request failed!"
gitFiles "GNUstep Make"           "${_GITHUB}/gnustep/tools-make.git"              "${_COREDIR}/make"     "Y" "${_BEFORE_DATE}" || zfail  "$?" "GIT request failed!"
gitFiles "GNUstep Base"           "${_GITHUB}/gnustep/libs-base.git"               "${_COREDIR}/base"     "Y" "${_BEFORE_DATE}" || zfail  "$?" "GIT request failed!"
gitFiles "GNUstep GUI"            "${_GITHUB}/gnustep/libs-gui.git"                "${_COREDIR}/gui"      "Y" "${_BEFORE_DATE}" || zfail  "$?" "GIT request failed!"
gitFiles "GNUstep AppKit Backend" "${_GITHUB}/gnustep/libs-back.git"               "${_COREDIR}/back"     "Y" "${_BEFORE_DATE}" || zfail  "$?" "GIT request failed!"

showPrompt

if [ "${_BUILD_APPS}" = "Y" ] ; then
	zecho "INFO" "Getting apps..."
	gitFiles "GNUstep Project Center"     "${_GITHUB}/gnustep/apps-projectcenter.git"     "${_COREDIR}/apps-projectcenter"     "N" || zfail  "$?" "GIT request failed!"
	gitFiles "GNUstep GORM"               "${_GITHUB}/gnustep/apps-gorm.git"              "${_COREDIR}/apps-gorm"              "N" || zfail  "$?" "GIT request failed!"
	gitFiles "GNUstep GWorkspace"         "${_GITHUB}/gnustep/apps-gworkspace.git"        "${_COREDIR}/apps-gworkspace"        "N" || zfail  "$?" "GIT request failed!"
	gitFiles "GNUstep System Preferences" "${_GITHUB}/gnustep/apps-systempreferences.git" "${_COREDIR}/apps-systempreferences" "N" || zfail  "$?" "GIT request failed!"
	showPrompt
fi

#############################################################################################
# Build GNUstep Make for the first time...
#
if [ "${_BUILD_INITIAL_MAKE}" = "Y" ]; then
	buildGNUstepMake || zfail "$?" "Building GNUstep Make Failed!"
	. "${_GNUSTEP}"
	sudo ldconfig
fi

#############################################################################################
# Build libdispatch and libobjc2...
#
if [ "${_BUILD_DISPATCH_FIRST}" = "Y" ]; then
	buildLibDispatch
	export LDFLAGS="-ldispatch ${LDFLAGS}"
	sudo ldconfig
	showPrompt
	buildLibObjc2
	export CFLAGS="${CFLAGS} ${_GNUVER}"
	export CXXFLAGS="${CXXFLAGS} ${_GNUVER}"
	export OBJCFLAGS="-fblocks ${_GNUVER} ${OBJCFLAGS}"
	export LDFLAGS="-L${_INSTALL_PATH}/lib ${LDFLAGS} -fblocks ${_GNUVER}"
	sudo ldconfig
else
	buildLibObjc2
	export CFLAGS="${CFLAGS} ${_GNUVER}"
	export CXXFLAGS="${CXXFLAGS} ${_GNUVER}"
	export OBJCFLAGS="-fblocks ${_GNUVER} ${OBJCFLAGS}"
	export LDFLAGS="-L${_INSTALL_PATH}/lib ${LDFLAGS} -fblocks ${_GNUVER}"
	sudo ldconfig
	showPrompt
	buildLibDispatch
	export LDFLAGS="-ldispatch ${LDFLAGS}"
	sudo ldconfig
fi
showPrompt

#############################################################################################
# Build GNUstep Make for the second time...
#
buildGNUstepMake || zfail "$?" "Building GNUstep Make Failed!"
. "${_GNUSTEP}"
sudo ldconfig
zecho "                       CFLAGS" "${CFLAGS}"
zecho "                     CXXFLAGS" "${CXXFLAGS}"
zecho "                    OBJCFLAGS" "${OBJCFLAGS}"
zecho "                      LDFLAGS" "${LDFLAGS}"
zecho "   Objective-C Compiler Flags" "`gnustep-config --objc-flags`"
zecho "Objective-C Base Linker Flags" "`gnustep-config --base-libs`"
showPrompt

#############################################################################################
# Build Foundation...
#
cd "${_COREDIR}/base"
showPrompt
if [ "${_NO_MIXED_ABI}" = "Y" ]; then
	zecho "CONFIGURING" "GNUstep Base WITHOUT Mixed-ABI support..."
	. "${_GNUSTEP}"
	./configure --disable-mixedabi || zfail "$?" "Configure Failed!"
else
	zecho "CONFIGURING" "GNUstep Base WITH Mixed-ABI support..."
	. "${_GNUSTEP}"
	./configure || zfail "$?" "Configure Failed!"
fi
showPrompt
zecho "BUILDING" "GNUstep Base"
make "-j${_PROCS}" || zfail "$?" "Build Failed!"
sudo -E make install || zfail "$?" "Install Failed!"
sudo ldconfig
showPrompt

#############################################################################################
# Build AppKit...
#
cd "${_COREDIR}/gui"
zecho "CONFIGURING" "GNUstep GUI"
./configure || zfail "$?" "Configure Failed!"
showPrompt
zecho "BUILDING" "GNUstep GUI"
make "-j${_PROCS}" || zfail "$?" "Build Failed!"
sudo -E make install || zfail "$?" "Install Failed!"
sudo ldconfig
showPrompt

#############################################################################################
# Build AppKit Backend...
#
cd "${_COREDIR}/back"
zecho "CONFIGURING" "GNUstep AppKit Backend"
./configure || zfail "$?" "Configure Failed!"
showPrompt
zecho "BUILDING" "GNUstep AppKit Backend"
make "-j${_PROCS}" || zfail "$?" "Build Failed!"
sudo -E make install || zfail "$?" "Install Failed!"
sudo ldconfig
showPrompt

#############################################################################################
# Make the UI look right...
#
defaults write NSGlobalDomain NSInterfaceStyleDefault NSWindows95InterfaceStyle
defaults write NSGlobalDomain GSSuppressAppIcon YES

#############################################################################################
# Build GNUstep Apps...
#
_APP_BUILD_MESSAGE=""

function BuildAppFailed() {
    _APP_BUILD_MESSAGE="$2"
    return "$1"
}

function BuildApp() {
    local _description="$1"
    local _sourcepath="$2"
    local _needsconfig="$3"

    cd "${_COREDIR}/${_sourcepath}" || BuildAppFailed "$?" "${_description} source directory does not exist."
    if [ "${_needsconfig}" = "Y" ]; then
        ./configure || BuildAppFailed "$?" "${_description} configuration failed."
    fi
    make "-j${_PROCS}" || BuildAppFailed "$?" "${_description} build failed."
    sudo -E make install || BuildAppFailed "$?" "${_description} installation failed."
    sudo ldconfig
    showPrompt
    zecho "${_description}" "Successfully built and installed."
    return 0
}

if [ "${_BUILD_APPS}" = "Y" ]; then
    BuildApp "GNUstep Project Center"     "apps-projectcenter"     "N" || zfail "$?" "${_APP_BUILD_MESSAGE}"
    BuildApp "GNUstep GORM"               "apps-gorm"              "N" || zfail "$?" "${_APP_BUILD_MESSAGE}"
    BuildApp "GNUstep GWorkspace"         "apps-gworkspace"        "Y" || zfail "$?" "${_APP_BUILD_MESSAGE}"
    BuildApp "GNUstep System Preferences" "apps-systempreferences" "N" || zfail "$?" "${_APP_BUILD_MESSAGE}"
fi

#############################################################################################
# Build Test...
#
cd "${_PDIR}/test"
./buildtest.sh || zfail "$?" "Building Test Apps Failed!"

#############################################################################################
# Run the test...
#
# ./test2

exit 0
