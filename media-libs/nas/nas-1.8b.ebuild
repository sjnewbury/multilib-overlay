# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/nas/nas-1.8b.ebuild,v 1.9 2007/06/24 21:59:53 vapier Exp $

inherit eutils toolchain-funcs multilib-native

DESCRIPTION="Network Audio System"
HOMEPAGE="http://radscan.com/nas.html"
SRC_URI="http://radscan.com/nas/${P}.src.tar.gz"

LICENSE="X11"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND="x11-libs/libXt[$(get_ml_usedeps)]
	x11-libs/libXau[$(get_ml_usedeps)]
	x11-libs/libXaw[$(get_ml_usedeps)]
	x11-libs/libX11[$(get_ml_usedeps)]
	x11-libs/libXres[$(get_ml_usedeps)]
	x11-libs/libXTrap[$(get_ml_usedeps)]
	x11-libs/libXp[$(get_ml_usedeps)]"
DEPEND="${RDEPEND}
	x11-misc/gccmakedep
	x11-misc/imake
	app-text/rman
	x11-proto/xproto"

ml-native_src_compile() {
	xmkmf || die "xmkmf failed."
	touch doc/man/lib/tmp.{_man,man}
	emake \
		MAKE="${MAKE:-gmake}" CDEBUGFLAGS="${CFLAGS}" CXXDEBUFLAGS="${CXXFLAGS}" \
		CC="$(tc-getCC)" CXX="$(tc-getCXX)" AS="$(tc-getAS)" LD="$(tc-getLD)" \
		RANLIB="$(tc-getRANLIB)" World || die "emake failed."
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	emake DESTDIR="${D}" install.man || die "emake install.man failed."

	dodoc BUGS BUILDNOTES FAQ HISTORY README RELEASE TODO
	use doc && dodoc doc/*.ps doc/{actions,README} doc/pdf/*.pdf doc/*.txt

	# rename example nasd.conf.eg to nasd.conf and change it so that NAS
	# doesn't change mixer's settings (inspired by Debian package):
	if  (use lib32 && is_final_abi) || ! use lib32; then
		mv "${D}"/etc/nas/nasd.conf{.eg,}
		sed -i -e 's,\(MixerInit.*\)"\(.*\)",\1"no",' "${D}"/etc/nas/nasd.conf
	fi

	newconfd "${FILESDIR}"/nas.conf.d nas
	newinitd "${FILESDIR}"/nas.init.d nas
}

pkg_postinst() {
	elog "To enable NAS on boot you will have to add it to the"
	elog "default profile, issue the following command as root to do so."
	elog ""
	elog "rc-update add nas default"
}
