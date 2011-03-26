# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcanberra/libcanberra-0.26.ebuild,v 1.7 2011/03/22 19:36:48 ranger Exp $

EAPI="3"
inherit gnome2-utils libtool multilib-native

DESCRIPTION="Portable Sound Event Library"
HOMEPAGE="http://0pointer.de/lennart/projects/libcanberra/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="alsa gstreamer +gtk oss pulseaudio +sound tdb"

COMMON_DEPEND="media-libs/libvorbis[lib32?]
	>=sys-devel/libtool-2.2.6b[lib32?]
	alsa? ( media-libs/alsa-lib[lib32?] )
	gstreamer? ( >=media-libs/gstreamer-0.10.15[lib32?] )
	gtk? ( >=x11-libs/gtk+-2.20.0:2[lib32?]
		>=gnome-base/gconf-2[lib32?] )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.11[lib32?] )
	tdb? ( sys-libs/tdb[lib32?] )"
RDEPEND="${COMMON_DEPEND}
	sound? ( x11-themes/sound-theme-freedesktop )" # Required for index.theme wrt #323379
DEPEND="${COMMON_DEPEND}
	>=dev-util/pkgconfig-0.17[lib32?]"

multilib-native_src_prepare_internal() {
	# Run elibtoolize for ~x86-fbsd.
	use x86-fbsd && elibtoolize
}

# --disable-gtk3 for now
multilib-native_src_configure_internal() {
	econf \
		--docdir=/usr/share/doc/${PF} \
		--disable-dependency-tracking \
		$(use_enable alsa) \
		$(use_enable oss) \
		$(use_enable pulseaudio pulse) \
		$(use_enable gstreamer) \
		$(use_enable gtk) \
		$(use_enable tdb) \
		--disable-lynx \
		--disable-gtk-doc \
		--disable-gtk-doc-html \
		--disable-gtk-doc-pdf \
		--disable-gtk3 \
		--with-html-dir=/usr/share/doc/${PF}/html
}

multilib-native_src_install_internal() {
	# Disable parallel installation until bug #253862 is solved
	emake -j1 DESTDIR="${ED}" install || die
	prepalldocs
}

multilib-native_pkg_preinst_internal() { gnome2_gconf_savelist; }
multilib-native_pkg_postinst_internal() { gnome2_gconf_install; }
