# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-murrine/gtk-engines-murrine-0.53.1-r1.ebuild,v 1.5 2008/07/07 21:55:24 jokey Exp $

EAPI="2"

inherit eutils multilib-native

MY_PN="murrine"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Murrine GTK+2 Cairo Engine"

HOMEPAGE="http://www.cimitan.com/murrine/"
URI_PREFIX="http://cimi.netsons.org/media/download_gallery"
SRC_URI="${URI_PREFIX}/${MY_PN}/${MY_P}.tar.bz2 ${URI_PREFIX}/MurrinaFancyCandy.tar.bz2 ${URI_PREFIX}/MurrinaVerdeOlivo.tar.bz2 ${URI_PREFIX}/MurrinaGilouche.tar.bz2 ${URI_PREFIX}/MurrinaLoveGray.tar.bz2 ${URI_PREFIX}/MurrineThemePack.tar.bz2 ${URI_PREFIX}/MurrineXfwm.tar.bz2 http://www.kernow-webhosting.com/~bvc/theme/mcity/Murrine.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.8[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]"

S="${WORKDIR}/${MY_P}"

multilib-native_src_prepare_internal() {
	# Fix for bug #198815
	epatch "${FILESDIR}/${P}-use-gtk_free.patch"
}

multilib-native_src_configure_internal() {
	econf --enable-animation || die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodir /usr/share/themes
	insinto /usr/share/themes
	doins -r "${WORKDIR}"/Murrin*

	dodoc AUTHORS ChangeLog CREDITS
}
