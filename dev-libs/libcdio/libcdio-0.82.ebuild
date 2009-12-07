# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcdio/libcdio-0.82.ebuild,v 1.1 2009/10/27 15:08:00 flameeyes Exp $

EAPI="2"

inherit eutils libtool multilib autotools multilib-native

DESCRIPTION="A library to encapsulate CD-ROM reading and control"
HOMEPAGE="http://www.gnu.org/software/libcdio/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="cddb minimal +cxx"

RDEPEND="cddb? ( >=media-libs/libcddb-1.0.1[lib32?] )
	virtual/libintl"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	dev-util/pkgconfig[lib32?]"

multilib-native_src_prepare_internal() {
	eautomake
	elibtoolize
}

multilib-native_src_configure_internal() {
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

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS
}

pkg_postinst() {
	ewarn "If you've upgraded from a previous version of ${PN}, you may need to re-emerge"
	ewarn "packages that linked against ${PN} (vlc, vcdimager and more) by running:"
	ewarn "\trevdep-rebuild"
}
