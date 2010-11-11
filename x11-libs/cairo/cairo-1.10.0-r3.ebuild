# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/cairo/cairo-1.10.0-r3.ebuild,v 1.3 2010/11/06 15:34:56 scarabeus Exp $

EAPI=3

EGIT_REPO_URI="git://anongit.freedesktop.org/git/cairo"
[[ ${PV} == *9999 ]] && GIT_ECLASS="git"

inherit eutils flag-o-matic autotools ${GIT_ECLASS} multilib-native

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="http://cairographics.org/"
[[ ${PV} == *9999 ]] || SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="X aqua debug directfb doc drm gallium opengl openvg qt4 static-libs +svg xcb"

# Test causes a circular depend on gtk+... since gtk+ needs cairo but test needs gtk+ so we need to block it
RESTRICT="test"

RDEPEND="media-libs/fontconfig[lib32?]
	media-libs/freetype:2[lib32?]
	media-libs/libpng:0[lib32?]
	sys-libs/zlib[lib32?]
	>=x11-libs/pixman-0.18.4[lib32?]
	directfb? ( dev-libs/DirectFB[lib32?] )
	opengl? ( virtual/opengl[lib32?] )
	openvg? ( media-libs/mesa[gallium,lib32?] )
	qt4? ( >=x11-libs/qt-gui-4.4:4[lib32?] )
	svg? ( dev-libs/libxml2[lib32?] )
	X? (
		>=x11-libs/libXrender-0.6[lib32?]
		x11-libs/libXext[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXft[lib32?]
		drm? (
			>=sys-fs/udev-136[lib32?]
			gallium? ( media-libs/mesa[gallium,lib32?] )
		)
	)
	xcb? (
		x11-libs/libxcb[lib32?]
		x11-libs/xcb-util[lib32?]
	)"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	>=sys-devel/libtool-2[lib32?]
	doc? (
		>=dev-util/gtk-doc-1.6
		~app-text/docbook-xml-dtd-4.2
	)
	X? (
		x11-proto/renderproto
		drm? (
			x11-proto/xproto
			>=x11-proto/xextproto-7.1
		)
	)"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-1.8.8-interix.patch
	epatch "${FILESDIR}"/${P}-buggy_gradients.patch #336696
	epatch "${FILESDIR}"/${P}-install-sh.patch #336329

	# Slightly messed build system YAY
	if [[ ${PV} == *9999* ]]; then
		touch boilerplate/Makefile.am.features
		touch src/Makefile.am.features
		touch ChangeLog
	fi

	# We need to run elibtoolize to ensure correct so versioning on FreeBSD
	# upgraded to an eautoreconf for the above interix patch.
	eautoreconf
}

multilib-native_src_configure_internal() {
	local myopts

	[[ ${CHOST} == *-interix* ]] && append-flags -D_REENTRANT
	# http://bugs.freedesktop.org/show_bug.cgi?id=15463
	[[ ${CHOST} == *-solaris* ]] && append-flags -D_POSIX_PTHREAD_SEMANTICS

	#gets rid of fbmmx.c inlining warnings
	append-flags -finline-limit=1200

	# bug #342319
	[[ ${CHOST} == powerpc*-*-darwin* ]] && filter-flags -mcpu=*

	if use X; then
		myopts+="
			$(use_enable drm)
		"

		if use drm; then
			myopts+="
				$(use_enable gallium)
				$(use_enable xcb xcb-drm)
			"
		else
			use gallium && ewarn "Gallium use requires drm use enabled. So disabling for now."
			myopts+="
				--disable-gallium
				--disable-xcb-drm
			"
		fi
	else
		use drm && ewarn "drm use requires X use enabled. So disabling for now."
		myopts+="
			--disable-drm
			--disable-gallium
			--disable-xcb-drm
		"
	fi

	# --disable-xcb-lib:
	#	do not override good xlib backed by hardforcing rendering over xcb
	econf \
		--disable-dependency-tracking \
		$(use_with X x) \
		$(use_enable X xlib) \
		$(use_enable X xlib-xrender) \
		$(use_enable aqua quartz) \
		$(use_enable aqua quartz-image) \
		$(use_enable debug test-surfaces) \
		$(use_enable directfb) \
		$(use_enable doc gtk-doc) \
		$(use_enable openvg vg) \
		$(use_enable opengl gl) \
		$(use_enable qt4 qt) \
		$(use_enable static-libs static) \
		$(use_enable svg) \
		$(use_enable xcb) \
		$(use_enable xcb xcb-shm) \
		--enable-ft \
		--enable-pdf \
		--enable-png \
		--enable-ps \
		--disable-xlib-xcb \
		${myopts}
}

multilib-native_src_install_internal() {
	# parallel make install fails
	emake -j1 DESTDIR="${D}" install || die "Installation failed"
	dodoc AUTHORS ChangeLog NEWS README || die
}
