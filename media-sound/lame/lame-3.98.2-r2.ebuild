# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/lame/lame-3.98.2-r2.ebuild,v 1.1 2009/07/22 19:03:13 ssuominen Exp $

EAPI="2"

inherit flag-o-matic toolchain-funcs eutils autotools versionator multilib-native

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="http://lame.sourceforge.net"

MY_PV=$(replace_version_separator 1 '')
[ ${MY_PV/.} = ${MY_PV} ] || MY_PV=$(replace_version_separator 1 '-' ${MY_PV})
S=${WORKDIR}/${PN}-${MY_PV}
SRC_URI="mirror://sourceforge/${PN}/${PN}-${MY_PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug mmx mp3rtp sndfile"

RDEPEND=">=sys-libs/ncurses-5.2[$(get_ml_usedeps)]
	sndfile? ( >=media-libs/libsndfile-1.0.2[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[$(get_ml_usedeps)]
	mmx? ( dev-lang/nasm )"

ml-native_src_prepare() {
	cd "${S}"

	# The frontened tries to link staticly, but we prefer shared libs
	epatch "${FILESDIR}"/${PN}-3.98-shared-frontend.patch

	# If ccc (alpha compiler) is installed on the system, the default
	# configure is broken, fix it to respect CC.  This is only
	# directly broken for ARCH=alpha but would affect anybody with a
	# ccc binary in their PATH.  Bug #41908  (26 Jul 2004 agriffis)
	epatch "${FILESDIR}"/${PN}-3.96-ccc.patch

	# Patch gtk stuff, otherwise eautoreconf dies
	epatch "${FILESDIR}"/${PN}-3.98-gtk-path.patch

	# Fix for ffmpeg-0.5, bug 265830
	epatch "${FILESDIR}"/${PN}-3.98.2-ffmpeg-0.5.patch

	# Read and write from std* when sndfile is used
	epatch "${FILESDIR}"/${PN}-3.98.2-get_audio.patch

	# It fails parallel make otherwise when enabling nasm...
	mkdir "${S}/libmp3lame/i386/.libs" || die

	AT_M4DIR="${S}" eautoreconf
	epunt_cxx # embedded bug #74498
}

ml-native_src_configure() {
	use sndfile && myconf="--with-fileio=sndfile"
	# The user sets compiler optimizations... But if you'd like
	# lame to choose it's own... uncomment one of these (experiMENTAL)
	# myconf="${myconf} --enable-expopt=full \
	# myconf="${myconf} --enable-expopt=norm \

	econf \
		--enable-shared \
		$(use_enable debug debug norm) \
		--disable-mp3x \
		$(use_enable mmx nasm) \
		$(use_enable mp3rtp) \
		${myconf} || die "econf failed"
}

ml-native_src_install() {
	emake DESTDIR="${D}" pkghtmldir="/usr/share/doc/${PF}/html" install || die

	dodoc API ChangeLog HACKING README* STYLEGUIDE TODO USAGE || die
	dohtml misc/lameGUI.html Dll/LameDLLInterface.htm || die

	dobin "${S}"/misc/mlame || die
}

pkg_postinst(){
	if use mp3rtp ; then
	    ewarn "Warning, support for the encode-to-RTP program, 'mp3rtp'"
	    ewarn "is broken as of August 2001."
	    ewarn " "
	fi
}
