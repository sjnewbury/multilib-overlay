# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# @ECLASS: multilib-native.eclass

IUSE="${IUSE} lib32"

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

# Arrays to hold ABI specific configuration
declare -a EMULTILIB_AS
declare -a EMULTILIB_CC
declare -a EMULTILIB_CXX
declare -a EMULTILIB_FC
declare -a EMULTILIB_LD
declare -a EMULTILIB_ASFLAGS
declare -a EMULTILIB_CFLAGS
declare -a EMULTILIB_CXXFLAGS
declare -a EMULTILIB_FCFLAGS
declare -a EMULTILIB_FFLAGS
declare -a EMULTILIB_LDFLAGS
declare -a EMULTILIB_CHOST
declare -a EMULTILIB_CBUILD
declare -a EMULTILIB_CDEFINE
declare -a EMULTILIB_LIBDIR

# -----------------------------------------------------------------------------

# These arrays are used to store environment for each ABI

declare -a EMULTILIB_ARRAY_INDEX

# Saved Portage/eclass variables
declare -a EMULTILIB_S
declare -a EMULTILIB_ECONF_SOURCE
declare -a EMULTILIB_KDE_S
declare -a EMULTILIB_CMAKE_BUILD_DIR
declare -a EMULTILIB_CCACHE_DIR
declare -a EMULTILIB_QTBINDIR
declare -a EMULTILIB_QMAKE
declare -a EMULTILIB_QMAKESPEC
declare -a EMULTILIB_myconf
declare -a EMULTILIB_mycmakeargs

# Non-default ABI binaries
declare -a EMULTILIB_PYTHON
declare -a EMULTILIB_PERLBIN

# On initialisation of multilib environment this gets incremented by 1
EMULTILIB_INITIALISED=""

# These may be useful in multilib-ised ebuilds
EMULTILIB_SOURCE_TOP_DIRNAME=""
EMULTILIB_SOURCE_TOPDIR=""
EMULTILIB_RELATIVE_BUILD_DIR=""

# -----------------------------------------------------------------------------

# @FUNCTION: multilib-native_pkg_setup
# @USAGE:
# @DESCRIPTION:
multilib-native_pkg_setup() {
	multilib-native_src_generic pkg_setup
}

# @FUNCTION: multilib-native_src_unpack
# @USAGE:
# @DESCRIPTION:
multilib-native_src_unpack() {
	multilib-native_src_unpack_internal
}

# @FUNCTION: multilib-native_src_prepare
# @USAGE:
# @DESCRIPTION:
multilib-native_src_prepare() {
	multilib-native_src_generic src_prepare
}

# @FUNCTION: multilib-native_src_configure
# @USAGE:
# @DESCRIPTION:
multilib-native_src_configure() {
	multilib-native_src_generic src_configure
}

# @FUNCTION: multilib-native_src_compile
# @USAGE:
# @DESCRIPTION:
multilib-native_src_compile() {
	multilib-native_src_generic src_compile
}

# @FUNCTION: multilib-native_src_install
# @USAGE:
# @DESCRIPTION:
multilib-native_src_install() {
	multilib-native_src_generic src_install
}

# @FUNCTION: multilib-native_pkg_preinst
# @USAGE:
# @DESCRIPTION:
multilib-native_pkg_preinst() {
	multilib-native_src_generic pkg_preinst
}

# @FUNCTION: multilib-native_pkg_postinst
# @USAGE:
# @DESCRIPTION:
multilib-native_pkg_postinst() {
	multilib-native_src_generic pkg_postinst
}

# @FUNCTION: multilib-native_pkg_postrm
# @USAGE:
# @DESCRIPTION:
multilib-native_pkg_postrm() {
	multilib-native_src_generic pkg_postrm
}

# @FUNCTION: multilib_debug
# @USAGE: multilib_debug name_of_variable content_of_variable
# @DESCRIPTION: print debug output if MULTILIB_DEBUG is set
multilib_debug() {
	[[ -n ${MULTILIB_DEBUG} ]] && einfo MULTILIB_DEBUG:${1}=${2}
}

# -----------------------------------------------------------------------------
_set_multilib_array_index() {
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
# @DESCRIPTION: This function overrides the function of the same name
#		in cmake-utils.eclass.  We handle the build dir ourselves. 
# Determine using IN or OUT source build
_check_build_dir() {
	# in/out source build
	echo ">>> Working in BUILD_DIR: \"$CMAKE_BUILD_DIR\""
}

# @FUNCTION: _find_ml_config_scripts
# @USAGE: <ABI>
# @DESCRIPTION: Find all linker config scripts on this system provided for
#		this ABI and export the appropriate env var to be used by
#		"configure" scripts
_find_ml_config_scripts() {
	EMULTILIB_config_vars=""
	local _config_script _config_var
	for _config_script in $(find "/usr/bin" -executable \
			-regex ".*-config.*-${1}"); do
		_config_var="${_config_script%%-*}"
		#convert to upper case letters.
		#with bash 4 we could use declare -u
		_config_var="$(echo $_config_var | tr "[:lower:]" "[:upper:]")"
		_config_var="${_config_var##*/}_CONFIG"
		_config_var="${_config_var/#LIB}"
		multilib_debug "${_config_var}_default" "${!_config_var}"
		multilib_debug "${_config_var}" "${_config_script}"
		declare ${_config_var}_default="${!_config_var}"
		export ${_config_var}="${_config_script}"
		EMULTILIB_config_vars="${EMULTILIB_config_vars} ${_config_var}"
	done
}

# @FUNCTION: _setup_multilib_platform_env
# @USAGE: <ABI>
# @DESCRIPTION: Setup initial environment for ABI, flags, workarounds etc.
_setup_multilib_platform_env() {
	local pyver="" libsuffix=""
	[[ -z $(_set_multilib_array_index ${1}) ]] && die "Unknown ABI (${1})" 

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
	export FCFLAGS="${FCFLAGS} $(get_abi_CFLAGS)"
	export FFLAGS="${FFLAGS} $(get_abi_CFLAGS)"
	export CHOST=$(get_abi_CHOST $1)
	export CBUILD=$(get_abi_CHOST $1)
	export LIBDIR=$(get_abi_LIBDIR $1)
	export LDFLAGS="${LDFLAGS} -L/${LIBDIR} -L/usr/${LIBDIR}"

	multilib_debug "CHOST" ${CHOST}
	multilib_debug "${ABI} CC" "${CC}"
	multilib_debug "${ABI} LD" "${LD}"
	# Multilib QT Support - This is needed for QT and CMake based packages
	if [[ -n ${QTDIR} ]] || ${QTBINDIR} || [[ -n "${CMAKE_BUILD_TYPE}" ]]; then
		libsuffix="${EMULTILIB_LIBDIR[$(_set_multilib_array_index ${1})]/lib}"
		if [[ -n "${libsuffix}" ]]; then
			QMAKESPEC="linux-g++-${libsuffix}"
		else
			QMAKESPEC="linux-g++"
		fi
		if [[ ! ${ABI} == ${DEFAULT_ABI} ]]; then
			if [[ -n "${libsuffix}" ]]; then 
				QTBINDIR="/usr/libexec/qt/${libsuffix}"
				QMAKESPEC="linux-g++-${libsuffix}"
			else
				QMAKESPEC="linux-g++"
				QTBINDIR="/usr/libexec/qt/${1}"
			fi
		else
			QTBINDIR="/usr/bin"
		fi
		QMAKE="${QTBINDIR}/qmake"
		multilib_debug "${ABI} QMAKESPEC" "${QMAKESPEC}"
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
		# Multilib CMake Support, qmake provides the paths to link QT
		mycmakeargs="${mycmakeargs} \
			-DQT_QMAKE_EXECUTABLE:FILEPATH=${QMAKE}"
		multilib_debug "${ABI} mycmakeargs" "${mycmakeargs}"

		CMAKE_BUILD_DIR="${WORKDIR}/${PN}_build_${ABI}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		[[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] && \
			S="${CMAKE_BUILD_DIR}"
		multilib_debug "${ABI} CMAKE_BUILD_DIR" "${CMAKE_BUILD_DIR}"

	else
		S="${WORKDIR}/${PN}_build_${ABI}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		if [[ -n ${MULTILIB_EXT_SOURCE_BUILD} ]]; then
			ECONF_SOURCE="${EMULTILIB_SOURCE_TOPDIR}/${EMULTILIB_RELATIVE_BUILD_DIR/${EMULTILIB_SOURCE_TOP_DIRNAME}}"
		fi
		multilib_debug "${ABI} ECONF_SOURCE" "${ECONF_SOURCE}"
	fi

	# If KDE_S is defined then the kde.eclass is in use
	if [[ -n ${KDE_S} ]]; then
		KDE_S="${S}"
		multilib_debug "${ABI} KDE_S" "${KDE_S}"
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

# @FUNCTION: _save_multilib_platform_env
# @USAGE: <ABI>
# @DESCRIPTION: Save environment for ABI
_save_multilib_platform_env() {
	multilib_debug "Saving Environment" "${1}"

	# Save toolchain flags for each ABI
	EMULTILIB_AS[$(_set_multilib_array_index ${1})]="${AS}"
	EMULTILIB_CC[$(_set_multilib_array_index ${1})]="${CC}"
	EMULTILIB_CXX[$(_set_multilib_array_index ${1})]="${CXX}"
	EMULTILIB_FC[$(_set_multilib_array_index ${1})]="${FC}"
	EMULTILIB_LD[$(_set_multilib_array_index ${1})]="${LD}"
	EMULTILIB_ASFLAGS[$(_set_multilib_array_index ${1})]="${ASFLAGS}"
	EMULTILIB_CFLAGS[$(_set_multilib_array_index ${1})]="${CFLAGS}"
	EMULTILIB_CXXFLAGS[$(_set_multilib_array_index ${1})]="${CXXFLAGS}"
	EMULTILIB_FCFLAGS[$(_set_multilib_array_index ${1})]="${FCFLAGS}"
	EMULTILIB_FFLAGS[$(_set_multilib_array_index ${1})]="${FFLAGS}"
	EMULTILIB_LDFLAGS[$(_set_multilib_array_index ${1})]="${LDFLAGS}"
	EMULTILIB_CDEFINE[$(_set_multilib_array_index ${1})]="${CBUILD}"
	EMULTILIB_CHOST[$(_set_multilib_array_index ${1})]="${CHOST}"
	EMULTILIB_CBUILD[$(_set_multilib_array_index ${1})]="${CBUILD}"
	EMULTILIB_LIBDIR[$(_set_multilib_array_index ${1})]="${LIBDIR}"

	# Saved Portage/eclass variables
	EMULTILIB_S[$(_set_multilib_array_index ${1})]="${S}"
	EMULTILIB_ECONF_SOURCE[$(_set_multilib_array_index ${1})]="${ECONF_SOURCE}"
	EMULTILIB_KDE_S[$(_set_multilib_array_index ${1})]="${KDE_S}"
	EMULTILIB_CMAKE_BUILD_DIR[$(_set_multilib_array_index ${1})]="${CMAKE_BUILD_DIR}"
	EMULTILIB_CCACHE_DIR[$(_set_multilib_array_index ${1})]="${CCACHE_DIR}"
	EMULTILIB_QTBINDIR[$(_set_multilib_array_index ${1})]="${QTBINDIR}"
	EMULTILIB_QMAKE[$(_set_multilib_array_index ${1})]="${QMAKE}"
	EMULTILIB_QMAKESPEC[$(_set_multilib_array_index ${1})]="${QMAKESPEC}"
	EMULTILIB_myconf[$(_set_multilib_array_index ${1})]="${myconf}"
	EMULTILIB_mycmakeargs[$(_set_multilib_array_index ${1})]="${mycmakeargs}"

	# Non-default ABI binaries
	EMULTILIB_PYTHON[$(_set_multilib_array_index ${1})]="${PYTHON}"
	EMULTILIB_PERLBIN[$(_set_multilib_array_index ${1})]="${PERLBIN}"

	multilib_debug "EMULTILIB_S[$(_set_multilib_array_index ${1})]" "${EMULTILIB_S[$(_set_multilib_array_index ${1})]}"
	multilib_debug "EMULTILIB_CC[$(_set_multilib_array_index ${1})]" "${EMULTILIB_CC[$(_set_multilib_array_index ${1})]}"
}

# @FUNCTION: _restore_multilib_platform_env
# @USAGE: <ABI>
# @DESCRIPTION: Restore environment for ABI
_restore_multilib_platform_env() {
	multilib_debug "Restoring Environment" "${1}"

	multilib_debug "EMULTILIB_S[$(_set_multilib_array_index ${1})]" "${EMULTILIB_S[$(_set_multilib_array_index ${1})]}"
	multilib_debug "EMULTILIB_CFLAGS[$(_set_multilib_array_index ${1})]" "${EMULTILIB_CFLAGS[$(_set_multilib_array_index ${1})]}"

	# Restore compiler and linker flags for each ABI
	AS="${EMULTILIB_AS[$(_set_multilib_array_index ${1})]}"
	CC="${EMULTILIB_CC[$(_set_multilib_array_index ${1})]}"
	CXX="${EMULTILIB_CXX[$(_set_multilib_array_index ${1})]}"
	FC="${EMULTILIB_FC[$(_set_multilib_array_index ${1})]}"
	LD="${EMULTILIB_LD[$(_set_multilib_array_index ${1})]}"
	ASFLAGS="${EMULTILIB_ASFLAGS[$(_set_multilib_array_index ${1})]}"
	CFLAGS="${EMULTILIB_CFLAGS[$(_set_multilib_array_index ${1})]}"
	CXXFLAGS="${EMULTILIB_CXXFLAGS[$(_set_multilib_array_index ${1})]}"
	FCFLAGS="${EMULTILIB_FCFLAGS[$(_set_multilib_array_index ${1})]}"
	FFLAGS="${EMULTILIB_FFLAGS[$(_set_multilib_array_index ${1})]}"
	LDFLAGS="${EMULTILIB_LDFLAGS[$(_set_multilib_array_index ${1})]}"
	CDEFINE="${EMULTILIB_CDEFINE[$(_set_multilib_array_index ${1})]}"
	CHOST="${EMULTILIB_CHOST[$(_set_multilib_array_index ${1})]}"
	CBUILD="${EMULTILIB_CBUILD[$(_set_multilib_array_index ${1})]}"
	LIBDIR="${EMULTILIB_LIBDIR[$(_set_multilib_array_index ${1})]}"

	# Saved Portage/eclass variables
	S="${EMULTILIB_S[$(_set_multilib_array_index ${1})]}"
	ECONF_SOURCE="${EMULTILIB_ECONF_SOURCE[$(_set_multilib_array_index ${1})]}"
	KDE_S="${EMULTILIB_KDE_S[$(_set_multilib_array_index ${1})]}"
	CMAKE_BUILD_DIR="${EMULTILIB_CMAKE_BUILD_DIR[$(_set_multilib_array_index ${1})]}"
	CCACHE_DIR="${EMULTILIB_CCACHE_DIR[$(_set_multilib_array_index ${1})]}"
	QTBINDIR="${EMULTILIB_QTBINDIR[$(_set_multilib_array_index ${1})]}"
	QMAKE="${EMULTILIB_QMAKE[$(_set_multilib_array_index ${1})]}"
	QMAKESPEC="${EMULTILIB_QMAKESPEC[$(_set_multilib_array_index ${1})]}"
	myconf="${EMULTILIB_myconf[$(_set_multilib_array_index ${1})]}"
	mycmakeargs="${EMULTILIB_mycmakeargs[$(_set_multilib_array_index ${1})]}"

	# Non-default ABI binaries
	PYTHON="${EMULTILIB_PYTHON[$(_set_multilib_array_index ${1})]}"
	PERLBIN="${EMULTILIB_PERLBIN[$(_set_multilib_array_index ${1})]}"

	multilib_debug "S" "${S}"
	multilib_debug "CFLAGS" "${CFLAGS}"
}

# @FUNCTION: multilib-native_src_generic
# @USAGE:
# @DESCRIPTION:
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
# @USAGE:
# @DESCRIPTION:
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
		_save_multilib_platform_env "INIT"

		[[ -n ${MULTILIB_DEBUG} ]] && \
			einfo "Determining SOURCE_TOPDIR from S and WORKDIR"
		EMULTILIB_RELATIVE_BUILD_DIR="${S#*${WORKDIR}\/}"
		EMULTILIB_SOURCE_TOP_DIRNAME="${EMULTILIB_RELATIVE_BUILD_DIR%%/*}"
		multilib_debug WORKDIR "${WORKDIR}"
		multilib_debug S "${S}"
		multilib_debug EMULTILIB_RELATIVE_BUILD_DIR "${EMULTILIB_RELATIVE_BUILD_DIR}"
		multilib_debug EMULTILIB_SOURCE_TOP_DIRNAME "${EMULTILIB_SOURCE_TOP_DIRNAME}"
		# If ${EMULTILIB_SOURCE_TOP_DIRNAME} is
		# empty, then we assume ${S} points to the top level.
		# (This should never happen.)
		if [[ -z ${EMULTILIB_SOURCE_TOP_DIRNAME} ]]; then
			ewarn "Unable to determine dirname of the source topdir:"
			ewarn "Assuming S points to the top level"
			EMULTILIB_SOURCE_TOP_DIRNAME=${EMULTILIB_RELATIVE_BUILD_DIR}
			multilib_debug EMULTILIB_SOURCE_TOP_DIRNAME ${EMULTILIB_SOURCE_TOP_DIRNAME}
		fi
		EMULTILIB_SOURCE_TOPDIR="${WORKDIR}/${EMULTILIB_SOURCE_TOP_DIRNAME}"
		multilib_debug EMULTILIB_SOURCE_TOPDIR ${EMULTILIB_SOURCE_TOPDIR}
	fi
	if [[ -n ${EMULTILIB_PKG} ]] && has_multilib_profile; then

		# If this is the src_prepare phase we only need to run for the
		# DEFAULT_ABI when we are building out of the source tree since
		# it is shared between each ABI.
		if [[ "${1}" == "src_prepare" ]] && \
				!([[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] || \
				[[ -z "${MULTILIB_EXT_SOURCE_BUILD}" ]]); then
			if [[ ! "${ABI}" == "${DEFAULT_ABI}" ]]; then
				einfo "Skipping ${1} for ${ABI}"
				return
			else
				einfo "Running ${1} for default ABI"
				multilib-native_${1}_internal
				return
			fi
		fi

		if [[ "${1/_*}" != "pkg" ]]; then
			# Is this our first run for this ABI?
			if [[ ! -d "${WORKDIR}/${PN}_build_${ABI}" ]]; then

				# We don't care what's set in the initial 
				# enviroment we need this to work
				export CC="$(tc-getCC)"
				export CXX="$(tc-getCXX)"
				export FC="$(tc-getFC)"

				# Restore INIT and setup multilib environment
				# for this ABI
				_restore_multilib_platform_env "INIT"
				_setup_multilib_platform_env "${ABI}"

				# Prepare build dir
				if [[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] || \
					[[ -z "${MULTILIB_EXT_SOURCE_BUILD}" ]]; then
					einfo "Copying source tree from ${EMULTILIB_SOURCE_TOPDIR} to ${WORKDIR}/${PN}_build_${ABI}"
					cp -al "${EMULTILIB_SOURCE_TOPDIR}" "${WORKDIR}/${PN}_build_${ABI}"
				else
					einfo "Creating build directory: ${WORKDIR}/${PN}_build_${ABI}"
					mkdir -p "${WORKDIR}/${PN}_build_${ABI}"
				fi
			else
				# If we are already setup then restore the
				# environment
				_restore_multilib_platform_env "${ABI}"
			fi
			[[ "${ABI}" == "${DEFAULT_ABI}" ]] || \
				_find_ml_config_scripts "${ABI}"
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
		# Restore config script variables to their defaults
		local _temp_var
		if [[ -n EMULTILIB_config_vars ]]; then
			for _config_var in ${EMULTILIB_config_vars}; do
				_temp_var=${_config_var}_default
				export ${_config_var}="${!_temp_var}"
			done
		fi


		# handle old-style (non-PKG-CONFIG) *-config* scripts
		if [[ ${1} == "src_install" ]] && \
				 [[ ! "${ABI}" == "${DEFAULT_ABI}" ]]; then
			einfo Looking for package config scripts
			local _config_script
			if [[ -d "${D}/usr/bin" ]]; then
				for _config_script in $(find "${D}/usr/bin" \
						-name "*config32*" -prune -o \( -executable -regex ".*-config.*" -print \)); do
					if (file "${_config_script}" | fgrep -q "script text"); then
						einfo Renaming "${_config_script}" as "${_config_script}-${ABI}"
						mv "${_config_script}" "${_config_script}-${ABI}"
					fi
				done
			fi
		fi
		
		# Now save the environment
		_save_multilib_platform_env "${ABI}"
	fi
}

# @FUNCTION: multilib-native_src_prepare_internal
# @USAGE: override this function if you want to use a custom src_configure.
# @DESCRIPTION:
multilib-native_src_prepare_internal() {
	multilib-native_check_inherited_funcs src_prepare
}

# @FUNCTION: multilib-native_src_configure_internal
# @USAGE: override this function if you want to use a custom src_configure.
# @DESCRIPTION:
multilib-native_src_configure_internal() {
	multilib-native_check_inherited_funcs src_configure
}

# @FUNCTION: multilib-native_src_compile_internal
# @USAGE: override this function if you want to use a custom src_compile.
# @DESCRIPTION:
multilib-native_src_compile_internal() {
	multilib-native_check_inherited_funcs src_compile
}

# @FUNCTION: multilib-native_src_install_internal
# @USAGE: override this function if you want to use a custom src_install
# @DESCRIPTION:
multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
}

# @FUNCTION: multilib-native_pkg_setup_internal
# @USAGE: override this function if you want to use a custom pkg_setup
# @DESCRIPTION:
multilib-native_pkg_setup_internal() {
	multilib-native_check_inherited_funcs pkg_setup
}

# @FUNCTION: multilib-native_src_unpack_internal
# @USAGE: override this function if you want to use a custom src_unpack
# @DESCRIPTION:
multilib-native_src_unpack_internal() {
	multilib-native_check_inherited_funcs src_unpack
}


# @FUNCTION: multilib-native_pkg_preinst_internal
# @USAGE: override this function if you want to use a custom pkg_preinst
# @DESCRIPTION:
multilib-native_pkg_preinst_internal() {
	multilib-native_check_inherited_funcs pkg_preinst
}


# @FUNCTION: multilib-native_pkg_postinst_internal
# @USAGE: override this function if you want to use a custom pkg_postinst
# @DESCRIPTION:
multilib-native_pkg_postinst_internal() {
	multilib-native_check_inherited_funcs pkg_postinst
}


# @FUNCTION: multilib-native_pkg_postrm_internal
# @USAGE: override this function if you want to use a custom pkg_postrm
# @DESCRIPTION:
multilib-native_pkg_postrm_internal() {
	multilib-native_check_inherited_funcs pkg_postrm
}

# @internal-function multilib-native_check_inherited_funcs
# @USAGE: call it in the phases
# @DESCRIPTION: checks all inherited eclasses for requested phase function
multilib-native_check_inherited_funcs() {
	# check all eclasses for given function, in order of inheritance.
	# if none provides it, the var stays empty. If more have it, the last one wins.
	# Ignore the ones we inherit ourselves, base doesn't matter, as we default
	# on it
	local declared_func=""
	local eclasses=""
	eclasses="${INHERITED/base/}"
	eclasses="${eclasses/multilib-native/}"

	for func in ${eclasses}; do
		if [[ -n $(declare -f ${func}_${1}) ]]; then
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
	
	[[ "${1/_*}" != "pkg" ]] && einfo "Using ${declared_func} ..."
	${declared_func}
}

prep_ml_binaries() {
	if [[ -n $EMULTILIB_PKG ]] ; then
		for binary in "$@"; do
			mv ${D}/${binary} ${D}/${binary}-${ABI}
			if [[ is_final_abi ]]; then
				ln -s /usr/bin/abi-wrapper ${D}/${binary}
			fi
		done
	fi		
}
