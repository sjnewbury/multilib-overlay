# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mozconfig-3.eclass,v 1.7 2009/02/23 16:36:12 armin76 Exp $
#
# mozconfig.eclass: the new mozilla.eclass

inherit multilib flag-o-matic mozcoreconf-2

IUSE="gnome dbus startup-notification"

RDEPEND="x11-libs/libXrender[$(get_ml_usedeps)]
	x11-libs/libXt[$(get_ml_usedeps)]
	x11-libs/libXmu[$(get_ml_usedeps)]
	>=media-libs/jpeg-6b[$(get_ml_usedeps)]
	dev-libs/expat[$(get_ml_usedeps)]
	app-arch/zip
	app-arch/unzip
	>=x11-libs/gtk+-2.8.6[$(get_ml_usedeps)]
	>=dev-libs/glib-2.8.2[$(get_ml_usedeps)]
	>=x11-libs/pango-1.10.1[$(get_ml_usedeps)]
	>=dev-libs/libIDL-0.8.0[$(get_ml_usedeps)]
	gnome? ( >=gnome-base/gnome-vfs-2.16.3[$(get_ml_usedeps)]
		>=gnome-base/libgnomeui-2.16.1[$(get_ml_usedeps)]
		>=gnome-base/gconf-2.16.0[$(get_ml_usedeps)]
		>=gnome-base/libgnome-2.16.0[$(get_ml_usedeps)] )
	dbus? ( >=dev-libs/dbus-glib-0.72[$(get_ml_usedeps)] )
	startup-notification? ( >=x11-libs/startup-notification-0.8[$(get_ml_usedeps)] )
	!<x11-base/xorg-x11-6.7.0-r2
	>=x11-libs/cairo-1.6.0[$(get_ml_usedeps)]"
	#According to bugs #18573, #204520, and couple of others in Mozilla's
	#bugzilla. libmng and mng support has been removed in 2003.


DEPEND="${RDEPEND}"

mozconfig_config() {
	if ${MN} || ${XUL} || ${TB}; then
	    mozconfig_annotate thebes --enable-default-toolkit=cairo-gtk2
	else
	    mozconfig_annotate -thebes --enable-default-toolkit=gtk2
	fi

	if ! use dbus; then
		mozconfig_annotate '' --disable-dbus
	fi
	mozconfig_use_enable startup-notification

#	if use debug; then
#		mozconfig_annotate +debug \
#			--enable-debug \
#			--enable-tests \
#			--enable-debugger-info-modules=ALL_MODULES
#	else
	mozconfig_annotate -debug \
		--disable-debug \
		--disable-tests

	# Currently --enable-elf-dynstr-gc only works for x86 and ppc,
	# thanks to Jason Wever <weeve@gentoo.org> for the fix.
	# -- This breaks now on ppc, no idea why
#	if use x86 || use ppc && [[ ${enable_optimize} != -O0 ]]; then
	if use x86 && [[ ${enable_optimize} != -O0 ]]; then
		mozconfig_annotate "${ARCH} optimized build" --enable-elf-dynstr-gc
	fi
#	fi

	if ! use gnome; then
		mozconfig_annotate -gnome --disable-gnomevfs
		mozconfig_annotate -gnome --disable-gnomeui
	fi
}
