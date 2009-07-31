# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-glib/dbus-glib-0.76.ebuild,v 1.8 2009/03/30 15:38:03 armin76 Exp $

EAPI="2"

inherit eutils multilib autotools multilib-native

DESCRIPTION="D-Bus bindings for glib"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="doc selinux debug"

RDEPEND=">=sys-apps/dbus-1.1.0[$(get_ml_usedeps)?]
	>=dev-libs/glib-2.6[$(get_ml_usedeps)?]
	selinux? ( sys-libs/libselinux )
	>=dev-libs/libxml2-2.6.21[$(get_ml_usedeps)?]"
	# expat code now sucks.. libxml2 is the default
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)?]
	doc? ( app-doc/doxygen app-text/xmlto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-introspection.patch
}

ml-native_src_configure() {
	local myconf=""

	econf \
		$(use_enable selinux) \
		$(use_enable debug verbose-mode) \
		$(use_enable debug checks) \
		$(use_enable debug asserts) \
		--with-xml=libxml \
		--with-system-pid-file=/var/run/dbus.pid \
		--with-system-socket=/var/run/dbus/system_bus_socket \
		--with-session-socket-dir=/tmp \
		--with-dbus-user=messagebus \
		--localstatedir=/var \
		$(use_enable doc doxygen-docs) \
		--disable-xml-docs \
		${myconf} \
		|| die "econf failed"

	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog HACKING NEWS README
}
