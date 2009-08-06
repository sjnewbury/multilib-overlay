# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# @ECLASS: multilib-native.eclass
# @MAINTAINER:
# Steven Newbury <steve@snewbury.org.uk>
# @BLURB: Provide infrastructure for native multilib ebuilds

inherit base multilib

IUSE="${IUSE} $(get_ml_useflags)"

DEPEND="${DEPEND} sys-apps/abi-wrapper"
RDEPEND="${RDEPEND} sys-apps/abi-wrapper"

case "${EAPI:-0}" in
	2)
		EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare src_configure src_compile src_install pkg_preinst pkg_postinst pkg_postrm
		;;
	*)
		EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_preinst pkg_postinst pkg_postrm
		;;
esac

# -----------------------------------------------------------------------------

# @VARIABLE: EMULTILIB_SAVE_VARS
# @DESCRIPTION: Environment variables to save
# EMULTILIB_SAVE_VARS="${EMULTILIB_SAVE_VARS}
#		AS CC CXX FC LD ASFLAGS CFLAGS CXXFLAGS FCFLAGS FFLAGS LDFLAGS
#		CHOST CBUILD CDEFINE LIBDIR S CCACHE_DIR myconf PYTHON PERLBIN
#		QMAKE QMAKESPEC QTBINDIR  QTBASEDIR QTLIBDIR QTPCDIR
#		QTPLUGINDIR CMAKE_BUILD_DIR mycmakeargs KDE_S ECONF_SOURCE
#		MY_LIBDIR MOZLIBDIR SDKDIR G2CONF PKG_CONFIG_PATH"
EMULTILIB_SAVE_VARS="${EMULTILIB_SAVE_VARS}
		AS CC CXX FC LD ASFLAGS CFLAGS CXXFLAGS FCFLAGS FFLAGS LDFLAGS
		CHOST CBUILD CDEFINE LIBDIR S CCACHE_DIR myconf PYTHON PERLBIN
		QMAKE QMAKESPEC QTBINDIR  QTBASEDIR QTLIBDIR QTPCDIR
		QTPLUGINDIR CMAKE_BUILD_DIR mycmakeargs KDE_S ECONF_SOURCE
		MY_LIBDIR MOZLIBDIR SDKDIR G2CONF PKG_CONFIG_PATH"

# @VARIABLE: EMULTILIB_ABILIST
# @DESCRIPTION: Holds the list of ABIs to build
# EMULTILIB_SOURCE_TOP_DIRNAME=""
EMULTILIB_ABILIST=""

# @VARIABLE: EMULTILIB_SOURCE_TOP_DIRNAME
# @DESCRIPTION: Holds the name of the top-level source directory
# EMULTILIB_SOURCE_TOP_DIRNAME=""
EMULTILIB_SOURCE_TOP_DIRNAME=""

# @VARIABLE: EMULTILIB_SOURCE_TOPDIR
# @DESCRIPTION:
# This may be used in multilib-ised ebuilds choosing to make use of
# external build directories for installing files from the source tree
# EMULTILIB_SOURCE_TOPDIR=""
EMULTILIB_SOURCE_TOPDIR=""

# @VARIABLE: EMULTILIB_RELATIVE_BUILD_DIR
# @DESCRIPTION:
# EMULTILIB_RELATIVE_BUILD_DIR=""
EMULTILIB_RELATIVE_BUILD_DIR=""

# @VARIABLE: EMULTILIB_INHERITED
# @DESCRIPTION:
# Holds a list of inherited eclasses
# is this var is onlky used in multilib-native_check_inherited_funcs
EMULTILIB_INHERITED=""

# -----------------------------------------------------------------------------

# @FUNCTION: multilib-native_pkg_setup
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the pkg_setup phase
multilib-native_pkg_setup() {
	multilib-native_src_generic pkg_setup
}

# @FUNCTION: multilib-native_src_unpack
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the src_unpack phase
multilib-native_src_unpack() {
	multilib-native_src_generic src_unpack
}

# @FUNCTION: multilib-native_src_prepare
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the src_prepare phase
multilib-native_src_prepare() {
	multilib-native_src_generic src_prepare
}

# @FUNCTION: multilib-native_src_configure
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the src_configure phase
multilib-native_src_configure() {
	multilib-native_src_generic src_configure
}

# @FUNCTION: multilib-native_src_compile
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the src_compile phase
multilib-native_src_compile() {
	multilib-native_src_generic src_compile
}

# @FUNCTION: multilib-native_src_install
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the src_install phase
multilib-native_src_install() {
	multilib-native_src_generic src_install
}

# @FUNCTION: multilib-native_pkg_preinst
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the pkg_preinst phase
multilib-native_pkg_preinst() {
	multilib-native_src_generic pkg_preinst
}

# @FUNCTION: multilib-native_pkg_postinst
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the pkg_postinst phase
multilib-native_pkg_postinst() {
	multilib-native_src_generic pkg_postinst
}

# @FUNCTION: multilib-native_pkg_postrm
# @USAGE:
# @DESCRIPTION: This is a multilib wrapper for the pkg_postrm phase
multilib-native_pkg_postrm() {
	multilib-native_src_generic pkg_postrm
}

# @FUNCTION: multilib_debug
# @USAGE: <name_of_variable> <content_of_variable>
# @DESCRIPTION: print debug output if MULTILIB_DEBUG is set
multilib_debug() {
	[[ -n ${MULTILIB_DEBUG} ]] && einfo "MULTILIB_DEBUG: ${1}=\"${2}\""
}

# -----------------------------------------------------------------------------

# Internal function
# @FUNCTION: multilib-native_src_generic
# @USAGE: <phase>
# @DESCRIPTION: Run each phase for each "install ABI"
multilib-native_src_generic() {
# Recurse this function for each ABI


	if [[ -z ${OABI} ]] ; then
		if has_multilib_profile ; then
			if [[ -z ${EMULTILIB_ABILIST} ]]; then
					local _ABI=""
				EMULTILIB_ABILIST="$(get_all_abis)"
				for _ABI in ${EMULTILIB_ABILIST}; do
					if ! use multilib_${_ABI}; then
						EMULTILIB_ABILIST="${EMULTILIB_ABILIST/$_ABI}"
						ewarn "ABI: ${_ABI} available in profile but USE=multilib_${_ABI} not set, disabling ..."
					fi
				done
				if [[ "$(echo ${EMULTILIB_ABILIST})" == "${DEFAULT_ABI}" ]] || \
						[[ ${EMULTILIB_ABILIST} == "" ]]; then
					unset EMULTILIB_PKG
					EMULTILIB_ABILIST=default
					einfo "No non-default multilib USE flags set; emerging for default ABI"
				else
					EMULTILIB_PKG=true
				
				fi
				multilib_debug EMULTILIB_ABILIST $EMULTILIB_ABILIST
				multilib_debug EMULTILIB_PKG $EMULTILIB_PKG
			fi 
			einfo "${1/src_/} multilib ${PN} for ABIs: ${EMULTILIB_ABILIST}"
		elif is_crosscompile || tc-is-cross-compiler ; then
			EMULTILIB_ABILIST=${DEFAULT_ABI}
		fi
		if [[ -n ${EMULTILIB_PKG} ]] ; then
			OABI=${ABI}
			for ABI in ${EMULTILIB_ABILIST} ; do
				export ABI
				multilib-native_src_generic ${1}
			done
			ABI=${OABI}
			unset OABI
			return 0
		fi
	fi
	multilib_debug EMULTILIB_PKG $EMULTILIB_PKG

# If this is the first time through, initialise the source path variables early
# and unconditionally, whether building for multilib or not.  (This allows
# multilib-native ebuilds to always make use of them.)  Then save the initial
# environment.
#
# Sometimes, packages assume a directory structure ABOVE "S". ("S" is set to a
# subdirectory of the tree they unpack into ${WORKDIR}.)  We need to deal with
# this by finding the top-level of the source tree and keeping track of ${S}
# relative to it.

	if [[ -z ${EMULTILIB_INITIALISED[$(multilib-native_abi_to_index_key "INIT")]} ]]; then
		[[ -n ${MULTILIB_DEBUG} ]] && \
			einfo "MULTILIB_DEBUG: Determining EMULTILIB_SOURCE_TOPDIR from S and WORKDIR"
		EMULTILIB_RELATIVE_BUILD_DIR="${S#*${WORKDIR}\/}"
		EMULTILIB_SOURCE_TOP_DIRNAME="${EMULTILIB_RELATIVE_BUILD_DIR%%/*}"
		EMULTILIB_SOURCE_TOPDIR="${WORKDIR}/${EMULTILIB_SOURCE_TOP_DIRNAME}"
		[[ -n ${MULTILIB_DEBUG} ]] && \
			einfo "MULTILIB_DEBUG: EMULTILIB_SOURCE_TOPDIR=\"${EMULTILIB_SOURCE_TOPDIR}\""
		multilib-native_save_abi_env "INIT"
		EMULTILIB_INITIALISED[$(multilib-native_abi_to_index_key "INIT")]=true
	fi

	if [[ -n ${EMULTILIB_PKG} ]] && has_multilib_profile; then
		multilib-native_src_generic_sub ${1}

# Save the environment for this ABI
		multilib-native_save_abi_env "${ABI}"

# If this is the default ABI and we have a build tree, update the INIT
# environment
		[[ "${ABI}" == "${DEFAULT_ABI}" ]] && \
				[[ -d "${WORKDIR}/${PN}_build_${ABI}" ]] && \
			multilib-native_save_abi_env "INIT"

# This assures the environment is correctly configured for non-multilib phases
# such as a src_unpack override in ebuilds.
		multilib-native_restore_abi_env "INIT"
	else
		ml-native_${1}
	fi
}



# Internal function
# @FUNCTION: multilib-native_src_generic_sub
# @USAGE: <phase>
# @DESCRIPTION: This function gets used for each ABI pass of each phase
multilib-native_src_generic_sub() {
# We support two kinds of build: By default we copy/move the source dir for
# each ABI. Where supported with the underlying package, we can just create an
# external build dir.  This requires a modified ebuild which makes use of the
# EMULTILIB_SOURCE_TOPDIR variable (which points the the top of the original
# source dir) to install doc files etc.  This latter behaviour is enabled with
# MULTILIB_EXT_SOURCE_BUILD.  For CMake based packages default is reversed and
# the CMAKE_IN_SOURCE_BUILD environment variable is used to specify the former
# behaviour.
#

	if [[ -z ${EMULTILIB_INITIALISED[$(multilib-native_abi_to_index_key ${ABI})]} ]]; then
		multilib-native_restore_abi_env "INIT"
		multilib-native_setup_abi_env "${ABI}"
	else
		multilib-native_restore_abi_env "${ABI}"
	fi

# If this is the unpack or prepare phase we only need to run for the
# DEFAULT_ABI when we are building out of the source tree since it is shared
# between each ABI.
#
# After the unpack phase, some eclasses change into the unpacked source tree
# (gnome2.eclass for example), we need to change back to the WORKDIR otherwise
# the next ABI tree will get unpacked into a subdir of previous tree.


	case ${1/*_} in
		setup)
		;;
		unpack)
			[[ -d "${WORKDIR}" ]] && cd "${WORKDIR}"
			if multilib-native_is_EBD && \
					[[ ! "${ABI}" == "${DEFAULT_ABI}" ]]; then
				einfo "Skipping ${1} for ${ABI}"
				return
			fi
		;;
		prepare)

			[[ ! -d "${WORKDIR}/${PN}_build_${ABI}" ]] && multilib-native_setup_build_directory
			[[ -d "${S}" ]] && cd "${S}"
			if multilib-native_is_EBD && [[ ! "${ABI}" == "${DEFAULT_ABI}" ]]; then
					einfo "Skipping ${1} for ${ABI}"
					return
			fi
		;;
		compile)
			[[ ! -d "${WORKDIR}/${PN}_build_${ABI}" ]] && multilib-native_setup_build_directory
			[[ -d "${S}" ]] && cd "${S}"
		;;
		install)
			[[ ! -d "${WORKDIR}/${PN}_build_${ABI}" ]] && multilib-native_setup_build_directory
			[[ -d "${S}" ]] && cd "${S}"
		;;
		*)
			[[ -d "${S}" ]] && cd "${S}"
		;;
	esac

# Call the "real" phase function
	ml-native_${1}

# If we've just unpacked the source, move it into place.
	if [[ ! "${1/unpack}" == "${1}" ]] && \
			([[ -d "${EMULTILIB_SOURCE_TOPDIR}" ]] && \
			[[ ! -d "${WORKDIR}/${PN}_build_${ABI}" ]]) && !(multilib-native_is_EBD); then
		einfo "Moving source tree from ${EMULTILIB_SOURCE_TOPDIR} to ${WORKDIR}/${PN}_build_${ABI}"
		mv "${EMULTILIB_SOURCE_TOPDIR}" "${WORKDIR}/${PN}_build_${ABI}"
		S="${WORKDIR}/${PN}_build_${ABI}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		[[ -n ${KDE_S} ]] && KDE_S="${S}"
	fi
}

multilib-native_setup_build_directory() {
	if multilib-native_is_EBD; then
		einfo "Preparing external build directory for ABI: ${ABI} ..."
		einfo "Creating build directory: ${WORKDIR}/${PN}_build_${ABI}"
		mkdir -p "${WORKDIR}/${PN}_build_${ABI}"
		if [[ -n "${CMAKE_BUILD_TYPE}" ]];then
			CMAKE_BUILD_DIR="${WORKDIR}/${PN}_build_${ABI}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"	
		else
			ECONF_SOURCE="${EMULTILIB_SOURCE_TOPDIR}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		fi
	else
		if [[ -d ${EMULTILIB_SOURCE_TOPDIR} ]]; then
			einfo "Copying source tree from ${EMULTILIB_SOURCE_TOPDIR} to ${WORKDIR}/${PN}_build_${ABI}"
			cp -al "${EMULTILIB_SOURCE_TOPDIR}" "${WORKDIR}/${PN}_build_${ABI}"
		fi
	fi
	if ([[ -n "${CMAKE_BUILD_TYPE}" ]] && \
			[[ -n "${CMAKE_IN_SOURCE_BUILD}" ]]) || \
			[[ -z "${CMAKE_BUILD_TYPE}" ]];then
		S="${WORKDIR}/${PN}_build_${ABI}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
	fi
}

# Internal function
# @FUNCTION: multilib-native_is_EBD
# @USAGE:
# @DESCRIPTION: Returns true if we're building with an "External Build Directory"
multilib-native_is_EBD() {
!([[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] || \
				([[ -z "${CMAKE_BUILD_TYPE}" ]] && \
				[[ -z "${MULTILIB_EXT_SOURCE_BUILD}" ]]))
}

# Internal function
# @FUNCTION: multilib-native_setup_abi_env
# @USAGE: <ABI>
# @DESCRIPTION: Setup initial environment for ABI, flags, workarounds etc.
multilib-native_setup_abi_env() {
	local pyver="" libsuffix=""
	[[ -z $(multilib-native_abi_to_index_key ${1}) ]] && \
						die "Unknown ABI (${1})" 

# Set the CHOST native first so that we pick up the native #202811.
	export CHOST=$(get_abi_CHOST ${DEFAULT_ABI})
	export AS="$(tc-getAS)"
	export CC="$(tc-getCC)"
	export CXX="$(tc-getCXX)"
	export FC="$(tc-getFC)"
	export LD="$(tc-getLD) $(get_abi_LDFLAGS)"
	export ASFLAGS="${ASFLAGS} $(get_abi_ASFLAGS)"
	export CFLAGS="${CFLAGS} $(get_abi_CFLAGS)"
	export CXXFLAGS="${CXXFLAGS} $(get_abi_CFLAGS)"
	export FCFLAGS="${FCFLAGS} ${CFLAGS}"
	export FFLAGS="${FFLAGS} ${CFLAGS}"
	export CHOST=$(get_abi_CHOST $1)
	export CBUILD=$(get_abi_CHOST $1)
	export CDEFINE="${CDEFINE} $(get_abi_CDEFINE $1)"
	export LIBDIR=$(get_abi_LIBDIR $1)
	export LDFLAGS="${LDFLAGS} -L/${LIBDIR} -L/usr/${LIBDIR} $(get_abi_CFLAGS)"

	if [[ -z PKG_CONFIG_PATH ]]; then
		export PKG_CONFIG_PATH="/usr/$(get_libdir)/pkgconfig"
	else
		PKG_CONFIG_PATH="${PKG_CONFIG_PATH/lib*\//$(get_libdir)/}:/usr/$(get_libdir)/pkgconfig"
	fi

# If we aren't building for the DEFAULT ABI we may need to use some ABI
# specific programs during the build.  The python binary is sometimes used to
# find the python install dir but there may be more than one version installed.
# Use the system default python to find the ABI specific version.
	if ! [[ "${ABI}" == "${DEFAULT_ABI}" ]]; then
		pyver=$(python --version 2>&1)
		pyver=${pyver/Python /python}
		pyver=${pyver%.*}
		PYTHON="/usr/bin/${pyver}-${ABI}"
		PERLBIN="/usr/bin/perl-${ABI}"
	fi

# ccache is ABI dependent
	if [[ -z ${CCACHE_DIR} ]] ; then 
		CCACHE_DIR="/var/tmp/ccache-${1}"
	else
		CCACHE_DIR="${CCACHE_DIR}-${1}"
	fi

	export PYTHON PERLBIN QMAKESPEC
	EMULTILIB_INITIALISED[$(multilib-native_abi_to_index_key ${1})]=true
}

# Internal function
# @FUNCTION: multilib-native_abi_to_index_key
# @USAGE: <ABI>
# @RETURN: <index key>
# @DESCRIPTION: Return an array index key for a given ABI
multilib-native_abi_to_index_key() {
# Until we can count on bash version > 4, we can't use associative arrays.
	local index=0 element=""
	if [[ -z "${EMULTILIB_ARRAY_INDEX}" ]]; then
		local EMULTILIB_ABILIST=""
		EMULTILIB_ABILIST=$(get_install_abis)
		EMULTILIB_ARRAY_INDEX=(INIT ${EMULTILIB_ABILIST})
	fi
	for element in ${EMULTILIB_ARRAY_INDEX[@]}; do
		[[ "${element}" == "${1}" ]] && echo "${index}"
		let index++
	done		
}

# Internal function
# @FUNCTION: multilib-native_save_abi_env
# @USAGE: <ABI>
# @DESCRIPTION: Save environment for ABI
multilib-native_save_abi_env() {
	[[ -n ${MULTILIB_DEBUG} ]] && \
		einfo "MULTILIB_DEBUG: Saving Environment:" "${1}"
	local _var _array
	for _var in ${EMULTILIB_SAVE_VARS}; do
		_array="EMULTILIB_${_var}"
		declare -p ${_var} &>/dev/null || continue
		multilib_debug ${_array}[$(multilib-native_abi_to_index_key ${1})] "${!_var}"
		eval "${_array}[$(multilib-native_abi_to_index_key ${1})]"=\"${!_var}\"
	done
}

# Internal function
# @FUNCTION: multilib-native_restore_abi_env
# @USAGE: <ABI>
# @DESCRIPTION: Restore environment for ABI
multilib-native_restore_abi_env() {
	[[ -n ${MULTILIB_DEBUG} ]] && \
		einfo "MULTILIB_DEBUG: Restoring Environment:" "${1}"
	local _var _array
	for _var in ${EMULTILIB_SAVE_VARS}; do
		_array="EMULTILIB_${_var}[$(multilib-native_abi_to_index_key ${1})]"
		if !(declare -p EMULTILIB_${_var} &>/dev/null) || \
						[[ -z ${!_array} ]]; then
			if (declare -p ${_var} &>/dev/null); then
				[[ -n ${MULTILIB_DEBUG} ]] && \
					einfo "MULTILIB_DEBUG: unsetting ${_var}"
				unset ${_var}
			fi
			continue
		fi
		multilib_debug "${_var}" "${!_array}"
		export ${_var}="${!_array}"
	done
}

# Internal function
# @FUNCTION multilib-native_check_inherited_funcs
# @USAGE: <phase>
# @DESCRIPTION: Checks all inherited eclasses for requested phase function
multilib-native_check_inherited_funcs() {
# Check all eclasses for given function, in order of inheritance.
# If none provides it, the var stays empty. If more have it, the last one wins.
# Ignore the ones we inherit ourselves, base doesn't matter, as we default on
# it.
	local declared_func=""
	if [[ -z ${EMULTILIB_INHERITED} ]]; then
		if [[ -f "${T}"/eclass-debug.log ]]; then
			EMULTILIB_INHERITED="$(grep EXPORT_FUNCTIONS "${T}"/eclass-debug.log | cut -d ' ' -f 4 | cut -d '_' -f 1)"
		else
			ewarn "You are using a package manager that does not provide "${T}"/eclass-debug.log."
			ewarn "Join #gentoo-multilib-overlay on freenode to help finding another way for you."
			ewarn "Falling back to old behaviour ..."
			EMULTILIB_INHERITED="${INHERITED}"
		fi
		EMULTILIB_INHERITED="${EMULTILIB_INHERITED//base/}"
		EMULTILIB_INHERITED="${EMULTILIB_INHERITED//multilib-native/}"
	fi

	multilib_debug EMULTILIB_INHERITED ${EMULTILIB_INHERITED}

	for func in ${EMULTILIB_INHERITED}; do
		if [[ -n $(declare -f ${func}_${1}) ]]; then
			multilib_debug declared_func "${declared_func}"
			declared_func="${func}_${1}"
		fi
	done

# Now if $declared_func is still empty, none of the inherited eclasses provides
# it, so default on base.eclass. Do nothing for pkg_post*
	if [[ -z "${declared_func}" ]]; then
		if [[ "${1/_*}" != "src" ]]; then
			declared_func="return"
		else
			declared_func="base_${1}"
		fi
	fi

	einfo "Using ${declared_func} for ABI ${ABI} ..."
	${declared_func}
}

# @FUNCTION: ml-native_src_prepare
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom src_configure.
ml-native_src_prepare() {
	multilib-native_check_inherited_funcs src_prepare
}

# @FUNCTION: ml-native_src_configure
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom src_configure.
ml-native_src_configure() {
	multilib-native_check_inherited_funcs src_configure
}

# @FUNCTION: ml-native_src_compile
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom src_compile.
ml-native_src_compile() {
	multilib-native_check_inherited_funcs src_compile
}

# @FUNCTION: ml-native_src_install
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom src_install
ml-native_src_install() {
	multilib-native_check_inherited_funcs src_install
}

# @FUNCTION: ml-native_pkg_setup
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom pkg_setup
ml-native_pkg_setup() {
	multilib-native_check_inherited_funcs pkg_setup
}

# @FUNCTION: ml-native_src_unpack
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom src_unpack
ml-native_src_unpack() {
	multilib-native_check_inherited_funcs src_unpack
}


# @FUNCTION: ml-native_pkg_preinst
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom pkg_preinst
ml-native_pkg_preinst() {
	multilib-native_check_inherited_funcs pkg_preinst
}


# @FUNCTION: ml-native_pkg_postinst
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom pkg_postinst
ml-native_pkg_postinst() {
	multilib-native_check_inherited_funcs pkg_postinst
}


# @FUNCTION: ml-native_pkg_postrm
# @USAGE:
# @DESCRIPTION: Override this function if you want a custom pkg_postrm
ml-native_pkg_postrm() {
	multilib-native_check_inherited_funcs pkg_postrm
}

# @FUNCTION: _check_build_dir
# @USAGE:
# @DESCRIPTION:
# This function overrides the function of the same name
# in cmake-utils.eclass.  We handle the build dir ourselves. 
# Determine using IN or OUT source build
_check_build_dir() {
	# @ECLASS-VARIABLE: CMAKE_USE_DIR
	# @DESCRIPTION:
	# Sets the directory where we are working with cmake.
	# For example when application uses autotools and only one
	# plugin needs to be done by cmake. By default it uses ${S}.
	: ${CMAKE_USE_DIR:=${S}}

# in/out source build
	echo ">>> Working in BUILD_DIR: \"$CMAKE_BUILD_DIR\""
}
