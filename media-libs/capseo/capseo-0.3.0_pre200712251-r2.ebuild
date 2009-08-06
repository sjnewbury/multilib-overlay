# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/capseo/capseo-0.3.0_pre200712251-r2.ebuild,v 1.3 2009/03/24 03:13:07 jer Exp $

inherit flag-o-matic multilib multilib-native

DESCRIPTION="Capseo Video Codec Library"
HOMEPAGE="http://rm-rf.in/captury/wiki/CapseoCodec"
SRC_URI="http://upstream.rm-rf.in/captury/captury-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc ~ppc64 ~x86"
IUSE="debug theora"

RDEPEND=">=media-libs/libtheora-1.0_alpha6-r1"
DEPEND="${RDEPEND}
	x86? ( >=dev-lang/yasm-0.4.0 )
	amd64? ( >=dev-lang/yasm-0.4.0 )
	dev-util/pkgconfig"

S="${WORKDIR}/captury-${PV}/${PN}"

EMULTILIB_PKG="true"

src_unpack() {
	unpack ${A} || die

	cd "${S}"
	einfo "pwd: $(pwd)"
	epatch "${FILESDIR}/no-cpsplay.diff"

	if [[ ! -f configure ]]; then
		./autogen.sh || die "autogen.sh failed"
	fi
}

ml-native_src_compile() {
		use debug && append-flags -O0 -g3
		use debug || append-flags -DNDEBUG=1

	cd "${S}" || die

	case ${ABI} in
		amd64|x86)
			myconf="${myconf} --with-accel=${ABI}"
			;;
	esac

	if is_final_abi; then
		myconf="${myconf} $(use_enable theora)"
	else
		# drop unnecessary theora dependency for secondary ABIs (as theora is
		# only used for the cpsrecode tool anyway).
		# see bug 200093.
		myconf="${myconf} --disable-theora"
	fi

	econf ${myconf} \
		--prefix="/usr" \
		--libdir="/usr/$(get_libdir)" \
		|| die "./configure for ABI ${ABI} failed"

	emake || die "make for ABI ${ABI} failed"
}

ml-native_src_install() {
	make install DESTDIR="${D}" || die "make install for ABI ${ABI} failed."

	rm "${D}/usr/bin/cpsplay" # currently unsupported

	dodoc AUTHORS ChangeLog* NEWS README* TODO
}

pkg_postinst() {
	einfo "Use the following command to re-encode your screen captures to a"
	einfo "file format current media players do understand:"
	einfo
	einfo "    cpsrecode -i capture.cps -o - | mencoder - -o capture.avi \\"
	einfo "              -ovc lavc -lavcopts vcodec=xvid:autoaspect=1"
	einfo
	einfo "or play in-place via mplayer:"
	einfo
	einfo "    cpsrecode -i capture.cps -o - | mplayer -demuxer y4m -"
	einfo
	einfo "or if use-flag theora enabled, create your ogg/theora file inplace:"
	einfo
	einfo "    cpsrecode -i capture.cps -o capture.ogg -c theora"
	echo
}

# vim:ai:noet:ts=4:nowrap
