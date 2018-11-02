#!/bin/bash
_CC=`which clang`
_GSTEP="/usr/local/gnustep"

. "${_GSTEP}/System/Library/Makefiles/GNUstep.sh"

rm -f *.d *.o test test2 test3

"${_CC}" `gnustep-config --objc-flags` `gnustep-config --gui-libs` -fobjc-arc -fobjc-arc-exceptions -fobjc-nonfragile-abi test.m -o test

"${_CC}" `gnustep-config --objc-flags` `gnustep-config --gui-libs` -fobjc-arc -fobjc-arc-exceptions -fobjc-nonfragile-abi test2.m -o test2

"${_CC}" `gnustep-config --objc-flags` `gnustep-config --gui-libs` -fobjc-arc -fobjc-nonfragile-abi \
    PGARCException.m PGTests.m main.m \
    -o test3a

"${_CC}" `gnustep-config --objc-flags` `gnustep-config --gui-libs` -fobjc-arc -fobjc-arc-exceptions -fobjc-nonfragile-abi \
    PGARCException.m PGTests.m main.m \
    -o test3b

exit "$?"
