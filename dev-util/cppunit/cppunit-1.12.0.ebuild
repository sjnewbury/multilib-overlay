# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cppunit/cppunit-1.12.0.ebuild,v 1.16 2008/07/27 20:18:05 carlo Exp $

EAPI=1

WANT_AUTOCONF=latest
WANT_AUTOMAKE=1.9

inherit eutils autotools qt3 multilib-native

DESCRIPTION="C++ port of the famous JUnit framework for unit testing"
HOMEPAGE="http://cppunit.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd"
IUSE="doc examples qt3"

RDEPEND="qt3? ( x11-libs/qt:3 )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen
	media-gfx/graphviz )"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.10.2-asneeded.patch"
	epatch "${FILESDIR}/${P}-add_missing_include.patch"

	sed -i \
		-e 's|-L\($${CPPUNIT_LIB_DIR}\)|\1|' \
		-e 's|\(../../lib\)|-L\1 -L../../src/cppunit/.libs|' \
		examples/qt/qt_example.pro || die "sed failed"

	AT_M4DIR="${S}/config"
	eautomake
	elibtoolize
}

multilib-native_src_compile_internal() {
	# Anything else than -O0 breaks on alpha
	use alpha && replace-flags "-O?" -O0

	econf \
		$(use_enable doc doxygen) \
		$(use_enable doc dot) \
		--htmldir=/usr/share/doc/${PF}/html \
		|| die "econf failed"
	emake || die "emake failed"

	if use qt3 ; then
		cd src/qttestrunner
		eqmake3 qttestrunnerlib.pro || die "qmake failed"
		emake || die "emake failed"
		if use examples ; then
			cd "${S}/examples/qt"
			eqmake3 qt_example.pro || die "qmake failed"
			emake || die "emake failed"
		fi
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS NEWS README THANKS TODO doc/FAQ

	if use qt3 ; then
		dolib lib/*
	fi

	if use examples ; then
		insinto /usr/share/${PN}
		doins -r examples
	fi
}
