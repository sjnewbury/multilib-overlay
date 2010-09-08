# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openssh/openssh-5.5_p1-r2.ebuild,v 1.5 2010/09/06 20:56:55 ranger Exp $

EAPI="2"
inherit eutils flag-o-matic multilib autotools pam multilib-native

# Make it more portable between straight releases
# and _p? releases.
PARCH=${P/_/}
PARCH_54=${PARCH/5.5/5.4}

HPN_PATCH="${PARCH}-hpn13v9.diff.gz"
HPN_X509_PATCH="${PARCH_54}-hpn13v7-x509variant.diff.gz"
LDAP_PATCH="${PARCH_54/openssh/openssh-lpk}-0.3.13.patch.gz"
X509_VER="6.2.3" X509_PATCH="${PARCH}+x509-${X509_VER}.diff.gz"

DESCRIPTION="Port of OpenBSD's free SSH release"
HOMEPAGE="http://www.openssh.org/"
SRC_URI="mirror://openbsd/OpenSSH/portable/${PARCH}.tar.gz
	${HPN_PATCH:+hpn? ( http://www.psc.edu/networking/projects/hpn-ssh/${HPN_PATCH} mirror://gentoo/${HPN_PATCH} )}
	${LDAP_PATCH:+ldap? ( mirror://gentoo/${LDAP_PATCH} )}
	${X509_PATCH:+X509? ( http://roumenpetrov.info/openssh/x509-${X509_VER}/${X509_PATCH} )}
	${HPN_X509_PATCH:+hpn? ( X509? ( mirror://gentoo/${HPN_X509_PATCH} ) )}
	"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~m68k ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="hpn kerberos ldap libedit pam selinux skey static tcpd X X509"

RDEPEND="pam? ( virtual/pam[lib32?] )
	kerberos? ( virtual/krb5[lib32?] )
	selinux? ( >=sys-libs/libselinux-1.28[lib32?] )
	skey? ( >=sys-auth/skey-1.1.5-r1 )
	ldap? ( net-nds/openldap[lib32?] )
	libedit? ( dev-libs/libedit[lib32?] )
	>=dev-libs/openssl-0.9.6d[lib32?]
	>=sys-libs/zlib-1.2.3[lib32?]
	tcpd? ( >=sys-apps/tcp-wrappers-7.6[lib32?] )
	X? ( x11-apps/xauth )
	userland_GNU? ( sys-apps/shadow )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	virtual/os-headers
	sys-devel/autoconf"
RDEPEND="${RDEPEND}
	pam? ( >=sys-auth/pambase-20081028 )"
PROVIDE="virtual/ssh"

S=${WORKDIR}/${PARCH}

multilib-native_pkg_setup_internal() {
	# this sucks, but i'd rather have people unable to `emerge -u openssh`
	# than not be able to log in to their server any more
	maybe_fail() { [[ -z ${!2} ]] && echo ${1} ; }
	local fail="
		$(use X509 && maybe_fail X509 X509_PATCH)
		$(use ldap && maybe_fail ldap LDAP_PATCH)
		$(use hpn && maybe_fail hpn HPN_PATCH)
		$(use X509 && use hpn && maybe_fail x509+hpn HPN_X509_PATCH)
	"
	fail=$(echo ${fail})
	if [[ -n ${fail} ]] ; then
		eerror "Sorry, but this version does not yet support features"
		eerror "that you requested:	 ${fail}"
		eerror "Please mask ${PF} for now and check back later:"
		eerror " # echo '=${CATEGORY}/${PF}' >> /etc/portage/package.mask"
		die "booooo"
	fi
}

multilib-native_src_prepare_internal() {
	sed -i \
		-e '/_PATH_XAUTH/s:/usr/X11R6/bin/xauth:/usr/bin/xauth:' \
		pathnames.h || die
	# keep this as we need it to avoid the conflict between LPK and HPN changing
	# this file.
	cp version.h version.h.pristine

	if use X509 ; then
		# Apply X509 patch
		epatch "${DISTDIR}"/${X509_PATCH}
		# Apply glue so that HPN will still work after X509
		#epatch "${FILESDIR}"/${PN}-5.2_p1-x509-hpn-glue.patch
	fi
	if ! use X509 ; then
		if [[ -n ${LDAP_PATCH} ]] && use ldap ; then
			epatch "${DISTDIR}"/${LDAP_PATCH}
			epatch "${FILESDIR}"/${PN}-5.2p1-ldap-stdargs.diff #266654
			# version.h patch conflict avoidence
			mv version.h version.h.lpk
			cp -f version.h.pristine version.h
		fi
	else
		use ldap && ewarn "Sorry, X509 and LDAP conflict internally, disabling LDAP"
	fi
	epatch "${FILESDIR}"/${PN}-5.4_p1-openssl.patch
	epatch "${FILESDIR}"/${PN}-4.7_p1-GSSAPI-dns.patch #165444 integrated into gsskex
	if [[ -n ${HPN_PATCH} ]] && use hpn; then
		if use X509 ; then
			epatch "${DISTDIR}"/${HPN_X509_PATCH}
		else
			epatch "${DISTDIR}"/${HPN_PATCH}
		fi
		# version.h patch conflict avoidence
		mv version.h version.h.hpn
		cp -f version.h.pristine version.h
		# The AES-CTR multithreaded variant is temporarily broken, and
		# causes random hangs when combined with the -f switch of ssh.
		# To avoid this, we change the internal table to use the non-multithread
		# version for the meantime.
		sed -i \
			-e '/aes...-ctr.*SSH_CIPHER_SSH2/s,evp_aes_ctr_mt,evp_aes_128_ctr,' \
			cipher.c || die
	fi
	epatch "${FILESDIR}"/${PN}-5.2_p1-autoconf.patch

	sed -i "s:-lcrypto:$(pkg-config --libs openssl):" configure{,.ac} || die

	# Disable PATH reset, trust what portage gives us. bug 254615
	sed -i -e 's:^PATH=/:#PATH=/:' configure || die

	# Now we can build a sane merged version.h
	t="${T}"/version.h
	m="${t}.merge" f="${t}.final"
	cat version.h.{hpn,pristine,lpk} 2>/dev/null \
		| sed '/^#define SSH_RELEASE/d' \
		| sort | uniq >"${m}"
	sed -n -r \
		-e '/^\//p' \
		<"${m}" >"${f}"
	sed -n -r \
		-e '/SSH_LPK/s,"lpk","-lpk",g' \
		-e '/^#define/p' \
		<"${m}" >>"${f}"
	v="SSH_VERSION SSH_PORTABLE"
	[[ -f version.h.hpn ]] && v="${v} SSH_HPN"
	[[ -f version.h.lpk ]] && v="${v} SSH_LPK"
	echo "#define SSH_RELEASE ${v}" >>"${f}"
	cp "${f}" version.h

	# Use CC not LD otherwise invalid LDFLAGS get passed to ld
	sed -i -e 's:$(LD):$(CC):' Makefile.in || die

	eautoreconf
}

static_use_with() {
	local flag=$1
	if use static && use ${flag} ; then
		ewarn "Disabling '${flag}' support because of USE='static'"
		# rebuild args so that we invert the first one (USE flag)
		# but otherwise leave everything else working so we can
		# just leverage use_with
		shift
		[[ -z $1 ]] && flag="${flag} ${flag}"
		set -- !${flag} "$@"
	fi
	use_with "$@"
}

multilib-native_src_configure_internal() {
	addwrite /dev/ptmx
	addpredict /etc/skey/skeykeys #skey configure code triggers this

	use static && append-ldflags -static

	econf \
		--with-ldflags="${LDFLAGS}" \
		--disable-strip \
		--sysconfdir=/etc/ssh \
		--libexecdir=/usr/$(get_libdir)/misc \
		--datadir=/usr/share/openssh \
		--with-privsep-path=/var/empty \
		--with-privsep-user=sshd \
		--with-md5-passwords \
		--with-ssl-engine \
		$(static_use_with pam) \
		$(static_use_with kerberos kerberos5 /usr) \
		${LDAP_PATCH:+$(use X509 || ( use ldap && use_with ldap ))} \
		$(use_with libedit) \
		$(use_with selinux) \
		$(use_with skey) \
		$(use_with tcpd tcp-wrappers) \
		|| die
}

multilib-native_src_compile_internal() {
	emake || die
}

multilib-native_src_install_internal() {
	emake install-nokeys DESTDIR="${D}" || die
	fperms 600 /etc/ssh/sshd_config
	dobin contrib/ssh-copy-id
	newinitd "${FILESDIR}"/sshd.rc6 sshd
	newconfd "${FILESDIR}"/sshd.confd sshd
	keepdir /var/empty

	newpamd "${FILESDIR}"/sshd.pam_include.2 sshd
	if use pam ; then
		sed -i \
			-e "/^#UsePAM /s:.*:UsePAM yes:" \
			-e "/^#PasswordAuthentication /s:.*:PasswordAuthentication no:" \
			-e "/^#PrintMotd /s:.*:PrintMotd no:" \
			-e "/^#PrintLastLog /s:.*:PrintLastLog no:" \
			"${D}"/etc/ssh/sshd_config || die "sed of configuration file failed"
	fi

	# This instruction is from the HPN webpage,
	# Used for the server logging functionality
	if [[ -n ${HPN_PATCH} ]] && use hpn; then
		keepdir /var/empty/dev
	fi

	doman contrib/ssh-copy-id.1
	dodoc ChangeLog CREDITS OVERVIEW README* TODO sshd_config

	diropts -m 0700
	dodir /etc/skel/.ssh
}

src_test() {
	local t tests skipped failed passed shell
	tests="interop-tests compat-tests"
	skipped=""
	shell=$(getent passwd ${UID} | cut -d: -f7)
	if [[ ${shell} == */nologin ]] || [[ ${shell} == */false ]] ; then
		elog "Running the full OpenSSH testsuite"
		elog "requires a usable shell for the 'portage'"
		elog "user, so we will run a subset only."
		skipped="${skipped} tests"
	else
		tests="${tests} tests"
	fi
	for t in ${tests} ; do
		# Some tests read from stdin ...
		emake -k -j1 ${t} </dev/null \
			&& passed="${passed}${t} " \
			|| failed="${failed}${t} "
	done
	einfo "Passed tests: ${passed}"
	ewarn "Skipped tests: ${skipped}"
	if [[ -n ${failed} ]] ; then
		ewarn "Failed tests: ${failed}"
		die "Some tests failed: ${failed}"
	else
		einfo "Failed tests: ${failed}"
		return 0
	fi
}

multilib-native_pkg_postinst_internal() {
	enewgroup sshd 22
	enewuser sshd 22 -1 /var/empty sshd

	ewarn "Remember to merge your config files in /etc/ssh/ and then"
	ewarn "reload sshd: '/etc/init.d/sshd reload'."
	if use pam ; then
		echo
		ewarn "Please be aware users need a valid shell in /etc/passwd"
		ewarn "in order to be allowed to login."
	fi
	# This instruction is from the HPN webpage,
	# Used for the server logging functionality
	if [[ -n ${HPN_PATCH} ]] && use hpn; then
		echo
		einfo "For the HPN server logging patch, you must ensure that"
		einfo "your syslog application also listens at /var/empty/dev/log."
	fi
}
