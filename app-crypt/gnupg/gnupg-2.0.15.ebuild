# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gnupg/gnupg-2.0.15.ebuild,v 1.14 2010/09/30 18:56:21 ssuominen Exp $

EAPI="3"

inherit flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="The GNU Privacy Guard, a GPL pgp replacement"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/gnupg/${P}.tar.bz2"
SRC_URI="ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="adns bzip2 caps doc ldap nls openct pcsc-lite static selinux smartcard"

COMMON_DEPEND_LIBS="
	>=dev-libs/pth-1.3.7[lib32?]
	>=dev-libs/libassuan-2[lib32?]
	>=dev-libs/libgcrypt-1.4[lib32?]
	>=dev-libs/libgpg-error-1.7[lib32?]
	>=dev-libs/libksba-1.0.2[lib32?]
	>=net-misc/curl-7.10[lib32?]
	adns? ( >=net-libs/adns-1.4[lib32?] )
	bzip2? ( app-arch/bzip2[lib32?] )
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0 )
	openct? ( >=dev-libs/openct-0.5.0[lib32?] )
	smartcard? ( =virtual/libusb-0*[lib32?] )
	ldap? ( net-nds/openldap[lib32?] )"
COMMON_DEPEND_BINS="|| ( app-crypt/pinentry app-crypt/pinentry-qt )"

# existence of bins are checked during configure
DEPEND="${COMMON_DEPEND_LIBS}
	${COMMON_DEPEND_BINS}
	static? ( >=dev-libs/libassuan-2[static-libs,lib32?] )
	nls? ( sys-devel/gettext[lib32?] )
	doc? ( sys-apps/texinfo )"

RDEPEND="!static? ( ${COMMON_DEPEND_LIBS} )
	${COMMON_DEPEND_BINS}
	virtual/mta
	!app-crypt/gpg-agent
	!<=app-crypt/gnupg-2.0.1
	selinux? ( sec-policy/selinux-gnupg )
	nls? ( virtual/libintl )"

multilib-native_src_configure_internal() {
	# 'USE=static' support was requested:
	# gnupg1: bug #29299
	# gnupg2: bug #159623
	use static && append-ldflags -static

	econf \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--enable-gpg \
		--enable-gpgsm \
		--enable-agent \
		$(use_with adns) \
		$(use_enable bzip2) \
		$(use_enable smartcard scdaemon) \
		$(use_enable !elibc_SunOS symcryptrun) \
		$(use_enable nls) \
		$(use_enable ldap) \
		$(use_with caps capabilities) \
		CC_FOR_BUILD=$(tc-getBUILD_CC)
}

multilib-native_src_compile_internal() {
	emake || die "emake failed"
	if use doc; then
		cd doc
		emake html || die "emake html failed"
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog NEWS README THANKS TODO VERSION

	mv "${ED}usr/share/gnupg/help"* "${ED}usr/share/doc/${PF}"
	ecompressdir "/usr/share/doc/${PF}"

	dosym gpg2 /usr/bin/gpg
	dosym gpgv2 /usr/bin/gpgv
	dosym gpg2keys_hkp /usr/libexec/gpgkeys_hkp
	dosym gpg2keys_finger /usr/libexec/gpgkeys_finger
	dosym gpg2keys_curl /usr/libexec/gpgkeys_curl
	use ldap && dosym gpg2keys_ldap /usr/libexec/gpgkeys_ldap
	echo ".so man1/gpg2.1" > "${ED}usr/share/man/man1/gpg.1"
	echo ".so man1/gpgv2.1" > "${ED}usr/share/man/man1/gpgv.1"

	use doc && dohtml doc/gnupg.html/* doc/*jpg doc/*png
}

multilib-native_pkg_postinst_internal() {
	elog "If you wish to view images emerge:"
	elog "media-gfx/xloadimage, media-gfx/xli or any other viewer"
	elog "Remember to use photo-viewer option in configuration file to activate"
	elog "the right viewer."

	ewarn "Please remember to restart gpg-agent if a different version"
	ewarn "of the agent is currently used. If you are unsure of the gpg"
	ewarn "agent you are using please run 'killall gpg-agent',"
	ewarn "and to start a fresh daemon just run 'gpg-agent --daemon'."
}
