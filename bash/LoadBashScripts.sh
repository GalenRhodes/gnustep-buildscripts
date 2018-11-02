#############################################################################
# Creating some useful functions for the command-line interface.  We will
# create our add-ons for the `.bashrc' file as several separate files that
# will live in a subdirectory called `.bash.d/' and will be imported by
# `.bashrc' from there.  This is nice because it keeps almost all of our
# changes separate and much easier to change and/or back out of. These
# subscripts all have the naming pattern of
# "bash[1234567890][1234567890]*.sh"
#
# Example: .bash.d/bash01setup.sh
#          .bash.d/bash28java.sh
#
# Note: In the example above, because of natural file-system ordering,
#       the numbers allow us to order the execution of the subscripts. So,
#       for example, `bash01setup.sh' will be executed before 
#       `bash02setup.sh'.  Also, `bash01aliases.sh' will be executed before 
#       `bash01setup.sh' because `aliases' is ordered before `setup'.
#
if [ -z "${LOAD_BASH_SCRIPTS_HAS_RUN}" ]; then
	__d="${HOME}/.bash.d"
	
	if [ -d "${__d}" ]; then
		for __f in ${__d}/bash[0-9][0-9]*.sh; do
			if [ -e "${__f}" -a ! -d "${__f}" ]; then
				source "${__f}"
			fi
		done
	fi
	
	unset __f __d
	export LOAD_BASH_SCRIPTS_HAS_RUN="Y"
fi;
