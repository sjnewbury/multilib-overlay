# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/libarchive/libarchive-2.8.4-r1.ebuild,v 1.6 2011/03/27 14:34:31 klausman Exp $

EAPI="2"

inherit eutils libtool toolchain-funcs flag-o-matic multilib-native

DESCRIPTION="BSD tar command"
HOMEPAGE="http://code.google.com/p/libarchive/"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz
	http://people.freebsd.org/~kientzle/libarchive/src/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~mips ppc ppc64 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="static static-libs acl xattr kernel_linux +bzip2 +lzma +zlib expat"

COMPRESS_LIBS_DEPEND="lzma? ( app-arch/xz-utils[lib32?] )
		bzip2? ( app-arch/bzip2[lib32?] )
		zlib? ( sys-libs/zlib[lib32?] )"

RDEPEND="!dev-libs/libarchive
	dev-libs/openssl[lib32?]
	!expat? ( dev-libs/libxml2[lib32?] )
	expat? ( dev-libs/expat[lib32?] )
	acl? ( virtual/acl[lib32?] )
	xattr? ( kernel_linux? ( sys-apps/attr[lib32?] ) )
	!static? ( ${COMPRESS_LIBS_DEPEND} )"
DEPEND="${RDEPEND}
	${COMPRESS_LIBS_DEPEND}
	kernel_linux? ( sys-fs/e2fsprogs[lib32?]
		virtual/os-headers )"

multilib-native_src_prepare_internal() {
	epatch "$FILESDIR"/libarchive-disable-lzma-size-test.patch
	elibtoolize
	epunt_cxx
}

multilib-native_src_configure_internal() {
	local myconf

	if ! use static ; then
		myconf="--enable-bsdtar=shared --enable-bsdcpio=shared"
	fi

	# force static libs for static binaries
	if use static && ! use static-libs; then
		myconf="${myconf} --enable-static"
	fi

	# Check for need of this in 2.7.1 and later, on 2.7.0, -Werror was
	# added to the final release, but since it's done in the
	# Makefile.am we can just work it around this way.
	append-flags -Wno-error

	# We disable lzmadec because we support the newer liblzma from xz-utils
	# and not liblzmadec with this version.
	econf --bindir=/bin \
		--enable-bsdtar --enable-bsdcpio \
		$(use_enable acl) $(use_enable xattr) \
		$(use_with zlib) \
		$(use_with bzip2 bz2lib) $(use_with lzma) \
		$(use_enable static-libs static) \
		$(use_with expat expat) \
		$(use_with !expat xml2) \
		--without-lzmadec \
		${myconf} \
		--disable-dependency-tracking
}

src_test() {
	# Replace the default src_test so that it builds tests in parallel
	emake check || die "tests failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."

	# remove useless .a and .la files (only for non static compilation)
	use static-libs || find "${D}" \( -name '*.a' -or -name '*.la' \) -delete

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
