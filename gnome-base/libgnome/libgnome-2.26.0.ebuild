# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnome/libgnome-2.26.0.ebuild,v 1.1 2009/05/10 18:34:54 eva Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="Essential Gnome Libraries"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="branding doc esd"

SRC_URI="${SRC_URI}
	branding? ( mirror://gentoo/gentoo-gdm-theme-r3.tar.bz2 )"

RDEPEND=">=gnome-base/gconf-2[$(get_ml_usedeps)?]
	>=dev-libs/glib-2.16[$(get_ml_usedeps)?]
	>=gnome-base/gnome-vfs-2.5.3[$(get_ml_usedeps)?]
	>=gnome-base/libbonobo-2.13[$(get_ml_usedeps)?]
	>=dev-libs/popt-1.7[$(get_ml_usedeps)?]
	esd? (
		>=media-sound/esound-0.2.26
		>=media-libs/audiofile-0.2.3 )"

DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.17[$(get_ml_usedeps)?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} --disable-schemas-install $(use_enable esd)"
}

ml-native_src_prepare() {
	gnome2_src_prepare

	use branding && epatch "${FILESDIR}"/${P}-branding.patch
}

ml-native_src_install() {
	gnome2_src_install

	if use branding; then
		# Add gentoo backgrounds
		dodir /usr/share/pixmaps/backgrounds/gnome/gentoo
		insinto /usr/share/pixmaps/backgrounds/gnome/gentoo
		doins "${WORKDIR}"/gentoo-emergence/gentoo-emergence.png || die "doins 1 failed"
		doins "${WORKDIR}"/gentoo-cow/gentoo-cow-alpha.png || die "doins 2 failed"
	fi
}
