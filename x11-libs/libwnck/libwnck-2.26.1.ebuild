# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libwnck/libwnck-2.26.1.ebuild,v 1.1 2009/05/04 22:35:25 eva Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="A window navigation construction kit"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.11.3[$(get_ml_usedeps)]
		 >=dev-libs/glib-2.13.0[$(get_ml_usedeps)]
		 >=x11-libs/startup-notification-0.4[$(get_ml_usedeps)]
		 x11-libs/libX11[$(get_ml_usedeps)]
		 x11-libs/libXres[$(get_ml_usedeps)]
		 x11-libs/libXext[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
		sys-devel/gettext[$(get_ml_usedeps)]
		>=dev-util/pkgconfig-0.9[$(get_ml_usedeps)]
		>=dev-util/intltool-0.40
		doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"
