# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.4.22.ebuild,v 1.2 2010/10/17 21:02:25 scarabeus Exp $

EAPI=3
inherit xorg-2 multilib-native

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="http://dri.freedesktop.org/${PN}/${P}.tar.bz2"
fi

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
VIDEO_CARDS="intel nouveau radeon vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} +libkms"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs[lib32?]"
DEPEND="${RDEPEND}"

multilib-native_pkg_setup_internal() {
	CONFIGURE_OPTIONS="--enable-udev
			$(use_enable video_cards_intel intel)
			$(use_enable video_cards_nouveau nouveau-experimental-api)
			$(use_enable video_cards_radeon radeon)
			$(use_enable video_cards_vmware vmwgfx-experimental-api)
			$(use_enable libkms)"

	xorg-2_pkg_setup
}
