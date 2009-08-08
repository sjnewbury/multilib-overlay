# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-murrine/gtk-engines-murrine-0.53.1.ebuild,v 1.5 2007/07/19 13:48:48 angelos Exp $

MY_PN="murrine"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="Murrine GTK+2 Cairo Engine"

HOMEPAGE="http://cimi.netsons.org/pages/murrine.php"
URI_PREFIX="http://cimi.netsons.org/media/download_gallery"
SRC_URI="${URI_PREFIX}/${MY_PN}/${MY_P}.tar.bz2 ${URI_PREFIX}/MurrinaFancyCandy.tar.bz2 ${URI_PREFIX}/MurrinaVerdeOlivo.tar.bz2 ${URI_PREFIX}/MurrinaGilouche.tar.bz2 ${URI_PREFIX}/MurrinaLoveGray.tar.bz2 ${URI_PREFIX}/MurrineThemePack.tar.bz2 ${URI_PREFIX}/MurrineXfwm.tar.bz2 http://www.kernow-webhosting.com/~bvc/theme/mcity/Murrine.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.6[$(get_ml_usedeps)]"
DEPEND=">=x11-libs/gtk+-2.6[$(get_ml_usedeps)]"

S="${WORKDIR}/${MY_P}"

ml-native_src_compile() {
	econf --enable-animation || die "econf failed"
	emake || die "emake failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodir /usr/share/themes
	insinto /usr/share/themes
	doins -r ${WORKDIR}/Murrin*
}
