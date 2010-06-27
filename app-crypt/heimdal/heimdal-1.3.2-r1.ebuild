# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/heimdal/heimdal-1.3.2-r1.ebuild,v 1.1 2010/05/09 16:32:44 darkside Exp $

EAPI=2
VIRTUALX_REQUIRED="manual"

inherit autotools libtool eutils virtualx toolchain-funcs multilib-native

PATCHVER=0.2
PATCH_P=${PN}-gentoo-patches-${PATCHVER}
RESTRICT="test"

DESCRIPTION="Kerberos 5 implementation from KTH"
HOMEPAGE="http://www.h5l.org/"
SRC_URI="http://www.h5l.org/dist/src/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh
~sparc ~x86"
IUSE="afs +berkdb hdb-ldap ipv6 otp pkinit ssl test threads X"

RDEPEND="ssl? ( dev-libs/openssl[lib32?] )
	berkdb? ( sys-libs/db[lib32?] )
	!berkdb? ( sys-libs/gdbm[lib32?] )
	>=dev-db/sqlite-3.5.7[lib32?]
	>=sys-libs/e2fsprogs-libs-1.41.11[lib32?]
	afs? ( net-fs/openafs )
	hdb-ldap? ( >=net-nds/openldap-2.3.0[lib32?] )
	!virtual/krb5"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	>=sys-devel/autoconf-2.62
	test? ( X? ( ${VIRTUALX_DEPEND} ) )"

PROVIDE="virtual/krb5"

GENTOODIR=${WORKDIR}/gentoo

multilib-native_src_prepare_internal() {
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--enable-kcm \
		--disable-osfc2 \
		--enable-shared \
		--with-libintl=/usr \
		--with-readline=/usr \
		--with-sqlite3=/usr \
		--libexecdir=/usr/sbin \
		$(use_enable afs afs-support) \
		$(use_enable berkdb berkeley-db) \
		$(use_enable otp) \
		$(use_enable pkinit kx509) \
		$(use_enable pkinit pk-init) \
		$(use_enable threads pthread-support) \
		$(use_with hdb-ldap openldap /usr) \
		$(use_with ipv6) \
		$(use_with ssl openssl /usr) \
		$(use_with X x)
}

multilib-native_src_compile_internal() {
	emake -j1 || die "emake failed"
}

multilib-native_src_install_internal() {
	INSTALL_CATPAGES="no" emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog README NEWS TODO

	# Begin client rename and install
	for i in {telnetd,ftpd,rshd,popper}
	do
		mv "${D}"/usr/share/man/man8/{,k}${i}.8
		mv "${D}"/usr/sbin/{,k}${i}
	done

	for i in {rcp,rsh,telnet,ftp,su,login,pagsh,kf}
	do
		mv "${D}"/usr/share/man/man1/{,k}${i}.1
		mv "${D}"/usr/bin/{,k}${i}
	done

	mv "${D}"/usr/share/man/man5/{,k}ftpusers.5
	mv "${D}"/usr/share/man/man5/{,k}login.access.5

	newinitd "${FILESDIR}"/heimdal-kdc.initd heimdal-kdc
	newinitd "${FILESDIR}"/heimdal-kadmind.initd heimdal-kadmind
	newinitd "${FILESDIR}"/heimdal-kpasswdd.initd heimdal-kpasswdd
	newinitd "${FILESDIR}"/heimdal-kcm.initd heimdal-kcm

	insinto /etc
	newins "${FILESDIR}"/krb5.conf krb5.conf.example

	if use hdb-ldap; then
		insinto /etc/openldap/schema
		newins "${S}/lib/hdb/hdb.schema" krb5-kdc.schema
	fi

	# default database dir
	keepdir /var/heimdal

	prep_ml_binaries /usr/bin/krb5-config
}