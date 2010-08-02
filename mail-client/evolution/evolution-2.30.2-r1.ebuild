# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/mail-client/evolution/evolution-2.30.2-r1.ebuild,v 1.4 2010/08/01 11:50:58 fauli Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit autotools gnome2 flag-o-matic python versionator multilib-native

DESCRIPTION="Integrated mail, addressbook and calendaring functionality"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="GPL-2 LGPL-2 OPENLDAP"
SLOT="2.0"
KEYWORDS="~alpha amd64 ~ia64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"

SRC_URI="${SRC_URI}
	mirror://gentoo/${P}-patches.tar.bz2"

IUSE="crypt kerberos ldap networkmanager pda profile python ssl
gstreamer +sound"
# pst
# mono - disabled because it just crashes on startup :S

# Pango dependency required to avoid font rendering problems
# We need a graphical pinentry frontend to be able to ask for the GPG
# password from inside evolution, bug 160302
RDEPEND=">=dev-libs/glib-2.22[lib32?]
	>=x11-libs/gtk+-2.18[lib32?]
	>=gnome-extra/evolution-data-server-$(get_version_component_range 1-2)
	>=gnome-base/gnome-desktop-2.26.0[lib32?]
	>=gnome-extra/gtkhtml-3.29.6[lib32?]
	>=gnome-base/gconf-2[lib32?]
	>=gnome-base/libgnomecanvas-2[lib32?]
	dev-libs/atk[lib32?]
	>=dev-libs/dbus-glib-0.74[lib32?]
	>=dev-libs/libunique-1[lib32?]
	>=dev-libs/libxml2-2.7.3[lib32?]
	>=dev-libs/libgweather-2.25.3[lib32?]
	>=net-libs/libsoup-2.4[lib32?]
	>=media-gfx/gtkimageview-1.6[lib32?]
	x11-libs/libnotify[lib32?]
	>=x11-misc/shared-mime-info-0.22
	>=x11-themes/gnome-icon-theme-2.20

	crypt? ( || (
				  ( >=app-crypt/gnupg-2.0.1-r2[lib32?]
					|| ( app-crypt/pinentry[gtk] app-crypt/pinentry[qt3] ) )
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
	sound? ( media-libs/libcanberra[lib32?] )
	ssl? (
		>=dev-libs/nspr-4.6.1[lib32?]
		>=dev-libs/nss-3.11[lib32?] )"
# champlain, geoclue, clutter, gtkimageview
#	mono? ( >=dev-lang/mono-1 )

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16[lib32?]
	>=dev-util/intltool-0.35.5
	sys-devel/gettext[lib32?]
	sys-devel/bison
	app-text/scrollkeeper
	>=gnome-base/gnome-common-2.12.0
	>=app-text/gnome-doc-utils-0.9.1[lib32?]"

DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS* README"
ELTCONF="--reverse-deps"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--without-kde-applnk-path
		--enable-plugins=experimental
		--enable-image-inline
		--enable-weather
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable networkmanager nm)
		$(use_enable gstreamer audio-inline)
		$(use_enable sound canberra)
		--disable-pst-import
		$(use_enable pda pilot-conduits)
		$(use_enable profile profiling)
		$(use_enable python)
		$(use_with ldap openldap)
		$(use_with kerberos krb5 /usr)
		--disable-contacts-map"

#		$(use_enable mono)

	# dang - I've changed this to do --enable-plugins=experimental.  This will
	# autodetect new-mail-notify and exchange, but that cannot be helped for the
	# moment.  They should be changed to depend on a --enable-<foo> like mono
	# is.  This cleans up a ton of crap from this ebuild.
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# FIXME: Fix compilation flags crazyness
	sed 's/CFLAGS="$CFLAGS $WARNING_FLAGS"//' \
		-i configure.ac configure || die "sed 1 failed"

	# Do not require unstable libunique
	epatch "${FILESDIR}/${PN}-2.30.1.2-configure.patch"

	# Apply upstream patches committed to gnome-2.30 branch
	epatch "${WORKDIR}"/${P}-patches/*.patch

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
