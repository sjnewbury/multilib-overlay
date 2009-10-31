# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openal/openal-1.9.563-r1.ebuild,v 1.1 2009/10/27 18:11:17 ssuominen Exp $

EAPI=2

inherit cmake-utils multilib-native

MY_P=${PN}-soft-${PV}

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html"
SRC_URI="http://kcat.strangesoft.net/openal-releases/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="alsa debug oss portaudio pulseaudio"

RDEPEND="alsa? ( media-libs/alsa-lib[lib32?] )
	portaudio? ( >=media-libs/portaudio-19_pre[lib32?] )
	pulseaudio? ( media-sound/pulseaudio[lib32?] )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}
DOCS="alsoftrc.sample"
PATCHES=( "${FILESDIR}/${P}-oss.patch" )

multilib-native_src_configure_internal() {
	local mycmakeargs="$(cmake-utils_use alsa ALSA)
		$(cmake-utils_use oss OSS)
		$(cmake-utils_use portaudio PORTAUDIO)
		$(cmake-utils_use pulseaudio PULSEAUDIO)"

	use debug && mycmakeargs+=" -DCMAKE_BUILD_TYPE=Debug"

	cmake-utils_src_configure
}

pkg_postinst() {
	elog "If you have performance problems using this library, then"
	elog "try add these lines to your ~/.alsoftrc config file:"
	elog "[alsa]"
	elog "mmap = off"
}
