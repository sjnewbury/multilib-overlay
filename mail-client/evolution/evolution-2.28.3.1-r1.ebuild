# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-client/evolution/evolution-2.28.3.1-r1.ebuild,v 1.3 2010/07/19 15:18:20 jer Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools gnome2 flag-o-matic python multilib-native

DESCRIPTION="Integrated mail, addressbook and calendaring functionality"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="GPL-2 FDL-1.1"
SLOT="2.0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="crypt dbus hal kerberos krb4 ldap mono networkmanager nntp pda profile python ssl gstreamer exchange"
# pst

# Pango dependency required to avoid font rendering problems
# We need a graphical pinentry frontend to be able to ask for the GPG
# password from inside evolution, bug 160302
RDEPEND=">=dev-libs/glib-2.20[lib32?]
	>=x11-libs/gtk+-2.16[lib32?]
	>=gnome-extra/evolution-data-server-${PV}[lib32?]
	>=x11-themes/gnome-icon-theme-2.20
	>=gnome-base/libbonobo-2.20.3[lib32?]
	>=gnome-base/libbonoboui-2.4.2[lib32?]
	>=gnome-extra/gtkhtml-3.27.90[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=gnome-base/libglade-2[lib32?]
	>=gnome-base/libgnomecanvas-2[lib32?]
	>=gnome-base/libgnomeui-2[lib32?]
	>=dev-libs/libxml2-2.7.3[lib32?]
	>=dev-libs/libgweather-2.25.3[lib32?]
	>=x11-misc/shared-mime-info-0.22
	>=gnome-base/gnome-desktop-2.26.0[lib32?]
	dbus? ( >=dev-libs/dbus-glib-0.74[lib32?] )
	hal? ( >=sys-apps/hal-0.5.4[lib32?] )
	x11-libs/libnotify[lib32?]
	pda? (
		>=app-pda/gnome-pilot-2.0.15[lib32?]
		>=app-pda/gnome-pilot-conduits-2[lib32?] )
	dev-libs/atk[lib32?]
	ssl? (
		>=dev-libs/nspr-4.6.1[lib32?]
		>=dev-libs/nss-3.11[lib32?] )
	networkmanager? (
		>=net-misc/networkmanager-0.7[lib32?]
		>=dev-libs/dbus-glib-0.74[lib32?] )
	>=net-libs/libsoup-2.4[lib32?]
	kerberos? ( virtual/krb5[lib32?] )
	krb4? ( app-crypt/mit-krb5[krb4,lib32?] )
	>=gnome-base/orbit-2.9.8[lib32?]
	crypt? ( || (
				  ( >=app-crypt/gnupg-2.0.1-r2[lib32?]
					app-crypt/pinentry[gtk] )
				  =app-crypt/gnupg-1.4*[lib32?] ) )
	ldap? ( >=net-nds/openldap-2[lib32?] )
	mono? ( >=dev-lang/mono-1 )
	python? ( >=dev-lang/python-2.4[lib32?] )
	gstreamer? (
		>=media-libs/gstreamer-0.10[lib32?]
		>=media-libs/gst-plugins-base-0.10[lib32?] )"
# Disabled until API stabilizes
#	pst? ( >=net-mail/libpst-0.6.41 )

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16[lib32?]
	>=dev-util/intltool-0.35.5
	sys-devel/gettext[lib32?]
	sys-devel/bison
	app-text/scrollkeeper
	>=gnome-base/gnome-common-2.12.0
	>=app-text/gnome-doc-utils-0.9.1[lib32?]
	app-text/docbook-xml-dtd:4.1.2"

PDEPEND="exchange? ( >=gnome-extra/evolution-exchange-2.26.1 )"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS* README"
ELTCONF="--reverse-deps"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--without-kde-applnk-path
		--enable-plugins=experimental
		--with-weather
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable mono)
		$(use_enable nntp)
		$(use_enable networkmanager nm)
		$(use_enable dbus)
		$(use_enable gstreamer audio-inline)
		$(use_enable exchange)
		--disable-pst-import
		$(use_enable pda pilot-conduits)
		$(use_enable profile profiling)
		$(use_enable python)
		$(use_with ldap openldap)
		$(use_with kerberos krb5 /usr)
		$(use_with krb4 krb4 /usr)"

	# DBUS is required for NetworkManager support (Bug #317841)
	use networkmanager && G2CONF="${G2CONF} --enable-dbus"

	# dang - I've changed this to do --enable-plugins=experimental.  This will
	# autodetect new-mail-notify and exchange, but that cannot be helped for the
	# moment.  They should be changed to depend on a --enable-<foo> like mono
	# is.  This cleans up a ton of crap from this ebuild.
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix timezone offsets on fbsd.  bug #183708
	# FIXME: bsd needs to be more active at pushing stuff upstream
	#epatch "${FILESDIR}/${PN}-2.21.3-fbsd.patch"

	# Fix delete keyboard shortcut, bug #????
	epatch "${FILESDIR}/${PN}-2.28.0-delete-key.patch"

	# Fix multiple automagic plugins, bug #204300 & bug #271451
	epatch "${FILESDIR}/${PN}-2.28.0-automagic-plugins.patch"

	# Apply all current 2.28.3.1 upstream fixes:
	epatch "${FILESDIR}/${P}-attachment-bar-RTL.patch"
	epatch "${FILESDIR}/${P}-unknown-attachment-size.patch"
	# Bug #317765
	epatch "${FILESDIR}/${P}-allow-setting-alarms_1.patch"
	epatch "${FILESDIR}/${P}-allow-setting-alarms_2.patch"
	epatch "${FILESDIR}/${P}-allow-setting-alarms_3.patch"

	# FIXME: Fix compilation flags crazyness
	sed 's/CFLAGS="$CFLAGS $WARNING_FLAGS"//' \
		-i configure.ac configure || die "sed 1 failed"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		sed -i -e "s|mozilla-nss|nss|
			s|mozilla-nspr|nspr|" "${S}"/configure || die "sed 1 failed"
		G2CONF="${G2CONF} --enable-nss=yes"
	else
		G2CONF="${G2CONF} --without-nspr-libs --without-nspr-includes \
			--without-nss-libs --without-nss-includes"
	fi

	# problems with -O3 on gcc-3.3.1
	replace-flags -O3 -O2
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst

	elog "To change the default browser if you are not using GNOME, do:"
	elog "gconftool-2 --set /desktop/gnome/url-handlers/http/command -t string 'mozilla %s'"
	elog "gconftool-2 --set /desktop/gnome/url-handlers/https/command -t string 'mozilla %s'"
	elog ""
	elog "Replace 'mozilla %s' with which ever browser you use."
	elog ""
	elog "Junk filters are now a run-time choice. You will get a choice of"
	elog "bogofilter or spamassassin based on which you have installed"
	elog ""
	elog "You have to install one of these for the spam filtering to actually work"
}
