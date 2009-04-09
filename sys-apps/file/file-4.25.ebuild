# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/file/file-4.25.ebuild,v 1.1 2008/07/17 20:06:49 cardoe Exp $

EAPI="2"

inherit eutils distutils libtool flag-o-matic multilib-native

DESCRIPTION="identify a file's format by scanning binary data for patterns"
HOMEPAGE="ftp://ftp.astron.com/pub/file/"
SRC_URI="ftp://ftp.astron.com/pub/file/${P}.tar.gz
	ftp://ftp.gw.com/mirrors/pub/unix/file/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="python"

DEPEND="python? ( dev-lang/python[lib32?] )"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-4.15-libtool.patch #99593

	elibtoolize
	epunt_cxx

	# make sure python links against the current libmagic #54401
	sed -i "/library_dirs/s:'\.\./src':'../src/.libs':" python/setup.py

	# dont let python README kill main README #60043
	mv python/README{,.python}
}

src_configure() { :; }

multilib-native_src_compile_internal() {
	# file uses things like strndup() and wcwidth()
	append-flags -D_GNU_SOURCE

	econf --datadir=/usr/share/misc || die
	emake || die "emake failed"

	use python && cd python && distutils_src_compile
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc ChangeLog MAINT README

	use python && cd python && distutils_src_install
}

pkg_postinst() {
	use python && distutils_pkg_postinst
}

pkg_postrm() {
	use python && distutils_pkg_postrm
}
