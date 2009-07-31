# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnomecanvas/libgnomecanvas-2.20.1.1.ebuild,v 1.8 2008/04/20 01:35:57 vapier Exp $

EAPI="2"

inherit virtualx gnome2 multilib-native

DESCRIPTION="The Gnome 2 Canvas library"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

# gtk+ raised to fix gail dependency
RDEPEND=">=x11-libs/gtk+-2.13[$(get_ml_usedeps)?]
	>=media-libs/libart_lgpl-2.3.8[$(get_ml_usedeps)?]
	>=x11-libs/pango-1.0.1[$(get_ml_usedeps)?]
	>=gnome-base/libglade-2[$(get_ml_usedeps)?]"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.18[$(get_ml_usedeps)?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

src_test() {
	Xmake check || die "Test phase failed"
}
