# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libunique/libunique-1.0.8.ebuild,v 1.19 2010/02/28 06:52:50 nirbheek Exp $

EAPI="2"

inherit autotools eutils gnome2 virtualx multilib-native

DESCRIPTION="a library for writing single instance application"
HOMEPAGE="http://live.gnome.org/LibUnique"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE="dbus debug doc"

RDEPEND=">=dev-libs/glib-2.12.0[lib32?]
	>=x11-libs/gtk+-2.11.0[lib32?]
	x11-libs/libX11[lib32?]
	dbus? ( >=dev-libs/dbus-glib-0.70[lib32?] )"
DEPEND="${RDEPEND}
	sys-devel/gettext[lib32?]
	>=dev-util/pkgconfig-0.17[lib32?]
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.6 )"

DOCS="AUTHORS NEWS ChangeLog README TODO"

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Make dbus support configurable, bug #265828
	epatch "${FILESDIR}/${P}-automagic-dbus.patch"
	eautoreconf
}

src_test() {
	cd "${S}/tests"

	# Fix environment variable leakage (due to `su` etc)
	unset DBUS_SESSION_BUS_ADDRESS

	# Force Xemake to use Xvfb, bug 279840
	unset XAUTHORITY
	unset DISPLAY

	cp "${FILESDIR}/run-tests" . || die "Unable to cp \${FILESDIR}/run-tests"
	Xemake -f run-tests || die "Tests failed"
}

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable dbus)
		$(use_enable debug)"
}
