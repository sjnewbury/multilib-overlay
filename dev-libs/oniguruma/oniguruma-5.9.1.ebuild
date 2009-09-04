# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/oniguruma/oniguruma-5.9.1.ebuild,v 1.14 2008/06/12 13:32:41 drac Exp $

inherit libtool multilib-native

MY_P=onig-${PV}

DESCRIPTION="a regular expression library for different character encodings"
HOMEPAGE="http://www.geocities.jp/kosako3/oniguruma"
SRC_URI="http://www.geocities.jp/kosako3/oniguruma/archive/${MY_P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ~ppc ppc64 sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE=""

S=${WORKDIR}/${MY_P}

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	# Needed for a sane .so versionning on fbsd, please dont drop
	elibtoolize
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS HISTORY README* doc/*

	prep_ml_binaries /usr/bin/onig-config
}
