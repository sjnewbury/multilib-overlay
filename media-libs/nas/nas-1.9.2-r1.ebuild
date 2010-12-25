# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/nas/nas-1.9.2-r1.ebuild,v 1.1 2010/10/31 11:08:59 ssuominen Exp $

EAPI="2"

inherit eutils toolchain-funcs multilib-native

DESCRIPTION="Network Audio System"
HOMEPAGE="http://radscan.com/nas.html"
SRC_URI="mirror://sourceforge/${PN}/${P}.src.tar.gz"

LICENSE="MIT as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc"

RDEPEND="x11-libs/libXt[lib32?]
	x11-libs/libXau[lib32?]
	x11-libs/libXaw[lib32?]
	x11-libs/libX11[lib32?]
	x11-libs/libXres[lib32?]
	x11-libs/libXTrap[lib32?]
	x11-libs/libXp[lib32?]"
DEPEND="${RDEPEND}
	x11-misc/gccmakedep
	x11-misc/imake[lib32?]
	app-text/rman
	x11-proto/xproto"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-asneeded.patch \
		"${FILESDIR}"/${P}-implicit-inet_ntoa-amd64.patch
}

multilib-native_src_configure_internal() {
	xmkmf || die "xmkmf failed"
	touch doc/man/lib/tmp.{_man,man}
}

multilib-native_src_compile_internal() {
	emake \
		LIBDIR="/usr/$(get_libdir)/X11" \
		MAKE="${MAKE:-gmake}" \
		CDEBUGFLAGS="${CFLAGS}" \
		CXXDEBUFLAGS="${CXXFLAGS}" \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR) clq" \
		AS="$(tc-getAS)" \
		LD="$(tc-getLD)" \
		RANLIB="$(tc-getRANLIB)" World || die "emake World failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install install.man || die "emake install failed"
	dodoc BUILDNOTES FAQ HISTORY README RELEASE TODO

	if use doc; then
		docinto doc
		dodoc doc/{actions,protocol.txt,README}
		insinto /usr/share/doc/${PF}/pdf
		doins doc/pdf/*.pdf
	fi

	mv "${D}"/etc/nas/nasd.conf{.eg,}

	newconfd "${FILESDIR}"/nas.conf.d nas
	newinitd "${FILESDIR}"/nas.init.d nas
}

multilib-native_pkg_postinst_internal() {
	elog "To enable NAS on boot you will have to add it to the"
	elog "default profile, issue the following command as root:"
	elog "# rc-update add nas default"
}
