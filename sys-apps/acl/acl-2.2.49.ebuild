# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/acl/acl-2.2.49.ebuild,v 1.1 2010/01/09 03:02:04 vapier Exp $

EAPI="2"

inherit eutils toolchain-funcs multilib-native

DESCRIPTION="access control list utilities, libraries and headers"
HOMEPAGE="http://savannah.nongnu.org/projects/acl"
SRC_URI="http://download.savannah.gnu.org/releases/${PN}/${P}.src.tar.gz
	nfs? ( http://www.citi.umich.edu/projects/nfsv4/linux/acl-patches/2.2.42-2/acl-2.2.42-CITI_NFS4_ALL-2.dif )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="nfs nls"

RDEPEND=">=sys-apps/attr-2.4[lib32?]
	nfs? ( net-libs/libnfsidmap[lib32?] )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext[lib32?] )"

src_unpack() {
	unpack ${P}.src.tar.gz
}

multilib-native_src_prepare_internal() {
	cd "${S}"
	if use nfs ; then
		cp "${DISTDIR}"/acl-2.2.42-CITI_NFS4_ALL-2.dif . || die
		sed -i \
			-e '/^diff --git a.debian.changelog b.debian.changelog/,/^diff --git/d' \
			acl-2.2.42-CITI_NFS4_ALL-2.dif || die
		epatch acl-2.2.42-CITI_NFS4_ALL-2.dif
	fi
	epatch "${FILESDIR}"/${P}-quote-strchr.patch
	sed -i \
		-e '/^as_dummy=/s:=":="$PATH$PATH_SEPARATOR:' \
		configure # hack PATH with AC_PATH_PROG
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
		--bindir=/bin \
		|| die
}

multilib-native_src_install_internal() {
	emake DIST_ROOT="${D}" install install-dev install-lib || die
	prepalldocs

	# move shared libs to /
	dodir /$(get_libdir)
	mv "${D}"/usr/$(get_libdir)/libacl.so* "${D}"/$(get_libdir)/ || die
	gen_usr_ldscript libacl.so
}
