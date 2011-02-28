# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/evolution-data-server/evolution-data-server-2.32.2.ebuild,v 1.4 2011/02/24 19:25:39 tomka Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit autotools db-use eutils flag-o-matic gnome2 versionator virtualx multilib-native

DESCRIPTION="Evolution groupware backend"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="LGPL-2 BSD DB"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"

IUSE="doc ipv6 kerberos gnome-keyring ldap ssl +weather"

RDEPEND=">=dev-libs/glib-2.25.12:2[lib32?]
	>=x11-libs/gtk+-2.20:2[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=dev-db/sqlite-3.5[lib32?]
	>=dev-libs/libgdata-0.6.3[lib32?]
	>=dev-libs/libical-0.43[lib32?]
	>=net-libs/libsoup-2.4:2.4[lib32?]
	>=dev-libs/libxml2-2[lib32?]
	>=sys-libs/db-4[lib32?]
	sys-libs/zlib[lib32?]
	virtual/libiconv
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.20.1[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	ldap? ( >=net-nds/openldap-2[lib32?] )
	ssl? (
		>=dev-libs/nspr-4.4[lib32?]
		>=dev-libs/nss-3.9[lib32?] )
	weather? ( >=dev-libs/libgweather-2.25.4:2[lib32?] )
"
DEPEND="${RDEPEND}
	dev-util/gperf
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35.5
	sys-devel/bison
	>=gnome-base/gnome-common-2
	>=dev-util/gtk-doc-am-1.9
	doc? ( >=dev-util/gtk-doc-1.9 )"
# eautoreconf needs:
#	>=gnome-base/gnome-common-2
#	>=dev-util/gtk-doc-am-1.9

multilib-native_pkg_setup_internal() {
	DOCS="ChangeLog MAINTAINERS NEWS TODO"
	G2CONF="${G2CONF}
		$(use_enable gnome-keyring)
		$(use_enable ipv6)
		$(use_with kerberos krb5 /usr)
		$(use_with ldap openldap)
		$(use_enable ssl ssl)
		$(use_enable ssl smime)
		$(use_with weather)
		--disable-gtk3
		--enable-largefile
		--with-libdb=/usr"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Adjust to gentoo's /etc/service
	epatch "${FILESDIR}/${PN}-2.31-gentoo_etc_services.patch"

	# GNOME bug 611353 (skips failing test atm)
	epatch "${FILESDIR}/e-d-s-camel-skip-failing-test.patch"

	# GNOME bug 621763 (skip failing test-ebook-stress-factory--fifo)
	sed -e 's/\(SUBDIRS =.*\)ebook/\1/' \
		-i addressbook/tests/Makefile.{am,in} \
		|| die "failing test sed 1 failed"

	# Fix build with >=libgdata-0.7
	epatch "${FILESDIR}/${PN}-2.32.1-libgdata07.patch"

	# /usr/include/db.h is always db-1 on FreeBSD
	# so include the right dir in CPPFLAGS
	append-cppflags "-I$(db_includedir)"

	# FIXME: Fix compilation flags crazyness
	sed 's/^\(AM_CPPFLAGS="\)$WARNING_FLAGS/\1/' \
		-i configure.ac configure || die "sed 3 failed"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

multilib-native_src_install_internal() {
	gnome2_src_install
	find "${ED}" -name "*.la" -delete || die "la files removal failed"

	if use ldap; then
		MY_MAJORV=$(get_version_component_range 1-2)
		insinto /etc/openldap/schema
		doins "${FILESDIR}"/calentry.schema || die "doins failed"
		dosym /usr/share/${PN}-${MY_MAJORV}/evolutionperson.schema /etc/openldap/schema/evolutionperson.schema
	fi
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	unset ORBIT_SOCKETDIR
	unset SESSION_MANAGER
	export XDG_DATA_HOME="${T}"
	unset DISPLAY
	Xemake check || die "Tests failed."
}

multilib-native_pkg_preinst_internal() {
	gnome2_pkg_preinst

	for lib in libcamel-provider-1.2.so.14 libedata-cal-1.2.so.7 \
		libgdata-1.2.so libgdata-google-1.2.so libcamel-1.2.so.14 \
		libedata-book-1.2.so.2 libebook-1.2.so.9 \
		libedataserver-1.2.so.13 libecal-1.2.so.7 libedataserverui-1.2.so.8
	do
		preserve_old_lib /usr/$(get_libdir)/$lib
	done
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst

	for lib in libcamel-provider-1.2.so.14 libedata-cal-1.2.so.7 \
		libgdata-1.2.so libgdata-google-1.2.so libcamel-1.2.so.14 \
		libedata-book-1.2.so.2 libebook-1.2.so.9 \
		libedataserver-1.2.so.13 libecal-1.2.so.7 libedataserverui-1.2.so.8
	do
		preserve_old_lib_notify /usr/$(get_libdir)/$lib
	done

	if use ldap; then
		elog ""
		elog "LDAP schemas needed by evolution are installed in /etc/openldap/schema"
	fi
}
