# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/evolution-data-server/evolution-data-server-2.26.3.ebuild,v 1.2 2009/07/22 21:21:52 eva Exp $

EAPI="2"

inherit db-use eutils flag-o-matic gnome2 autotools versionator multilib-native

DESCRIPTION="Evolution groupware backend"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="LGPL-2 Sleepycat"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="doc ipv6 kerberos gnome-keyring krb4 ldap ssl"

RDEPEND=">=dev-libs/glib-2.16.1[$(get_ml_usedeps)]
	>=x11-libs/gtk+-2.14[$(get_ml_usedeps)]
	>=gnome-base/orbit-2.9.8[$(get_ml_usedeps)]
	>=gnome-base/libbonobo-2.20.3[$(get_ml_usedeps)]
	>=gnome-base/gconf-2[$(get_ml_usedeps)]
	>=gnome-base/libglade-2[$(get_ml_usedeps)]
	>=gnome-base/libgnome-2[$(get_ml_usedeps)]
	>=dev-libs/libxml2-2[$(get_ml_usedeps)]
	>=net-libs/libsoup-2.4[$(get_ml_usedeps)]
	>=dev-libs/libgweather-2.25.4[$(get_ml_usedeps)]
	>=dev-libs/libical-0.43[$(get_ml_usedeps)]
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.20.1[$(get_ml_usedeps)] )
	>=dev-db/sqlite-3.5[$(get_ml_usedeps)]
	ssl? (
		>=dev-libs/nspr-4.4[$(get_ml_usedeps)]
		>=dev-libs/nss-3.9[$(get_ml_usedeps)] )
	>=gnome-base/libgnomeui-2[$(get_ml_usedeps)]
	sys-libs/zlib[$(get_ml_usedeps)]
	=sys-libs/db-4*[$(get_ml_usedeps)]
	ldap? ( >=net-nds/openldap-2.0[$(get_ml_usedeps)] )
	kerberos? ( virtual/krb5 )
	krb4? ( app-crypt/mit-krb5[krb4,$(get_ml_usedeps)] )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35.5
	>=gnome-base/gnome-common-2
	>=dev-util/gtk-doc-am-1.9
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="ChangeLog MAINTAINERS NEWS TODO"

ml-native_pkg_setup() {
	G2CONF="${G2CONF}
		$(use_with ldap openldap)
		$(use_with krb4 krb4 /usr)
		$(use_with kerberos krb5 /usr)
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_with ssl nss-libs /usr/$(get_libdir)/nss)
		$(use_with ssl nspr-libs /usr/$(get_libdir)/nspr)
		$(use_with ssl nss-includes /usr/include/nss)
		$(use_with ssl nspr-includes /usr/include/nspr)
		$(use_enable ipv6)
		$(use_enable gnome-keyring)
		--with-weather
		--with-libdb=/usr/$(get_libdir)"
}

ml-native_src_prepare() {
	gnome2_src_prepare

	# Adjust to gentoo's /etc/service
	epatch "${FILESDIR}"/${PN}-2.27.5-gentoo_etc_services.patch

	# Fix broken libdb build
	epatch "${FILESDIR}"/${PN}-2.27.5-no-libdb.patch

	# Rewind in camel-disco-diary to fix a crash
	epatch "${FILESDIR}"/${PN}-1.8.0-camel-rewind.patch

	# Fix building evo-exchange with --as-needed, upstream bug #342830
	# and configure failing to detect kerberos5-libs with as-needed
	epatch "${FILESDIR}"/${PN}-2.27.5-as-needed.patch

	epatch "${FILESDIR}"/${PN}-2.27.5-disable-dolt.patch

	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/usr/bin/gtkdoc-rebase" \
			-i gtk-doc.make || die "sed 1 failed"
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=$(type -P true)" \
			-i gtk-doc.make || die "sed 2 failed"
	fi

	export dolt_supported=no

	# gtk-doc-am and gnome-common needed for this
	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf

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
}

ml-native_src_install() {
	gnome2_src_install

	if use ldap; then
		MY_MAJORV=$(get_version_component_range 1-2)
		insinto /etc/openldap/schema
		doins "${FILESDIR}"/calentry.schema || die "doins failed"
		dosym "${D}"/usr/share/${PN}-${MY_MAJORV}/evolutionperson.schema /etc/openldap/schema/evolutionperson.schema
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	if use ldap; then
		elog ""
		elog "LDAP schemas needed by evolution are installed in /etc/openldap/schema"
	fi
}
