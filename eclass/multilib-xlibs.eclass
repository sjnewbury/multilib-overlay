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

# @ECLASS-VARIABLE: XMODULAR_MULTILIB
# @DESCRIPTION:
# If set to 'yes' the eclass uses the x-modular_src_compile and x-modular_src_install functions of the x-modular eclass
# Set before inheriting this eclass and use only if you are inheriting the x-modular eclass (i dont find a way to check this yet)

# @ECLASS-VARIABLE: MULTILIB_SPLITTREE
# @DESCRIPTION:
# If set to 'yes' if the package dont support building of both trees on the same dir (currently only needed with mesa package)
# Set before inheriting this eclass.

# @FUNCTION: multilib-xlibs_src_compile
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_compile() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if [[ -z ${OABI} ]] ; then
			local abilist=""
			if has_multilib_profile ; then
				abilist=$(get_install_abis)
				einfo "Building multilib ${PN} for ABIs: ${abilist}"
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

# @FUNCTION: multilib-xlibs_src_compile_sub
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_compile_sub() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		local myconf
		local OCFLAGS=""
		local OCXXFLAGS=""
		local OCHOST=""
		local OSPATH=""
		export CC="$(tc-getCC)"
		export CXX="$(tc-getCXX)"

		if has_multilib_profile ; then
			OCFLAGS="${CFLAGS}"
			OCXXFLAGS="${CXXFLAGS}"
			OCHOST="${CHOST}"
			OSPATH="${S}"
			if use amd64 || use ppc64 ; then
				case ${ABI} in
					x86)    CHOST="i686-${OCHOST#*-}"
					CFLAGS="${OCFLAGS} -m32"
					CXXFLAGS="${OCXXFLAGS} -m32"
					;;
					amd64)  CHOST="x86_64-${OCHOST#*-}"
					CFLAGS="${OCFLAGS} -m64"
					CXXFLAGS="${CXXFLAGS} -m64"
					;;
					ppc)   CHOST="powerpc-${OCHOST#*-}"
					CFLAGS="${OCFLAGS} -m32"
					CXXFLAGS="${OCXXFLAGS} -m32"
					;;
					ppc64)   CHOST="powerpc64-${OCHOST#*-}"
					CFLAGS="${OCFLAGS} -m64"
					CXXFLAGS="${OCXXFLAGS} -m64"
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
	if [[ -n ${XMODULAR_MULTILIB} ]]; then
		x-modular_src_compile
	else
		multilib-xlibs_src_compile_internal
	fi
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if has_multilib_profile; then
			CFLAGS="${OCFLAGS}"
			CXXFLAGS="${OCXXFLAGS}"
			CHOST="${OCHOST}"
			S="${OSPATH}"
		fi
	fi
}

# @FUNCTION: multilib-xlibs_src_compile_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_compile.
# @DESCRIPTION:
multilib-xlibs_src_compile_internal() {
	econf || die
	emake || die
}

# @FUNCTION: multilib-xlibs_src_install_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_install
# @DESCRIPTION:
multilib-xlibs_src_install_internal() {
	src_install
}

EXPORT_FUNCTIONS src_compile src_install 
