# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcanberra/libcanberra-0.11.ebuild,v 1.8 2009/04/12 20:51:12 bluebird Exp $

EAPI="2"

inherit gnome2-utils multilib-native

DESCRIPTION="Portable Sound Event Library"
HOMEPAGE="http://0pointer.de/lennart/projects/libcanberra/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~hppa ia64 ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="alsa doc gstreamer +gtk oss"

RDEPEND="media-libs/libvorbis[$(get_ml_usedeps)]
	sys-devel/libtool[$(get_ml_usedeps)]
	alsa? ( media-libs/alsa-lib[$(get_ml_usedeps)] )
	gstreamer? ( >=media-libs/gstreamer-0.10.15 )
	pulse? ( media-sound/pulseaudio[$(get_ml_usedeps)] )
	gtk? ( dev-libs/glib:2[$(get_ml_usedeps)]
		>=x11-libs/gtk+-2.13.4:2[$(get_ml_usedeps)]
		>=gnome-base/gconf-2[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.17[$(get_ml_usedeps)]
	doc? ( >=dev-util/gtk-doc-1.9 )"

ml-native_src_configure() {
	econf --disable-static \
		$(use_enable alsa) \
		$(use_enable gstreamer) \
		$(use_enable gtk) \
		$(use_enable oss) \
		$(use_enable doc gtk-doc) \
		--disable-pulse \
		--disable-tdb \
		--disable-lynx
	# tdb support would need a split-out from samba before we can use it
}

ml-native_src_install() {
	# we must delay gconf schema installation due to sandbox
	export GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL="1"

	emake DESTDIR="${D}" install || die "emake install failed."

	unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL

	rm "${D}/usr/share/doc/${PN}/README"
	# If the rmdir errors, you probably need to add a file to dodoc
	# and remove the package installed above
	rmdir "${D}/usr/share/doc/${PN}"
	dodoc README
}

ml-native_pkg_preinst() {
	gnome2_gconf_savelist
}

ml-native_pkg_postinst() {
	gnome2_gconf_install
}

#pkg_prerm() {
#	gnome2_gconf_uninstall
#}
