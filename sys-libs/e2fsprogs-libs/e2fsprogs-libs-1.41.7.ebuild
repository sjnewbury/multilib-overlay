# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/e2fsprogs-libs/e2fsprogs-libs-1.41.7.ebuild,v 1.4 2010/12/04 21:51:20 vapier Exp $

EAPI="2"

inherit flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="e2fsprogs libraries (common error, subsystem, uuid, block id)"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="nls elibc_glibc"

RDEPEND="elibc_glibc? ( >=sys-libs/glibc-2.6 )
	!sys-libs/com_err
	!sys-libs/ss
	!<sys-fs/e2fsprogs-1.41"
DEPEND="nls? ( sys-devel/gettext[lib32?] )
	dev-util/pkgconfig[lib32?]"

multilib-native_src_prepare_internal() {
	# stupid configure script clobbers CC for us
	sed -i '/if test -z "$CC" ; then CC=cc; fi/d' configure
}

multilib-native_src_configure_internal() {
	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	ac_cv_path_LDCONFIG=: \
	econf \
		--enable-${libtype}-shlibs \
		$(tc-has-tls || echo --disable-tls) \
		$(use_enable nls)
}

multilib-native_src_install_internal() {
	emake STRIP=: DESTDIR="${D}" install || die

	set -- "${D}"/usr/$(get_libdir)/*.a
	set -- ${@/*\/lib}
	gen_usr_ldscript -a "${@/.a}"
}
