# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.24.1.ebuild,v 1.2 2009/04/27 22:00:09 eva Exp $

EAPI="2"

inherit gnome2 pam eutils autotools multilib-native

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc hal pam test"

RDEPEND=">=dev-libs/glib-2.16[$(get_ml_usedeps)]
	 >=x11-libs/gtk+-2.6[$(get_ml_usedeps)]
	 gnome-base/gconf[$(get_ml_usedeps)]
	 >=sys-apps/dbus-1.0[$(get_ml_usedeps)]
	 hal? ( >=sys-apps/hal-0.5.7[$(get_ml_usedeps)] )
	 pam? ( virtual/pam )
	 >=dev-libs/libgcrypt-1.2.2[$(get_ml_usedeps)]
	 >=dev-libs/libtasn1-0.3.4[$(get_ml_usedeps)]
	 lib32? ( pam? ( sys-libs/pam[$(get_ml_usedeps)] ) )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[$(get_ml_usedeps)]
	dev-util/gtk-doc-am
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

# upstream bug: http://bugzilla.gnome.org/show_bug.cgi?id=553164
RESTRICT="test"

ml-native_pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable hal)
		$(use_enable test tests)
		$(use_enable pam)
		$(use_with pam pam-dir $(getpam_mod_dir))
		--with-root-certs=/usr/share/ca-certificates/
		--enable-acl-prompts
		--enable-ssh-agent"
}

ml-native_src_prepare() {
	gnome2_src_prepare

	# Fix configure with recent libtasn1, bug #266554
	epatch "${FILESDIR}/${PN}-2.22.3-pkg-libtasn1.patch"

	intltoolize --force --copy --automake || die "inltoolize failed"
	eautoreconf
}
