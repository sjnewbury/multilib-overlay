# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/cups/cups-1.4.2.ebuild,v 1.1 2009/11/13 18:53:55 tgurr Exp $

EAPI="2"

inherit eutils flag-o-matic multilib pam versionator multilib-native

MY_P=${P/_}

DESCRIPTION="The Common Unix Printing System."
HOMEPAGE="http://www.cups.org/"
SRC_URI="mirror://easysw/${PN}/${PV}/${MY_P}-source.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="acl dbus debug gnutls java +jpeg kerberos ldap pam perl php +png python samba slp +ssl static +tiff X xinetd zeroconf"

COMMON_DEPEND="acl? ( kernel_linux? ( sys-apps/acl sys-apps/attr ) )
	dbus? ( sys-apps/dbus[lib32?] )
	gnutls? ( net-libs/gnutls[lib32?] )
	java? ( >=virtual/jre-1.4 )
	jpeg? ( >=media-libs/jpeg-6b[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	ldap? ( net-nds/openldap[lib32?] )
	pam? ( virtual/pam[lib32?] )
	perl? ( dev-lang/perl[lib32?] )
	php? ( dev-lang/php )
	png? ( >=media-libs/libpng-1.2.1[lib32?] )
	python? ( dev-lang/python[lib32?] )
	slp? ( >=net-libs/openslp-1.0.4[lib32?] )
	ssl? ( !gnutls? ( >=dev-libs/openssl-0.9.8g[lib32?] ) )
	tiff? ( >=media-libs/tiff-3.5.5[lib32?] )
	xinetd? ( sys-apps/xinetd )
	zeroconf? ( || ( net-dns/avahi[mdnsresponder-compat,lib32?] net-misc/mDNSResponder[lib32?] ) )
	app-text/libpaper[lib32?]
	app-text/poppler-utils
	dev-libs/libgcrypt[lib32?]
	dev-libs/libusb[lib32?]
	!net-print/cupsddk"

DEPEND="${COMMON_DEPEND}"

RDEPEND="${COMMON_DEPEND}
	!virtual/lpr
	X? ( x11-misc/xdg-utils )"

PDEPEND="|| ( app-text/ghostscript-gpl[cups] app-text/ghostscript-gnu[cups] )"

PROVIDE="virtual/lpr"

# upstream includes an interactive test which is a nono for gentoo.
# therefore, since the printing herd has bigger fish to fry, for now,
# we just leave it out, even if FEATURES=test
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

LANGS="da de es eu fi fr it ja ko nl no pl pt pt_BR ru sv zh zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

multilib-native_pkg_setup_internal() {
	enewgroup lp
	enewuser lp -1 -1 -1 lp
	enewgroup lpadmin 106
}

multilib-native_src_prepare_internal() {
	# create a missing symlink to allow https printing via IPP, bug #217293
	epatch "${FILESDIR}/${PN}-1.4.0-backend-https.patch"
}

multilib-native_src_configure_internal() {
	# locale support
	strip-linguas ${LANGS}
	if [ -z "${LINGUAS}" ] ; then
		export LINGUAS=none
	fi

	local myconf

	if use ssl || use gnutls ; then
		myconf="${myconf} \
			$(use_enable gnutls) \
			$(use_enable !gnutls openssl)"
	else
		myconf="${myconf} \
			--disable-gnutls \
			--disable-openssl"
	fi

	econf \
		--libdir=/usr/$(get_libdir) \
		--localstatedir=/var \
		--with-cups-user=lp \
		--with-cups-group=lp \
		--with-docdir=/usr/share/cups/html \
		--with-languages=${LINGUAS} \
		--with-pdftops=pdftops \
		--with-system-groups=lpadmin \
		$(use_enable acl) \
		$(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable debug debug-guards) \
		$(use_enable jpeg) \
		$(use_enable kerberos gssapi) \
		$(use_enable ldap) \
		$(use_enable pam) \
		$(use_enable png) \
		$(use_enable slp) \
		$(use_enable static) \
		$(use_enable tiff) \
		$(use_enable xinetd xinetd /etc/xinetd.d) \
		$(use_enable zeroconf dnssd) \
		$(use_with java) \
		$(use_with perl) \
		$(use_with php) \
		$(use_with python) \
		--enable-libpaper \
		--enable-libusb \
		--enable-threads \
		--enable-pdftops \
		${myconf}

	# install in /usr/libexec always, instead of using /usr/lib/cups, as that
	# makes more sense when facing multilib support.
	sed -i -e 's:SERVERBIN.*:SERVERBIN = "$(BUILDROOT)"/usr/libexec/cups:' Makedefs
	sed -i -e 's:#define CUPS_SERVERBIN.*:#define CUPS_SERVERBIN "/usr/libexec/cups":' config.h
	sed -i -e 's:cups_serverbin=.*:cups_serverbin=/usr/libexec/cups:' cups-config
}

multilib-native_src_install_internal() {
	emake BUILDROOT="${D}" install || die "emake install failed"
	dodoc {CHANGES,CREDITS,README}.txt || die "dodoc install failed"

	# clean out cups init scripts
	rm -rf "${D}"/etc/{init.d/cups,rc*,pam.d/cups}

	# install our init script
	local neededservices
	use zeroconf && has_version 'net-dns/avahi' && neededservices="$neededservices avahi-daemon"
	use zeroconf && has_version 'net-misc/mDNSResponder' && neededservices="$neededservices mDNSResponderPosix"
	use dbus && neededservices="$neededservices dbus"
	[[ -n ${neededservices} ]] && neededservices="need${neededservices}"
	sed -e "s/@neededservices@/$neededservices/" "${FILESDIR}"/cupsd.init.d > "${T}"/cupsd
	doinitd "${T}"/cupsd || die "doinitd failed"

	# install our pam script
	pamd_mimic_system cups auth account

	if use xinetd ; then
		# correct path
		sed -i -e "s:server = .*:server = /usr/libexec/cups/daemon/cups-lpd:" "${D}"/etc/xinetd.d/cups-lpd
		# it is safer to disable this by default, bug #137130
		grep -w 'disable' "${D}"/etc/xinetd.d/cups-lpd || \
			sed -i -e "s:}:\tdisable = yes\n}:" "${D}"/etc/xinetd.d/cups-lpd
	else
		rm -rf "${D}"/etc/xinetd.d
	fi

	keepdir /usr/libexec/cups/driver /usr/share/cups/{model,profiles} \
		/var/cache/cups /var/cache/cups/rss /var/log/cups /var/run/cups/certs \
		/var/spool/cups/tmp

	keepdir /etc/cups/{interfaces,ppd,ssl}

	use X || rm -r "${D}"/usr/share/applications

	# create /etc/cups/client.conf, bug #196967 and #266678
	echo "ServerName /var/run/cups/cups.sock" >> "${D}"/etc/cups/client.conf

	prep_ml_binaries /usr/bin/cups-config
}

pkg_postinst() {
	echo
	elog "For information about installing a printer and general cups setup"
	elog "take a look at: http://www.gentoo.org/doc/en/printing-howto.xml"
	echo
}
