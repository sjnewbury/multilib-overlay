# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
#
# @ECLASS: multilib-xlibs.eclass

# temporary stuff to to have some debug info what's going on with
# multilib-xlibs_check_inherited_funcs() and maybe other stuff. Remove this var and 
# the stuff in the phase functions when done...
ECLASS_DEBUG="yes"

IUSE="${IUSE} lib32"

if use lib32; then
	EMULTILIB_PKG="true"
fi

# this var is used in multilib-xlibs_check_inherited_funcs(), take care!
MY_ECLASSES="base multilib"
inherit ${MY_ECLASSES}

case "${EAPI:-0}" in
	2)
		EXPORT_FUNCTIONS src_prepare src_configure src_compile src_install pkg_postinst
		;;
	*)
		EXPORT_FUNCTIONS src_compile src_install pkg_postinst
		;;
esac

EMULTILIB_OCFLAGS=""
EMULTILIB_OCXXFLAGS=""
EMULTILIB_OCHOST=""
EMULTILIB_OSPATH=""

# @FUNCTION: multilib-xlibs_src_prepare
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_prepare() {
	multilib-xlibs_src_generic src_prepare
}

# @FUNCTION: multilib-xlibs_src_configure
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_configure() {
	multilib-xlibs_src_generic src_configure
}

# @FUNCTION: multilib-xlibs_src_compile
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_compile() {
	multilib-xlibs_src_generic src_compile
}

# @FUNCTION: multilib-xlibs_src_install
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_install() {
	multilib-xlibs_src_generic src_install
}

# @FUNCTION: multilib-xlibs_pkg_postinst
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_pkg_postinst() {
	multilib-xlibs_src_generic pkg_postinst
}

# @FUNCTION: multilib-xlibs_pkg_postrm
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_pkg_postrm() {
	multilib-xlibs_src_generic pkg_postrm
}

# @FUNCTION: multilib-xlibs_src_generic
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_generic() {
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if [[ -z ${OABI} ]] ; then
			local abilist=""
			if has_multilib_profile ; then
				abilist=$(get_install_abis)
				einfo "${1}ing multilib ${PN} for ABIs: ${abilist}"
			elif is_crosscompile || tc-is-cross-compiler ; then
				abilist=${DEFAULT_ABI}
			fi
			if [[ -n ${abilist} ]] ; then
				OABI=${ABI}
				for ABI in ${abilist} ; do
					export ABI
					multilib-xlibs_src_generic ${1}
				done
				ABI=${OABI}
				unset OABI
				return 0
			fi
		fi
	fi
	multilib-xlibs_src_generic_sub ${1}
}

# @FUNCTION: multilib-xlibs_src_generic_sub
# @USAGE:
# @DESCRIPTION:
multilib-xlibs_src_generic_sub() {
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

		if [[ ! -d "${WORKDIR}/builddir.${ABI}" ]]; then
			einfo "Copying source tree to ${WORKDIR}/builddir.${ABI}"
			cp -al ${S} ${WORKDIR}/builddir.${ABI}
		fi

		cd ${WORKDIR}/builddir.${ABI}
		S=${WORKDIR}/builddir.${ABI}

		PKG_CONFIG_PATH="/usr/$(get_libdir)/pkgconfig"
	fi
	if [[ -n ${MULTILIBX86_ECLASS} ]]; then
		${MULTILIBX86_ECLASS}_${1}
	else
		multilib-xlibs_${1}_internal
	fi
	if [[ -n ${EMULTILIB_PKG} ]]; then
		if has_multilib_profile; then
			CFLAGS="${EMULTILIB_OCFLAGS}"
			CXXFLAGS="${EMULTILIB_OCXXFLAGS}"
			CHOST="${EMULTILIB_OCHOST}"
			S="${EMULTILIB_OSPATH}"
		fi
	fi
}

# @internal-function multilib-xlibs_check_inherited_funcs
# @USAGE: call it in the phases
# @DESCRIPTION: checks all inherited eclasses for requested phase function
multilib-xlibs_check_inherited_funcs() {
	# check all eclasses for given function, in order of inheritance.
	# if none provides it, the var stays empty. If more have it, the last one wins.
	# Ignore the ones we inherit ourselves, base doesn't matter, as we default
	# on it
	local declared_func=""
	for func in ${INHERITED/${MY_ECLASSES}-xlibs/}; do
		if [[ -n $(declare -f ${func}_${1}) ]]; then
			declared_func="${func}_${1}"
		fi
	done

	# now if $declared_func is still empty, none of the inherited eclasses
	# provides it, so default on base.eclass
	if [[ -z "${declared_func}" ]]; then
		declared_func="base_${1}"
	fi

	echo ${declared_func}
}

# @FUNCTION: multilib-xlibs_src_prepare_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_configure.
# @DESCRIPTION:
multilib-xlibs_src_prepare_internal() {
	[[ "${ECLASS_DEBUG}" == "yes" ]] && einfo "Using $(multilib-xlibs_check_inherited_funcs src_prepare) ..."
	$(multilib-xlibs_check_inherited_funcs src_prepare)
}

# @FUNCTION: multilib-xlibs_src_configure_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_configure.
# @DESCRIPTION:
multilib-xlibs_src_configure_internal() {
	[[ "${ECLASS_DEBUG}" == "yes" ]] && einfo "Using $(multilib-xlibs_check_inherited_funcs src_configure) ..."
	$(multilib-xlibs_check_inherited_funcs src_configure)
}

# @FUNCTION: multilib-xlibs_src_compile_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_compile.
# @DESCRIPTION:
multilib-xlibs_src_compile_internal() {
	[[ "${ECLASS_DEBUG}" == "yes" ]] && einfo "Using $(multilib-xlibs_check_inherited_funcs src_compile) ..."
	$(multilib-xlibs_check_inherited_funcs src_compile)
}

# @FUNCTION: multilib-xlibs_src_install_internal
# @USAGE: override this function if you arent using x-modules eclass and want to use a custom src_install
# @DESCRIPTION:
multilib-xlibs_src_install_internal() {
	[[ "${ECLASS_DEBUG}" == "yes" ]] && einfo "Using $(check_inherited_funcs src_install) ..."
	$(multilib-xlibs_check_inherited_funcs src_install)
}

multilib-xlibs_pkg_postinst_internal() {
	:;	
}

multilib-xlibs_pkg_postrm_internal() {
	:;
}
