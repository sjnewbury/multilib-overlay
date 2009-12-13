# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/e2fsprogs-libs/e2fsprogs-libs-1.41.3-r1.ebuild,v 1.4 2009/12/01 04:49:06 vapier Exp $

EAPI="2"

inherit flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="e2fsprogs libraries (common error, subsystem, uuid, block id)"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="nls"

RDEPEND="!sys-libs/com_err
	!sys-libs/ss
	!<sys-fs/e2fsprogs-1.41"
DEPEND="nls? ( sys-devel/gettext )
	dev-util/pkgconfig[lib32?]
	sys-devel/bc"

multilib-native_src_configure_internal() {
	export LDCONFIG=/bin/true
	export CC=$(tc-getCC)

	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	econf \
		--enable-${libtype}-shlibs \
		$(tc-has-tls || echo --disable-tls) \
		$(use_enable nls) \
		|| die

}

multilib-native_src_compile_internal() {
	export LDCONFIG=/bin/true
	export CC=$(tc-getCC)
	emake STRIP=/bin/true || die
}

multilib-native_src_install_internal() {
	export LDCONFIG=/bin/true
	export CC=$(tc-getCC)

	emake STRIP=/bin/true DESTDIR="${D}" install || die

	dodir /$(get_libdir)
	local lib slib
	for lib in "${D}"/usr/$(get_libdir)/*.a ; do
		slib=${lib##*/}
		mv "${lib%.a}"$(get_libname)* "${D}"/$(get_libdir)/ || die "moving lib ${slib}"
		gen_usr_ldscript ${slib%.a}$(get_libname)
	done
}
