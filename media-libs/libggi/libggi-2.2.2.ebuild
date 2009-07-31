# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libggi/libggi-2.2.2.ebuild,v 1.11 2007/07/27 11:22:45 uberlord Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Fast and safe graphics and drivers for about any graphics card to the Linux kernel (sometimes)"
HOMEPAGE="http://www.ggi-project.org"
SRC_URI="mirror://sourceforge/ggi/${P}.src.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="X aalib svga fbcon directfb 3dfx debug mmx vis"

RDEPEND=">=media-libs/libgii-1.0.2[$(get_ml_usedeps)]
	X? ( x11-libs/libXt[$(get_ml_usedeps)]
		x11-libs/libXxf86dga[$(get_ml_usedeps)]
		x11-libs/libXxf86vm[$(get_ml_usedeps)]
		x11-libs/libXt[$(get_ml_usedeps)] )
	svga? ( >=media-libs/svgalib-1.4.2[$(get_ml_usedeps)] )
	aalib? ( >=media-libs/aalib-1.2-r1[$(get_ml_usedeps)] )"
DEPEND="${RDEPEND}
	X? ( x11-proto/xf86dgaproto
		x11-proto/xf86vidmodeproto
		x11-proto/xextproto )"

ml-native_src_configure() {
	local myconf=""

	use svga || myconf="${myconf} --disable-svga --disable-vgagl"

	if use !fbcon && use !directfb; then
		myconf="${myconf} --disable-fbdev --disable-directfb"
	elif use directfb; then
		myconf="${myconf} --enable-fbdev --enable-directfb"
	else
		myconf="${myconf} --enable-fbdev"
	fi

	if use amd64 || use ppc64 || use ia64 ; then
		myconf="${myconf} --enable-64bitc"
	else
		myconf="${myconf} --disable-64bitc"
	fi

	econf $(use_enable 3dfx glide) \
		$(use_enable aalib aa) \
		$(use_enable debug) \
		$(use_enable mmx) \
		$(use_enable vis) \
		$(use_with X x) \
		$(use_enable X x) \
		${myconf}
}

ml-native_src_install() {
	emake DESTDIR=${D} install || die "emake install failed."

	dodoc ChangeLog* FAQ NEWS README
	docinto txt
	dodoc doc/*.txt
}

pkg_postinst() {
	elog
	elog "Be noted that API has been changed, and you need to run"
	elog "revdep-rebuild from gentoolkit to correct deps."
	elog
}
