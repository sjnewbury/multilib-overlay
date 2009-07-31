# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/e2fsprogs-libs/e2fsprogs-libs-1.41.8.ebuild,v 1.3 2009/07/20 10:02:49 vapier Exp $

EAPI="2"

inherit flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="e2fsprogs libraries (common error and subsystem)"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="nls"

RDEPEND="elibc_glibc? ( >=sys-libs/glibc-2.6 )
	!sys-libs/com_err
	!sys-libs/ss
	!<sys-fs/e2fsprogs-1.41.8"
DEPEND="nls? ( sys-devel/gettext )
	dev-util/pkgconfig[lib32?]
	sys-devel/bc"

ml-native_src_prepare() {
	# stupid configure script clobbers CC for us
	sed -i '/if test -z "$CC" ; then CC=cc; fi/d' configure
}

ml-native_src_configure() {
	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	# we use blkid/uuid from util-linux now
	ac_cv_lib_uuid_uuid_generate=yes \
	ac_cv_lib_blkid_blkid_get_cache=yes \
	ac_cv_path_LDCONFIG=: \
	econf \
		--disable-libblkid \
		--disable-libuuid \
		--enable-${libtype}-shlibs \
		$(use_enable !elibc_uclibc tls) \
		$(use_enable nls)
}

ml-native_src_install() {
	emake STRIP=: DESTDIR="${D}" install || die

	set -- "${D}"/usr/$(get_libdir)/*.a
	set -- ${@/*\/lib}
	gen_usr_ldscript -a "${@/.a}"
}
