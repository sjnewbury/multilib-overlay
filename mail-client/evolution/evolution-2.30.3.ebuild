# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-client/evolution/evolution-2.30.3.ebuild,v 1.4 2010/12/21 22:06:14 eva Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools eutils flag-o-matic gnome2 python versionator multilib-native

DESCRIPTION="Integrated mail, addressbook and calendaring functionality"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="GPL-2 LGPL-2 OPENLDAP"
SLOT="2.0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="crypt doc gstreamer kerberos ldap networkmanager nntp pda python ssl"
# pst
# mono - disabled because it just crashes on startup :S

# Pango dependency required to avoid font rendering problems
# We need a graphical pinentry frontend to be able to ask for the GPG.
# Note that separate pinenetry-qt is actually newer than USE=qt4 in pinentry.
# password from inside evolution, bug 160302
PINENTRY_DEPEND="|| ( app-crypt/pinentry[gtk] app-crypt/pinentry-qt app-crypt/pinentry[qt4] app-crypt/pinentry[qt3] )"
RDEPEND=">=dev-libs/glib-2.22[lib32?]
	>=x11-libs/gtk+-2.18[lib32?]
	>=gnome-extra/evolution-data-server-$(get_version_component_range 1-2)[weather]
	>=gnome-base/gnome-desktop-2.26[lib32?]
	>=gnome-extra/gtkhtml-3.29.6[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=gnome-base/libgnomecanvas-2[lib32?]
	dev-libs/atk[lib32?]
	>=dev-libs/dbus-glib-0.74[lib32?]
	>=dev-libs/libunique-1.1.2[lib32?]
	>=dev-libs/libxml2-2.7.3[lib32?]
	>=dev-libs/libgweather-2.25.3[lib32?]
	>=net-libs/libsoup-2.4[lib32?]
	>=media-gfx/gtkimageview-1.6[lib32?]
	media-libs/libcanberra[gtk,lib32?]
	x11-libs/libnotify[lib32?]
	>=x11-misc/shared-mime-info-0.22
	>=x11-themes/gnome-icon-theme-2.20

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
	pda? (
		>=app-pda/gnome-pilot-2.0.16[lib32?]
		>=app-pda/gnome-pilot-conduits-2[lib32?] )
	python? ( >=dev-lang/python-2.4[lib32?] )
	ssl? (
		>=dev-libs/nspr-4.6.1[lib32?]
		>=dev-libs/nss-3.11[lib32?] )

	!<gnome-extra/evolution-exchange-2.30"
# champlain, geoclue, clutter, gtkimageview
#	mono? ( >=dev-lang/mono-1 )

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

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS* README"
ELTCONF="--reverse-deps"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--without-kde-applnk-path
		--enable-plugins=experimental
		--enable-image-inline
		--enable-canberra
		--enable-weather
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable networkmanager nm)
		$(use_enable nntp)
		$(use_enable gstreamer audio-inline)
		$(use_enable pda pilot-conduits)
		--disable-profiling
		--disable-pst-import
		$(use_enable python)
		$(use_with ldap openldap)
		$(use_with kerberos krb5 /usr)
		--disable-contacts-map"

#		$(use_enable mono)

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
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix linking issues with libeshell, upstream #629098
	epatch "${FILESDIR}/${PN}-2.30.3-fix-linking-issues-in-libeshell.patch"

	# FIXME: Fix compilation flags crazyness
	sed -e 's/CFLAGS="$CFLAGS $WARNING_FLAGS"//' \
		-i configure.ac configure || die "sed 1 failed"
	sed -e 's/-DG.*_DISABLE_DEPRECATED//' \
		-e 's/-DPANGO_DISABLE_DEPRECATED//' \
		-i configure.ac configure || die "sed 2 failed"

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		sed -e 's|mozilla-nss|nss|' \
			-e 's|mozilla-nspr|nspr|' \
			-i configure.ac configure || die "sed 3 failed"
	fi

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
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
