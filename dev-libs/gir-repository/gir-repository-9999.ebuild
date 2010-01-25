# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit autotools git eutils gnome2 multilib-native

EGIT_REPO_URI="git://git.gnome.org/gir-repository"

DESCRIPTION="GObject Introspection tools and library"
HOMEPAGE="http://live.gnome.org/GObjectIntrospection"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="-x86"
IUSE="atk avahi babl dbus gconf gnome-keyring goocanvas +gtk gtksourceview gupnp libnotify libsoup libwnck nautilus pango poppler vte"

RDEPEND=">=dev-libs/gobject-introspection-0.6.5"
DEPEND="${RDEPEND}
	atk? ( >=dev-libs/atk-1.29.4[lib32?] )
	avahi? ( >=net-dns/avahi-0.6[lib32?] )
	babl? ( media-libs/babl[lib32?] )
	dbus? ( dev-libs/dbus-glib[lib32?] )
	gconf? ( gnome-base/gconf[lib32?] )
	gnome-keyring? ( gnome-base/gnome-keyring[lib32?] )
	goocanvas? ( x11-libs/goocanvas[lib32?] )
	gtksourceview? ( x11-libs/gtksourceview[lib32?] )
	gupnp? (
		net-libs/gssdp[lib32?]
		net-libs/gupnp[lib32?] )
	libnotify? ( x11-libs/libnotify[lib32?] )
	libsoup? ( net-libs/libsoup:2.4[lib32?] )
	libwnck? ( x11-libs/libwnck[lib32?] )
	nautilus? ( gnome-base/nautilus[lib32?] )
	pango? ( >=x11-libs/pango-1.26.2[lib32?] )
	poppler? ( >=virtual/poppler-glib-0.8[lib32?] )
	vte? ( x11-libs/vte[lib32?] )
	webkit? ( >=net-libs/webkit-gtk-1.1.17[lib32?] )
	libsoup? ( >=net-libs/libsoup-2.29[lib32?] )
	gtk? ( >=x11-libs/gtk+-2.19.2[lib32?] )
"

GIR_MODULES="${IUSE}"

_auto_dep() {
	if use ${1} && ! use ${2}; then
		ewarn "${2} is disabled, but ${1} needs ${2}. Auto-enabling..."
		GIR_MODULES="${GIR_MODULES/$2}"
	fi
}

_gir_to_module() {
	case "$1" in
		avahi)		echo "Avahi"
		;;
		babl) 		echo "BABL"
		;;
		dbus) 		echo "DBus"
		;;
		gconf) 		echo "GConf"
		;;
		gnome-keyring) 	echo "GnomeKeyring"
		;;
		goocanvas) 	echo "GooCanvas"
		;;
		gtksourceview)	echo "GtkSourceView"
		;;
		gupnp) 		echo "GUPNP"
		;;
		libnotify) 	echo "Notify"
		;;
		libwnck) 	echo "Wnck"
		;;
		nautilus) 	echo "Nautilus"
		;;
		pango)		echo "Pango"
		;;
		poppler)	echo "Poppler"
		;;
		vte)		echo "Vte"
		;;
	esac
}

multilib-native_pkg_setup_internal() {
	# FIXME: installs even disabled stuff if it's a dependency of something enabled
	# Already upstream:
	SKIPPED_GIR_MODULES="Atk,Gtk,Gnio,Gst,Unique,WebKit,Soup,Pango"

	for MODULE in "${GIR_MODULES}"; do
		use ${MODULE} || 
			SKIPPED_GIR_MODULES="${SKIPPED_GIR_MODULES},$(_gir_to_module ${MODULE})"
	done

	G2CONF="${G2CONF} --with-skipped-gir-modules=${SKIPPED_GIR_MODULES}"
}

multilib-native_src_unpack_internal() {
	git_src_unpack	
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare
	epatch "${FILESDIR}/${P}-gstreamer.patch"
	eautoreconf
}

multilib-native_src_install_internal() {
	emake install DESTDIR=${D} || die "Failed to install"
}
