# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/libarchive/libarchive-2.6.2.ebuild,v 1.8 2009/04/27 13:51:00 jer Exp $

EAPI=2

inherit eutils libtool toolchain-funcs multilib-native

DESCRIPTION="BSD tar command"
HOMEPAGE="http://people.freebsd.org/~kientzle/libarchive"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz
	http://people.freebsd.org/~kientzle/libarchive/src/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="static acl xattr kernel_linux +bzip2 +lzma +zlib"

COMPRESS_LIBS_DEPEND="lzma? ( app-arch/lzma-utils[lib32?] )
		bzip2? ( app-arch/bzip2[lib32?] )
		zlib? ( sys-libs/zlib[lib32?] )"

RDEPEND="!dev-libs/libarchive
	kernel_linux? (
		acl? ( sys-apps/acl[lib32?] )
		xattr? ( sys-apps/attr[lib32?] )
	)
	!static? ( ${COMPRESS_LIBS_DEPEND} )"
DEPEND="${RDEPEND}
	${COMPRESS_LIBS_DEPEND}
	kernel_linux? ( sys-fs/e2fsprogs[lib32?]
		virtual/os-headers )"

multilib-native_src_prepare_internal() {
	elibtoolize
	epunt_cxx
}

multilib-native_src_configure_internal() {
	local myconf

	if ! use static ; then
		myconf="--enable-bsdtar=shared --enable-bsdcpio=shared"
	fi

	econf --bindir=/bin \
		--enable-bsdtar --enable-bsdcpio \
		$(use_enable acl) $(use_enable xattr) \
		$(use_with zlib) \
		$(use_with bzip2 bz2lib) $(use_with lzma lzmadec) \
		${myconf} \
		--disable-dependency-tracking || die "econf failed."
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."

	# Create tar symlink for FreeBSD
	if [[ ${CHOST} == *-freebsd* ]]; then
		dosym bsdtar /bin/tar
		dosym bsdtar.1 /usr/share/man/man1/tar.1
		# We may wish to switch to symlink bsdcpio to cpio too one day
	fi

	dodoc NEWS README
	dodir /$(get_libdir)
	mv "${D}"/usr/$(get_libdir)/*.so* "${D}"/$(get_libdir)
	gen_usr_ldscript libarchive.so
}
