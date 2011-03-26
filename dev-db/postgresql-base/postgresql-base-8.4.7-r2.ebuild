# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgresql-base/postgresql-base-8.4.7-r2.ebuild,v 1.1 2011/03/24 11:19:25 titanofold Exp $

EAPI="3"

WANT_AUTOMAKE="none"

inherit autotools eutils multilib prefix versionator multilib-native

SLOT="$(get_version_component_range 1-2)"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"

DESCRIPTION="PostgreSQL libraries and clients"
HOMEPAGE="http://www.postgresql.org/"
SRC_URI="mirror://postgresql/source/v${PV}/postgresql-${PV}.tar.bz2
		 http://dev.gentoo.org/~titanofold/postgresql-patches-${SLOT}.tbz2"
LICENSE="POSTGRESQL"

S=${WORKDIR}/postgresql-${PV}

# No tests to be done for clients and libraries
RESTRICT="test"

LINGUAS="af cs de es fa fr hr hu it ko nb pl pt_BR ro ru sk sl sv tr zh_CN zh_TW"
IUSE="doc kerberos nls pam readline ssl threads zlib ldap pg_legacytimestamp"

for lingua in ${LINGUAS} ; do
	IUSE+=" linguas_${lingua}"
done

wanted_languages() {
	local enable_langs

	for lingua in ${LINGUAS} ; do
		use linguas_${lingua} && enable_langs+="${lingua} "
	done

	echo -n ${enable_langs}
}

RDEPEND="kerberos? ( virtual/krb5[lib32?] )
	pam? ( virtual/pam[lib32?] )
	readline? ( >=sys-libs/readline-4.1[lib32?] )
	ssl? ( >=dev-libs/openssl-0.9.6-r1[lib32?] )
	zlib? ( >=sys-libs/zlib-1.1.3[lib32?] )
	>=app-admin/eselect-postgresql-0.3
	virtual/libintl
	!!dev-db/postgresql-libs
	!!dev-db/postgresql-client
	!!dev-db/libpq
	!!dev-db/postgresql
	ldap? ( net-nds/openldap[lib32?] )"
DEPEND="${RDEPEND}
	sys-devel/flex[lib32?]
	>=sys-devel/bison-1.875
	nls? ( sys-devel/gettext[lib32?] )"
PDEPEND="doc? ( ~dev-db/postgresql-docs-${PV} )"

multilib-native_src_prepare_internal() {
	epatch "${WORKDIR}/autoconf.patch" \
		"${WORKDIR}/base.patch" \
		"${WORKDIR}/darwin.patch" \
		"${WORKDIR}/SuperH.patch"

	eprefixify src/include/pg_config_manual.h

	# to avoid collision - it only should be installed by server
	rm "${S}/src/backend/nls.mk"

	# because psql/help.c includes the file
	ln -s "${S}/src/include/libpq/pqsignal.h" "${S}/src/bin/psql/"

	eautoconf
}

multilib-native_src_configure_internal() {
	export LDFLAGS_SL="${LDFLAGS}"
	econf --prefix=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT} \
		--datadir=${EROOT%/}/usr/share/postgresql-${SLOT} \
		--docdir=${EROOT%/}/usr/share/doc/postgresql-${SLOT} \
		--sysconfdir=${EROOT%/}/etc/postgresql-${SLOT} \
		--includedir=${EROOT%/}/usr/include/postgresql-${SLOT} \
		--mandir=${EROOT%/}/usr/share/postgresql-${SLOT}/man \
		--enable-depend \
		--without-tcl \
		--without-perl \
		--without-python \
		$(use_with readline) \
		$(use_with kerberos krb5) \
		$(use_with kerberos gssapi) \
		"$(use_enable nls nls "$(wanted_languages)")" \
		$(use_with pam) \
		$(use_enable !pg_legacytimestamp integer-datetimes ) \
		$(use_with ssl openssl) \
		$(use_enable threads thread-safety) \
		$(use_with zlib) \
		$(use_with ldap) \
		|| die "configure failed"
}

multilib-native_src_compile_internal() {
	emake || die "emake failed"

	cd "${S}/contrib"
	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	insinto /usr/include/postgresql-${SLOT}/postmaster
	doins "${S}"/src/include/postmaster/*.h
	dodir /usr/share/postgresql-${SLOT}/man/man1
	tar -zxf "${S}/doc/man.tar.gz" -C "${ED}"/usr/share/postgresql-${SLOT}/man man1/{ecpg,pg_config}.1

	rm -r "${ED}/usr/share/doc/postgresql-${SLOT}/html"
	rm "${ED}/usr/share/postgresql-${SLOT}/man/man1"/{initdb,pg_controldata,pg_ctl,pg_resetxlog,pg_restore,postgres,postmaster}.1
	fowners root:0 /usr/share/postgresql-${SLOT}/man/man1/{ecpg,pg_config}.1
	dodoc README HISTORY doc/{README.*,TODO,bug.template}

	cd "${S}/contrib"
	emake DESTDIR="${D}" install || die "emake install failed"
	cd "${S}"

	dodir /etc/eselect/postgresql/slots/${SLOT}

	IDIR="${EROOT%/}/usr/include/postgresql-${SLOT}"
	cat > "${ED}/etc/eselect/postgresql/slots/${SLOT}/base" <<-__EOF__
postgres_ebuilds="\${postgres_ebuilds} ${PF}"
postgres_prefix=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT}
postgres_datadir=${EROOT%/}/usr/share/postgresql-${SLOT}
postgres_bindir=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT}/bin
postgres_symlinks=(
	${IDIR} ${EROOT%/}/usr/include/postgresql
	${IDIR}/libpq-fe.h ${EROOT%/}/usr/include/libpq-fe.h
	${IDIR}/pg_config_manual.h ${EROOT%/}/usr/include/pg_config_manual.h
	${IDIR}/libpq ${EROOT%/}/usr/include/libpq
	${IDIR}/postgres_ext.h ${EROOT%/}/usr/include/postgres_ext.h
)
__EOF__

	cat >"${T}/50postgresql-94-${SLOT}" <<-__EOF__
		LDPATH=${EROOT%/}/usr/$(get_libdir)/postgresql-${SLOT}/$(get_libdir)
		MANPATH=${EROOT%/}/usr/share/postgresql-${SLOT}/man
	__EOF__
	doenvd "${T}/50postgresql-94-${SLOT}"

	keepdir /etc/postgresql-${SLOT}

	prep_ml_binaries /usr/bin/pg_config
}

multilib-native_pkg_postinst_internal() {
	eselect postgresql update
	[[ "$(eselect postgresql show)" = "(none)" ]] && eselect postgresql set ${SLOT}
	elog "If you need a global psqlrc-file, you can place it in:"
	elog "    ${EROOT%/}/etc/postgresql-${SLOT}/"
}

multilib-native_pkg_postrm_internal() {
	eselect postgresql update
}
