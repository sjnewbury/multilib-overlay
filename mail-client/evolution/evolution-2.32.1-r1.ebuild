# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-client/evolution/evolution-2.32.1-r1.ebuild,v 1.1 2011/01/01 18:06:57 pacho Exp $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="python? 2:2.4"

inherit autotools flag-o-matic gnome2 python versionator multilib-native

MY_MAJORV=$(get_version_component_range 1-2)

DESCRIPTION="Integrated mail, addressbook and calendaring functionality"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

SRC_URI="${SRC_URI} mirror://gentoo/${P}-patches.tar.bz2"

LICENSE="GPL-2 LGPL-2 OPENLDAP"
SLOT="2.0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="clutter connman crypt doc gstreamer kerberos ldap networkmanager python ssl"

# We need a graphical pinentry frontend to be able to ask for the GPG
# password from inside evolution, bug 160302
PINENTRY_DEPEND="|| ( app-crypt/pinentry[gtk] app-crypt/pinentry-qt app-crypt/pinentry[qt4] )"

# contacts-map plugin requires libchaimplain and geoclue
# glade-3 support is for maintainers only per configure.ac
# mono plugin disabled as it's incompatible with 2.8 and lacks maintainance (see bgo#634571)
# pst is not mature enough and changes API/ABI frequently
RDEPEND=">=dev-libs/glib-2.25.12:2[lib32?]
	>=x11-libs/gtk+-2.20.0:2[lib32?]
	>=dev-libs/libunique-1.1.2[lib32?]
	>=gnome-base/gnome-desktop-2.26:2[lib32?]
	>=dev-libs/libgweather-2.25.3[lib32?]
	media-libs/libcanberra[gtk,lib32?]
	>=x11-libs/libnotify-0.3[lib32?]
	>=gnome-extra/evolution-data-server-${PV}-r1[weather]
	>=gnome-extra/gtkhtml-3.31.90:3.14[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=gnome-base/libgnomecanvas-2[lib32?]
	dev-libs/atk[lib32?]
	>=dev-libs/libxml2-2.7.3[lib32?]
	>=net-libs/libsoup-2.4:2.4[lib32?]
	>=media-gfx/gtkimageview-1.6[lib32?]
	>=x11-misc/shared-mime-info-0.22
	>=x11-themes/gnome-icon-theme-2.30.2.1
	>=dev-libs/libgdata-0.4[lib32?]

	clutter? ( media-libs/clutter:1.0[gtk] )
	connman? ( net-misc/connman )
	crypt? ( || (
				  ( >=app-crypt/gnupg-2.0.1-r2[lib32?]
					${PINENTRY_DEPEND} )
				  =app-crypt/gnupg-1.4*[lib32?] ) )
	gstreamer? (
		>=media-libs/gstreamer-0.10[lib32?]
		>=media-libs/gst-plugins-base-0.10[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	ldap? ( >=net-nds/openldap-2[lib32?] )
	networkmanager? ( >=net-misc/networkmanager-0.7[lib32?] )
	ssl? (
		>=dev-libs/nspr-4.6.1[lib32?]
		>=dev-libs/nss-3.11[lib32?] )

	!<gnome-extra/evolution-exchange-2.32"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16[lib32?]
	>=dev-util/intltool-0.35.5
	sys-devel/gettext[lib32?]
	sys-devel/bison
	app-text/scrollkeeper
	>=app-text/gnome-doc-utils-0.9.1[lib32?]
	app-text/docbook-xml-dtd:4.1.2
	>=gnome-base/gnome-common-2.12
	>=dev-util/gtk-doc-am-1.9
	doc? ( >=dev-util/gtk-doc-1.9 )"
# eautoreconf needs:
#	>=gnome-base/gnome-common-2.12
#	>=dev-util/gtk-doc-am-1.9

multilib-native_pkg_setup_internal() {
	ELTCONF="--reverse-deps"
	DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS* README"
	G2CONF="${G2CONF}
		--without-kde-applnk-path
		--enable-plugins=experimental
		--enable-image-inline
		--enable-canberra
		--enable-weather
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable networkmanager nm)
		$(use_enable connman)
		$(use_enable gstreamer audio-inline)
		--disable-profiling
		--disable-pst-import
		$(use_enable python)
		$(use_with clutter)
		$(use_with ldap openldap)
		$(use_with kerberos krb5 /usr)
		--disable-contacts-map
		--without-glade-catalog
		--disable-mono
		--disable-gtk3"

	# dang - I've changed this to do --enable-plugins=experimental.  This will
	# autodetect new-mail-notify and exchange, but that cannot be helped for the
	# moment.  They should be changed to depend on a --enable-<foo> like mono
	# is.  This cleans up a ton of crap from this ebuild.

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		G2CONF="${G2CONF} --enable-nss=yes"
	else
		G2CONF="${G2CONF}
			--without-nspr-libs
			--without-nspr-includes
			--without-nss-libs
			--without-nss-includes"
	fi

	# NM and connman support cannot coexist
	if use networkmanager && use connman ; then
		ewarn "It is not possible to enable both ConnMan and NetworkManager, disabling connman..."
		G2CONF="${G2CONF} --disable-connman"
	fi

	python_set_active_version 2
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix invalid use of la file in contact-editor, upstream bug #635002
	epatch "${FILESDIR}/${PN}-2.32.0-wrong-lafile-usage.patch"

	# Apply upstream patches committed to gnome-2.32 branch
	epatch "${WORKDIR}"/${P}-patches/*.patch

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		sed -e 's|mozilla-nss|nss|' \
			-e 's|mozilla-nspr|nspr|' \
			-i configure.ac configure || die "sed 2 failed"
	fi

	# Fix compilation flags crazyness
	sed -e 's/CFLAGS="$CFLAGS $WARNING_FLAGS"//' \
		-i configure.ac configure || die "sed 1 failed"

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

multilib-native_src_install_internal() {
	gnome2_src_install

	find "${ED}"/usr/$(get_libdir)/evolution/${MY_MAJORV}/plugins \
		-name "*.la" -delete || die "la files removal failed 1"
	find "${ED}"/usr/$(get_libdir)/evolution/${MY_MAJORV}/modules \
		-name "*.la" -delete || die "la files removal failed 2"
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst

	elog "To change the default browser if you are not using GNOME, do:"
	elog "gconftool-2 --set /desktop/gnome/url-handlers/http/command -t string 'firefox %s'"
	elog "gconftool-2 --set /desktop/gnome/url-handlers/https/command -t string 'firefox %s'"
	elog ""
	elog "Replace 'firefox %s' with which ever browser you use."
	elog ""
	elog "Junk filters are now a run-time choice. You will get a choice of"
	elog "bogofilter or spamassassin based on which you have installed"
	elog ""
	elog "You have to install one of these for the spam filtering to actually work"
}
