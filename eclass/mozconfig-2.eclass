# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mozconfig-2.eclass,v 1.19 2008/07/29 20:50:24 armin76 Exp $
#
# mozconfig.eclass: the new mozilla.eclass

inherit multilib flag-o-matic mozcoreconf

IUSE="debug gnome ipv6 xinerama"

RDEPEND="x11-libs/libXrender[$(get_ml_usedeps)]
	x11-libs/libXt[$(get_ml_usedeps)]
	x11-libs/libXmu[$(get_ml_usedeps)]
	>=media-libs/jpeg-6b[$(get_ml_usedeps)]
	>=media-libs/libpng-1.2.1[$(get_ml_usedeps)]
	dev-libs/expat[$(get_ml_usedeps)]
	app-arch/zip
	app-arch/unzip
	>=x11-libs/gtk+-2.8.6[$(get_ml_usedeps)]
	>=dev-libs/glib-2.8.2[$(get_ml_usedeps)]
	>=x11-libs/pango-1.10.1[$(get_ml_usedeps)]
	>=dev-libs/libIDL-0.8.0[$(get_ml_usedeps)]
	gnome? ( >=gnome-base/gnome-vfs-2.3.5[$(get_ml_usedeps)]
		>=gnome-base/libgnomeui-2.2.0[$(get_ml_usedeps)] )
	!<x11-base/xorg-x11-6.7.0-r2
	>=x11-libs/cairo-1.0.0[$(get_ml_usedeps)]"
	#According to bugs #18573, #204520, and couple of others in Mozilla's
	#bugzilla. libmng and mng support has been removed in 2003.


DEPEND="${RDEPEND}
	xinerama? ( x11-proto/xineramaproto )"

mozconfig_config() {
	mozconfig_use_enable ipv6
	mozconfig_use_enable xinerama

	# We use --enable-pango to do truetype fonts, and currently pango
	# is required for it to build
	mozconfig_annotate gentoo --disable-freetype2

	if use debug; then
		mozconfig_annotate +debug \
			--enable-debug \
			--enable-tests \
			--disable-reorder \
			--enable-debugger-info-modules=ALL_MODULES
	else
		mozconfig_annotate -debug \
			--disable-debug \
			--disable-tests \
			--enable-reorder \

		# Currently --enable-elf-dynstr-gc only works for x86 and ppc,
		# thanks to Jason Wever <weeve@gentoo.org> for the fix.
		# -- This breaks now on ppc, no idea why
#		if use x86 || use ppc && [[ ${enable_optimize} != -O0 ]]; then
		if use x86 && [[ ${enable_optimize} != -O0 ]]; then
			mozconfig_annotate "${ARCH} optimized build" --enable-elf-dynstr-gc
		fi
	fi

	if ! use gnome; then
		mozconfig_annotate -gnome --disable-gnomevfs
		mozconfig_annotate -gnome --disable-gnomeui
	fi
}
