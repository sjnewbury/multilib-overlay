# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libexif/libexif-0.6.17.ebuild,v 1.7 2009/02/06 20:10:42 jer Exp $

EAPI=2

inherit eutils libtool multilib-native

DESCRIPTION="Library for parsing, editing, and saving EXIF data"
HOMEPAGE="http://libexif.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc nls"

DEPEND="dev-util/pkgconfig[lib32?]
	doc? ( app-doc/doxygen )
	nls? ( sys-devel/gettext[lib32?] )"

RDEPEND="nls? ( virtual/libintl )"

multilib-native_src_unpack_internal() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.6.13-pkgconfig.patch"

	# We do this for sane .so versioning on FreeBSD
	elibtoolize
}

multilib-native_src_compile_internal() {
	local my_conf="--with-doc-dir=/usr/share/doc/${PF}"
	use nls || my_conf="${my_conf} --without-libintl-prefix"
	econf $(use_enable nls) $(use_enable doc docs) \
		--with-pic --disable-rpath ${my_conf} || die
	emake || die
}

multilib-native_src_install_internal() {
	dodir /usr/$(get_libdir)
	dodir /usr/include/libexif
	use nls && dodir /usr/share/locale
	use doc && dodir /usr/share/doc/${PF}
	dodir /usr/$(get_libdir)/pkgconfig

	make DESTDIR="${D}" install || die

	dodoc ChangeLog README

	# installs a blank directory for whatever broken reason
	use nls || rm -rf "${D}usr/share/locale"
}

pkg_preinst() {
	has_version "<${CATEGORY}/${PN}-0.6.13-r2"
	previous_less_than_0_6_13_r2=$?
}

pkg_postinst() {
	if [[ $previous_less_than_0_6_13_r2 = 0 ]] ; then
		elog "If you are upgrading from a version of libexif older than 0.6.13-r2,"
		elog "you will need to do the following to rebuild dependencies:"
		elog "# revdep-rebuild --soname libexif.so.9"
		elog "# revdep-rebuild --soname libexif.so.10"
		elog ""
		elog "Note, it is actually safe to create a symlink from libexif.so.10 to"
		elog "libexif.so.12 if you need to during the update."
	fi
}
