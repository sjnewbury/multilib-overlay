# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/acl/acl-2.2.47-r1.ebuild,v 1.2 2009/12/29 01:39:03 abcd Exp $

EAPI="2"

inherit eutils autotools toolchain-funcs multilib-native

MY_P="${PN}_${PV}-1"
DESCRIPTION="Access control list utilities, libraries and headers"
HOMEPAGE="http://oss.sgi.com/projects/xfs/"
SRC_URI="ftp://oss.sgi.com/projects/xfs/download/cmd_tars/${MY_P}.tar.gz
	ftp://xfs.org/mirror/SGI/cmd_tars/${MY_P}.tar.gz
	nfs? ( http://www.citi.umich.edu/projects/nfsv4/linux/acl-patches/2.2.42-2/acl-2.2.42-CITI_NFS4_ALL-2.dif )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="nfs nls"

RDEPEND=">=sys-apps/attr-2.4[lib32?]
	nfs? ( net-libs/libnfsidmap )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext[lib32?] )"

multilib-native_src_prepare_internal() {
	if use nfs ; then
		cp "${DISTDIR}"/acl-2.2.42-CITI_NFS4_ALL-2.dif . || die
		sed -i '/^diff --git a.debian.changelog b.debian.changelog/,/^diff --git/d' acl-2.2.42-CITI_NFS4_ALL-2.dif || die
		epatch acl-2.2.42-CITI_NFS4_ALL-2.dif
	fi
	epatch \
		"${FILESDIR}"/0001-Introduce-new-WALK_TREE_DEREFERENCE_TOPLEVEL-flag.patch \
		"${FILESDIR}"/0001-Make-sure-that-getfacl-R-only-calls-stat-2-on-symlin.patch #265425
	epatch "${FILESDIR}"/${PN}-2.2.45-libtool.patch #158068
	epatch "${FILESDIR}"/${PN}-2.2.45-linguas.patch #205948
	epatch "${FILESDIR}"/${PN}-2.2.32-only-symlink-when-needed.patch
	epatch "${FILESDIR}"/${P}-search-PATH.patch
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

multilib-native_src_configure_internal() {
	use prefix || EPREFIX=
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir) \
		--bindir="${EPREFIX}"/bin
}

multilib-native_src_install_internal() {
	emake DIST_ROOT="${D}" install install-dev install-lib || die
	prepalldocs

	# move shared libs to /
	gen_usr_ldscript -a acl
}
