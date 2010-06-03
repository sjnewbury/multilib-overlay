# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba-libs/samba-libs-3.3.10.ebuild,v 1.1 2010/01/14 12:52:52 patrick Exp $

EAPI="2"

inherit pam confutils versionator multilib multilib-native

MY_P="samba-${PV}"

DESCRIPTION="Libraries from Samba"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86"
IUSE="ads aio caps cluster cups debug examples ldap pam syslog winbind"

DEPEND="dev-libs/popt[lib32?]
	virtual/libiconv
	ads? ( virtual/krb5[lib32?] sys-fs/e2fsprogs[lib32?] )
	caps? ( sys-libs/libcap[lib32?] )
	cluster? ( dev-db/ctdb )
	cups? ( net-print/cups[lib32?] )
	debug? ( dev-libs/dmalloc )
	ldap? ( net-nds/openldap[lib32?] )
	pam? ( virtual/pam[lib32?]
		winbind? ( dev-libs/iniparser[lib32?] ) )
	syslog? ( virtual/logger )
	!<net-fs/samba-3.3
	!sys-libs/tdb
	!sys-libs/talloc"
RDEPEND="${DEPEND}"

# Disable tests since we don't want to build that much here
RESTRICT="test"

S="${WORKDIR}/${MY_P}/source"

# TODO:
# - enable iPrint on Prefix/OSX and Darwin?
# - selftest-prefix? selftest?

CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

multilib-native_pkg_setup_internal() {
	confutils_use_depend_all ads ldap
}

multilib-native_src_prepare_internal() {
	sed -i \
		-e 's|"lib32" ||' \
		-e 's|if test -d "$i/$l" ;|if test -d "$i/$l" -o -L "$i/$l";|' \
		configure || die "sed failed"
}

multilib-native_src_configure_internal() {
	local myconf

	# Filter out -fPIE
	[[ ${CHOST} == *-*bsd* ]] && myconf="${myconf} --disable-pie"
	use hppa && myconf="${myconf} --disable-pie"

	# Upstream refuses to make this configurable
	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	# Notes:
	# - FAM is a plugin for the server
	# - DNS-SD is only used in client/server code
	# - AFS is a pw-auth-method and only used in client/server code
	# - AFSACL is a server module
	# - automount is only needed in conjunction with NIS and we don't have that
	#   anymore
	# - quota-support is only needed in server-code
	# - acl-support is only used in server-code
	# - --without-dce-dfs and --without-nisplus-home can't be passed to configure but are disabled by default
	econf ${myconf} \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable debug developer) \
		--enable-largefile \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		--disable-swat \
		$(use_enable debug dmalloc) \
		$(use_enable cups) \
		--disable-iprint \
		--disable-fam \
		--enable-shared-libs \
		--disable-dnssd \
		--disable-avahi \
		--with-fhs \
		--with-privatedir=/var/lib/samba/private \
		--with-rootsbindir=/var/cache/samba \
		--with-lockdir=/var/cache/samba \
		--with-swatdir=/usr/share/doc/${PF}/swat \
		--with-configdir=/etc/samba \
		--with-logfilebase=/var/log/samba \
		--with-pammodulesdir=$(getpam_mod_dir) \
		--without-afs \
		--without-fake-kaserver \
		--without-vfs-afsacl \
		$(use_with ldap) \
		$(use_with ads) \
		$(use_with ads krb5 /usr) \
		$(use_with ads dnsupdate) \
		--without-automount \
		--without-cifsmount \
		--without-cifsupcall \
		$(use_with pam) \
		$(use_with pam pam_smbpass) \
		$(use_with syslog) \
		--without-quotas \
		--without-sys-quotas \
		--without-utmp \
		--with-lib{talloc,tdb,netapi,smbclient,smbsharemodes} \
		--without-libaddns \
		$(use_with cluster ctdb /usr) \
		$(use_with cluster cluster-support) \
		--without-acl-support \
		$(use_with aio aio-support) \
		--with-sendfile-support \
		$(use_with winbind) \
		--without-included-popt \
		--without-included-iniparser
}

multilib-native_src_compile_internal() {
	emake libs pam_modules nss_modules || die "emake failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" installlibs || die "emake installlibs failed"
	if use pam ; then
		emake DESTDIR="${D}" installpammodules || die "emake installpammodules failed"
	fi

	# Remove empty installation directories
	rmdir \
		"${D}/usr/$(get_libdir)/samba" \
		"${D}/usr"/{sbin,bin} \
		"${D}/usr/share"/{man,locale,} \
		"${D}/var"/{run,lib/samba/private,lib/samba,lib,cache/samba,cache,} \
		|| die "tried to remove non-empty dirs, this seems like a bug in the ebuild"

	# Nsswitch extensions. Make link for wins and winbind resolvers
	if use winbind ; then
		dolib.so nsswitch/libnss_wins.so
		dosym libnss_wins.so /usr/$(get_libdir)/libnss_wins.so.2
		dolib.so nsswitch/libnss_winbind.so
		dosym libnss_winbind.so /usr/$(get_libdir)/libnss_winbind.so.2
	fi

	if use pam ; then
		if use winbind ; then
			newpamd "${CONFDIR}/system-auth-winbind.pam" system-auth-winbind
			doman ../docs/manpages/pam_winbind.7
			dohtml ../docs/htmldocs/manpages/pam_winbind.7.html

			if use examples ; then
				insinto /usr/share/doc/${PF}/examples
				doins -r ../examples/pam_winbind
			fi
		fi

		newpamd "${CONFDIR}/samba.pam" samba
		dodoc pam_smbpass/README
	fi

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r ../examples/libsmbclient

		use winbind && doins -r ../examples/nss
	fi

}
