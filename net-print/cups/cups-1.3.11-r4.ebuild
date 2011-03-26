# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/cups/cups-1.3.11-r4.ebuild,v 1.4 2011/03/19 17:56:31 ssuominen Exp $

EAPI=2
inherit autotools eutils flag-o-matic multilib pam multilib-native

MY_P=${P/_}

DESCRIPTION="The Common Unix Printing System"
HOMEPAGE="http://www.cups.org/"
SRC_URI="mirror://easysw/${PN}/${PV}/${MY_P}-source.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="acl avahi dbus gnutls java jpeg kerberos ldap pam perl php png ppds python samba slp ssl static tiff X xinetd zeroconf"

COMMON_DEPEND="
	app-text/libpaper[lib32?]
	dev-libs/libgcrypt[lib32?]
	acl? (
		kernel_linux? (
			sys-apps/acl[lib32?]
			sys-apps/attr[lib32?]
		)
	)
	avahi? ( net-dns/avahi[mdnsresponder-compat,lib32?] )
	dbus? ( sys-apps/dbus[lib32?] )
	gnutls? ( net-libs/gnutls[lib32?] )
	java? ( >=virtual/jre-1.4 )
	jpeg? ( virtual/jpeg[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	ldap? ( net-nds/openldap[lib32?] )
	pam? ( virtual/pam[lib32?] )
	perl? ( dev-lang/perl[lib32?] )
	php? ( dev-lang/php )
	png? ( >=media-libs/libpng-1.2.1[lib32?] )
	python? ( dev-lang/python[lib32?] )
	slp? ( >=net-libs/openslp-1.0.4[lib32?] )
	ssl? (
		!gnutls? ( >=dev-libs/openssl-0.9.8g[lib32?] )
	)
	tiff? ( >=media-libs/tiff-3.5.5[lib32?] )
	xinetd? ( sys-apps/xinetd )
	zeroconf? (
		!avahi? ( net-misc/mDNSResponder )
	)
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}
	!<net-print/foomatic-filters-ppds-20070501
	!<net-print/hplip-1.7.4a-r1
	X? ( x11-misc/xdg-utils )
"
PDEPEND="
	app-text/ghostscript-gpl
	>=app-text/poppler-0.12.3-r3[utils]
	ppds? (
		|| (
			(
				net-print/foomatic-filters-ppds
				net-print/foomatic-db-ppds
			)
			net-print/foomatic-filters-ppds
			net-print/foomatic-db-ppds
			net-print/hplip
			net-print/gutenprint
			net-print/foo2zjs
			net-print/cups-pdf
		)
	)
	samba? ( >=net-fs/samba-3.0.8 )
"

# upstream includes an interactive test which is a nono for gentoo.
# therefore, since the printing herd has bigger fish to fry, for now,
# we just leave it out, even if FEATURES=test
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

LANGS="de en es et fr he id it ja pl sv zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

multilib-native_pkg_setup_internal() {
	enewgroup lp
	enewuser lp -1 -1 -1 lp

	enewgroup lpadmin 106
}

multilib-native_src_prepare_internal() {
	# disable configure automagic for acl/attr, upstream bug STR #2723
	epatch "${FILESDIR}/${PN}-1.3.0-configure.patch"

	# create a missing symlink to allow https printing via IPP, bug #217293
	epatch "${FILESDIR}/${PN}-1.3.7-backend-https.patch"

	# detect recent libgnutls versions, upstream bug STR #3178
	epatch "${FILESDIR}/${PN}-1.3.10-str3178.patch"

	# CVE-2009-2820: Several XSS flaws in forms processed by CUPS web interface
	# upstream bug STR #3178 and STR #3401
	epatch "${FILESDIR}/${PN}-1.3.11-str3367-security-1.3v2.patch"
	epatch "${FILESDIR}/${PN}-1.3.11-str3401-security-1.3v2-regression.patch"
	# CVE-2009-3553: Use-after-free (crash) due improper reference counting in abstract file descriptors handling interface
	# upstream bug STR #3200
	epatch "${FILESDIR}/${PN}-1.3.11-str3200.patch"
	# Fix failing if poppler is not around
	epatch "${FILESDIR}/${PN}-1.3.11-pdf-m4.patch"

	# cups does not use autotools "the usual way" and ship a static config.h.in
	eaclocal
	eautoconf
}

multilib-native_src_configure_internal() {
	# Fails to compile on SH
	use sh && replace-flags -O? -O0

	# needed to prevent ghostscript compile failures
	use kerberos && strip-flags

	# locale support
	strip-linguas ${LANGS}

	if [ -z "${LINGUAS}" ] ; then
		export LINGUAS=all
	fi

	export DSOFLAGS="${LDFLAGS}"

	if use ldap ; then
		append-flags -DLDAP_DEPRECATED
	fi

	local myconf

	if use avahi || use zeroconf ; then
		myconf="${myconf} --enable-dnssd"
	else
		myconf="${myconf} --disable-dnssd"
	fi

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
		--with-pdftops=/usr/bin/pdftops \
		--with-system-groups=lpadmin \
		--with-xinetd=/etc/xinetd.d \
		$(use_enable acl) \
		$(use_enable dbus) \
		$(use_enable jpeg) \
		$(use_enable kerberos gssapi) \
		$(use_enable ldap) \
		$(use_enable pam) \
		$(use_enable png) \
		$(use_enable slp) \
		$(use_enable static) \
		$(use_enable tiff) \
		$(use_with java) \
		$(use_with perl) \
		$(use_with php) \
		$(use_with python) \
		--enable-libpaper \
		--enable-threads \
		--with-optim="${CFLAGS}" \
		${myconf}

	# install in /usr/libexec always, instead of using /usr$(get_libdir)cups, as that
	# makes more sense when facing multilib support.
	sed -i -e 's:SERVERBIN.*:SERVERBIN = "$(BUILDROOT)"/usr/libexec/cups:' Makedefs
	sed -i -e 's:#define CUPS_SERVERBIN.*:#define CUPS_SERVERBIN "/usr/libexec/cups":' config.h
	sed -i -e 's:cups_serverbin=.*:cups_serverbin=/usr/libexec/cups:' cups-config
}

multilib-native_src_install_internal() {
	emake BUILDROOT="${D}" install || die "emake install failed"
	dodoc {CHANGES{,-1.{0,1}},CREDITS,README}.txt || die "dodoc install failed"

	# clean out cups init scripts
	rm -rf "${D}"/etc/{init.d/cups,rc*,pam.d/cups}

	# install our init script
	local neededservices
	use avahi && neededservices="$neededservices avahi-daemon"
	use dbus && neededservices="$neededservices dbus"
	use zeroconf && ! use avahi && neededservices="$neededservices mDNSResponderPosix"
	[[ -n ${neededservices} ]] && neededservices="need${neededservices}"
	sed -e "s/@neededservices@/$neededservices/" "${FILESDIR}"/cupsd.init.d > "${T}"/cupsd
	doinitd "${T}"/cupsd

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

	keepdir /usr/share/cups/profiles /usr/libexec/cups/driver /var/log/cups \
		/var/run/cups/certs /var/cache/cups /var/spool/cups/tmp /etc/cups/ssl

	# .desktop handling. X useflag. xdg-open from freedesktop is preferred, upstream bug STR #2724.
	if use X ; then
		sed -i -e "s:htmlview:xdg-open:" "${D}"/usr/share/applications/cups.desktop
	else
		rm -r "${D}"/usr/share/applications
	fi

	# fix a symlink collision, see bug #172341
	dodir /usr/share/ppd
	dosym /usr/share/ppd /usr/share/cups/model/foomatic-ppds

	# create RSS feed directory
	diropts -m 0740 -o lp -g lp
	dodir /var/cache/cups/rss

	# create /etc/cups/client.conf, bug #196967 and #266678
	echo "ServerName /var/run/cups/cups.sock" >> "${D}"/etc/cups/client.conf

	prep_ml_binaries /usr/bin/cups-config
}

multilib-native_pkg_preinst_internal() {
	# cleanups
	[ -n "${PN}" ] && rm -fR "${ROOT}"/usr/share/doc/"${PN}"-*
	has_version "=${CATEGORY}/${PN}-1.2*"
	upgrade_from_1_2=$?
}

multilib-native_pkg_postinst_internal() {
	echo
	elog "For information about installing a printer and general cups setup"
	elog "take a look at: http://www.gentoo.org/doc/en/printing-howto.xml"
	echo

	local good_gs=false
	for x in app-text/ghostscript-gpl app-text/ghostscript-gnu ; do
		if has_version ${x} && built_with_use ${x} cups ; then
			good_gs=true
			break
		fi
	done
	if ! ${good_gs} ; then
		echo
		ewarn "You need to emerge ghostscript with the \"cups\" USE flag turned on."
		echo
	fi

	if [[ $upgrade_from_1_2 = 0 ]] ; then
		echo
		ewarn "You have upgraded from an older cups version. Please make sure"
		ewarn "to run \"etc-update\" and \"revdep-rebuild\" NOW."
		echo
	fi

	if [ -e "${ROOT}"/usr/$(get_libdir)/cups ] ; then
		echo
		ewarn "/usr/$(get_libdir)/cups exists - You need to remerge every ebuild that"
		ewarn "installed into /usr/$(get_libdir)/cups and /etc/cups, qfile is in portage-utils:"
		ewarn "# FEATURES=-collision-protect emerge -va1 \$(qfile -qC /usr/$(get_libdir)/cups /etc/cups | sed -e \"s:net-print/cups$::\")"
		echo
		ewarn "FEATURES=-collision-protect is needed to overwrite the compatibility"
		ewarn "symlinks installed by this package, it won't be needed on later merges."
		ewarn "You should also run revdep-rebuild"
		echo

		# place symlinks to make the update smoothless
		for i in "${ROOT}"/usr/$(get_libdir)/cups/{backend,filter}/* ; do
			if [ "${i/\*}" == "${i}" ] && ! [ -e ${i/$(get_libdir)/libexec} ] ; then
				ln -s ${i} ${i/$(get_libdir)/libexec}
			fi
		done
	fi
}
