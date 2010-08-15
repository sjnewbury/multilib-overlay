# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/nautilus/nautilus-2.28.4-r1.ebuild,v 1.7 2010/08/14 18:50:56 armin76 Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit eutils gnome2 virtualx multilib-native

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="http://www.gnome.org/projects/nautilus/"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ia64 ~ppc64 sh sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="beagle doc gnome xmp"

# not adding gnome-base/gail because it is in >=gtk+-2.13
RDEPEND=">=dev-libs/glib-2.21.3[lib32?]
	>=gnome-base/gnome-desktop-2.25.5[lib32?]
	>=x11-libs/pango-1.1.2[lib32?]
	>=x11-libs/gtk+-2.16.0[lib32?]
	>=dev-libs/libxml2-2.4.7[lib32?]
	>=media-libs/libexif-0.5.12[lib32?]
	>=gnome-base/gconf-2.0[lib32?]
	dev-libs/libunique[lib32?]
	dev-libs/dbus-glib[lib32?]
	x11-libs/libXft[lib32?]
	x11-libs/libXrender[lib32?]
	beagle? ( || (
		dev-libs/libbeagle[lib32?]
		=app-misc/beagle-0.2* ) )
	xmp? ( >=media-libs/exempi-2[lib32?] )"

DEPEND="${RDEPEND}
	>=dev-lang/perl-5[lib32?]
	sys-devel/gettext[lib32?]
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.40.1
	doc? ( >=dev-util/gtk-doc-1.4 )"
# For eautoreconf
#	gnome-base/gnome-common
#	dev-util/gtk-doc-am"

PDEPEND="gnome? ( >=x11-themes/gnome-icon-theme-1.1.91 )
	>=gnome-base/gvfs-0.1.2"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README THANKS TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-update-mimedb
		--disable-packagekit
		--disable-tracker
		$(use_enable beagle)
		$(use_enable xmp)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# FIXME: tarball generated with broken gtk-doc, revisit me.
	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/usr/bin/gtkdoc-rebase" \
			-i gtk-doc.make || die "sed 1 failed"
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/bin/true" \
			-i gtk-doc.make || die "sed 2 failed"
	fi

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in \
		|| die "sed 3 failed"

	# Remove crazy CFLAGS
	sed 's:-DG.*DISABLE_DEPRECATED::g' -i configure.in configure \
		|| die "sed 4 failed"

	# Fix nautilus flipping-out with --no-desktop -- bug 266398
	epatch "${FILESDIR}/${PN}-2.27.4-change-reg-desktop-file-with-no-desktop.patch"
}

src_test() {
	addwrite "/root/.gnome2_private"
	unset SESSION_MANAGER
	unset ORBIT_SOCKETDIR
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "Test phase failed"
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${D}" -name "*.la" -delete || die "remove of la files failed"
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst

	elog "nautilus can use gstreamer to preview audio files. Just make sure"
	elog "to have the necessary plugins available to play the media type you"
	elog "want to preview"
}
