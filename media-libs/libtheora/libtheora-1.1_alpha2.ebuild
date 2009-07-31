# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libtheora/libtheora-1.1_alpha2.ebuild,v 1.2 2009/06/21 03:37:29 ssuominen Exp $

EAPI=2
inherit autotools eutils flag-o-matic multilib-native

DESCRIPTION="The Theora Video Compression Codec"
HOMEPAGE="http://www.theora.org"
SRC_URI="http://downloads.xiph.org/releases/theora/${P/_}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc encode examples"

RDEPEND="media-libs/libogg[lib32?]
	encode? ( media-libs/libvorbis[lib32?] )
	examples? ( media-libs/libpng[lib32?]
		media-libs/libvorbis[lib32?]
		media-libs/libsdl[lib32?] )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-util/pkgconfig[lib32?]"

VARTEXFONTS=${T}/fonts
S=${WORKDIR}/${P/_}

ml-native_src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.0_beta2-flags.patch
	AT_M4DIR="m4" eautoreconf
}

ml-native_src_configure() {
	use x86 && filter-flags -fforce-addr -frename-registers #200549
	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"

	local myconf
	use examples && myconf="--enable-encode"

	# --disable-spec because LaTeX documentation has been prebuilt
	econf \
		--disable-dependency-tracking \
		--disable-spec \
		$(use_enable encode) \
		$(use_enable examples) \
		${myconf}
}

ml-native_src_install() {
	emake DESTDIR="${D}" docdir=/usr/share/doc/${PF} \
		install || die "emake install failed"

	dodoc AUTHORS CHANGES README
	prepalldocs

	if use examples; then
		if use doc; then
			insinto /usr/share/doc/${PF}/examples
			doins examples/*.[ch]
		fi

		dobin examples/.libs/png2theora || die "dobin failed"
		for bin in dump_{psnr,video} {encoder,player}_example; do
			newbin examples/.libs/${bin} theora_${bin} || die "newbin failed"
		done
	fi
}
