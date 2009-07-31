# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/attr/attr-2.4.43.ebuild,v 1.8 2009/03/14 12:31:23 vapier Exp $

EAPI="2"

inherit eutils autotools toolchain-funcs multilib-native

MY_P="${PN}_${PV}-1"
DESCRIPTION="Extended attributes tools"
HOMEPAGE="http://oss.sgi.com/projects/xfs/"
SRC_URI="ftp://oss.sgi.com/projects/xfs/download/cmd_tars/${MY_P}.tar.gz
	ftp://xfs.org/mirror/SGI/cmd_tars/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext[lib32?] )
	sys-devel/autoconf"
RDEPEND=""

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.4.39-gettext.patch
	epatch "${FILESDIR}"/${PN}-2.4.43-linguas.patch #205948
	epatch "${FILESDIR}"/${PN}-2.4.24-only-symlink-when-needed.patch
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		-e '/HAVE_ZIPPED_MANPAGES/s:=.*:=false:' \
		include/builddefs.in \
		|| die "failed to update builddefs"
	# libtool will clobber install-sh which is really a custom file
	mv install-sh acl.install-sh || die
	AT_M4DIR="m4" eautoreconf
	mv acl.install-sh install-sh || die
	strip-linguas po
}

ml-native_src_configure() {
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--libexecdir=/usr/$(get_libdir) \
		--bindir=/bin \
		|| die
}

ml-native_src_install() {
	emake DIST_ROOT="${D}" install install-lib install-dev || die
	# the man-pages packages provides the man2 files
	rm -r "${D}"/usr/share/man/man2
	prepalldocs

	# move shared libs to /
	dodir /$(get_libdir)
	mv "${D}"/usr/$(get_libdir)/libattr.so* "${D}"/$(get_libdir)/ || die
	gen_usr_ldscript libattr.so
}
