# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libasyncns/libasyncns-0.7.ebuild,v 1.2 2009/01/25 11:34:19 armin76 Exp $

inherit libtool flag-o-matic multilib-native

DESCRIPTION="C library for executing name service queries asynchronously."
HOMEPAGE="http://0pointer.de/lennart/projects/libasyncns/"
SRC_URI="http://0pointer.de/lennart/projects/libasyncns/${P}.tar.gz"

SLOT="0"

LICENSE="LGPL-2.1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"

IUSE="doc debug"

RDEPEND=""
DEPEND="doc? ( app-doc/doxygen )"

multilib-native_src_unpack_internal() {
	unpack ${A}

	elibtoolize
}

multilib-native_src_compile_internal() {
	# libasyncns uses assert()
	use debug || append-flags -DNDEBUG

	econf \
		--docdir=/usr/share/doc/${PF} \
		--htmldir=/usr/share/doc/${PF}/html \
		--disable-dependency-tracking \
		--disable-lynx \
		|| die "econf failed"
	emake || die "emake failed"

	if use doc; then
		doxygen doxygen/doxygen.conf || die "doxygen failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	if use doc; then
		docinto apidocs
		dohtml html/*
	fi
}
