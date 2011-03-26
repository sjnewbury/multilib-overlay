# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-3.5.7.ebuild,v 1.2 2011/03/04 15:41:09 jer Exp $

EAPI="2"

inherit pam confutils versionator multilib eutils multilib-native

MY_PV=${PV/_/}
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Library bits of the samba network filesystem"
HOMEPAGE="http://www.samba.org/"
SRC_URI="mirror://samba/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="acl addns ads aio avahi caps +client cluster cups debug doc examples fam
	ldap ldb +netapi pam quota +readline +server +smbclient smbsharemodes swat
	syslog winbind "

DEPEND="dev-libs/popt[lib32?]
	!net-fs/samba-client
	!net-fs/samba-libs
	!net-fs/samba-server
	!net-fs/cifs-utils
	sys-libs/talloc[lib32?]
	sys-libs/tdb[lib32?]
	virtual/libiconv
	ads? ( virtual/krb5[lib32?] sys-fs/e2fsprogs[lib32?]
		client? ( sys-apps/keyutils[lib32?] ) )
	avahi? ( net-dns/avahi[lib32?] )
	caps? ( sys-libs/libcap[lib32?] )
	client? ( !net-fs/mount-cifs
		dev-libs/iniparser[lib32?] )
	cluster? ( >=dev-db/ctdb-1.0.114_p1 )
	cups? ( net-print/cups[lib32?] )
	debug? ( dev-libs/dmalloc )
	fam? ( virtual/fam[lib32?] )
	ldap? ( net-nds/openldap[lib32?] )
	pam? ( virtual/pam[lib32?]
		winbind? ( dev-libs/iniparser[lib32?] ) )
	readline? ( >=sys-libs/readline-5.2[lib32?] )
	syslog? ( virtual/logger )"

RDEPEND="${DEPEND}"

# Disable tests since we don't want to build that much here
RESTRICT="test"

SBINPROGS=""
BINPROGS=""
KRBPLUGIN=""
PLUGINEXT=".so"
SHAREDMODS=""

S="${WORKDIR}/${MY_P}/source3"

# TODO:
# - enable iPrint on Prefix/OSX and Darwin?
# - selftest-prefix? selftest?
# - AFS?

CONFDIR="${FILESDIR}/$(get_version_component_range 1-2)"

multilib-native_pkg_setup_internal() {
	if use server ; then
		SBINPROGS="${SBINPROGS} bin/smbd bin/nmbd"
		BINPROGS="${BINPROGS} bin/testparm bin/smbstatus bin/smbcontrol bin/pdbedit
			bin/profiles bin/sharesec bin/eventlogadm"

		use swat && SBINPROGS="${SBINPROGS} bin/swat"
		use winbind && SBINPROGS="${SBINPROGS} bin/winbindd"
		use ads && use winbind && KRBPLUGIN="${KRBPLUGIN} bin/winbind_krb5_locator"
	fi

	if use client ; then
		BINPROGS="${BINPROGS} bin/smbclient bin/net bin/smbget bin/smbtree
			bin/nmblookup bin/smbpasswd bin/rpcclient bin/smbcacls bin/smbcquotas
			bin/ntlm_auth"

		use ads && SBINPROGS="${SBINPROGS} bin/cifs.upcall"
	fi

	use cups && BINPROGS="${BINPROGS} bin/smbspool"
	use ldb && BINPROGS="${BINPROGS} bin/ldbedit bin/ldbsearch bin/ldbadd bin/ldbdel bin/ldbmodify bin/ldbrename";

	if use winbind ; then
		BINPROGS="${BINPROGS} bin/wbinfo"
		SHAREDMODS="${SHAREDMODS}idmap_rid,idmap_hash"
		use ads && SHAREDMODS="${SHAREDMODS},idmap_ad"
		use ldap && SHAREDMODS="${SHAREDMODS},idmap_ldap,idmap_adex"
	fi

	if use winbind &&
		[[ $(tc-getCC)$ == *gcc* ]] &&
		[[ $(gcc-major-version)$(gcc-minor-version) -lt 43 ]]
	then
		eerror "It is a known issue that ${P} will not build with "
		eerror "winbind use flag enabled when using gcc < 4.3 ."
		eerror "Please use at least the latest stable gcc version."
		die "Using sys-devel/gcc < 4.3 with winbind use flag."
	fi

	confutils_use_depend_all ads ldap
	confutils_use_depend_all swat server
}

multilib-native_src_prepare_internal() {
	cp "${FILESDIR}/samba-3.4.2-lib.tevent.python.mk" "../lib/tevent/python.mk"

	# ensure that winbind has correct ldflags (QA notice)
	sed -i \
		-e 's|LDSHFLAGS="|LDSHFLAGS="\\${LDFLAGS} |g' \
		configure || die "sed failed"

	epatch "${CONFDIR}"/${PN}-3.5.6-kerberos-dummy.patch
}

multilib-native_src_configure_internal() {
	local myconf

	# Filter out -fPIE
	[[ ${CHOST} == *-*bsd* ]] && myconf="${myconf} --disable-pie"

	# Upstream refuses to make this configurable
	use caps && export ac_cv_header_sys_capability_h=yes || export ac_cv_header_sys_capability_h=no

	# use_with doesn't accept 2 USE-flags
	if use client && use ads ; then
		myconf="${myconf} --with-cifsupcall"
	else
		myconf="${myconf} --without-cifsupcall"
	fi

	# Notes:
	# - automount is only needed in conjunction with NIS and we don't have that
	# anymore => LDAP?
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
		--disable-dnssd \
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
		$(use_with client cifsmount) \
		$(use_with client cifsumount) \
		$(use_with pam) \
		$(use_with pam pam_smbpass) \
		$(use_with syslog) \
		$(use_with quota quotas) \
		$(use_with quota sys-quotas) \
		--without-utmp \
		--without-lib{talloc,tdb} \
		$(use_with netapi libnetapi) \
		$(use_with smbclient libsmbclient) \
		$(use_with smbsharemodes libsmbsharemodes) \
		$(use_with addns libaddns) \
		$(use_with cluster ctdb /usr) \
		$(use_with cluster cluster-support) \
		$(use_with acl acl-support) \
		$(use_with aio aio-support) \
		--with-sendfile-support \
		$(use_with winbind) \
		--with-shared-modules=${SHAREDMODS} \
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
	emake modules || die "building modules failed"

	# compile pam moudles
	if use pam ; then
		einfo "make pam modules"
		emake pam_modules || die "emake pam_modules failed";
	fi

	# compile winbind nss modules
	if use winbind ; then
		einfo "make nss modules"
		emake nss_modules || die "emake nss_modules failed";
	fi

	# compile utilities
	if [ -n "${BINPROGS}" ] ; then
		einfo "make binprogs"
		emake ${BINPROGS} || die "emake binprogs failed";
	fi
	if [ -n "${SBINPROGS}" ] ; then
		einfo "make sbinprogs"
		emake ${SBINPROGS} || die "emake sbinprogs failed";
	fi

	if [ -n "${KRBPLUGIN}" ] ; then
		einfo "make krbplugin"
		emake ${KRBPLUGIN}${PLUGINEXT} || die "emake krbplugin failed";
	fi

	if use client ; then
		einfo "make {,u}mount.cifs"
		emake bin/{,u}mount.cifs || die "emake {,u}mount.cifs failed"
	fi
}

multilib-native_src_install_internal() {
	# install libs
	if use addns ; then
		einfo "install addns library"
		emake installlibaddns DESTDIR="${D}" || die "emake install libaddns failed"
	fi
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

	# install modules
	emake installmodules DESTDIR="${D}" || die "installing modules failed"

	if use pam ; then
		einfo "install pam modules"
		emake installpammodules DESTDIR="${D}" || die "emake installpammodules failed"

		if use winbind ; then
			newpamd "${CONFDIR}/system-auth-winbind.pam" system-auth-winbind
			doman ../docs/manpages/pam_winbind.8
		fi

		newpamd "${CONFDIR}/samba.pam" samba
		dodoc pam_smbpass/README
	fi

	# Nsswitch extensions. Make link for wins and winbind resolvers
	if use winbind ; then
		einfo "install libwbclient"
		emake installlibwbclient DESTDIR="${D}" || die "emake installlibwbclient failed"
		dolib.so ../nsswitch/libnss_wins.so
		dosym libnss_wins.so /usr/$(get_libdir)/libnss_wins.so.2
		dolib.so ../nsswitch/libnss_winbind.so
		dosym libnss_winbind.so /usr/$(get_libdir)/libnss_winbind.so.2
		einfo "install libwbclient related manpages"
		doman ../docs/manpages/idmap_rid.8
		doman ../docs/manpages/idmap_hash.8
		if use ldap ; then
			doman ../docs/manpages/idmap_adex.8
			doman ../docs/manpages/idmap_ldap.8
		fi
		if use ads ; then
			doman ../docs/manpages/idmap_ad.8
		fi
	fi

	# install binaries
	insinto /usr
	for prog in ${SBINPROGS} ; do
		dosbin ${prog} || die "installing ${prog} failed"
		doman ../docs/manpages/${prog/bin\/}* || die "doman failed"
	done

	for prog in ${BINPROGS} ; do
		dobin ${prog} || die "installing ${prog} failed"
		doman ../docs/manpages/${prog/bin\/}* || die "doman failed"
	done

	# install krbplugin
	if [ -n "${KRBPLUGIN}" ] ; then
		if has_version app-crypt/mit-krb5 ; then
			insinto /usr/$(get_libdir)/krb5/plugins/libkrb5
			doins ${KRBPLUGIN}${PLUGINEXT} || die "installing
			${KRBPLUGIN}${PLUGINEXT} failed"
		elif has_version app-crypt/heimdal ; then
			insinto /usr/$(get_libdir)/plugin/krb5
			doins ${KRBPLUGIN}${PLUGINEXT} || die "installing
			${KRBPLUGIN}${PLUGINEXT} failed"
		fi
		insinto /usr
		for prog in ${KRBPLUGIN} ; do
			doman ../docs/manpages/${prog/bin\/}* || die "doman failed"
		done
	fi

	# install server components
	if use server ; then
		doman ../docs/manpages/vfs* ../docs/manpages/samba.7

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
		doins "${CONFDIR}"/{smbusers,lmhosts}

		if use ldap ; then
			insinto /etc/openldap/schema
			doins ../examples/LDAP/samba.schema
		fi

		if use swat ; then
			insinto /etc/xinetd.d
			newins "${CONFDIR}/swat.xinetd" swat
			script/installswat.sh "${D}" "${ROOT}/usr/share/doc/${PF}/swat" "${S}" \
				|| die "installing swat failed"
		fi

		dodoc ../MAINTAINERS ../README* ../Roadmap ../WHATSNEW.txt ../docs/THANKS
	fi

	# install client files ({u,}mount.cifs into /)
	if use client ; then
		into /
		dosbin bin/{u,}mount.cifs || die "u/mount.cifs not around"
		doman ../docs/manpages/{u,}mount.cifs.8 || die "can't create man pages"
	fi

	# install the spooler to cups
	if use cups ; then
		dosym /usr/bin/smbspool $(cups-config --serverbin)/backend/smb
	fi

	# install misc files
	insinto /etc/samba
	doins "${CONFDIR}"/smb.conf.default
	doman  ../docs/manpages/smb.conf.5

	insinto /usr/"$(get_libdir)"/samba
	doins ../codepages/{valid.dat,upcase.dat,lowcase.dat}

	# install docs
	if use doc ; then
		dohtml -r ../docs/htmldocs/*
		dodoc ../docs/*.pdf
	fi

	# install examples
	if use examples ; then
		insinto /usr/share/doc/${PF}/examples

		if use smbclient ; then
			doins -r ../examples/libsmbclient
		fi

		if use winbind ; then
			doins -r ../examples/pam_winbind ../examples/nss
		fi

		if use server ; then
			cd ../examples
			doins -r auth autofs dce-dfs LDAP logon misc pdb \
			perfcounter printer-accounting printing scripts tridge \
			validchars VFS
		fi
	fi

	# Remove empty installation directories
	rmdir --ignore-fail-on-non-empty \
		"${D}/usr/$(get_libdir)/samba" \
		"${D}/usr"/{sbin,bin} \
		"${D}/usr/share"/{man,locale,} \
		"${D}/var"/{run,lib/samba/private,lib/samba,lib,cache/samba,cache,} \
	#	|| die "tried to remove non-empty dirs, this seems like a bug in the ebuild"
}

multilib-native_pkg_postinst_internal() {
	elog "The default value of 'wide links' has been changed to 'no' in samba 3.5"
	elog "to avoid an insecure default configuration"
	elog "('wide links = yes' and 'unix extensions = yes'). For more details,"
	elog "please see http://www.samba.org/samba/news/symlink_attack.html ."
	elog ""
	elog "An EXPERIMENTAL implementation of the SMB2 protocol has been added."
	elog "SMB2 can be enabled by setting 'max protocol = smb2'. SMB2 is a new "
	elog "implementation of the SMB protocol used by Windows Vista and higher"
	elog ""
	elog "For further information make sure to read the release notes at"
	elog "http://samba.org/samba/history/${P}.html and "
	elog "http://samba.org/samba/history/${PN}-3.5.0.html"
}
