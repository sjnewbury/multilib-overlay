# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gconf/gconf-2.26.2-r1.ebuild,v 1.12 2011/03/16 10:24:45 nirbheek Exp $

EAPI="2"

inherit eutils gnome2 multilib-native

MY_PN=GConf
MY_P=${MY_PN}-${PV}
PVP=(${PV//[-\._]/ })

DESCRIPTION="Gnome Configuration System and Daemon"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/${MY_PN}/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~mips"
IUSE="debug doc ldap"

RDEPEND=">=dev-libs/glib-2.14:2[lib32?]
	>=x11-libs/gtk+-2.8.16:2[lib32?]
	>=dev-libs/dbus-glib-0.74[lib32?]
	>=sys-apps/dbus-1[lib32?]
	>=gnome-base/orbit-2.4:2[lib32?]
	>=dev-libs/libxml2-2:2[lib32?]
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
		--disable-static
		$(use_with ldap openldap)
		--disable-defaults-service"
	kill_gconf

	# Need host's IDL compiler for cross or native build, bug #262747
	export EXTRA_EMAKE="${EXTRA_EMAKE} ORBIT_IDL=/usr/bin/orbit-idl-2"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Do not start gconfd when installing schemas, fix bug #238276, upstream ?
	epatch "${FILESDIR}/${PN}-2.24.0-no-gconfd.patch"

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in || die "sed failed"
}

# Can't run tests, missing script.
#src_test() {
#	emake -C tests || die "make tests failed"
#	sh "${S}"/tests/runtests.sh || die "running tests failed"
#}

multilib-native_src_install_internal() {
	gnome2_src_install

	keepdir /etc/gconf/gconf.xml.mandatory
	keepdir /etc/gconf/gconf.xml.defaults
	# Make sure this directory exists, bug #268070, upstream #572027
	keepdir /etc/gconf/gconf.xml.system

	echo 'CONFIG_PROTECT_MASK="/etc/gconf"' > 50gconf
	doenvd 50gconf || die "doenv failed"
	dodir /root/.gconfd
}

multilib-native_pkg_preinst_internal() {
	kill_gconf
}

multilib-native_pkg_postinst_internal() {
	kill_gconf

	# change the permissions to avoid some gconf bugs
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
