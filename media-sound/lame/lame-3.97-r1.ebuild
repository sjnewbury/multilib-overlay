# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/lame/lame-3.97-r1.ebuild,v 1.11 2008/11/09 21:06:42 loki_val Exp $

EAPI="2"

inherit flag-o-matic toolchain-funcs eutils autotools multilib-native

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="http://lame.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug mp3rtp gtk"

RDEPEND=">=sys-libs/ncurses-5.2[lib32?]
	 gtk? ( =x11-libs/gtk+-1.2*[lib32?] )"
DEPEND="${RDEPEND}"

src_prepare() {
	cd "${S}"

	# The frontened tries to link staticly, but we prefer shared libs
	epatch "${FILESDIR}"/${PN}-3.96.1-shared-frontend.patch

	# If ccc (alpha compiler) is installed on the system, the default
	# configure is broken, fix it to respect CC.  This is only
	# directly broken for ARCH=alpha but would affect anybody with a
	# ccc binary in their PATH.  Bug #41908  (26 Jul 2004 agriffis)
	epatch "${FILESDIR}"/${PN}-3.96-ccc.patch

	# Make sure -lm is linked in the library to fix other programs linking to
	# this while using --as-needed
	epatch "${FILESDIR}"/${PN}-3.96.1-asneeded.patch

	AT_M4DIR="${S}" eautoreconf || die
	epunt_cxx # embedded bug #74498
}

multilib-native_src_configure_internal() {
	# take out -fomit-frame-pointer from CFLAGS if k6-2
	is-flag "-march=k6-3" && filter-flags "-fomit-frame-pointer"
	is-flag "-march=k6-2" && filter-flags "-fomit-frame-pointer"
	is-flag "-march=k6" && filter-flags "-fomit-frame-pointer"

	# The user sets compiler optimizations... But if you'd like
	# lame to choose it's own... uncomment one of these (experiMENTAL)
	# myconf="${myconf} --enable-expopt=full \
	# myconf="${myconf} --enable-expopt=norm \

	econf \
		--enable-shared \
		$(use_enable debug debug norm) \
		--disable-mp3x \
		$(use_enable mp3rtp mp3rtp) \
		$(use_enable gtk gtktest) \
		${myconf} || die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" pkghtmldir="/usr/share/doc/${PF}/html" install || die

	dodoc API ChangeLog HACKING README* STYLEGUIDE TODO USAGE
	dohtml misc/lameGUI.html Dll/LameDLLInterface.htm

	dobin "${S}"/misc/mlame || die
}

pkg_postinst(){
	if use mp3rtp ; then
	    ewarn "Warning, support for the encode-to-RTP program, 'mp3rtp'"
	    ewarn "is broken as of August 2001."
	    ewarn " "
	fi
}
