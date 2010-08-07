# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/pkgconfig/pkgconfig-0.25-r2.ebuild,v 1.3 2010/08/06 12:16:58 fauli Exp $

EAPI=2
inherit eutils flag-o-matic multilib-native

MY_P=pkg-config-${PV}

DESCRIPTION="Package config system that manages compile/link flags"
HOMEPAGE="http://pkgconfig.freedesktop.org/wiki/"
SRC_URI="http://pkgconfig.freedesktop.org/releases/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="elibc_FreeBSD hardened"

DEPEND=">=dev-libs/popt-1.15[lib32?]"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-dnl.patch
}

multilib-native_src_configure_internal() {
	use ppc64 && use hardened && replace-flags -O[2-3] -O1

	# Force using all the requirements when linking, so that needed -pthread
	# lines are inherited between libraries
	local myconf
	use elibc_FreeBSD && myconf="--enable-indirect-deps"

	# adjust the default pc search path
	if [[ -n EMULTILIB_PKG ]]; then
		local pc_path="/usr/$(get_libdir)/pkgconfig"
		local abi
		for abi in ${MULTILIB_ABIS}; do
			if [[ "$(get_libdir)" != "$(get_abi_LIBDIR ${abi})" ]]; then
				pc_path="${pc_path}:/usr/$(get_abi_LIBDIR ${abi})/pkgconfig"
			fi
		done
		pc_path="${pc_path}:/usr/share/pkgconfig"
		myconf="${myconf} --with-pc-path=${pc_path}"
	fi

	econf \
		--docdir=/usr/share/doc/${PF}/html \
		--with-installed-popt \
		${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README

	prep_ml_binaries /usr/bin/pkg-config
}
