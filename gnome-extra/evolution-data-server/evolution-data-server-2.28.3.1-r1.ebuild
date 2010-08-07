# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/evolution-data-server/evolution-data-server-2.28.3.1-r1.ebuild,v 1.5 2010/08/05 16:56:20 ssuominen Exp $

EAPI="2"

inherit autotools db-use eutils flag-o-matic gnome2 versionator multilib-native

DESCRIPTION="Evolution groupware backend"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="LGPL-2 BSD DB"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE="doc ipv6 kerberos gnome-keyring ldap ssl"

RDEPEND=">=dev-libs/glib-2.16.1[lib32?]
	>=x11-libs/gtk+-2.14[lib32?]
	>=gnome-base/orbit-2.9.8[lib32?]
	>=gnome-base/libbonobo-2.20.3[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=gnome-base/libglade-2[lib32?]
	>=dev-libs/libxml2-2[lib32?]
	>=net-libs/libsoup-2.4[lib32?]
	>=dev-libs/libgweather-2.25.4[lib32?]
	>=dev-libs/libical-0.43[lib32?]
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.20.1[lib32?] )
	>=dev-db/sqlite-3.5[lib32?]
	ssl? (
		>=dev-libs/nspr-4.4[lib32?]
		>=dev-libs/nss-3.9[lib32?] )
	sys-libs/zlib[lib32?]
	=sys-libs/db-4*[lib32?]
	ldap? ( >=net-nds/openldap-2.0[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9[lib32?]
	>=dev-util/intltool-0.35.5
	>=gnome-base/gnome-common-2
	>=dev-util/gtk-doc-am-1.9
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="ChangeLog MAINTAINERS NEWS TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		$(use_with ldap openldap)
		$(use_with kerberos krb5 /usr)
		$(use_with kerberos krb5-libs /usr/$(get_libdir) )
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable ipv6)
		$(use_enable gnome-keyring)
		--with-weather
		--with-libdb=/usr/$(get_libdir)"
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Adjust to gentoo's /etc/service
	epatch "${FILESDIR}/${PN}-2.28.0-gentoo_etc_services.patch"

	# Rewind in camel-disco-diary to fix a crash
	epatch "${FILESDIR}/${PN}-1.8.0-camel-rewind.patch"

	# Append .1 to version properly as talked with upstream
	epatch "${FILESDIR}/${P}-version-number.patch"

	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/usr/bin/gtkdoc-rebase" \
			-i gtk-doc.make || die "sed 1 failed"
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=$(type -P true)" \
			-i gtk-doc.make || die "sed 2 failed"
	fi

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		sed -i -e "s|mozilla-nss|nss|
			s|mozilla-nspr|nspr|" "${S}"/configure || die "sed failed"
		G2CONF="${G2CONF} --enable-nss=yes"
	else
		G2CONF="${G2CONF} --without-nspr-libs --without-nspr-includes \
		--without-nss-libs --without-nss-includes"
	fi

	# /usr/include/db.h is always db-1 on FreeBSD
	# so include the right dir in CPPFLAGS
	append-cppflags "-I$(db_includedir)"

	# FIXME: Fix compilation flags crazyness
	sed 's/CFLAGS="$CFLAGS $WARNING_FLAGS"//' \
		-i configure.ac configure || die "sed 3 failed"

	# Fix intltoolize broken file, see upstream #577133
	sed "s:'\^\$\$lang\$\$':\^\$\$lang\$\$:g" -i po/Makefile.in.in \
		|| die "intltool rules fix failed"

	eautoconf
}

multilib-native_src_install_internal() {
	gnome2_src_install

	if use ldap; then
		MY_MAJORV=$(get_version_component_range 1-2)
		insinto /etc/openldap/schema
		doins "${FILESDIR}"/calentry.schema || die "doins failed"
		dosym /usr/share/${PN}-${MY_MAJORV}/evolutionperson.schema /etc/openldap/schema/evolutionperson.schema
	fi
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst

	if use ldap; then
		elog ""
		elog "LDAP schemas needed by evolution are installed in /etc/openldap/schema"
	fi
}
