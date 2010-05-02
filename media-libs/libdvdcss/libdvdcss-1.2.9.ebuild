# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdvdcss/libdvdcss-1.2.9.ebuild,v 1.23 2008/02/03 17:10:05 aballier Exp $

inherit eutils autotools flag-o-matic multilib-native

DESCRIPTION="A portable abstraction library for DVD decryption"
HOMEPAGE="http://www.videolan.org/developers/libdvdcss.html"
SRC_URI="http://www.videolan.org/pub/${PN}/${PV}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1.2"
KEYWORDS="alpha amd64 arm hppa ia64 mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

multilib-native_pkg_preinst_internal() {
	# these could cause problems if they exist from
	# earlier builds
	for x in libdvdcss.so.0 libdvdcss.so.1 libdvdcss.0.dylib libdvdcss.1.dylib ; do
		if [[ -e ${ROOT}/usr/$(get_libdir)/${x} ]] ; then
			rm -f "${ROOT}"/usr/$(get_libdir)/${x}
		fi
	done
}

multilib-native_src_unpack_internal() {
	unpack ${A}
	cd "${S}"

	# add configure switches to enable/disable doc building
	epatch "${FILESDIR}"/${P}-doc.patch

	eautoreconf
}

multilib-native_src_compile_internal() {
	# Dont use custom optimiziations, as it gives problems
	# on some archs
	strip-flags

	# See bug #98854, requires access to fonts cache for TeX
	# No need to use addwrite, just set TeX font cache in the sandbox
	use doc && export VARTEXFONTS="${T}/fonts"

	econf \
		--enable-static --enable-shared \
		$(use_enable doc) \
		--disable-dependency-tracking || die
	emake || die
}

multilib-native_src_install_internal() {
	make install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog NEWS README
	use doc && dohtml doc/html/*
}
