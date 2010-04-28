# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/x264/x264-0.0.20090502.ebuild,v 1.1 2009/05/03 20:08:47 aballier Exp $

EAPI="1"
inherit multilib eutils toolchain-funcs versionator multilib-native

MY_P="x264-snapshot-$(get_version_component_range 3)-2245"

DESCRIPTION="A free library for encoding X264/AVC streams"
HOMEPAGE="http://www.videolan.org/developers/x264.html"
SRC_URI="ftp://ftp.videolan.org/pub/videolan/x264/snapshots/${MY_P}.tar.bz2"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="debug +threads"

RDEPEND=""
DEPEND="amd64? ( >=dev-lang/yasm-0.6.2 )
	x86? ( >=dev-lang/yasm-0.6.2 )
	x86-fbsd? ( >=dev-lang/yasm-0.6.2 )"

S="${WORKDIR}/${MY_P}"

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-nostrip.patch"
	epatch "${FILESDIR}/${PN}-onlylib-20090408.patch"
}

multilib-native_src_compile_internal() {
	local myconf=""
	use debug && myconf="${myconf} --enable-debug"
	./configure --prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--enable-pic --enable-shared \
		"--extra-cflags=${CFLAGS}" \
		"--extra-ldflags=${LDFLAGS}" \
		"--extra-asflags=${ASFLAGS}" \
		"--host=${CHOST}" \
		$(use_enable threads pthread) \
		${myconf} \
		--disable-mp4-output \
		|| die "configure failed"
	emake CC="$(tc-getCC)" || die "make failed"
}

multilib-native_src_install_internal() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS doc/*.txt
}

multilib-native_pkg_postinst_internal() {
	elog "Please note that this package now only installs"
	elog "${PN} libraries. In order to have the encoder,"
	elog "please emerge media-video/x264-encoder."
}
