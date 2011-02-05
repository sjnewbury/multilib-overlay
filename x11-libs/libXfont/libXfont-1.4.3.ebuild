# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXfont/libXfont-1.4.3.ebuild,v 1.8 2011/01/27 16:52:22 darkside Exp $

EAPI=3
inherit xorg-2 multilib-native

DESCRIPTION="X.Org Xfont library"

KEYWORDS="~alpha amd64 arm hppa ~ia64 ~mips ~ppc ppc64 ~s390 ~sh ~sparc x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc ipv6"

RDEPEND="x11-libs/xtrans[lib32?]
	x11-libs/libfontenc[lib32?]
	>=media-libs/freetype-2[lib32?]
	app-arch/bzip2[lib32?]
	x11-proto/xproto
	x11-proto/fontsproto"
DEPEND="${RDEPEND}
	doc? ( app-text/xmlto )"

multilib-native_pkg_setup_internal() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="$(use_enable ipv6)
		$(use_enable doc devel-docs)
		$(use_with doc xmlto)
		--with-bzip2
		--without-fop
		--with-encodingsdir=${EPREFIX}/usr/share/fonts/encodings"
}
