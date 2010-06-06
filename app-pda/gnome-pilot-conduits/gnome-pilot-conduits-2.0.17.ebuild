# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-pda/gnome-pilot-conduits/gnome-pilot-conduits-2.0.17.ebuild,v 1.4 2009/06/02 17:14:30 armin76 Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

DESCRIPTION="Gnome Pilot Conduits"
HOMEPAGE="http://live.gnome.org/GnomePilot"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc sparc x86"
IUSE=""

RDEPEND=">=gnome-base/libgnome-2.0[lib32?]
	>=app-pda/gnome-pilot-${PVR}[lib32?]
	>=dev-libs/libxml2-2.5[lib32?]"
DEPEND="sys-devel/gettext[lib32?]
	dev-util/pkgconfig[lib32?]
	${RDEPEND}"

G2CONF="${G2CONF} --enable-pilotlinktest"
SCROLLKEEPER_UPDATE="0"

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# fix build failures
	sed -i "s:pi-md5.h:libpisock/pi-md5.h:g" \
		mal-conduit/mal/common/AG{Digest,MD5}.c || die "sed failed"
}
