# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/mit-krb5/mit-krb5-1.9-r2.ebuild,v 1.1 2011/03/16 09:38:52 eras Exp $

EAPI=3

inherit eutils flag-o-matic versionator multilib-native

MY_P="${P/mit-}"
P_DIR=$(get_version_component_range 1-2)
DESCRIPTION="MIT Kerberos V"
HOMEPAGE="http://web.mit.edu/kerberos/www/"
SRC_URI="http://web.mit.edu/kerberos/dist/krb5/${P_DIR}/${MY_P}-signed.tar"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc +keyutils openldap +pkinit +threads test xinetd"

RDEPEND="!!app-crypt/heimdal
	>=sys-libs/e2fsprogs-libs-1.41.0[lib32?]
	keyutils? ( sys-apps/keyutils[lib32?] )
	openldap? ( net-nds/openldap[lib32?] )
	xinetd? ( sys-apps/xinetd )"
DEPEND="${RDEPEND}
	doc? ( virtual/latex-base )
	test? ( dev-lang/tcl[lib32?]
	        dev-lang/python[lib32?]
			dev-util/dejagnu )"

S=${WORKDIR}/${MY_P}/src

multilib-native_src_unpack_internal() {
	unpack ${A}
	unpack ./"${MY_P}".tar.gz
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/CVE-2010-4022.patch"
	epatch "${FILESDIR}/CVE-2011-0281.0282.0283.patch"
	epatch "${FILESDIR}/CVE-2011-0284.patch"
}

multilib-native_src_configure_internal() {
	append-flags "-I${EPREFIX}/usr/include/et"
	use keyutils || export ac_cv_header_keyutils_h=no
	econf \
		$(use_with openldap ldap) \
		"$(use_with test tcl "${EPREFIX}/usr")" \
		$(use_enable pkinit) \
		$(use_enable threads thread-support) \
		--without-krb4 \
		--without-hesiod \
		--enable-shared \
		--with-system-et \
		--with-system-ss \
		--enable-dns-for-realm \
		--enable-kdc-lookaside-cache \
		--disable-rpath
}

multilib-native_src_compile_internal() {
	emake -j1 || die "emake failed"

	if use doc ; then
		cd ../doc
		for dir in api implement ; do
			emake -C "${dir}" || die "doc emake failed"
		done
	fi
}

multilib-native_src_install_internal() {
	emake \
		DESTDIR="${D}" \
		EXAMPLEDIR="${EPREFIX}/usr/share/doc/${PF}/examples" \
		install || die "install failed"

	# default database dir
	keepdir /var/lib/krb5kdc

	cd ..
	dodoc NOTICE README
	dodoc doc/*.{ps,txt}
	doinfo doc/*.info*
	dohtml -r doc/*.html

	# die if we cannot respect a USE flag
	if use doc ; then
	    dodoc doc/{api,implement}/*.ps || die "dodoc failed"
	fi

	newinitd "${FILESDIR}"/mit-krb5kadmind.initd mit-krb5kadmind || die
	newinitd "${FILESDIR}"/mit-krb5kdc.initd mit-krb5kdc || die

	insinto /etc
	newins "${ED}/usr/share/doc/${PF}/examples/krb5.conf" krb5.conf.example
	insinto /var/lib/krb5kdc
	newins "${ED}/usr/share/doc/${PF}/examples/kdc.conf" kdc.conf.example

	if use openldap ; then
		insinto /etc/openldap/schema
		doins "${S}/plugins/kdb/ldap/libkdb_ldap/kerberos.schema" || die
	fi

	if use xinetd ; then
		insinto /etc/xinetd.d
		newins "${FILESDIR}/kpropd.xinetd" kpropd || die
	fi

	prep_ml_binaries /usr/bin/krb5-config
}

multilib-native_pkg_preinst_internal() {
	if has_version "<${CATEGORY}/${PN}-1.8.0" ; then
		elog "MIT split the Kerberos applications from the base Kerberos"
		elog "distribution.  Kerberized versions of telnet, rlogin, rsh, rcp,"
		elog "ftp clients and telnet, ftp deamons now live in"
		elog "\"app-crypt/mit-krb5-appl\" package."
	fi
}
