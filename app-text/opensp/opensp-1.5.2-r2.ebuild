# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/opensp/opensp-1.5.2-r2.ebuild,v 1.8 2011/01/07 21:31:47 xarthisius Exp $

EAPI=2
inherit eutils flag-o-matic multilib-native

MY_P=${P/opensp/OpenSP}
DESCRIPTION="A free, object-oriented toolkit for SGML parsing and entity management"
HOMEPAGE="http://openjade.sourceforge.net/"
SRC_URI="mirror://sourceforge/openjade/${MY_P}.tar.gz"

LICENSE="JamesClark"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="doc nls static-libs"

DEPEND="nls? ( >=sys-devel/gettext-0.14.5[lib32?] )
	doc? (
		app-text/xmlto
		~app-text/docbook-xml-dtd-4.1.2
	)"
RDEPEND=""

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.5-gcc34.patch
}

multilib-native_src_configure_internal() {
	#
	# The following filters are taken from openjade's ebuild. See bug #100828.
	#

	# Please note!  Opts are disabled.  If you know what you're doing
	# feel free to remove this line.  It may cause problems with
	# docbook-sgml-utils among other things.
	ALLOWED_FLAGS="-O -O1 -O2 -pipe -g -march"
	strip-flags

	econf \
		--disable-dependency-tracking \
		--enable-http \
		--enable-default-catalog=/etc/sgml/catalog   \
		--enable-default-search-path=/usr/share/sgml \
		--datadir=/usr/share/sgml/${P}               \
		$(use_enable nls) \
		$(use_enable doc doc-build) \
		$(use_enable static-libs static)
}

multilib-native_src_compile_internal() {
	emake pkgdocdir=/usr/share/doc/${PF} || die "Compilation failed"
}

src_test() {
	echo ">>> Test phase [check]: ${CATEGORY}/${PF}"
	einfo "Skipping tests known not to work"
	make SHOWSTOPPERS= check || die "Make test failed"
	SANDBOX_PREDICT="${SANDBOX_PREDICT%:/}"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" \
		pkgdocdir=/usr/share/doc/${PF} install || die "Installation failed"

	dodoc AUTHORS BUGS ChangeLog NEWS README
}

multilib-native_pkg_postinst_internal() {
	ewarn "Please note that the soname of the library changed."
	ewarn "If you are upgrading from a previous version you need"
	ewarn "to fix dynamic linking inconsistencies by executing:"
	ewarn
	ewarn "    revdep-rebuild --library='libosp.so.*'"
}
