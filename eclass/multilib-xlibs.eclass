# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# @ECLASS: multilib-xlibs.eclass

IUSE="${IUSE} lib32"

if use lib32; then
	EMULTILIB_PKG="true"
fi

inherit multilib

EMULTILIB_OCFLAGS=""
EMULTILIB_OCXXFLAGS=""
EMULTILIB_OCHOST=""
EMULTILIB_OSPATH=""

# @ECLASS-VARIABLE: XMODULAR_MULTILIB
# @DESCRIPTION:
# If set to 'yes' the eclass uses the x-modular_src_compile and x-modular_src_install functions of the x-modular eclass
# Set before inheriting this eclass and use only if you are inheriting the x-modular eclass (i dont find a way to check this yet)

# @ECLASS-VARIABLE: MULTILIB_SPLITTREE
# @DESCRIPTION:
# If set to 'yes' if the package dont support building of both trees on the same dir (currently only needed with mesa package)
# Set before inheriting this eclass.

# @FUNCTION: multilib-xlibs_src_configure
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_configure() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if [[ -z ${OABI} ]] ; then
			local abilist=""
			if has_multilib_profile ; then
				abilist=$(get_install_abis)
				einfo "Configureing multilib ${PN} for ABIs: ${abilist}"
			elif is_crosscompile || tc-is-cross-compiler ; then
				abilist=${DEFAULT_ABI}
			fi
			if [[ -n ${abilist} ]] ; then
				OABI=${ABI}
				for ABI in ${abilist} ; do
					export ABI
					multilib-xlibs_src_configure
				done
				ABI=${OABI}
				unset OABI
				return 0
			fi
		fi
	fi
	multilib-xlibs_src_configure_sub
}

# @FUNCTION: multilib-xlibs_src_compile
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_compile() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if [[ -z ${OABI} ]] ; then
			local abilist=""
			if has_multilib_profile ; then
				abilist=$(get_install_abis)
				einfo "Compileing multilib ${PN} for ABIs: ${abilist}"
			elif is_crosscompile || tc-is-cross-compiler ; then
				abilist=${DEFAULT_ABI}
			fi
			if [[ -n ${abilist} ]] ; then
				OABI=${ABI}
				for ABI in ${abilist} ; do
					export ABI
					multilib-xlibs_src_compile
				done
				ABI=${OABI}
				unset OABI
				return 0
			fi
		fi
	fi
	multilib-xlibs_src_compile_sub
}

# @FUNCTION: multilib-xlibs_src_install
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_install() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if [[ -z ${OABI} ]] ; then
			local abilist=""
			if has_multilib_profile ; then
				abilist=$(get_install_abis)
				einfo "Installing multilib ${PN} for ABIs: ${abilist}"
			elif is_crosscompile || tc-is-cross-compiler ; then
				abilist=${DEFAULT_ABI}
			fi
			if [[ -n ${abilist} ]] ; then
				OABI=${ABI}
				for ABI in ${abilist} ; do
					export ABI
					multilib-xlibs_src_install
				done
				ABI=${OABI}
				unset OABI
				return 0
			fi
		fi
		einfo "Installing ${PN} ${ABI} ..."

		if [[ -n ${MULTILIB_SPLITTREE} ]]; then
			cd ${WORKDIR}/builddir.${ABI}
		else
			cd "${S}/objdir-${ABI}"
		fi
	fi
	if [[ -n ${XMODULAR_MULTILIB} ]]; then
		x-modular_src_install
	else
		multilib-xlibs_src_install_internal
	fi
}

set_environment() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		export CC="$(tc-getCC)"
		export CXX="$(tc-getCXX)"

		if has_multilib_profile ; then
			EMULTILIB_OCFLAGS="${CFLAGS}"
			EMULTILIB_OCXXFLAGS="${CXXFLAGS}"
			EMULTILIB_OCHOST="${CHOST}"
			EMULTILIB_OSPATH="${S}"
			if use amd64 || use ppc64 ; then
				case ${ABI} in
					x86)    CHOST="i686-${EMULTILIB_OCHOST#*-}"
					CFLAGS="${EMULTILIB_OCFLAGS} -m32"
					CXXFLAGS="${EMULTILIB_OCXXFLAGS} -m32"
					;;
					amd64)  CHOST="x86_64-${EMULTILIB_OCHOST#*-}"
					CFLAGS="${EMULTILIB_OCFLAGS} -m64"
					CXXFLAGS="${EMULTILIB_OCXXFLAGS} -m64"
					;;
					ppc)   CHOST="powerpc-${EMULTILIB_OCHOST#*-}"
					CFLAGS="${EMULTILIB_OCFLAGS} -m32"
					CXXFLAGS="${EMULTILIB_OCXXFLAGS} -m32"
					;;
					ppc64)   CHOST="powerpc64-${EMULTILIB_OCHOST#*-}"
					CFLAGS="${EMULTILIB_OCFLAGS} -m64"
					CXXFLAGS="${EMULTILIB_OCXXFLAGS} -m64"
					;;
					*)   die "Unknown ABI"
					;;
				esac
			fi
		fi

		#Nice way to avoid the "cannot run test program while cross compiling" :)
		CBUILD=$CHOST

		if [[ -n ${MULTILIB_SPLITTREE} ]]; then
			cp -al ${S} ${WORKDIR}/builddir.${ABI}
			cd ${WORKDIR}/builddir.${ABI}
			S=${WORKDIR}/builddir.${ABI}
		else
			mkdir "${S}/objdir-${ABI}"
			cd "${S}/objdir-${ABI}"
			ECONF_SOURCE=".."
		fi

		PKG_CONFIG_PATH="/usr/$(get_libdir)/pkgconfig"
	fi
}

unset_environment() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if has_multilib_profile; then
			CFLAGS="${EMULTILIB_OCFLAGS}"
			CXXFLAGS="${EMULTILIB_OCXXFLAGS}"
			CHOST="${EMULTILIB_OCHOST}"
			S="${EMULTILIB_OSPATH}"
		fi
	fi
}

# @FUNCTION: multilib-xlibs_src_configure_sub
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_configure_sub() {
	set_environment
	if [[ -n ${XMODULAR_MULTILIB} ]]; then
		x-modular_src_configure
	else
		multilib-xlibs_src_configure_internal
	fi
	unset_environment
}

# @FUNCTION: multilib-xlibs_src_compile_sub
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_compile_sub() {
	set_environment
	if [[ -n ${XMODULAR_MULTILIB} ]]; then
		x-modular_src_compile
	else
		multilib-xlibs_src_compile_internal
	fi
	unset_environment
}

# @FUNCTION: multilib-xlibs_src_configure_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_configure.
# @DESCRIPTION:
multilib-xlibs_src_configure_internal() {
	econf || die
}

# @FUNCTION: multilib-xlibs_src_compile_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_compile.
# @DESCRIPTION:
multilib-xlibs_src_compile_internal() {
	if [[ EAPI -lt 2 ]]
	then
		econf || die
	fi
	emake || die
}

# @FUNCTION: multilib-xlibs_src_install_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_install
# @DESCRIPTION:
multilib-xlibs_src_install_internal() {
	src_install
}

EXPORT_FUNCTIONS src_configure src_compile src_install 
