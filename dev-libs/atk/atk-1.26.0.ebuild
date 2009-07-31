# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/atk/atk-1.24.0.ebuild,v 1.6 2009/03/18 14:19:48 armin76 Exp $

EAPI="2"

inherit gnome2 multilib-native

DESCRIPTION="GTK+ & GNOME Accessibility Toolkit"
HOMEPAGE="http://developer.gnome.org/projects/gap/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2[lib32?]"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	sys-devel/gettext
	>=dev-util/pkgconfig-0.9[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"
