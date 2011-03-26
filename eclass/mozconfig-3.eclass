# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mozconfig-3.eclass,v 1.15 2011/03/23 00:40:34 nirbheek Exp $
#
# mozconfig.eclass: the new mozilla.eclass

inherit multilib flag-o-matic mozcoreconf-2

# use-flags common among all mozilla ebuilds
IUSE="+alsa +dbus debug libnotify startup-notification system-sqlite wifi"

# XXX: GConf is used for setting the default browser
#      revisit to make it optional with GNOME 3
RDEPEND="app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.2[lib32?]
	dev-libs/expat[lib32?]
	>=dev-libs/libIDL-0.8.0[lib32?]
	>=dev-libs/libevent-1.4.7
	!<x11-base/xorg-x11-6.7.0-r2
	>=x11-libs/cairo-1.10.2[X,lib32?]
	>=x11-libs/gtk+-2.8.6:2[lib32?]
	>=x11-libs/pango-1.10.1[lib32?]
	virtual/jpeg[lib32?]
	alsa? ( media-libs/alsa-lib[lib32?] )
	dbus? ( >=dev-libs/dbus-glib-0.72[lib32?] )
	libnotify? ( >=x11-libs/libnotify-0.4[lib32?] )
	startup-notification? ( >=x11-libs/startup-notification-0.8[lib32?] )
	wifi? ( net-wireless/wireless-tools )"
DEPEND="${RDEPEND}"

mozconfig_config() {
	mozconfig_annotate '' --enable-default-toolkit=cairo-gtk2

	if has bindist ${IUSE}; then
		mozconfig_use_enable !bindist official-branding
	fi

	mozconfig_use_enable alsa ogg
	mozconfig_use_enable alsa wave
	if has crashreporter ${IUSE} ; then
		mozconfig_use_enable crashreporter
	fi
	mozconfig_use_enable dbus
	mozconfig_use_enable debug
	mozconfig_use_enable debug tests
	mozconfig_use_enable debug debugger-info-modeules
	if has ipc ${IUSE}; then
		mozconfig_use_enable ipc
	fi
	mozconfig_use_enable libnotify
	mozconfig_use_enable startup-notification
	mozconfig_use_enable system-sqlite
	if use system-sqlite; then
		mozconfig_annotate '' --with-sqlite-prefix="${EPREFIX}"/usr
	fi
	mozconfig_use_enable wifi necko-wifi

	if [[ ${PN} == xulrunner ]] ; then
		mozconfig_annotate 'mozjs' --enable-shared-js
	fi

	if [[ ${PN} != thunderbird ]]; then
		if has +webm ${IUSE} && use webm; then
			if ! use alsa; then
				echo "Enabling alsa support due to webm request"
				mozconfig_annotate '+webm -alsa' --enable-ogg
				mozconfig_annotate '+webm -alsa' --enable-wave
				mozconfig_annotate '+webm' --enable-webm
			else
				mozconfig_use_enable webm
				mozconfig_use_with webm system-libvpx
			fi
		fi

		if use amd64 || use x86 || use arm || use sparc; then
			mozconfig_annotate '' --enable-tracejit
		fi
	fi

	# These are enabled by default in all mozilla applications
	mozconfig_annotate '' --with-system-nspr --with-nspr-prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --with-system-nss --with-nss-prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --x-includes="${EPREFIX}"/usr/include --x-libraries="${EPREFIX}"/usr/$(get_libdir)
	mozconfig_annotate '' --with-system-libevent="${EPREFIX}"/usr
	mozconfig_annotate '' --enable-system-hunspell
	mozconfig_annotate '' --disable-gnomevfs
	mozconfig_annotate '' --disable-gnomeui
	mozconfig_annotate '' --enable-gio
	if [[ ${PN} != thunderbird ]] ; then
		mozconfig_annotate 'places' --enable-storage --enable-places --enable-places_bookmarks
		mozconfig_annotate '' --enable-oji --enable-mathml
		mozconfig_annotate 'broken' --disable-mochitest
	fi
}
