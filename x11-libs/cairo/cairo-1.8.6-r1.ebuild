# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/cairo/cairo-1.8.6-r1.ebuild,v 1.7 2009/03/27 17:03:18 armin76 Exp $

EAPI="2"

inherit eutils flag-o-matic libtool multilib-native

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="http://cairographics.org/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="cleartype debug directfb doc glitz opengl svg X xcb"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

RDEPEND="media-libs/fontconfig[$(get_ml_usedeps)?]
	>=media-libs/freetype-2.1.9[$(get_ml_usedeps)?]
	sys-libs/zlib[$(get_ml_usedeps)?]
	media-libs/libpng[$(get_ml_usedeps)?]
	>=x11-libs/pixman-0.12.0[$(get_ml_usedeps)?]
	directfb? ( >=dev-libs/DirectFB-0.9.24 )
	glitz? ( >=media-libs/glitz-0.5.1[$(get_ml_usedeps)?] )
	svg? ( dev-libs/libxml2 )
	X? ( 	>=x11-libs/libXrender-0.6[$(get_ml_usedeps)?]
		x11-libs/libXext[$(get_ml_usedeps)?]
		x11-libs/libX11[$(get_ml_usedeps)?]
		x11-libs/libXft[$(get_ml_usedeps)?] )
	xcb? (	>=x11-libs/libxcb-0.92[$(get_ml_usedeps)?]
		x11-libs/xcb-util[$(get_ml_usedeps)?] )"
#	test? (
#	pdf test
#	x11-libs/pango
#	>=x11-libs/gtk+-2.0
#	>=app-text/poppler-bindings-0.9.2
#	ps test
#	virtual/ghostscript
#	svg test
#	>=x11-libs/gtk+-2.0
#	>=gnome-base/librsvg-2.15.0

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19[$(get_ml_usedeps)?]
	doc? (	>=dev-util/gtk-doc-1.6
		~app-text/docbook-xml-dtd-4.2 )
	X? ( x11-proto/renderproto )
	xcb? ( x11-proto/xcb-proto )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-1.8.6-status-return-fix.patch
	# ClearType-like patches applied by ArchLinux
	use cleartype && epatch "${FILESDIR}"/cairo-1.2.4-lcd-cleartype-like.diff

	# We need to run elibtoolize to ensure correct so versioning on FreeBSD
	elibtoolize
}

ml-native_src_configure() {
	#gets rid of fbmmx.c inlining warnings
	append-flags -finline-limit=1200

	if use glitz && use opengl; then
		export glitz_LIBS=$(pkg-config --libs glitz-glx)
	fi

	local myconf
	if use lib32 && ! is_final_abi; then
		myconf="--enable-directfb=no"
	else
		myconf="$(use_enable directfb)"
	fi

	econf $(use_enable X xlib) $(use_enable doc gtk-doc) \
		$(use_enable directfb) $(use_enable xcb) \
		${myconf} \
		$(use_enable svg) $(use_enable glitz) $(use_enable X xlib-xrender) \
		$(use_enable debug test-surfaces) --enable-pdf  --enable-png \
		--enable-ft --enable-ps \
		|| die "configure failed"
}

ml-native_src_install() {
	make DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	if use xcb; then
		ewarn "You have enabled the Cairo XCB backend which is used only by"
		ewarn "a select few apps. The Cairo XCB backend is presently"
		ewarn "un-maintained and needs a lot of work to get it caught up"
		ewarn "to the Xrender and Xlib backends, which are the backends used"
		ewarn "by most applications. See:"
		ewarn "http://lists.freedesktop.org/archives/xcb/2008-December/004139.html"
	fi
}
