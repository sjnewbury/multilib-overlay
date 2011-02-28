# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/curl/curl-7.21.4.ebuild,v 1.3 2011/02/20 14:22:58 ulm Exp $

# NOTE: If you bump this ebuild, make sure you bump dev-python/pycurl!

EAPI=4

inherit autotools multilib eutils libtool prefix multilib-native

DESCRIPTION="A Client that groks URLs"
HOMEPAGE="http://curl.haxx.se/"
SRC_URI="http://curl.haxx.se/download/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="ares gnutls idn ipv6 kerberos ldap libssh2 nss ssl static-libs test threads"

RDEPEND="ldap? ( net-nds/openldap[lib32?] )
	ssl? (
		gnutls? ( net-libs/gnutls[lib32?] dev-libs/libgcrypt[lib32?] app-misc/ca-certificates )
		nss? ( !gnutls? ( dev-libs/nss[lib32?] app-misc/ca-certificates ) )
		!gnutls? ( !nss? ( dev-libs/openssl[lib32?] ) )
	)
	idn? ( net-dns/libidn[lib32?] )
	ares? ( >=net-dns/c-ares-1.4.0[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	libssh2? ( >=net-libs/libssh2-0.16[lib32?] )"

# rtmpdump ( media-video/rtmpdump )  / --with-librtmp
# fbopenssl (not in gentoo) --with-spnego
# krb4 http://web.mit.edu/kerberos/www/krb4-end-of-life.html

DEPEND="${RDEPEND}
	test? (
		sys-apps/diffutils
		dev-lang/perl[lib32?]
	)"
# used - but can do without in self test: net-misc/stunnel

# ares must be disabled for threads and both can be disabled
# one can use wether gnutls or nss if ssl is enabled
REQUIRED_USE="threads? ( !ares )
	gnutls? ( ssl )
	nss? ( ssl )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-7.20.0-strip-ldflags.patch \
		"${FILESDIR}"/${PN}-7.19.7-test241.patch \
		"${FILESDIR}"/${PN}-7.18.2-prefix.patch \
		"${FILESDIR}"/${PN}-respect-cflags.patch

	eprefixify curl-config.in
	eautoreconf
}

multilib-native_src_configure_internal() {
	local myconf

	myconf="$(use_enable ldap)
		$(use_enable ldap ldaps)
		$(use_with idn libidn)
		$(use_with kerberos gssapi "${EPREFIX}"/usr)
		$(use_with libssh2)
		$(use_enable static-libs static)
		$(use_enable ipv6)
		$(use_enable threads threaded-resolver)
		$(use_enable ares)
		--enable-http
		--enable-ftp
		--enable-gopher
		--enable-file
		--enable-dict
		--enable-manual
		--enable-telnet
		--enable-smtp
		--enable-pop3
		--enable-imap
		--enable-rtsp
		--enable-nonblocking
		--enable-largefile
		--enable-maintainer-mode
		--disable-sspi
		--without-krb4
		--without-librtmp
		--without-spnego"

	if use ssl ; then
		if use gnutls; then
			myconf+=" --without-ssl --with-gnutls --without-nss"
			myconf+=" --with-ca-bundle=${EPREFIX}/etc/ssl/certs/ca-certificates.crt"
		elif use nss; then
			myconf+=" --without-ssl --without-gnutls --with-nss"
			myconf+=" --with-ca-bundle=${EPREFIX}/etc/ssl/certs/ca-certificates.crt"
		else
			myconf+=" --without-gnutls --without-nss --with-ssl"
			myconf+=" --without-ca-bundle --with-ca-path=${EPREFIX}/etc/ssl/certs"
		fi
	else
		myconf+=" --without-gnutls --without-nss --without-ssl"
	fi

	econf ${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install
	find "${ED}" -name '*.la' -exec rm -f {} +
	rm -rf "${ED}"/etc/

	# https://sourceforge.net/tracker/index.php?func=detail&aid=1705197&group_id=976&atid=350976
	insinto /usr/share/aclocal
	doins docs/libcurl/libcurl.m4

	dodoc CHANGES README
	dodoc docs/FEATURES docs/INTERNALS
	dodoc docs/MANUAL docs/FAQ docs/BUGS docs/CONTRIBUTE

	prep_ml_binaries /usr/bin/curl-config
}
