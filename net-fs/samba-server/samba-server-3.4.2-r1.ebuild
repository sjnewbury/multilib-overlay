# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba-server/samba-server-3.4.2-r1.ebuild,v 1.2 2009/10/24 08:32:33 patrick Exp $

EAPI="2"

inherit pam confutils versionator multilib autotools multilib-native

MY_P="samba-${PV}"

DESCRIPTION="Samba Server component"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/${MY_P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc64 ~x86"
IUSE="samba4 acl ads aio avahi caps cluster cups debug doc examples fam ldap quota swat syslog winbind zeroconf"

# It doesn't matter that mDNSResponder isn't in the multilib overlay, because
# it's the second choice.
DEPEND="!<net-fs/samba-3.3
	ads? ( virtual/krb5[lib32?] sys-fs/e2fsprogs[lib32?] net-fs/samba-libs[ads,lib32?] )
	dev-libs/popt[lib32?]
	virtual/libiconv
	avahi? ( net-dns/avahi[lib32?] )
	zeroconf? ( !avahi? ( || ( net-dns/avahi[mdnsresponder-compat,lib32?] net-misc/mDNSResponder[lib32?] ) ) )
	caps? ( sys-libs/libcap[lib32?] )
	cups? ( net-print/cups[lib32?] )
	debug? ( dev-libs/dmalloc[lib32?] )
	fam? ( dev-libs/libgamin[lib32?] )
	ldap? ( net-nds/openldap[lib32?] )
	syslog? ( virtual/logger )
	sys-libs/tdb[lib32?]
	sys-libs/talloc[lib32?]
	net-fs/samba-libs[caps?,cluster?,cups?,ldap?,syslog?,winbind?,ads?,samba4?,lib32?]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/source3"

RESTRICT="test"

CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"
SBINPROGS="bin/smbd bin/nmbd"
BINPROGS="bin/testparm bin/smbstatus bin/smbcontrol bin/pdbedit
	bin/profiles bin/sharesec
	bin/eventlogadm bin/ldbedit bin/ldbsearch bin/ldbadd bin/ldbdel bin/ldbmodify bin/ldbrename"

multilib-native_pkg_setup_internal() {
	confutils_use_depend_all samba4 ads
	confutils_use_depend_all ads ldap
}

multilib-native_src_prepare_internal() {

	cd ".."

	epatch \
		"${FILESDIR}/samba-3.4.2-add-zlib-linking.patch" \
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
	use caps && export ac_cv_header_sys_capability_h=yes

	local dnssd="--disable-dnssd"
	use zeroconf && ! use avahi && dnssd="--enable-dnssd"

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
		--with-piddir=/var/run/samba \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		$(use_enable debug developer) \
		--enable-largefile \
		--enable-socket-wrapper \
		--enable-nss-wrapper \
		$(use_enable swat) \
		$(use_enable debug dmalloc) \
		$(use_enable cups) \
		--disable-iprint \
		$(use_enable fam) \
		--enable-shared-libs \
		${dnssd} \
		$(use_enable avahi) \
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
		--without-pam \
		--without-pam_smbpass \
		$(use_with syslog) \
		$(use_with quota quotas) \
		$(use_with quota sys-quotas) \
		--without-utmp \
		--without-lib{talloc,tdb,netapi,smbclient,smbsharemodes} \
		--without-libaddns \
		$(use_with cluster ctdb /usr) \
		$(use_with cluster cluster-support) \
		$(use_with acl acl-support) \
		$(use_with aio aio-support) \
		--with-sendfile-support \
		$(use_with winbind)

	use swat && SBINPROGS="${SBINPROGS} bin/swat"
	use winbind && SBINPROGS="${SBINPROGS} bin/winbindd"
	use ads && use winbind && SBIN_PROGS="${SBINPROGS} bin/winbind_krb5_locator"

	use winbind && BINPROGS="${BINPROGS} bin/wbinfo"
}

multilib-native_src_compile_internal() {
	emake ${SBINPROGS} || die "building server binaries failed"
	emake modules || die "building modules failed"
	emake ${BINPROGS} || die "building binaries failed"
}

multilib-native_src_install_internal() {
	dosbin ${SBINPROGS} || die "installing server binaries failed"

	emake DESTDIR="${D}" installmodules || die "installing modules failed"

	dobin ${BINPROGS} || die "installing binaries failed"

	for prog in ${BINPROGS} ${SBINPROGS} ; do
		doman ../docs/manpages/${prog/bin\/}*
	done

	doman ../docs/manpages/vfs* ../docs/manpages/samba.7 ../docs/manpages/smb.conf.5

	diropts -m0700
	keepdir /var/lib/samba/private

	diropts -m1777
	keepdir /var/spool/samba

	diropts -m0755
	keepdir /var/{cache,log}/samba
	keepdir /var/lib/samba/{netlogon,profiles}
	keepdir /var/lib/samba/printers/{W32X86,WIN40,W32ALPHA,W32MIPS,W32PPC,X64,IA64,COLOR}
	keepdir /usr/$(get_libdir)/samba/{auth,pdb,rpc,idmap,nss_info,gpext}

	newconfd "${CONFDIR}/samba.confd" samba
	newinitd "${CONFDIR}/samba.initd" samba

	insinto /etc/samba
	doins "${CONFDIR}"/{smbusers,lmhosts,smb.conf.default}

	insinto /usr/"$(get_libdir)"/samba
	doins ../codepages/{valid.dat,upcase.dat,lowcase.dat}

	if use ldap ; then
		insinto /etc/openldap/schema
		doins ../examples/LDAP/samba.schema
	fi

	if use swat ; then
		insinto /etc/xinetd.d
		newins "${CONFDIR}/swat.xinetd" swat
	fi

	dodoc ../MAINTAINERS ../README* ../Roadmap ../WHATSNEW.txt ../docs/THANKS

	if use doc ; then
		dohtml -r ../docs/htmldocs/*
		dodoc ../docs/*.pdf
	fi

	if use examples ; then
		cd ../examples
		insinto /usr/share/doc/${PF}/examples
		doins -r \
			auth autofs dce-dfs LDAP logon misc pdb perfcounter \
			printer-accounting printing scripts tridge validchars VFS
	fi
}
