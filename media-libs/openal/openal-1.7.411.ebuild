# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/openal/openal-1.7.411.ebuild,v 1.1 2009/04/08 20:11:46 hanno Exp $

EAPI="2"

inherit eutils cmake-utils multilib-native

MY_P=${PN}-soft-${PV}

DESCRIPTION="A software implementation of the OpenAL 3D audio API"
HOMEPAGE="http://kcat.strangesoft.net/openal.html"
SRC_URI="http://kcat.strangesoft.net/openal-releases/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="alsa oss debug"
DEPEND="alsa? ( media-libs/alsa-lib[lib32?] )"
RDEPEND="${DEPEND}"
S=${WORKDIR}/${MY_P}

DOCS="alsoftrc.sample"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}/openal-soft-1.7.411-multilib.patch" || die "epatch failed"
}

multilib-native_src_compile_internal() {
	local mycmakeargs=""

	use alsa || mycmakeargs="${mycmakeargs} -DALSA=OFF"
	use oss || mycmakeargs="${mycmakeargs} -DOSS=OFF"
	use debug && mycmakeargs="${mycmakeargs} -DCMAKE_BUILD_TYPE=Debug"

	cmake-utils_src_compile
}

pkg_postinst() {
	einfo "If you have performance problems using this library, then"
	einfo "try add these lines to your ~/.alsoftrc config file:"
	einfo "[alsa]"
	einfo "mmap = off"
}
