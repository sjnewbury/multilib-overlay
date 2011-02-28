# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/postgresql-base/postgresql-base-9.0.3.ebuild,v 1.5 2011/02/27 10:03:54 klausman Exp $

EAPI="2"

WANT_AUTOMAKE="none"

inherit eutils multilib versionator autotools multilib-native

KEYWORDS="alpha amd64 ~arm hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"

DESCRIPTION="PostgreSQL libraries and clients"
HOMEPAGE="http://www.postgresql.org/"

MY_PV=${PV/_/}
SRC_URI="mirror://postgresql/source/v${MY_PV}/postgresql-${MY_PV}.tar.bz2"
S=${WORKDIR}/postgresql-${MY_PV}

LICENSE="POSTGRESQL"
SLOT="$(get_version_component_range 1-2)"
LINGUAS="af cs de es fa fr hr hu it ko nb pl pt_BR ro ru sk sl sv tr zh_CN zh_TW"
IUSE="doc kerberos ldap nls pam pg_legacytimestamp readline ssl threads zlib"

for lingua in ${LINGUAS}; do
	IUSE+=" linguas_${lingua}"
done

RESTRICT="test"

wanted_languages() {
	local enable_langs

	for lingua in ${LINGUAS} ; do
		use linguas_${lingua} && enable_langs+="${lingua} "
	done

	echo -n ${enable_langs}
}

RDEPEND="!!dev-db/postgresql-libs
	!!dev-db/postgresql-client
	!!dev-db/libpq
	!!dev-db/postgresql
	>=app-admin/eselect-postgresql-0.3
	virtual/libintl
	kerberos? ( virtual/krb5[lib32?] )
	ldap? ( net-nds/openldap[lib32?] )
	pam? ( virtual/pam[lib32?] )
	readline? ( sys-libs/readline[lib32?] )
	ssl? ( >=dev-libs/openssl-0.9.6-r1[lib32?] )
	zlib? ( sys-libs/zlib[lib32?] )"
DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex[lib32?]
	nls? ( sys-devel/gettext[lib32?] )"
PDEPEND="doc? ( ~dev-db/postgresql-docs-${PV} )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/postgresql-9.0-common.3.patch" \
		"${FILESDIR}/postgresql-${SLOT}-base.3.patch"

	# to avoid collision - it only should be installed by server
	rm "${S}/src/backend/nls.mk"

	# because psql/help.c includes the file
	ln -s "${S}/src/include/libpq/pqsignal.h" "${S}/src/bin/psql/" || die

	eautoconf
}

multilib-native_src_configure_internal() {
	export LDFLAGS_SL="${LDFLAGS}"
	econf \
		--prefix=/usr/$(get_libdir)/postgresql-${SLOT} \
		--datadir=/usr/share/postgresql-${SLOT} \
		--docdir=/usr/share/doc/postgresql-${SLOT} \
		--sysconfdir=/etc/postgresql-${SLOT} \
		--includedir=/usr/include/postgresql-${SLOT} \
		--mandir=/usr/share/postgresql-${SLOT}/man \
		--enable-depend \
		--without-tcl \
		--without-perl \
		--without-python \
		$(use_with readline) \
		$(use_with kerberos krb5) \
		$(use_with kerberos gssapi) \
		"$(use_enable nls nls "$(wanted_languages)")" \
		$(use_with pam) \
		$(use_enable !pg_legacytimestamp integer-datetimes) \
		$(use_with ssl openssl) \
		$(use_enable threads thread-safety) \
		$(use_with zlib) \
		$(use_with ldap)
}

multilib-native_src_compile_internal() {
	emake || die "emake failed"

	cd "${S}/contrib"
	emake || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	insinto /usr/include/postgresql-${SLOT}/postmaster
	doins "${S}"/src/include/postmaster/*.h || die

	dodir /usr/share/postgresql-${SLOT}/man/man1/ || die
	cp  "${S}"/doc/src/sgml/man1/* "${D}"/usr/share/postgresql-${SLOT}/man/man1/ || die

	rm "${D}/usr/share/postgresql-${SLOT}/man/man1"/{initdb,ipcclean,pg_controldata,pg_ctl,pg_resetxlog,pg_restore,postgres,postmaster}.1
	dodoc README HISTORY doc/{README.*,TODO,bug.template} || die

	cd "${S}/contrib"
	emake DESTDIR="${D}" install || die "emake install failed"
	cd "${S}"

	dodir /etc/eselect/postgresql/slots/${SLOT} || die

	IDIR="/usr/include/postgresql-${SLOT}"
	cat > "${D}/etc/eselect/postgresql/slots/${SLOT}/base" <<-__EOF__
postgres_ebuilds="\${postgres_ebuilds} ${PF}"
postgres_prefix=/usr/$(get_libdir)/postgresql-${SLOT}
postgres_datadir=/usr/share/postgresql-${SLOT}
postgres_bindir=/usr/$(get_libdir)/postgresql-${SLOT}/bin
postgres_symlinks=(
	${IDIR} /usr/include/postgresql
	${IDIR}/libpq-fe.h /usr/include/libpq-fe.h
	${IDIR}/pg_config_manual.h /usr/include/pg_config_manual.h
	${IDIR}/libpq /usr/include/libpq
	${IDIR}/postgres_ext.h /usr/include/postgres_ext.h
)
__EOF__

	cat >"${T}/50postgresql-94-${SLOT}" <<-__EOF__
LDPATH=/usr/$(get_libdir)/postgresql-${SLOT}/$(get_libdir)
MANPATH=/usr/share/postgresql-${SLOT}/man
__EOF__
	doenvd "${T}/50postgresql-94-${SLOT}" || die

	keepdir /etc/postgresql-${SLOT} || die

	prep_ml_binaries /usr/bin/pg_config
}

multilib-native_pkg_postinst_internal() {
	eselect postgresql update
	[[ "$(eselect postgresql show)" = "(none)" ]] && eselect postgresql set ${SLOT}
	elog "If you need a global psqlrc-file, you can place it in:"
	elog "    '${ROOT}/etc/postgresql-${SLOT}/'"
	elog
}

multilib-native_pkg_postrm_internal() {
	eselect postgresql update
}
