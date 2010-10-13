# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pango/pango-1.28.3.ebuild,v 1.1 2010/10/03 22:22:26 eva Exp $

EAPI="3"
GCONF_DEBUG="yes"

inherit autotools eutils gnome2 multilib toolchain-funcs multilib-native

DESCRIPTION="Internationalized text layout and rendering library"
HOMEPAGE="http://www.pango.org/"

LICENSE="LGPL-2 FTL"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="X doc +introspection test"

RDEPEND=">=dev-libs/glib-2.17.3[lib32?]
	>=media-libs/fontconfig-2.5.0[lib32?]
	media-libs/freetype:2[lib32?]
	>=x11-libs/cairo-1.7.6[X?,lib32?]
	X? (
		x11-libs/libXrender[lib32?]
		x11-libs/libX11[lib32?]
		x11-libs/libXft[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/gtk-doc-am-1.13
	doc? (
		>=dev-util/gtk-doc-1.13
		~app-text/docbook-xml-dtd-4.1.2
		x11-libs/libXft[lib32?] )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5[lib32?] )
	test? (
		>=dev-util/gtk-doc-1.13
		~app-text/docbook-xml-dtd-4.1.2
		x11-libs/libXft[lib32?] )
	X? ( x11-proto/xproto )"

DOCS="AUTHORS ChangeLog* NEWS README THANKS"

function multilib_enabled() {
	has_multilib_profile || ( use x86 && [ "$(get_libdir)" = "lib32" ] )
}

multilib-native_pkg_setup_internal() {
	tc-export CXX
	G2CONF="${G2CONF}
		$(use_enable introspection)
		$(use_with X x)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# make config file location host specific so that a 32bit and 64bit pango
	# wont fight with each other on a multilib system.  Fix building for
	# emul-linux-x86-gtklibs
	if multilib_enabled ; then
		epatch "${FILESDIR}/${PN}-1.26.0-lib64.patch"
	fi

	eautoreconf
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${ED}/usr/$(get_libdir)/pango/1.6.0/modules" -name "*.la" -delete || die

	prep_ml_binaries /usr/bin/pango-querymodules
}

multilib-native_pkg_postinst_internal() {
	if [ "${ROOT}" = "/" ] ; then
		einfo "Generating modules listing..."

		local PANGO_CONFDIR=

		if multilib_enabled ; then
			PANGO_CONFDIR="/etc/pango/${CHOST}"
		else
			PANGO_CONFDIR="/etc/pango"
		fi

		mkdir -p ${PANGO_CONFDIR}

		pango-querymodules > ${PANGO_CONFDIR}/pango.modules
	fi
}
