# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libgnome/libgnome-2.32.1.ebuild,v 1.6 2011/03/22 19:16:21 ranger Exp $

EAPI="3"
GCONF_DEBUG="yes"

inherit gnome2 eutils multilib-native

DESCRIPTION="Essential Gnome Libraries"
HOMEPAGE="http://library.gnome.org/devel/libgnome/stable/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="branding doc esd"

SRC_URI="${SRC_URI}
	branding? ( mirror://gentoo/gentoo-gdm-theme-r3.tar.bz2 )"

RDEPEND=">=gnome-base/gconf-2[lib32?]
	>=dev-libs/glib-2.16[lib32?]
	>=gnome-base/gnome-vfs-2.5.3[lib32?]
	>=gnome-base/libbonobo-2.13[lib32?]
	>=dev-libs/popt-1.7[lib32?]
	media-libs/libcanberra[lib32?]
	esd? (
		>=media-sound/esound-0.2.26[lib32?]
		>=media-libs/audiofile-0.2.3[lib32?] )"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.17[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

PDEPEND="gnome-base/gvfs"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-schemas-install
		--enable-canberra
		$(use_enable esd)"
	DOCS="AUTHORS ChangeLog NEWS README"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Make sure menus have icons. People don't like change
	epatch "${FILESDIR}/${PN}-2.28.0-menus-have-icons.patch"

	use branding && epatch "${FILESDIR}"/${PN}-2.26.0-branding.patch
}

multilib-native_src_install_internal() {
	gnome2_src_install

	if use branding; then
		# Add gentoo backgrounds
		dodir /usr/share/pixmaps/backgrounds/gnome/gentoo || die "dodir failed"
		insinto /usr/share/pixmaps/backgrounds/gnome/gentoo
		doins "${WORKDIR}"/gentoo-emergence/gentoo-emergence.png || die "doins 1 failed"
		doins "${WORKDIR}"/gentoo-cow/gentoo-cow-alpha.png || die "doins 2 failed"
	fi
}
