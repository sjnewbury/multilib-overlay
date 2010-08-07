# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomecanvas/libgnomecanvas-2.26.0.ebuild,v 1.10 2010/08/03 01:19:58 jer Exp $

EAPI="2"

inherit virtualx gnome2 multilib-native

DESCRIPTION="The Gnome 2 Canvas library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

# gtk+ raised to fix gail dependency
RDEPEND=">=x11-libs/gtk+-2.13[lib32?]
	>=media-libs/libart_lgpl-2.3.8[lib32?]
	>=x11-libs/pango-1.0.1[lib32?]
	>=gnome-base/libglade-2[lib32?]"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	sys-devel/gettext[lib32?]
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.18[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

src_test() {
	Xmake check || die "Test phase failed"
}
