# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# @ECLASS: multilib-native.eclass

# temporary stuff to to have some debug info what's going on with
# multilib-native_check_inherited_funcs() and maybe other stuff. Remove this var and 
# the stuff in the phase functions when done...
ECLASS_DEBUG="yes"

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

EMULTILIB_OCFLAGS=""
EMULTILIB_OCXXFLAGS=""
EMULTILIB_OLDFLAGS=""
EMULTILIB_OCHOST=""
EMULTILIB_OSPATH=""
EMULTILIB_OCCACHE_DIR=""
EMULTILIB_OPYTHON=""
EMULTILIB_OPYTHON_CONFIG=""
EMULTILIB_OCUPS_CONFIG=""
EMULTILIB_OGNUTLS_CONFIG=""
EMULTILIB_OCURL_CONFIG=""
EMULTILIB_OCACA_CONFIG=""
EMULTILIB_OAALIB_CONFIG=""
EMULTILIB_OPERLBIN=""
EMULTILIB_Omyconf=""
EMULTILIB_OKDE_S=""
EMULTILIB_Omycmakeargs=""

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

# @FUNCTION: _check_build_dir
# @DESCRIPTION: This function overrides the function of the same name
#		in cmake-utils.eclass.  We handle the build dir ourselves. 
# Determine using IN or OUT source build
_check_build_dir() {
	# in/out source build
	echo ">>> Working in BUILD_DIR: \"$CMAKE_BUILD_DIR\""
}

# @FUNCTION: _set_platform_env
# @DESCRIPTION: Set environment up for 32bit or 64bit ABI
_set_platform_env() {
	local pyver=""
	CFLAGS="${EMULTILIB_OCFLAGS} -m$1"
	CXXFLAGS="${EMULTILIB_OCXXFLAGS} -m$1"
	LDFLAGS="${EMULTILIB_OLDFLAGS} -m$1 -L/usr/lib$1"
	QMAKESPEC="linux-g++-$1"
	if [[ $1 == "32" ]]; then
		# TODO: this should be changed to ${ABI}
		QTBINDIR="/usr/libexec/qt/$1"
	else
		QTBINDIR="/usr/bin"
	fi
	mycmakeargs="${EMULTILIB_Omycmakeargs} \
		-DQT_QMAKE_EXECUTABLE:FILEPATH=${QTBINDIR}/qmake"
	if [[ -z ${CCACHE_DIR} ]] ; then 
		CCACHE_DIR="/var/tmp/ccache"
	else
		CCACHE_DIR="${CCACHE_DIR}$1"
	fi
	pyver=$(eselect python show)

	if ! is_final_abi; then
		PYTHON=/usr/bin/python${pyver}-${ABI}
		PYTHON_CONFIG=/usr/bin/python-config-${pyver/python}-${ABI}
		CUPS_CONFIG=/usr/bin/cups-config-${ABI}
		GNUTLS_CONFIG=/usr/bin/gnutls-config-${ABI}
		CURL_CONFIG=/usr/bin/curl-config-${ABI}
		CACA_CONFIG=/usr/bin/caca-config-${ABI}
		AALIB_CONFIG=/usr/bin/aalib-config-${ABI}
		PERLBIN=/usr/bin/perl-${ABI}
	fi
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
				if [[ -z "$(echo ${1}|grep pkg)" ]]; then
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
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if [[ "$1" == "src_prepare" ]] && ! is_final_abi; then
			if !([[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] || \
			[[ -n "${MULTILIB_IN_SOURCE_BUILD}" ]]); then
				return
			fi
		fi
		export CC="$(tc-getCC)"
		export CXX="$(tc-getCXX)"

		if has_multilib_profile ; then
			# Save env before each ABI pass
			EMULTILIB_OCFLAGS="${CFLAGS}"
			EMULTILIB_OCXXFLAGS="${CXXFLAGS}"
			EMULTILIB_OLDFLAGS="${LDFLAGS}"
			EMULTILIB_OCHOST="${CHOST}"
			EMULTILIB_OSPATH="${S}"

			# Various libraries store build-time linking
			# information in a config script file or program binary
			EMULTILIB_OCCACHE_DIR="${CCACHE_DIR}"
			EMULTILIB_OPYTHON="${PYTHON}"
			EMULTILIB_OPYTHON_CONFIG="${PYTHON_CONFIG}"
			EMULTILIB_OCUPS_CONFIG="${CUPS_CONFIG}"
			EMULTILIB_OGNUTLS_CONFIG="${GNUTLS_CONFIG}"
			EMULTILIB_OCURL_CONFIG="${CURL_CONFIG}"
			EMULTILIB_OCACA_CONFIG="${CACA_CONFIG}"
			EMULTILIB_OAALIB_CONFIG="${AALIB_CONFIG}"
			EMULTILIB_OPERLBIN="${PERLBIN}"
			EMULTILIB_OKDE_S="${KDE_S}"
			EMULTILIB_Omycmakeargs="${mycmakeargs}"
			# We need to prevent myconf from accumulating through
			# each pass, but respect initial value
			EMULTILIB_Omyconf="${myconf}"

			if use amd64 || use ppc64 ; then
				case ${ABI} in
					x86)    CHOST="i686-${EMULTILIB_OCHOST#*-}"
						_set_platform_env 32
					;;
					amd64)  CHOST="x86_64-${EMULTILIB_OCHOST#*-}"
						_set_platform_env 64
					;;
					ppc)   CHOST="powerpc-${EMULTILIB_OCHOST#*-}"
						_set_platform_env 32
					;;
					ppc64)   CHOST="powerpc64-${EMULTILIB_OCHOST#*-}"
						_set_platform_env 64
					;;
					*)   die "Unknown ABI"
					;;
				esac
				export QMAKESPEC CUPS_CONFIG GNUTLS_CONFIG CURL_CONFIG PYTHON_CONFIG PYTHON 
				export CACA_CONFIG AALIB_CONFIG PERLBIN
			fi
		fi

		#Nice way to avoid the "cannot run test program while cross compiling" :)
		CBUILD=$CHOST

		# qt-build.eclass sets these in pkg_setup, but that results
		# in the path always pointing to the primary ABI libdir.
		QTBASEDIR=/usr/$(get_libdir)/qt4
		QTLIBDIR=/usr/$(get_libdir)/qt4
		QTPCDIR=/usr/$(get_libdir)/pkgconfig
		QTPLUGINDIR=${QTLIBDIR}/plugins

		# Prepare build dir
		if [[ ! -d "${WORKDIR}/${PN}_build_${ABI}" ]] && \
				[[ -z "$(echo ${1}|grep pkg)" ]]; then
			if [[ -n "${CMAKE_IN_SOURCE_BUILD}" ]] || \
					[[ -n "${MULTILIB_IN_SOURCE_BUILD}" ]]; then
				einfo "Copying source tree to ${WORKDIR}/${PN}_build_${ABI}"
				cp -al ${S} ${WORKDIR}/${PN}_build_${ABI}

				# Workaround case where ${S} points to a src subdir of build tree and doc is
				# is also in the package root (fixes doc install in some packages)
				[[ -d "${S}/../doc" && ! -d "${WORKDIR}/doc" ]] && \
					cp -al ${S}/../doc ${WORKDIR}/doc


			else
				einfo "Creating build directory"
				local _docdir=""
				# Create build dir
				mkdir -p "${WORKDIR}/${PN}_build_${ABI}"
				# Populate build dir with filtered FILES from source
				# root and any directories matching *doc*:
				# This is a bit of a hack, but it ensures
				# doc files are available for install phase
				cp -al $(find ${S} -maxdepth 1 -type f \
					! -executable | \
					grep -v -e ".*\.in\|.*\.am\|.*config.*\|.*\.h\|.*\.c.*\|.*\.cmake" ) \
					${WORKDIR}/${PN}_build_${ABI}
				for _docdir in $(find ${S} -type d -name '*doc*'); do
					mkdir -p ${_docdir/"${S}"/"${WORKDIR}/${PN}_build_${ABI}"}
					cp -al ${_docdir}/* ${_docdir/"${S}"/"${WORKDIR}/${PN}_build_${ABI}"}
				done

			fi
		fi
		
		[[ -z "${MULTILIB_IN_SOURCE_BUILD}" ]] && \
			ECONF_SOURCE="${S}"

		# S should not be redefined for out-of-source-tree prepare
		# phase, or at all in the cmake case
		if [[ -n "${CMAKE_BUILD_TYPE}" ]]; then
			if [[ -n "${CMAKE_IN_SOURCE_BUILD}" ]]; then
				S=${WORKDIR}/${PN}_build_${ABI}
			fi
		else
			if !([[ "$1" == "src_prepare" ]] && \
					[[ -z "${MULTILIB_IN_SOURCE_BUILD}" ]]); then
				S=${WORKDIR}/${PN}_build_${ABI}
			fi
		fi

		CMAKE_BUILD_DIR="${WORKDIR}/${PN}_build_${ABI}"
		KDE_S="${S}"

		#[[ -d "${WORKDIR}/${PN}_build_${ABI}" ]] && \
		#	cd ${WORKDIR}/${PN}_build_${ABI}
		[[ -d "${S}" ]] && cd ${S}

		export PKG_CONFIG_PATH="/usr/$(get_libdir)/pkgconfig"
	fi
	
	multilib-native_${1}_internal

	if [[ -n ${EMULTILIB_PKG} ]]; then
		if has_multilib_profile; then
			CFLAGS="${EMULTILIB_OCFLAGS}"
			CXXFLAGS="${EMULTILIB_OCXXFLAGS}"
			LDFLAGS="${EMULTILIB_OLDFLAGS}"
			CHOST="${EMULTILIB_OCHOST}"
			S="${EMULTILIB_OSPATH}"
			CCACHE_DIR="${EMULTILIB_OCCACHE_DIR}"
			PYTHON="${EMULTILIB_OPYTHON}"
			PYTHON_CONFIG="${EMULTILIB_OPYTHON_CONFIG}"
			CUPS_CONFIG="${EMULTILIB_OCUPS_CONFIG}"
			GNUTLS_CONFIG="${EMULTILIB_OGNUTLS_CONFIG}"
			CURL_CONFIG="${EMULTILIB_OCURL_CONFIG}"
			CACA_CONFIG="${EMULTILIB_OCACA_CONFIG}"
			AALIB_CONFIG="${EMULTILIB_OAALIB_CONFIG}"
			PERLBIN="${EMULTILIB_OPERLBIN}"
			myconf="${EMULTILIB_Omyconf}"
			KDE_S="${EMULTILIB_OKDE_S}"
			mycmakeargs="${EMULTILIB_Omycmakeargs}"

			# handle old-style (non-PKG-CONFIG) *-config* scripts
			if [[ ${1} == "src_install" ]] && \
					 ( ! is_final_abi ); then
				einfo Looking for package config scripts
				local _config
				for _config in $(find "${D}/usr/bin" -executable \
						-regex ".*-config.*"); do
					einfo Renaming ${_config} as ${_config}-${ABI}
					mv ${_config} ${_config}-${ABI}
				done
			fi
		fi
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
		if [[ -z "$(echo ${1}|grep src)" ]]; then
			declared_func="return"
		else
			declared_func="base_${1}"
		fi
	fi
	
	[[ -z "$(echo ${1}|grep pkg)" ]] && einfo "Using ${declared_func} ..."
	${declared_func}
}
