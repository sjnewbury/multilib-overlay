# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/attr/attr-2.4.44.ebuild,v 1.7 2010/12/05 16:07:43 armin76 Exp $

EAPI="2"

inherit eutils toolchain-funcs multilib-native

DESCRIPTION="Extended attributes tools"
HOMEPAGE="http://savannah.nongnu.org/projects/attr"
SRC_URI="mirror://nongnu/${PN}/${P}.src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext[lib32?] )
	sys-devel/autoconf"
RDEPEND=""

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-2.4.44-gettext.patch
	epatch "${FILESDIR}"/${P}-headers.patch
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		-e '/HAVE_ZIPPED_MANPAGES/s:=.*:=false:' \
		include/builddefs.in \
		|| die "failed to update builddefs"
	strip-linguas po
}

multilib-native_src_configure_internal() {
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--libexecdir=/usr/$(get_libdir) \
		--bindir=/bin
}

multilib-native_src_install_internal() {
	emake DIST_ROOT="${D}" install install-lib install-dev || die
	# the man-pages packages provides the man2 files
	rm -r "${D}"/usr/share/man/man2
	prepalldocs

	# we install attr into /bin, so we need the shared lib with it
	gen_usr_ldscript -a attr
}
