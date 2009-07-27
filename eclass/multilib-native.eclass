# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# @ECLASS: multilib-native.eclass
# @MAINTAINER:
# Steven Newbury <steve@snewbury.org.uk>
# @BLURB: Provide infrastructure for native multilib ebuilds

IUSE="${IUSE} lib32"

DEPEND="${DEPEND} sys-apps/abi-wrapper"
RDEPEND="${RDEPEND} sys-apps/abi-wrapper"

if use lib32; then
	EMULTILIB_PKG="true"
fi

inherit base multilib

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
#		QMAKE QMAKESPEC QTBINDIR CMAKE_BUILD_DIR mycmakeargs KDE_S
#		ECONF_SOURCE MY_LIBDIR MOZLIBDIR SDKDIR"
EMULTILIB_SAVE_VARS="${EMULTILIB_SAVE_VARS}
		AS CC CXX FC LD ASFLAGS CFLAGS CXXFLAGS FCFLAGS FFLAGS LDFLAGS
		CHOST CBUILD CDEFINE LIBDIR S CCACHE_DIR myconf PYTHON PERLBIN
		QMAKE QMAKESPEC QTBINDIR CMAKE_BUILD_DIR mycmakeargs KDE_S
		ECONF_SOURCE MY_LIBDIR MOZLIBDIR SDKDIR"

# @VARIABLE: EMULTILIB_SOURCE_TOP_DIRNAME
# @DESCRIPTION: On initialisation of multilib environment this gets incremented by 1
# EMULTILIB_INITIALISED=""
EMULTILIB_INITIALISED=""

# @VARIABLE: EMULTILIB_SOURCE_TOP_DIRNAME
# @DESCRIPTION:
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
	multilib-native_src_unpack_internal
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
# @FUNCTION: multilib-native_abi_to_index_key
# @USAGE: <ABI>
# @RETURN: <index key>
multilib-native_abi_to_index_key() {
	# Until we can count on bash version > 4, we can't use associative
	# arrays.
	local index=0 element=""
	if [[ -z "${EMULTILIB_ARRAY_INDEX}" ]]; then
		local abilist=""
		abilist=$(get_install_abis)
		EMULTILIB_ARRAY_INDEX=(INIT ${abilist})
	fi
	for element in ${EMULTILIB_ARRAY_INDEX[@]}; do
		[[ "${element}" == "${1}" ]] && echo "${index}"
		let index++
	done		
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
	# plugin needs to be done by cmake.
	# By default it uses ${S}.
	: ${CMAKE_USE_DIR:=${S}}

	# in/out source build
	echo ">>> Working in BUILD_DIR: \"$CMAKE_BUILD_DIR\""
}

# Internal function
# @FUNCTION: multilib-native_setup_abi_env
# @USAGE: <ABI>
# @DESCRIPTION: Setup initial environment for ABI, flags, workarounds etc.
multilib-native_setup_abi_env() {
	local pyver="" libsuffix=""
	[[ -z $(multilib-native_abi_to_index_key ${1}) ]] && die "Unknown ABI (${1})" 

	# Set the CHOST native first so that we pick up the native
	# toolchain and not a cross-compiler by accident #202811.
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

	# Hack to get mysql.eclass to work: mysql.eclass only sets MY_LIBDIR
	# if it isn't already unset, this results in it being defined during
	# the src_unpack phase and always being set to the DEFAULT_ABI libdir.
	# mysql_version_is_at_least is defined in mysql_fx.eclass, which is
	# inherited by mysql.eclass, if it exists then the ebuild has
	# inherited mysql.eclass.
	#
	# Ideally we should make src_unpack multilib instead. <-- TODO!
	if mysql_version_is_at_least &>/dev/null; then
		[[ -n ${MY_LIBDIR} ]] && export MY_LIBDIR=/usr/$(get_libdir)/mysql
	fi

	# If we aren't building for the DEFAULT ABI we may need to use some
	# ABI specific programs during the build.  The python binary is
	# sometimes used to find the python install dir but there may be more
	# than one version installed.  Use the system default python to find
	# the ABI specific version.
	if ! [[ "${ABI}" == "${DEFAULT_ABI}" ]]; then
		pyver=$(python --version 2>&1)
		pyver=${pyver/Python /python}
		pyver=${pyver%.*}
		PYTHON="/usr/bin/${pyver}-${ABI}"
		PERLBIN="/usr/bin/perl-${ABI}"
	fi

	# S should not be redefined for the CMake !CMAKE_IN_SOURCE_BUILD case,
	# otherwise ECONF_SOURCE should point to the _prepared_ source dir and
	# S into the build directory
	if [[ -n "${CMAKE_BUILD_TYPE}" ]]; then
		CMAKE_BUILD_DIR="${WORKDIR}/${PN}_build_${ABI}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		[[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] && \
			S="${CMAKE_BUILD_DIR}"
	else
		S="${WORKDIR}/${PN}_build_${ABI}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		if [[ -n ${MULTILIB_EXT_SOURCE_BUILD} ]]; then
			ECONF_SOURCE="${EMULTILIB_SOURCE_TOPDIR}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		fi
	fi

	# If KDE_S is defined then the kde.eclass is in use
	if [[ -n ${KDE_S} ]]; then
		KDE_S="${S}"
	fi

	# ccache is ABI dependent
	if [[ -z ${CCACHE_DIR} ]] ; then 
		CCACHE_DIR="/var/tmp/ccache-${1}"
	else
		CCACHE_DIR="${CCACHE_DIR}-${1}"
	fi

	export PYTHON PERLBIN QMAKESPEC
	let EMULTILIB_INITIALISED++
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
		multilib_debug "${_var}" "${!_array}"
		export ${_var}="${!_array}"
	done
}

# @FUNCTION: multilib-native_src_generic
# @USAGE: <phase>
# @DESCRIPTION: Run each phase for each "install ABI"
multilib-native_src_generic() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if [[ -z ${OABI} ]] ; then
			local abilist=""
			if has_multilib_profile ; then
				abilist=$(get_install_abis)
				if [[ "${1/_*}" != "pkg" ]]; then
					einfo "${1/src_/} multilib ${PN} for ABIs: ${abilist}"
				fi
			elif is_crosscompile || tc-is-cross-compiler ; then
				abilist=${DEFAULT_ABI}
			fi
			if [[ -n ${abilist} ]] ; then
				OABI=${ABI}
				for ABI in ${abilist} ; do
					export ABI
					multilib-native_src_generic ${1}
				done
				ABI=${OABI}
				unset OABI
				return 0
			fi
		fi
	fi
	multilib-native_src_generic_sub ${1}
}

# @FUNCTION: multilib-native_src_generic_sub
# @USAGE: <phase>
# @DESCRIPTION: This function gets used for each ABI pass of each phase
multilib-native_src_generic_sub() {
	EMULTILIB_config_vars=""

	# We support two kinds of build, by default we copy the source dir for
	# each ABI. Where supportable with the underlying package we can just
	# create an external build dir (objdir) this requires a modified ebuild
	# which makes use of the EMULTILIB_SOURCE_TOPDIR variable (which points
	# the the top of the original source dir) to install files.  This
	# latter behaviour is enabled with MULTILIB_EXT_SOURCE_BUILD (MOSB).
	# For CMake based packages default is reversed and the
	# CMAKE_IN_SOURCE_BUILD environment variable is used to specify the
	# former behaviour.
	#
	# With multilib builds "S" eventually points into the build tree, but
	# initially "S" points to the source the same as non-multilib
	# packages. Sometimes, however, packages assume a directory structure
	# ABOVE "S". ("S" is set to a subdirectory of the tree they unpack
	# into ${WORKDIR})
	#
	# We need to deal with this by finding the top-level of the source
	# tree and keeping track of ${S} relative to it.
	#
	# We initialise the variables early and unconditionally (except only
	# while no multilib environment has been initialised), whether
	# building for multilib or not.  This allows multilib-native ebuilds
	# to always make use of them. (It is intended for this to happen for
	# each phase until multilib is initialised, this allows ebuilds to
	# modify the common environment, right up until we setup a build dir.)
	if [[ -z ${EMULTILIB_INITIALISED} ]]; then
		multilib-native_save_abi_env "INIT"

		[[ -n ${MULTILIB_DEBUG} ]] && \
			einfo "MULTILIB_DEBUG: Determining EMULTILIB_SOURCE_TOPDIR from S and WORKDIR"
		EMULTILIB_RELATIVE_BUILD_DIR="${S#*${WORKDIR}\/}"
		EMULTILIB_SOURCE_TOP_DIRNAME="${EMULTILIB_RELATIVE_BUILD_DIR%%/*}"
		# If ${EMULTILIB_SOURCE_TOP_DIRNAME} is
		# empty, then we assume ${S} points to the top level.
		# (This should never happen.)
		if [[ -z ${EMULTILIB_SOURCE_TOP_DIRNAME} ]]; then
			ewarn "Unable to determine dirname of the source topdir:"
			ewarn "Assuming S points to the top level"
			EMULTILIB_SOURCE_TOP_DIRNAME=${EMULTILIB_RELATIVE_BUILD_DIR}
		fi
		EMULTILIB_SOURCE_TOPDIR="${WORKDIR}/${EMULTILIB_SOURCE_TOP_DIRNAME}"
		[[ -n ${MULTILIB_DEBUG} ]] && \
			einfo "MULTILIB_DEBUG: EMULTILIB_SOURCE_TOPDIR=\"${EMULTILIB_SOURCE_TOPDIR}\""
	fi
	if [[ -n ${EMULTILIB_PKG} ]] && has_multilib_profile; then

		# If this is the src_prepare phase we only need to run for the
		# DEFAULT_ABI when we are building out of the source tree since
		# it is shared between each ABI.
		if [[ "${1}" == "src_prepare" ]] && \
				!([[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] || \
				([[ -z "${CMAKE_BUILD_TYPE}" ]] && [[ -z "${MULTILIB_EXT_SOURCE_BUILD}" ]])); then
			if [[ ! "${ABI}" == "${DEFAULT_ABI}" ]]; then
				einfo "Skipping ${1} for ${ABI}"
				return
			else
				einfo "Running ${1} for default ABI"
				multilib-native_${1}_internal
				return
			fi
		fi

		if [[ "${1}" != "pkg_setup" && "${1}" != "pkg_postrm" ]]; then
			# Is this our first run for this ABI?
			if [[ ! -d "${WORKDIR}/${PN}_build_${ABI}" ]]; then

				# Restore INIT and setup multilib environment
				# for this ABI
				multilib-native_restore_abi_env "INIT"
				multilib-native_setup_abi_env "${ABI}"

				# Prepare build dir
				if [[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] || \
					([[ -z "${CMAKE_BUILD_TYPE}" ]] && [[ -z "${MULTILIB_EXT_SOURCE_BUILD}" ]]); then
					einfo "Copying source tree from ${EMULTILIB_SOURCE_TOPDIR} to ${WORKDIR}/${PN}_build_${ABI}"
					cp -al "${EMULTILIB_SOURCE_TOPDIR}" "${WORKDIR}/${PN}_build_${ABI}"
				else
					einfo "Creating build directory: ${WORKDIR}/${PN}_build_${ABI}"
					mkdir -p "${WORKDIR}/${PN}_build_${ABI}"
				fi
			else
				# If we are already setup then restore the
				# environment
				multilib-native_restore_abi_env "${ABI}"
			fi
		fi

		# qt-build.eclass sets these in pkg_setup, but that results
		# in the path always pointing to the primary ABI libdir.
		# These need to run on each pass to set correctly.
		QTBASEDIR=/usr/"$(get_libdir)"/qt4
		QTLIBDIR=/usr/"$(get_libdir)"/qt4
		QTPCDIR=/usr/"$(get_libdir)"/pkgconfig
		QTPLUGINDIR="${QTLIBDIR}"/plugins

		export PKG_CONFIG_PATH="/usr/$(get_libdir)/pkgconfig"

		[[ -d "${S}" ]] && cd "${S}"
	fi

	multilib-native_${1}_internal

	if [[ -n ${EMULTILIB_PKG} ]] && has_multilib_profile && \
				[[ "${1/_*}" != "pkg" ]]; then
		# Now save the environment
		multilib-native_save_abi_env "${ABI}"
	fi
}

# @FUNCTION: multilib-native_src_prepare_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom src_configure.
multilib-native_src_prepare_internal() {
	multilib-native_check_inherited_funcs src_prepare
}

# @FUNCTION: multilib-native_src_configure_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom src_configure.
multilib-native_src_configure_internal() {
	multilib-native_check_inherited_funcs src_configure
}

# @FUNCTION: multilib-native_src_compile_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom src_compile.
multilib-native_src_compile_internal() {
	multilib-native_check_inherited_funcs src_compile
}

# @FUNCTION: multilib-native_src_install_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom src_install
multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
}

# @FUNCTION: multilib-native_pkg_setup_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom pkg_setup
multilib-native_pkg_setup_internal() {
	multilib-native_check_inherited_funcs pkg_setup
}

# @FUNCTION: multilib-native_src_unpack_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom src_unpack
multilib-native_src_unpack_internal() {
	multilib-native_check_inherited_funcs src_unpack
}


# @FUNCTION: multilib-native_pkg_preinst_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom pkg_preinst
multilib-native_pkg_preinst_internal() {
	multilib-native_check_inherited_funcs pkg_preinst
}


# @FUNCTION: multilib-native_pkg_postinst_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom pkg_postinst
multilib-native_pkg_postinst_internal() {
	multilib-native_check_inherited_funcs pkg_postinst
}


# @FUNCTION: multilib-native_pkg_postrm_internal
# @USAGE:
# @DESCRIPTION: Override this function if you want to use a custom pkg_postrm
multilib-native_pkg_postrm_internal() {
	multilib-native_check_inherited_funcs pkg_postrm
}

# Internal function
# @FUNCTION multilib-native_check_inherited_funcs
# @USAGE: <phase>
# @DESCRIPTION: Checks all inherited eclasses for requested phase function
multilib-native_check_inherited_funcs() {
	# check all eclasses for given function, in order of inheritance.
	# if none provides it, the var stays empty. If more have it, the last one wins.
	# Ignore the ones we inherit ourselves, base doesn't matter, as we default
	# on it
	local declared_func=""
	if [[ -z ${EMULTILIB_INHERITED} ]]; then
		if [[ -f "${T}"/eclass-debug.log ]]; then
			EMULTILIB_INHERITED="$(grep EXPORT_FUNCTIONS "${T}"/eclass-debug.log | cut -d ' ' -f 4 | cut -d '_' -f 1)"
		else
			ewarn "you are using a packet manager that do not provide "${T}"/eclass-debug.log"
			ewarn "join #gentoo-multilib-overlay on freenode to help finding another way for you"
			ewarn "falling back to old behaviour"
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

	# now if $declared_func is still empty, none of the inherited eclasses
	# provides it, so default on base.eclass. Do nothing for pkg_post*
	if [[ -z "${declared_func}" ]]; then
		if [[ "${1/_*}" != "src" ]]; then
			declared_func="return"
		else
			declared_func="base_${1}"
		fi
	fi
	
	[[ "${1/_*}" != "pkg" ]] && einfo "Using ${declared_func} for ABI ${ABI} ..."
	${declared_func}
}

# @FUNCTION prep_ml_binaries
# @USAGE:
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
