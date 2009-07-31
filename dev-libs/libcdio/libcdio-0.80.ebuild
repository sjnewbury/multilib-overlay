# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcdio/libcdio-0.80.ebuild,v 1.13 2008/11/27 18:49:00 jer Exp $

EAPI="2"

inherit eutils libtool multilib autotools multilib-native

DESCRIPTION="A library to encapsulate CD-ROM reading and control"
HOMEPAGE="http://www.gnu.org/software/libcdio/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc ~sparc-fbsd x86 ~x86-fbsd"
IUSE="cddb minimal +cxx"

RDEPEND="cddb? ( >=media-libs/libcddb-1.0.1[lib32?] )
	virtual/libintl"
DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/pkgconfig[lib32?]"

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${P}-minimal.patch
	epatch "${FILESDIR}"/${P}-fix-pkgconfig.patch
	epatch "${FILESDIR}"/${P}-fbsd.patch

	sed -i -e 's:noinst_PROGRAMS:EXTRA_PROGRAMS:' test/Makefile.am \
		|| die "unable to remove testdefault build"

	# Fix building against libiconv
	sed -i -e 's:@LIBICONV@:$(LTLIBICONV):' lib/driver/Makefile.am \
		|| die "unable to fix libiconv link - part 1"

	find . -name Makefile.am -print0 | xargs -0 \
		sed -i -e 's:$(LIBICONV):$(LTLIBICONV):' \
		|| die "unable to fix libiconv link - part 2"

	eautomake
	elibtoolize
}

ml-native_src_configure() {
	econf \
		$(use_enable cddb) \
		$(use_with !minimal cd-drive) \
		$(use_with !minimal cd-info) \
		$(use_with !minimal cd-paranoia) \
		$(use_with !minimal cdda-player) \
		$(use_with !minimal cd-read) \
		$(use_with !minimal iso-info) \
		$(use_with !minimal iso-read) \
		$(use_enable cxx) \
		--disable-example-progs --disable-cpp-progs \
		--with-cd-paranoia-name=libcdio-paranoia \
		--disable-vcd-info \
		--disable-dependency-tracking \
		--disable-maintainer-mode || die "configure failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS
}

pkg_postinst() {
	ewarn "If you've upgraded from a previous version of ${PN}, you may need to re-emerge"
	ewarn "packages that linked against ${PN} (vlc, vcdimager and more) by running:"
	ewarn "\trevdep-rebuild"
}
