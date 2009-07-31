# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/imlib2/imlib2-1.4.2-r1.ebuild,v 1.6 2008/12/07 11:30:44 keytoaster Exp $

EAPI="2"

inherit enlightenment toolchain-funcs eutils multilib-native

MY_P=${P/_/-}
DESCRIPTION="Version 2 of an advanced replacement library for libraries like libXpm"
HOMEPAGE="http://www.enlightenment.org/"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="X bzip2 gif jpeg mmx mp3 png tiff zlib"

DEPEND="=media-libs/freetype-2*[$(get_ml_usedeps)?]
	bzip2? ( app-arch/bzip2[$(get_ml_usedeps)?] )
	zlib? ( sys-libs/zlib[$(get_ml_usedeps)?] )
	gif? ( >=media-libs/giflib-4.1.0[$(get_ml_usedeps)?] )
	png? ( >=media-libs/libpng-1.2.1[$(get_ml_usedeps)?] )
	jpeg? ( media-libs/jpeg[$(get_ml_usedeps)?] )
	tiff? ( >=media-libs/tiff-3.5.5[$(get_ml_usedeps)?] )
	X? ( x11-libs/libXext x11-proto/xextproto )
	mp3? ( media-libs/libid3tag[$(get_ml_usedeps)?] )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-CVE-2008-5187.patch #248057
}

ml-native_src_configure() {
	# imlib2 has diff configure options for x86/amd64 mmx
	local myconf=""
	if [[ $(tc-arch) == "amd64" ]] ; then
		myconf="$(use_enable mmx amd64) --disable-mmx"
	else
		myconf="--disable-amd64 $(use_enable mmx)"
	fi

	[[ $(gcc-major-version) -ge 4 ]] && myconf="${myconf} --enable-visibility-hiding"

	export MY_ECONF="
		$(use_with X x) \
		$(use_with jpeg) \
		$(use_with png) \
		$(use_with tiff) \
		$(use_with gif) \
		$(use_with zlib) \
		$(use_with bzip2) \
		$(use_with mp3 id3) \
		${myconf} \
	"
}

ml-native_src_install() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/imlib2-config 
}
