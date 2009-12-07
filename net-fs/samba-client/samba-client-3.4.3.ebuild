# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba-client/samba-client-3.4.3.ebuild,v 1.4 2009/11/30 16:24:14 armin76 Exp $

EAPI="2"

inherit pam confutils versionator multilib eutils toolchain-funcs autotools multilib-native

MY_P="samba-${PV}"

DESCRIPTION="Client bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="samba4 ads aio avahi caps cluster cups debug ldap minimal syslog winbind zeroconf"

DEPEND="!<net-fs/samba-3.3
	!net-fs/mount-cifs
	ads? ( virtual/krb5 sys-fs/e2fsprogs
		net-fs/samba-libs[ads] sys-apps/keyutils )
	!minimal? (
		dev-libs/popt
		dev-libs/iniparser
		virtual/libiconv
		zeroconf? ( || ( net-dns/avahi[mdnsresponder-compat] net-misc/mDNSResponder ) )
		caps? ( sys-libs/libcap )
		cups? ( net-print/cups )
		debug? ( dev-libs/dmalloc )
		ldap? ( net-nds/openldap )
		syslog? ( virtual/logger )
		sys-libs/tdb
		sys-libs/talloc
		~net-fs/samba-libs-${PV}[caps?,cups?,ldap?,syslog?,winbind?,ads?,samba4?,netapi] )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/source3"

# TODO:
# - enable iPrint on Prefix/OSX and Darwin?
# - selftest-prefix? selftest?

RESTRICT="test"

CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"
BINPROGS="bin/smbclient bin/net bin/smbget bin/smbtree bin/nmblookup bin/smbpasswd bin/rpcclient bin/smbcacls bin/smbcquotas bin/ntlm_auth"

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
#		"${FILESDIR}/samba-3.4.2-upgrade-tevent-version.patch" \

	cp "${FILESDIR}/samba-3.4.2-lib.tevent.python.mk" "lib/tevent/python.mk"

	cd "source3"
	eautoconf -Ilibreplace -Im4 -I../m4 -I../lib/replace -I../source4
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
	export ac_cv_header_sys_capability_h=no
	if ! use minimal ; then
		use caps && export ac_cv_header_sys_capability_h=yes
	fi

	if ! use minimal || use ads; then
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
		# - current DNS/SD support in the client is via the mdnsresponder-compat api in avahi
		econf ${myconf} \
			--sysconfdir=/etc/samba \
			--localstatedir=/var \
			$(use_enable debug developer) \
			--enable-largefile \
			--enable-socket-wrapper \
			--enable-nss-wrapper \
			--disable-swat \
			$(use_enable debug dmalloc) \
			$(use minimal && echo "--disable-cups" || echo "$(use_enable cups)") \
			--disable-iprint \
			--disable-fam \
			--enable-shared-libs \
			$(use minimal && echo "--disable-dnssd" || echo "$(use_enable avahi dnssd)") \
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
			$(use minimal && echo "--without-ldap" || echo "$(use_with ldap)") \
			$(use minimal && echo "--without-ads" || echo "$(use_with ads)") \
			$(use minimal && echo "--without-krb5" || echo "$(use_with ads krb5 /usr)") \
			$(use minimal && echo "--without-dnsupdate" || echo "$(use_with ads dnsupdate)") \
			--without-automount \
			--without-cifsmount \
			--without-cifsupcall \
			--without-pam \
			--without-pam_smbpass \
			$(use minimal && echo "--without-syslog" || echo "$(use_with syslog)") \
			--without-quotas \
			--without-sys-quotas \
			--without-utmp \
			--without-lib{talloc,tdb,netapi,smbclient,smbsharemodes} \
			--without-libaddns \
			$(use minimal && echo "--without-ctdb" || echo "$(use_with cluster ctdb /usr)") \
			$(use minimal && echo "--without-cluster" || echo "$(use_with cluster cluster-support)") \
			--without-acl-support \
			$(use minimal && echo "--without-aio-support" || echo "$(use_with aio aio-support)") \
			--with-sendfile-support \
			$(use minimal && echo "--without-winbind" || echo "$(use_with winbind)") \
			--without-included-popt \
			--without-included-iniparser
	fi
}

multilib-native_src_compile_internal() {
	mkdir bin
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o bin/mount.cifs client/{mount.cifs,mtab}.c || die "building mount.cifs failed"
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o bin/umount.cifs client/{umount.cifs,mtab}.c || die "building umount.cifs failed"

	if use ads ; then
		emake bin/cifs.upcall || die "emake cifs.upcall failed"
	fi

	if ! use minimal ; then
		emake ${BINPROGS} || die "emake binprogs failed"
		if use cups ; then
			emake bin/smbspool || die "emake smbspool failed"
		fi
	fi
}

multilib-native_src_install_internal() {
	into /
	dosbin bin/mount.cifs bin/umount.cifs || die "u/mount.cifs not around"
	doman ../docs/manpages/{u,}mount.cifs.8 || die "can't create man pages"
	dohtml ../docs/htmldocs/manpages/{u,}mount.cifs.8.html || die "dohtml failed"

	into /usr
	if use ads ; then
		dosbin bin/cifs.upcall || die "cifs.upcall not around"
		doman ../docs/manpages/cifs.upcall.8 || die "doman failed"
		dohtml ../docs/htmldocs/manpages/cifs.upcall.8.html || die "doman failed"
	fi

	if ! use minimal ; then
		dobin ${BINPROGS} || die "not all bins around"
		for prog in ${BINPROGS} ; do
			doman ../docs/manpages/${prog/bin\/}* || die "doman failed"
			dohtml ../docs/htmldocs/manpages/${prog/bin\/}*.html || die "dohtml failed"
		done

		if use cups ; then
			dobin bin/smbspool || die "smbspool not around"
			doman ../docs/manpages/smbspool.8 || die "doman failed"
			dohtml ../docs/htmldocs/manpages/smbspool.8.html || die "dohtml failed"
			dosym /usr/bin/smbspool $(cups-config --serverbin)/backend/smb
		fi
	fi
}
