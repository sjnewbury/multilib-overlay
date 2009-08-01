# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/multilib.eclass,v 1.74 2009/06/14 11:40:14 grobian Exp $

# @ECLASS: multilib.eclass
# @MAINTAINER:
# amd64@gentoo.org
# toolchain@gentoo.org
# @BLURB: This eclass is for all functions pertaining to handling multilib configurations.
# @DESCRIPTION:
# This eclass is for all functions pertaining to handling multilib configurations.

___ECLASS_RECUR_MULTILIB="yes"
[[ -z ${___ECLASS_RECUR_TOOLCHAIN_FUNCS} ]] && inherit toolchain-funcs

# Defaults:
export MULTILIB_ABIS=${MULTILIB_ABIS:-"default"}
export DEFAULT_ABI=${DEFAULT_ABI:-"default"}
export CFLAGS_default
export LDFLAGS_default
export CHOST_default=${CHOST_default:-${CHOST}}
export CTARGET_default=${CTARGET_default:-${CTARGET:-${CHOST_default}}}
export LIBDIR_default=${CONF_LIBDIR:-"lib"}
export CDEFINE_default="__unix__"
export KERNEL_ABI=${KERNEL_ABI:-${DEFAULT_ABI}}

# @FUNCTION: has_multilib_profile
# @DESCRIPTION:
# Return true if the current profile is a multilib profile and lists more than
# one abi in ${MULTILIB_ABIS}.  When has_multilib_profile returns true, that
# profile should enable the 'multilib' use flag. This is so you can DEPEND on
# a package only for multilib or not multilib.
has_multilib_profile() {
	[ -n "${MULTILIB_ABIS}" -a "${MULTILIB_ABIS}" != "${MULTILIB_ABIS/ /}" ]
}

# @FUNCTION: get_libdir
# @RETURN: the libdir for the selected ABI
# @DESCRIPTION:
# This function simply returns the desired lib directory. With portage
# 2.0.51, we now have support for installing libraries to lib32/lib64
# to accomidate the needs of multilib systems. It's no longer a good idea
# to assume all libraries will end up in lib. Replace any (sane) instances
# where lib is named directly with $(get_libdir) if possible.
#
# Jeremy Huddleston <eradicator@gentoo.org> (23 Dec 2004):
#   Added support for ${ABI} and ${DEFAULT_ABI}.  If they're both not set,
#   fall back on old behavior.  Any profile that has these set should also
#   depend on a newer version of portage (not yet released) which uses these
#   over CONF_LIBDIR in econf, dolib, etc...
get_libdir() {
	local CONF_LIBDIR
	if [ -n  "${CONF_LIBDIR_OVERRIDE}" ] ; then
		# if there is an override, we want to use that... always.
		echo ${CONF_LIBDIR_OVERRIDE}
	else
		get_abi_LIBDIR
	fi
}

# @FUNCTION: get_multilibdir
# @RETURN: Returns the multilibdir
get_multilibdir() {
	if has_multilib_profile; then
		eerror "get_multilibdir called, but it shouldn't be needed with the new multilib approach.  Please file a bug at http://bugs.gentoo.org and assign it to eradicator@gentoo.org"
		exit 1
	fi
	echo ${CONF_MULTILIBDIR:=lib32}
}

# @FUNCTION: get_libdir_override
# @DESCRIPTION:
# Sometimes you need to override the value returned by get_libdir. A good
# example of this is xorg-x11, where lib32 isnt a supported configuration,
# and where lib64 -must- be used on amd64 (for applications that need lib
# to be 32bit, such as adobe acrobat). Note that this override also bypasses
# portage version sanity checking.
# get_libdir_override expects one argument, the result get_libdir should
# return:
#
#   get_libdir_override lib64
get_libdir_override() {
	if has_multilib_profile; then
		eerror "get_libdir_override called, but it shouldn't be needed with the new multilib approach.  Please file a bug at http://bugs.gentoo.org and assign it to eradicator@gentoo.org"
		exit 1
	fi
	CONF_LIBDIR="$1"
	CONF_LIBDIR_OVERRIDE="$1"
	LIBDIR_default="$1"
}

# @FUNCTION: get_abi_var
# @USAGE: <VAR> [ABI]
# @RETURN: returns the value of ${<VAR>_<ABI>} which should be set in make.defaults
# @DESCRIPTION:
# ex:
# CFLAGS=$(get_abi_var CFLAGS sparc32) # CFLAGS=-m32
#
# Note that the prefered method is to set CC="$(tc-getCC) $(get_abi_CFLAGS)"
# This will hopefully be added to portage soon...
#
# If <ABI> is not specified, ${ABI} is used.
# If <ABI> is not specified and ${ABI} is not defined, ${DEFAULT_ABI} is used.
# If <ABI> is not specified and ${ABI} and ${DEFAULT_ABI} are not defined, we return an empty string.
get_abi_var() {
	local flag=$1
	local abi
	if [ $# -gt 1 ]; then
		abi=${2}
	elif [ -n "${ABI}" ]; then
		abi=${ABI}
	elif [ -n "${DEFAULT_ABI}" ]; then
		abi=${DEFAULT_ABI}
	else
		abi="default"
	fi

	local var="${flag}_${abi}"
	echo ${!var}
}

# @FUNCTION: get_abi_CFLAGS
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var CFLAGS'
get_abi_CFLAGS() { get_abi_var CFLAGS "$@"; }

# @FUNCTION: get_abi_ASFLAGS
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var ASFLAGS'
get_abi_ASFLAGS() { get_abi_var ASFLAGS "$@"; }

# @FUNCTION: get_abi_LDFLAGS
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var LDFLAGS'
get_abi_LDFLAGS() { get_abi_var LDFLAGS "$@"; }

# @FUNCTION: get_abi_CHOST
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var CHOST'
get_abi_CHOST() { get_abi_var CHOST "$@"; }

# @FUNCTION: get_abi_CTARGET
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var CTARGET'
get_abi_CTARGET() { get_abi_var CTARGET "$@"; }

# @FUNCTION: get_abi_FAKE_TARGETS
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var FAKE_TARGETS'
get_abi_FAKE_TARGETS() { get_abi_var FAKE_TARGETS "$@"; }

# @FUNCTION: get_abi_CDEFINE
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var CDEFINE'
get_abi_CDEFINE() { get_abi_var CDEFINE "$@"; }

# @FUNCTION: get_abi_LIBDIR
# @USAGE: [ABI]
# @DESCRIPTION:
# Alias for 'get_abi_var LIBDIR'
get_abi_LIBDIR() { get_abi_var LIBDIR "$@"; }

# @FUNCTION: get_install_abis
# @DESCRIPTION:
# Return a list of the ABIs we want to install for with
# the last one in the list being the default.
get_install_abis() {
	local order=""

	if [[ -z ${MULTILIB_ABIS} ]] ; then
		echo "default"
		return 0
	fi

	if [[ ${EMULTILIB_PKG} == "true" ]] ; then
		for x in ${MULTILIB_ABIS} ; do
			if [[ ${x} != "${DEFAULT_ABI}" ]] ; then
				hasq ${x} ${ABI_DENY} || ordera="${ordera} ${x}"
			fi
		done
		hasq ${DEFAULT_ABI} ${ABI_DENY} || order="${ordera} ${DEFAULT_ABI}"

		if [[ -n ${ABI_ALLOW} ]] ; then
			local ordera=""
			for x in ${order} ; do
				if hasq ${x} ${ABI_ALLOW} ; then
					ordera="${ordera} ${x}"
				fi
			done
			order=${ordera}
		fi
	else
		order=${DEFAULT_ABI}
	fi

	if [[ -z ${order} ]] ; then
		die "The ABI list is empty.  Are you using a proper multilib profile?  Perhaps your USE flags or MULTILIB_ABIS are too restrictive for this package."
	fi

	echo ${order}
	return 0
}

# @FUNCTION: get_all_abis
# @DESCRIPTION: 
# Return a list of the ABIs supported by this profile.
# the last one in the list being the default.
get_all_abis() {
	local order=""

	if [[ -z ${MULTILIB_ABIS} ]] ; then
		echo "default"
		return 0
	fi

	for x in ${MULTILIB_ABIS}; do
		if [[ ${x} != ${DEFAULT_ABI} ]] ; then
			order="${order:+${order} }${x}"
		fi
	done
	order="${order:+${order} }${DEFAULT_ABI}"

	echo ${order}
	return 0
}

# @FUNCTION: get_all_libdirs
# @DESCRIPTION:
# Returns a list of all the libdirs used by this profile.  This includes
# those that might not be touched by the current ebuild and always includes
# "lib".
get_all_libdirs() {
	local libdirs="lib"
	local abi
	local dir

	for abi in ${MULTILIB_ABIS}; do
		[ "$(get_abi_LIBDIR ${abi})" != "lib" ] && libdirs="${libdirs} $(get_abi_LIBDIR ${abi})"
	done

	echo "${libdirs}"
}

# @FUNCTION: is_final_abi
# @DESCRIPTION:
# Return true if ${ABI} is the last ABI on our list (or if we're not
# using the new multilib configuration.  This can be used to determine
# if we're in the last (or only) run through src_{unpack,compile,install}
is_final_abi() {
	has_multilib_profile || return 0
	local ALL_ABIS=$(get_install_abis)
	local LAST_ABI=${ALL_ABIS/* /}
	[[ ${LAST_ABI} == ${ABI} ]]
}

# @FUNCTION: number_abis
# @DESCRIPTION:
# echo the number of ABIs we will be installing for
number_abis() {
	get_install_abis | wc -w
}

# @FUNCTION: get_ml_incdir
# @USAGE: [include_dir] [ABI]
# @DESCRIPTION:
# include dir defaults to /usr/include
# ABI defaults to ${ABI} or ${DEFAULT_ABI}
#
# If a multilib include dir is associated with the passed include dir, then
# we return it, otherwise, we just echo back the include dir.  This is
# neccessary when a built script greps header files rather than testing them
# via #include (like perl) to figure out features.
get_ml_incdir() {
	local dir=/usr/include

	if [[ $# -gt 0 ]]; then
		incdir=$1
		shift
	fi

	if [[ -z "${MULTILIB_ABIS}" ]]; then
		echo ${incdir}
		return 0
	fi

	local abi=${ABI-${DEFAULT_ABI}}
	if [[ $# -gt 0 ]]; then
		abi=$1
		shift
	fi

	if [[ -d "${dir}/gentoo-multilib/${abi}" ]]; then
		echo ${dir}/gentoo-multilib/${abi}
	else
		echo ${dir}
	fi
}

# @FUNCTION: prep_ml_includes
# @DESCRIPTION:
# Some includes (include/asm, glibc, etc) are ABI dependent.  In this case,
# We can install them in different locations for each ABI and create a common
# header which includes the right one based on CDEFINE_${ABI}.  If your
# package installs ABI-specific headers, just add 'prep_ml_includes' to the
# end of your src_install().  It takes a list of directories that include
# files are installed in (default is /usr/include if none are passed).
#
# Example:
#     src_install() {
#        ...
#        prep_ml_includes /usr/qt/3/include
#     }
prep_ml_includes() {
	if [[ $(number_abis) -gt 1 ]] ; then
		local dir
		local dirs
		local base

		if [[ $# -eq 0 ]] ; then
			dirs=/usr/include
		else
			dirs="$@"
		fi

		for dir in ${dirs} ; do
			base=${T}/gentoo-multilib/${dir}/gentoo-multilib
			mkdir -p "${base}"
			[[ -d ${base}/${ABI} ]] && rm -rf "${base}/${ABI}"
			mv "${D}/${dir}" "${base}/${ABI}"
		done

		if is_final_abi; then
			base=${T}/gentoo-multilib
			pushd "${base}"
			find . | tar -c -T - -f - | tar -x --no-same-owner -f - -C "${D}"
			popd

			# This 'set' stuff is required by mips profiles to properly pass
			# CDEFINE's (which have spaces) to sub-functions
			set --
			for dir in ${dirs} ; do
				set -- "$@" "${dir}"
				local abi
				for abi in $(get_install_abis); do
					set -- "$@" "$(get_abi_CDEFINE ${abi}):${dir}/gentoo-multilib/${abi}"
				done
				create_ml_includes "$@"
			done
		fi
	fi
}

# @FUNCTION: create_ml_includes
# @USAGE: <include_dir> <symbol_1>:<dir_1> [<symbol_2>:<dir_2>...]
# @DESCRIPTION:
# If you need more control than prep_ml_includes can offer (like linux-headers
# for the asm-* dirs, then use create_ml_includes.  The firs argument is the
# common dir.  The remaining args are of the form <symbol>:<dir> where
# <symbol> is what is put in the #ifdef for choosing that dir.
#
# Ideas for this code came from debian's sparc-linux headers package.
#
# Example:
#     create_ml_includes /usr/include/asm __sparc__:/usr/include/asm-sparc __sparc64__:/usr/include/asm-sparc64
#     create_ml_includes /usr/include/asm __i386__:/usr/include/asm-i386 __x86_64__:/usr/include/asm-x86_64
#
# Warning: Be careful with the ordering here. The default ABI has to be the
# last, because it is always defined (by GCC)
create_ml_includes() {
	local dest=$1
	shift
	local basedirs=$(create_ml_includes-listdirs "$@")

	create_ml_includes-makedestdirs ${dest} ${basedirs}

	local file
	for file in $(create_ml_includes-allfiles ${basedirs}) ; do
		#local name=$(echo ${file} | tr '[:lower:]' '[:upper:]' | sed 's:[^[:upper:]]:_:g')
		(
			echo "/* Autogenerated by create_ml_includes() in multilib.eclass */"

			local dir
			for dir in ${basedirs}; do
				if [[ -f ${D}/${dir}/${file} ]] ; then
					echo ""
					local sym=$(create_ml_includes-sym_for_dir ${dir} "$@")
					if [[ ${sym/=} != "${sym}" ]] ; then
						echo "#if ${sym}"
					elif [[ ${sym::1} == "!" ]] ; then
						echo "#ifndef ${sym:1}"
					else
						echo "#ifdef ${sym}"
					fi
					echo "# include <$(create_ml_includes-absolute ${dir}/${file})>"
					echo "#endif /* ${sym} */"
				fi
			done

			#echo "#endif /* __CREATE_ML_INCLUDES_STUB_${name}__ */"
		) > "${D}/${dest}/${file}"
	done
}

# Helper function for create_ml_includes
create_ml_includes-absolute() {
	local dst="$(create_ml_includes-tidy_path $1)"

	dst=(${dst//\// })

	local i
	for ((i=0; i<${#dst[*]}; i++)); do
		[ "${dst[i]}" == "include" ] && break
	done

	local strip_upto=$i

	for ((i=strip_upto+1; i<${#dst[*]}-1; i++)); do
		echo -n ${dst[i]}/
	done

	echo -n ${dst[i]}
}

# Helper function for create_ml_includes
create_ml_includes-tidy_path() {
	local removed=$1

	if [ -n "${removed}" ]; then
		# Remove multiple slashes
		while [ "${removed}" != "${removed/\/\//\/}" ]; do
			removed=${removed/\/\//\/}
		done

		# Remove . directories
		while [ "${removed}" != "${removed//\/.\//\/}" ]; do
			removed=${removed//\/.\//\/}
		done
		[ "${removed##*/}" = "." ] && removed=${removed%/*}

		# Removed .. directories
		while [ "${removed}" != "${removed//\/..\/}" ]; do
			local p1="${removed%%\/..\/*}"
			local p2="${removed#*\/..\/}"

			removed="${p1%\/*}/${p2}"
		done

		# Remove trailing ..
		[ "${removed##*/}" = ".." ] && removed=${removed%/*/*}

		# Remove trailing /
		[ "${removed##*/}" = "" ] && removed=${removed%/*}

		echo ${removed}
	fi
}

# Helper function for create_ml_includes
create_ml_includes-listdirs() {
	local dirs
	local data
	for data in "$@"; do
		dirs="${dirs} ${data/*:/}"
	done
	echo ${dirs:1}
}

# Helper function for create_ml_includes
create_ml_includes-makedestdirs() {
	local dest=$1
	shift
	local basedirs=$@

	dodir ${dest}

	local basedir
	for basedir in ${basedirs}; do
		local dir
		for dir in $(find "${D}"/${basedir} -type d); do
			dodir ${dest}/${dir/${D}\/${basedir}/}
		done
	done
}

# Helper function for create_ml_includes
create_ml_includes-allfiles() {
	local basedir file
	for basedir in "$@" ; do
		for file in $(find "${D}"/${basedir} -type f); do
			echo ${file/${D}\/${basedir}\//}
		done
	done | sort | uniq
}

# Helper function for create_ml_includes
create_ml_includes-sym_for_dir() {
	local dir=$1
	shift
	local data
	for data in "$@"; do
		if [[ ${data} == *:${dir} ]] ; then
			echo ${data/:*/}
			return 0
		fi
	done
	echo "Shouldn't be here -- create_ml_includes-sym_for_dir $1 $@"
	# exit because we'll likely be called from a subshell
	exit 1
}

# @FUNCTION: get_libname
# @USAGE: [version]
# @DESCRIPTION:
# Returns libname with proper suffix {.so,.dylib,.dll,etc} and optionally
# supplied version for the current platform identified by CHOST.
#
# Example:
#     get_libname ${PV}
#     Returns: .so.${PV} (ELF) || .${PV}.dylib (MACH) || ...
get_libname() {
	local libname
	local ver=$1
	case ${CHOST} in
		*-cygwin|mingw*|*-mingw*) libname="dll";;
		*-darwin*)                libname="dylib";;
		*-aix*)                   libname="a";;
		*-mint*)                  libname="irrelevant";;
		*)                        libname="so";;
	esac

	if [[ -z $* ]] ; then
		echo ".${libname}"
	else
		for ver in "$@" ; do
			case ${CHOST} in
				*-darwin*) echo ".${ver}.${libname}";;
				*-aix*)    echo ".${libname}";;
				*-mint*)   echo ".${libname}";;
				*)         echo ".${libname}.${ver}";;
			esac
		done
	fi
}

# This is for the toolchain to setup profile variables when pulling in
# a crosscompiler (and thus they aren't set in the profile)
multilib_env() {
	local CTARGET=${1:-${CTARGET}}

	case ${CTARGET} in
		x86_64*)
			export CFLAGS_x86=${CFLAGS_x86--m32}
			export CHOST_x86=${CTARGET/x86_64/i686}
			export CTARGET_x86=${CHOST_x86}
			export CDEFINE_x86="__i386__"
			export LIBDIR_x86="lib"

			export CFLAGS_amd64=${CFLAGS_amd64--m64}
			export CHOST_amd64=${CTARGET}
			export CTARGET_amd64=${CHOST_amd64}
			export CDEFINE_amd64="__x86_64__"
			export LIBDIR_amd64="lib64"

			export MULTILIB_ABIS="amd64 x86"
			export DEFAULT_ABI="amd64"
		;;
		mips64*)
			export CFLAGS_o32=${CFLAGS_o32--mabi=32}
			export CHOST_o32=${CTARGET/mips64/mips}
			export CTARGET_o32=${CHOST_o32}
			export CDEFINE_o32="_MIPS_SIM == _ABIO32"
			export LIBDIR_o32="lib"

			export CFLAGS_n32=${CFLAGS_n32--mabi=n32}
			export CHOST_n32=${CTARGET}
			export CTARGET_n32=${CHOST_n32}
			export CDEFINE_n32="_MIPS_SIM == _ABIN32"
			export LIBDIR_n32="lib32"

			export CFLAGS_n64=${CFLAGS_n64--mabi=64}
			export CHOST_n64=${CTARGET}
			export CTARGET_n64=${CHOST_n64}
			export CDEFINE_n64="_MIPS_SIM == _ABI64"
			export LIBDIR_n64="lib64"

			export MULTILIB_ABIS="n64 n32 o32"
			export DEFAULT_ABI="n32"
		;;
		powerpc64*)
			export CFLAGS_ppc=${CFLAGS_ppc--m32}
			export CHOST_ppc=${CTARGET/powerpc64/powerpc}
			export CTARGET_ppc=${CHOST_ppc}
			export CDEFINE_ppc="!__powerpc64__"
			export LIBDIR_ppc="lib"

			export CFLAGS_ppc64=${CFLAGS_ppc64--m64}
			export CHOST_ppc64=${CTARGET}
			export CTARGET_ppc64=${CHOST_ppc64}
			export CDEFINE_ppc64="__powerpc64__"
			export LIBDIR_ppc64="lib64"

			export MULTILIB_ABIS="ppc64 ppc"
			export DEFAULT_ABI="ppc64"
		;;
		s390x*)
			export CFLAGS_s390=${CFLAGS_s390--m31} # the 31 is not a typo
			export CHOST_s390=${CTARGET/s390x/s390}
			export CTARGET_s390=${CHOST_s390}
			export CDEFINE_s390="!__s390x__"
			export LIBDIR_s390="lib"

			export CFLAGS_s390x=${CFLAGS_s390x--m64}
			export CHOST_s390x=${CTARGET}
			export CTARGET_s390x=${CHOST_s390x}
			export CDEFINE_s390x="__s390x__"
			export LIBDIR_s390x="lib64"

			export MULTILIB_ABIS="s390x s390"
			export DEFAULT_ABI="s390x"
		;;
		sparc*)
			export CFLAGS_sparc32=${CFLAGS_sparc32}
			export CHOST_sparc32=${CTARGET/sparc64/sparc}
			export CTARGET_sparc32=${CHOST_sparc32}
			export CDEFINE_sparc32="!__arch64__"
			export LIBDIR_sparc32="lib"

			export CFLAGS_sparc64=${CFLAGS_sparc64--m64}
			export CHOST_sparc64=${CTARGET}
			export CTARGET_sparc64=${CHOST_sparc64}
			export CDEFINE_sparc64="__arch64__"
			export LIBDIR_sparc64="lib64"

			export MULTILIB_ABIS="${MULTILIB_ABIS-sparc64 sparc32}"
			export DEFAULT_ABI="${DEFAULT_ABI-sparc64}"
		;;
		*)
			export MULTILIB_ABIS="default"
			export DEFAULT_ABI="default"
		;;
	esac
}

# @FUNCTION: multilib_toolchain_setup
# @DESCRIPTION:
# Hide multilib details here for packages which are forced to be compiled for a
# specific ABI when run on another ABI (like x86-specific packages on amd64)
multilib_toolchain_setup() {
	local v vv

	export ABI=$1

	# We want to avoid the behind-the-back magic of gcc-config as it
	# screws up ccache and distcc.  See #196243 for more info.
	if [[ ${ABI} != ${DEFAULT_ABI} ]] ; then
		if [[ ${DEFAULT_ABI_SAVED} != "true" ]] ; then
			for v in CHOST CBUILD AS CC CXX LD ; do
				export __abi_saved_${v}="${!v}"
			done
			export DEFAULT_ABI_SAVED="true"
		fi

		# Set the CHOST native first so that we pick up the native
		# toolchain and not a cross-compiler by accident #202811.
		export CHOST=$(get_abi_CHOST ${DEFAULT_ABI})
		export AS="$(tc-getAS) $(get_abi_ASFLAGS)"
		export CC="$(tc-getCC) $(get_abi_CFLAGS)"
		export CXX="$(tc-getCXX) $(get_abi_CFLAGS)"
		export LD="$(tc-getLD) $(get_abi_LDFLAGS)"
		export CHOST=$(get_abi_CHOST $1)
		export CBUILD=$(get_abi_CHOST $1)

	elif [[ ${DEFAULT_ABI_SAVED} == "true" ]] ; then
		for v in CHOST CBUILD AS CC CXX LD ; do
			vv="__abi_saved_${v}"
			export ${v}=${!vv}
		done
	fi
}

# @FUNCTION prep_ml_binaries
# @DESCRIPTION: Use wrapper to support non-default binaries 
prep_ml_binaries() {
	if [[ -n $EMULTILIB_PKG ]] ; then
		for binary in "$@"; do
			mv ${D}/${binary} ${D}/${binary}-${ABI}
			echo mv ${D}/${binary} ${D}/${binary}-${ABI}
			if is_final_abi; then
				ln -s /usr/bin/abi-wrapper ${D}/${binary}
				echo ln -s /usr/bin/abi-wrapper ${D}/${binary}
			fi
		done
	fi		
}

# @FUNCTION get_ml_usedeps
# @RETURN: USE dependencies
# @DESCRIPTION: Function to generate USE dependencies from get_install_abis()
get_ml_usedeps() {
	local order=""

	if [[ -z ${MULTILIB_ABIS} ]] ; then
		return 0
	fi

	for x in ${MULTILIB_ABIS} ; do
		if [[ ${x} != "${DEFAULT_ABI}" ]] ; then
			hasq ${x} ${ABI_DENY} || ordera="${ordera} ${x}"
		fi
	done
	hasq ${DEFAULT_ABI} ${ABI_DENY} || order="${ordera} ${DEFAULT_ABI}"
		if [[ -n ${ABI_ALLOW} ]] ; then
		local ordera=""
		for x in ${order} ; do
			if hasq ${x} ${ABI_ALLOW} ; then
				ordera="${ordera} ${x}"
			fi
		done
		order=${ordera}
	fi

	if [[ -z ${order} ]] ; then
		die "The ABI list is empty.  Are you using a proper multilib profile?  Perhaps your USE flags or MULTILIB_ABIS are too restrictive for this package."
	fi

	local ordera=""
	for x in ${order}; do
		if use multilib_${x}; then
			[[ -n ${ordera} ]] && ordera="${ordera},"
			ordera="${ordera}multilib_${x}"
		fi
	done

	[[ "$(echo ${ordera})" == "multilib_${DEFAULT_ABI}" ]] || [[ -z $ordera ]] && ordera=${DEFAULT_ABI}
	order=${ordera}

	echo ${order}
	return 0
}

# @FUNCTION get_ml_useflags
# @RETURN: USE flags
# @DESCRIPTION: Function to generate IUSE flags from get_all_abis()
get_ml_useflags() {
	local order=""

	if [[ -z ${MULTILIB_ABIS} ]] ; then
		return 0
	fi

	for x in ${MULTILIB_ABIS} ; do
		if [[ ${x} != "${DEFAULT_ABI}" ]] ; then
			hasq ${x} ${ABI_DENY} || ordera="${ordera} ${x}"
		fi
	done
	hasq ${DEFAULT_ABI} ${ABI_DENY} || order="${ordera} ${DEFAULT_ABI}"
		if [[ -n ${ABI_ALLOW} ]] ; then
		local ordera=""
		for x in ${order} ; do
			if hasq ${x} ${ABI_ALLOW} ; then
				ordera="${ordera} ${x}"
			fi
		done
		order=${ordera}
	fi

	if [[ -z ${order} ]] ; then
		die "The ABI list is empty.  Are you using a proper multilib profile?  Perhaps your USE flags or MULTILIB_ABIS are too restrictive for this package."
	fi

	local ordera=""
	for x in ${order}; do
		ordera="${ordera} multilib_${x}"
	done
	[[ "$(echo ${ordera})" == "multilib_${DEFAULT_ABI}" ]] && ordera=""
	order=${ordera}

	echo ${order}
	return 0
}
