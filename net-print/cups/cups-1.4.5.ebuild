# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/cups/cups-1.4.5.ebuild,v 1.1 2010/12/01 12:34:34 scarabeus Exp $

EAPI=3

PYTHON_DEPEND="python? 2:2.5"

inherit autotools eutils flag-o-matic multilib pam perl-module python versionator java-pkg-opt-2 multilib-native

MY_P=${P/_}

DESCRIPTION="The Common Unix Printing System"
HOMEPAGE="http://www.cups.org/"
SRC_URI="mirror://easysw/${PN}/${PV}/${MY_P}-source.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="acl dbus debug gnutls java +jpeg kerberos ldap pam perl php +png python samba slp +ssl static-libs +threads +tiff +usb X xinetd"

LANGS="da de es eu fi fr id it ja ko nl no pl pt pt_BR ru sv zh zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

RDEPEND="
	app-text/libpaper[lib32?]
	dev-libs/libgcrypt[lib32?]
	acl? (
		kernel_linux? (
			sys-apps/acl[lib32?]
			sys-apps/attr[lib32?]
		)
	)
	dbus? ( sys-apps/dbus[lib32?] )
	java? ( >=virtual/jre-1.6 )
	jpeg? ( virtual/jpeg:0[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	ldap? ( net-nds/openldap[ssl?,gnutls?,lib32?] )
	pam? ( virtual/pam[lib32?] )
	perl? ( dev-lang/perl[lib32?] )
	php? ( dev-lang/php )
	png? ( >=media-libs/libpng-1.4.3[lib32?] )
	slp? ( >=net-libs/openslp-1.0.4[lib32?] )
	ssl? (
		gnutls? ( net-libs/gnutls[lib32?] )
		!gnutls? ( >=dev-libs/openssl-0.9.8g[lib32?] )
	)
	tiff? ( >=media-libs/tiff-3.5.5[lib32?] )
	usb? ( virtual/libusb:0[lib32?] )
	X? ( x11-misc/xdg-utils )
	xinetd? ( sys-apps/xinetd )
	!net-print/cupsddk
"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
"

PDEPEND="
	app-text/ghostscript-gpl[cups]
	>=app-text/poppler-0.12.3-r3[utils]
"

PROVIDE="virtual/lpr"

# upstream includes an interactive test which is a nono for gentoo.
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

multilib-native_pkg_setup_internal() {
	enewgroup lp
	enewuser lp -1 -1 -1 lp
	enewgroup lpadmin 106

	# python 3 is no-go
	python_set_active_version 2
	python_pkg_setup
}

multilib-native_src_prepare_internal() {
	# create a missing symlink to allow https printing via IPP, bug #217293
	epatch "${FILESDIR}/${PN}-1.4.0-backend-https.patch"
	# various build time fixes
	epatch "${FILESDIR}/${PN}-1.4.4-dont-compress-manpages.patch"
	epatch "${FILESDIR}/${PN}-1.4.4-fix-install-perms.patch"
	epatch "${FILESDIR}/${PN}-1.4.4-nostrip.patch"
	epatch "${FILESDIR}/${PN}-1.4.4-php-destdir.patch"
	epatch "${FILESDIR}/${PN}-1.4.4-perl-includes.patch"

	AT_M4DIR=config-scripts eaclocal
	eautoconf
}

multilib-native_src_configure_internal() {
	export DSOFLAGS="${LDFLAGS}"

	# locale support
	strip-linguas ${LANGS}
	if [ -z "${LINGUAS}" ] ; then
		export LINGUAS=none
	fi

	local myconf
	if use ssl || use gnutls ; then
		myconf+="
			$(use_enable gnutls)
			$(use_enable !gnutls openssl)
		"
	else
		myconf+="
			--disable-gnutls
			--disable-openssl
		"
	fi

	econf \
		--libdir=/usr/$(get_libdir) \
		--localstatedir=/var \
		--with-cups-user=lp \
		--with-cups-group=lp \
		--with-docdir=/usr/share/cups/html \
		--with-languages="${LINGUAS}" \
		--with-pdftops=/usr/bin/pdftops \
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
		$(use_enable static-libs static) \
		$(use_enable threads) \
		$(use_enable tiff) \
		$(use_enable usb libusb) \
		$(use_with java) \
		$(use_with perl) \
		$(use_with php) \
		$(use_with python) \
		$(use_with xinetd xinetd /etc/xinetd.d) \
		--enable-libpaper \
		--disable-dnssd \
		${myconf}

	# install in /usr/libexec always, instead of using /usr/lib/cups, as that
	# makes more sense when facing multilib support.
	sed -i -e 's:SERVERBIN.*:SERVERBIN = "$(BUILDROOT)"/usr/libexec/cups:' Makedefs || die
	sed -i -e 's:#define CUPS_SERVERBIN.*:#define CUPS_SERVERBIN "/usr/libexec/cups":' config.h || die
	sed -i -e 's:cups_serverbin=.*:cups_serverbin=/usr/libexec/cups:' cups-config || die
}

multilib-native_src_compile_internal() {
	emake || die "emake failed"

	if use perl ; then
		cd "${S}"/scripting/perl
		perl-module_src_prep
		perl-module_src_compile
	fi

	if use php ; then
		cd "${S}"/scripting/php
		emake || die "emake php failed"
	fi
}

multilib-native_src_install_internal() {
	emake BUILDROOT="${D}" install || die "emake install failed"
	dodoc {CHANGES,CREDITS,README}.txt || die "dodoc install failed"

	if use perl ; then
		cd "${S}"/scripting/perl
		perl-module_src_install
		fixlocalpod
	fi

	if use php ; then
		cd "${S}"/scripting/php
		emake DESTDIR="${D}" install || die "emake install for php bindings failed"
	fi

	# clean out cups init scripts
	rm -rf "${D}"/etc/{init.d/cups,rc*,pam.d/cups}

	# install our init script
	local neededservices
	use dbus && neededservices+=" dbus"
	[[ -n ${neededservices} ]] && neededservices="need${neededservices}"
	cp "${FILESDIR}"/cupsd.init.d "${T}"/cupsd || die
	sed -i \
		-e "s/@neededservices@/$neededservices/" \
		"${T}"/cupsd || die
	doinitd "${T}"/cupsd || die "doinitd failed"

	# install our pam script
	pamd_mimic_system cups auth account

	if use xinetd ; then
		# correct path
		sed -i \
			-e "s:server = .*:server = /usr/libexec/cups/daemon/cups-lpd:" \
			"${D}"/etc/xinetd.d/cups-lpd || die
		# it is safer to disable this by default, bug #137130
		grep -w 'disable' "${D}"/etc/xinetd.d/cups-lpd || \
			{ sed -i -e "s:}:\tdisable = yes\n}:" "${D}"/etc/xinetd.d/cups-lpd || die ; }
		# write permission for file owner (root), bug #296221
		fperms u+w /etc/xinetd.d/cups-lpd || die "fperms failed"
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

multilib-native_pkg_postinst_internal() {
	echo
	elog "For information about installing a printer and general cups setup"
	elog "take a look at: http://www.gentoo.org/doc/en/printing-howto.xml"
	echo
}
