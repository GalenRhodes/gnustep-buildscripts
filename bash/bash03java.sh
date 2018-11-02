################################################################
#
_f="/usr/local/java/jdk-9"
# _f="/usr/lib/jvm/java-8-openjdk-amd64"

if [ -e "${_f}" ]; then
	export JDK_HOME="${_f}"

	if [ -e "${JDK_HOME}/jre" ]; then
		export JAVA_HOME="${JDK_HOME}/jre"
	else
		export JAVA_HOME="${JDK_HOME}"
	fi

	AddToPath "${JDK_HOME}/bin" "${JAVA_HOME}/bin"
else
	_f="/usr/lib/jvm/default-java"

	if [ -e "${_f}" ]; then
		export JDK_HOME="${_f}"
		export JAVA_HOME="${JDK_HOME}/jre"
		AddToPath "${JDK_HOME}/bin" "${JAVA_HOME}/bin"
	else
		############################################################
		# Find the JRE and JDK the hard way...
		#
		_e=`find /usr -name "java" | grep -E 'bin/java' | sort | tail -n1`
		_f=`find /usr -name "javac" | grep -E 'bin/javac' | sort | tail -n1`

		if [ -n "${_e}" ]; then
			export JAVA_HOME=$(dirname "$(dirname "${_e}")")
			AddToPath "${JAVA_HOME}/bin"

			if [ -n "${_f}" ]; then
				export JDK_HOME=$(dirname "$(dirname "${_f}")")
				AddToPath "${JDK_HOME}/bin"
			fi
		fi
		unset _e
	fi
	#
	############################################################
fi
unset _f
#
################################################################
