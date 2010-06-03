# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba-libs/samba-libs-3.4.5.ebuild,v 1.1 2010/01/19 19:04:25 patrick Exp $

EAPI="2"

inherit pam confutils versionator multilib autotools multilib-native

MY_P="samba-${PV}"

DESCRIPTION="Library bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="samba4 ads aio caps cluster cups debug examples ldap pam syslog winbind
	ldb +netapi +smbclient smbsharemodes addns tools"

DEPEND="dev-libs/popt[lib32?]
	sys-libs/talloc[lib32?]
	sys-libs/tdb[lib32?]
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
	!=net-fs/samba-server-3.4.3[tools]"
# last blocker is only temporary for #288516

RDEPEND="${DEPEND}"

# Disable tests since we don't want to build that much here
RESTRICT="test"

BINPROGS=""

if use tools ; then
	if use ldb ; then BINPROGS="${BINPROGS} bin/ldbedit bin/ldbsearch bin/ldbadd bin/ldbdel bin/ldbmodify bin/ldbrename"; fi
fi

S="${WORKDIR}/${MY_P}/source3"

# TODO:
# - enable iPrint on Prefix/OSX and Darwin?
# - selftest-prefix? selftest?

CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

multilib-native_pkg_setup_internal() {
	confutils_use_depend_all samba4 ads
	confutils_use_depend_all ads ldap
}

multilib-native_src_prepare_internal() {

	cd ".."

	epatch \
		"${FILESDIR}/samba-3.4.2-missing_includes.patch" \
		"${FILESDIR}/samba-3.4.2-fix-samba4-automake.patch" \
		"${FILESDIR}/samba-3.4.2-insert-AC_LD_VERSIONSCRIPT.patch"
		#"${FILESDIR}/samba-3.4.4-version.h.patch"

	cp "${FILESDIR}/samba-3.4.2-lib.tevent.python.mk" "lib/tevent/python.mk"

	cd "source3"
	eautoconf -Ilibreplace -Im4 -I../m4 -I../lib/replace -I../source4

	# ensure that winbind has correct ldflags (QA notice)
	sed -i \
		-e 's|LDSHFLAGS="|LDSHFLAGS="\\${LDFLAGS} |g' \
		configure || die "sed failed"
}

multilib-native_src_configure_internal() {
	local myconf

	# compile franky samba4 hybrid
	# http://wiki.samba.org/index.php/Franky
	if use samba4 ; then
		myconf="${myconf} --enable-merged-build --enable-developer"
		if has_version app-crypt/heimdal ; then
			myconf="${myconf} --with-krb5=/usr/"
		elif has_version app-crypt/mit-krb5 ; then
			die "MIT Kerberos not supported by samba 4, use heimdal"
		else
			die "No supported kerberos provider detected"
		fi
	fi

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
	# anymore
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
		--without-libtdb \
		$(use_with netapi libnetapi) \
		--without-libtalloc \
		$(use_with smbclient libsmbclient) \
		$(use_with smbsharemodes libsmbsharemodes) \
		$(use_with addns libaddns) \
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

	# compile libs
	if use addns ; then
		einfo "make addns library"
		emake libaddns || die "emake libaddns failed"
	fi
	if use netapi ; then
		einfo "make netapi library"
		emake libnetapi || die "emake libnetapi failed"
	fi
	if use smbclient ; then
		einfo "make smbclient library"
		emake libsmbclient || die "emake libsmbclient failed"
	fi
	if use smbsharemodes ; then
		einfo "make smbsharemodes library"
		emake libsmbsharemodes || die "emake libsmbsharemodes failed"
	fi

	# compile modules
	if use pam ; then
		einfo "make pam modules"
		emake pam_modules || die "emake pam_modules failed";
	fi
	if use winbind ; then
		einfo "make nss modules"
		emake nss_modules || die "emake nss_modules failed";
	fi

	# compile utilities
	if use tools ; then
		einfo "make utilities"
		emake ${BINPROGS} || die "emake binprogs failed";
	fi

}

multilib-native_src_install_internal() {

	# install libs
	if use netapi ; then
		einfo "install netapi library"
		emake installlibnetapi DESTDIR="${D}" || die "emake install libnetapi failed"
	fi
	if use smbclient ; then
		einfo "install smbclient library"
		emake installlibsmbclient DESTDIR="${D}" || die "emake install libsmbclient failed"
	fi
	if use smbsharemodes ; then
		einfo "install smbsharemodes library"
		emake installlibsmbsharemodes DESTDIR="${D}" || die "emake install libsmbsharemodes failed"
	fi
	if use addns ; then
		einfo "install addns library"
		emake installlibaddns DESTDIR="${D}" || die "emake install libaddns failed"
	fi

	# install modules
	if use pam ; then
		einfo "install pam modules"
		emake installpammodules DESTDIR="${D}" || die "emake installpammodules failed"
	fi

	# Remove empty installation directories
	rmdir \
		"${D}/usr/$(get_libdir)/samba" \
		"${D}/usr"/{sbin,bin} \
		"${D}/usr/share"/{man,locale,} \
		"${D}/var"/{run,lib/samba/private,lib/samba,lib,cache/samba,cache,} \
	#	|| die "tried to remove non-empty dirs, this seems like a bug in the ebuild"

	# Nsswitch extensions. Make link for wins and winbind resolvers
	if use winbind ; then
		einfo "install lbwbclient"
		emake installlibwbclient DESTDIR="${D}" || die "emake installlibwbclient failed"
		dolib.so ../nsswitch/libnss_wins.so
		dosym libnss_wins.so /usr/$(get_libdir)/libnss_wins.so.2
		dolib.so ../nsswitch/libnss_winbind.so
		dosym libnss_winbind.so /usr/$(get_libdir)/libnss_winbind.so.2
	fi

	if use pam ; then
		if use winbind ; then
			newpamd "${CONFDIR}/system-auth-winbind.pam" system-auth-winbind
			doman ../docs/manpages/pam_winbind.8
			dohtml ../docs/htmldocs/manpages/pam_winbind.8.html

			if use examples ; then
				insinto /usr/share/doc/${PF}/examples
				doins -r ../examples/pam_winbind
			fi
		fi

		newpamd "${CONFDIR}/samba.pam" samba
		dodoc pam_smbpass/README
	fi

	# install utilities
	if use tools && [[ -n "${BINPROGS}" ]] ; then
		einfo "install utilities"
		dobin ${BINPROGS} || die "not all bins around"
		for prog in ${BINPROGS} ; do
			doman ../docs/manpages/${prog/bin\/}* || die "doman failed"
			dohtml ../docs/htmldocs/manpages/${prog/bin\/}*.html || die "dohtml failed"
		done
	fi

	# install examples
	if use examples ; then
		einfo "install examples"
		insinto /usr/share/doc/${PF}/examples
		doins -r ../examples/libsmbclient
		use winbind && doins -r ../examples/nss
	fi

}
