# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/cairo/cairo-1.8.10.ebuild,v 1.10 2011/03/07 17:22:33 ssuominen Exp $

EAPI=2

inherit eutils flag-o-matic autotools multilib-native

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="http://cairographics.org/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz
	mirror://gentoo/${PN}-1.8-lcd_filter.patch.bz2"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="aqua cleartype debug directfb doc lcdfilter opengl +svg X xcb"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

RDEPEND="media-libs/fontconfig[lib32?]
	>=media-libs/freetype-2.1.9[lib32?]
	sys-libs/zlib[lib32?]
	>=media-libs/libpng-1.2.43-r2:0[lib32?]
	>=x11-libs/pixman-0.12.0[lib32?]
	directfb? ( >=dev-libs/DirectFB-0.9.24[lib32?] )
	svg? ( dev-libs/libxml2[lib32?] )
	X? ( 	>=x11-libs/libXrender-0.6[lib32?]
		x11-libs/libXext[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXft[lib32?] )
	xcb? (	>=x11-libs/libxcb-0.92[lib32?]
		x11-libs/xcb-util[lib32?] )"
#	test? (
#	pdf test
#	x11-libs/pango
#	>=x11-libs/gtk+-2.0
#	>=app-text/poppler-bindings-0.9.2[gtk]
#	ps test
#	app-text/ghostscript-gpl
#	svg test
#	>=x11-libs/gtk+-2.0
#	>=gnome-base/librsvg-2.15.0

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19[lib32?]
	>=sys-devel/libtool-2[lib32?]
	doc? (	>=dev-util/gtk-doc-1.6
		~app-text/docbook-xml-dtd-4.2 )
	X? ( x11-proto/renderproto )"

multilib-native_src_prepare_internal() {
	if use lcdfilter; then
		# LCD filter patch from Ubuntu, taken from:
		# http://bazaar.launchpad.net/%7Eubuntu-branches/ubuntu/lucid/cairo/lucid/files/head%3A/debian/patches/
		epatch "${WORKDIR}"/${PN}-1.8-lcd_filter.patch
	elif use cleartype; then
		# ClearType-like patches applied by ArchLinux
		epatch "${FILESDIR}"/${PN}-1.2.4-lcd-cleartype-like.diff
	fi

	epatch "${FILESDIR}"/${PN}-1.8.8-interix.patch \
		"${FILESDIR}"/${P}-libpng14.patch

	# We need to run elibtoolize to ensure correct so versioning on FreeBSD
	# upgraded to an eautoreconf for the above interix patch.
	eautoreconf
}

multilib-native_src_configure_internal() {
	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT
	# http://bugs.freedesktop.org/show_bug.cgi?id=15463
	[[ ${CHOST} == *-solaris* ]] && append-flags -D_POSIX_PTHREAD_SEMANTICS

	#gets rid of fbmmx.c inlining warnings
	append-flags -finline-limit=1200

	econf $(use_enable X xlib) $(use_enable doc gtk-doc) \
		$(use_enable directfb) $(use_enable xcb) \
		$(use_enable svg) --disable-glitz $(use_enable X xlib-xrender) \
		$(use_enable debug test-surfaces) --enable-pdf  --enable-png \
		--enable-ft --enable-ps \
		$(use_enable aqua quartz) $(use_enable aqua quartz-image) \
		|| die "configure failed"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog NEWS README
}

multilib-native_pkg_postinst_internal() {
	if use xcb; then
		ewarn "You have enabled the Cairo XCB backend which is used only by"
		ewarn "a select few apps. The Cairo XCB backend is presently"
		ewarn "un-maintained and needs a lot of work to get it caught up"
		ewarn "to the Xrender and Xlib backends, which are the backends used"
		ewarn "by most applications. See:"
		ewarn "http://lists.freedesktop.org/archives/xcb/2008-December/004139.html"
	fi
}
