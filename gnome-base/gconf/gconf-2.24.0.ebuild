# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gconf/gconf-2.24.0.ebuild,v 1.11 2009/05/01 11:39:25 eva Exp $

EAPI="2"

inherit autotools eutils gnome2 multilib-native

MY_PN=GConf
MY_P=${MY_PN}-${PV}
PVP=(${PV//[-\._]/ })

DESCRIPTION="Gnome Configuration System and Daemon"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/${MY_PN}/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug doc ldap"

# FIXME: add policykit support
RDEPEND=">=dev-libs/glib-2.14[lib32?]
	>=x11-libs/gtk+-2.8.16[lib32?]
	>=dev-libs/dbus-glib-0.74[lib32?]
	>=sys-apps/dbus-1[lib32?]
	>=gnome-base/orbit-2.4[lib32?]
	>=dev-libs/libxml2-2[lib32?]
	ldap? ( net-nds/openldap[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/gtk-doc-am-1.10
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

S="${WORKDIR}/${MY_P}"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--enable-gtk
		--disable-defaults-service
		$(use_enable debug)
		$(use_with ldap openldap)"
	#$(use_enable policykit defaults-service)
	kill_gconf

	# Need host's IDL compiler for cross or native build, bug #262747
	export EXTRA_EMAKE="${EXTRA_EMAKE} ORBIT_IDL=/usr/bin/orbit-idl-2"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# fix bug #193442, GNOME bug #498934
	epatch "${FILESDIR}/${P}-automagic-ldap.patch"

	# fix bug #238276
	epatch "${FILESDIR}/${P}-no-gconfd.patch"

	eautoreconf
}

# Can't run tests, missing script.
#src_test() {
#	emake -C tests || die "make tests failed"
#	sh "${S}"/tests/runtests.sh || die "running tests failed"
#}

multilib-native_src_install_internal() {
	gnome2_src_install

	keepdir /etc/gconf/gconf.xml.mandatory
	keepdir /etc/gconf/gconf.xml.defaults

	echo 'CONFIG_PROTECT_MASK="/etc/gconf"' > 50gconf
	doenvd 50gconf || die "doenv failed"
	dodir /root/.gconfd
}

multilib-native_pkg_preinst_internal() {
	kill_gconf
}

multilib-native_pkg_postinst_internal() {
	kill_gconf

	#change the permissions to avoid some gconf bugs
	einfo "changing permissions for gconf dirs"
	find  /etc/gconf/ -type d -exec chmod ugo+rx "{}" \;

	einfo "changing permissions for gconf files"
	find  /etc/gconf/ -type f -exec chmod ugo+r "{}" \;
}

kill_gconf() {
	# This function will kill all running gconfd-2 that could be causing troubles
	if [ -x /usr/bin/gconftool-2 ]
	then
		/usr/bin/gconftool-2 --shutdown
	fi

	return 0
}
