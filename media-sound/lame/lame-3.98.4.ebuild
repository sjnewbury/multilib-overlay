# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/lame/lame-3.98.4.ebuild,v 1.7 2010/12/09 16:09:49 rich0 Exp $

EAPI=3
inherit autotools eutils multilib-native

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="http://lame.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="debug mmx mp3rtp sndfile static-libs"

RDEPEND=">=sys-libs/ncurses-5.2[lib32?]
	sndfile? ( >=media-libs/libsndfile-1.0.2[lib32?] )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	mmx? ( dev-lang/nasm )"

multilib-native_src_prepare_internal() {
	epatch \
		"${FILESDIR}"/${PN}-3.98-shared-frontend.patch \
		"${FILESDIR}"/${PN}-3.96-ccc.patch \
		"${FILESDIR}"/${PN}-3.98-gtk-path.patch \
		"${FILESDIR}"/${PN}-3.98.2-get_audio.patch

	mkdir libmp3lame/i386/.libs || die #workaround parallel build with nasm

	sed -i -e '/define sp/s/+/ + /g' libmp3lame/i386/nasm.h || die

	AT_M4DIR="${S}" eautoreconf
	epunt_cxx #74498
}

multilib-native_src_configure_internal() {
	local myconf
	use sndfile && myconf="--with-fileio=sndfile"

	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable debug debug norm) \
		$(use_enable mmx nasm) \
		--disable-mp3x \
		$(use_enable mp3rtp) \
		${myconf}
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" pkghtmldir="${EPREFIX}/usr/share/doc/${PF}/html" install || die
	dobin misc/mlame || die

	dodoc API ChangeLog HACKING README* STYLEGUIDE TODO USAGE || die
	dohtml misc/lameGUI.html Dll/LameDLLInterface.htm || die

	find "${ED}" -name '*.la' -exec rm -f '{}' +
}
