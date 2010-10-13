# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/lame/lame-3.98.2-r1.ebuild,v 1.9 2010/10/04 15:21:56 mr_bones_ Exp $

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
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug mmx mp3rtp sndfile"

RDEPEND=">=sys-libs/ncurses-5.2[lib32?]
	sndfile? ( >=media-libs/libsndfile-1.0.2[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	mmx? ( dev-lang/nasm )"

multilib-native_src_prepare_internal() {
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

	# It fails parallel make otherwise when enabling nasm...
	mkdir "${S}/libmp3lame/i386/.libs" || die

	sed -i -e '/define sp/s/+/ + /g' libmp3lame/i386/nasm.h || die

	AT_M4DIR="${S}" eautoreconf
	epunt_cxx # embedded bug #74498
}

multilib-native_src_configure_internal() {
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

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" pkghtmldir="/usr/share/doc/${PF}/html" install || die

	dodoc API ChangeLog HACKING README* STYLEGUIDE TODO USAGE || die
	dohtml misc/lameGUI.html Dll/LameDLLInterface.htm || die

	dobin "${S}"/misc/mlame || die
}

multilib-native_pkg_postinst_internal(){
	if use mp3rtp ; then
	    ewarn "Warning, support for the encode-to-RTP program, 'mp3rtp'"
	    ewarn "is broken as of August 2001."
	    ewarn " "
	fi
}
