# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/popt/popt-1.10.7.ebuild,v 1.13 2009/03/23 18:11:03 jsbronder Exp $

inherit eutils multilib-native

DESCRIPTION="Parse Options - Command line parser"
HOMEPAGE="http://www.rpm.org/"
SRC_URI="ftp://jbj.org/pub/rpm-4.4.x/${P}.tar.gz"

LICENSE="popt"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.10.4-regression.patch
	epatch "${FILESDIR}"/${PN}-1.10.4-lib64.patch
	epatch "${FILESDIR}"/${PN}-1.10.7-scrub-lame-gettext.patch
}

multilib-native_src_compile_internal() {
	econf \
		--without-included-gettext \
		$(use_enable nls) \
		|| die
	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die
	dodoc CHANGES README
}
