# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/popt/popt-1.16-r1.ebuild,v 1.1 2010/12/24 22:41:58 mattst88 Exp $

EAPI=3

# For bug 349558, epatch
inherit eutils multilib-native

DESCRIPTION="Parse Options - Command line parser"
HOMEPAGE="http://rpm5.org/"
SRC_URI="http://rpm5.org/files/popt/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext[lib32?] )"

multilib-native_src_prepare_internal() {
	# For bug 349558
	epatch "${FILESDIR}"/fix-popt-pkgconfig-libdir.patch

	sed -i \
		-e 's:lt-test1:test1:' \
		testit.sh || die
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable nls)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc CHANGES README || die
}
