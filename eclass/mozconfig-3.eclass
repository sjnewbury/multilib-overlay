# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mozconfig-3.eclass,v 1.10 2010/07/23 19:53:30 ssuominen Exp $
#
# mozconfig.eclass: the new mozilla.eclass

inherit multilib flag-o-matic mozcoreconf-2

IUSE="gnome dbus startup-notification"

RDEPEND="x11-libs/libXrender[lib32?]
	x11-libs/libXt[lib32?]
	x11-libs/libXmu[lib32?]
	virtual/jpeg[lib32?]
	dev-libs/expat[lib32?]
	app-arch/zip
	app-arch/unzip
	>=x11-libs/gtk+-2.8.6[lib32?]
	>=dev-libs/glib-2.8.2[lib32?]
	>=x11-libs/pango-1.10.1[lib32?]
	>=dev-libs/libIDL-0.8.0[lib32?]
	gnome? ( >=gnome-base/gnome-vfs-2.16.3[lib32?]
		>=gnome-base/libgnomeui-2.16.1[lib32?]
		>=gnome-base/gconf-2.16.0[lib32?]
		>=gnome-base/libgnome-2.16.0[lib32?] )
	dbus? ( >=dev-libs/dbus-glib-0.72[lib32?] )
	startup-notification? ( >=x11-libs/startup-notification-0.8[lib32?] )
	!<x11-base/xorg-x11-6.7.0-r2
	>=x11-libs/cairo-1.6.0[lib32?]"

DEPEND="${RDEPEND}"

mozconfig_config() {
	if ${MN} || ${XUL} || ${TB}; then
	    mozconfig_annotate thebes --enable-default-toolkit=cairo-gtk2
	else
	    mozconfig_annotate -thebes --enable-default-toolkit=gtk2
	fi

	mozconfig_use_enable dbus
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

	mozconfig_use_enable gnome gnomevfs
	mozconfig_use_enable gnome gnomeui
}
