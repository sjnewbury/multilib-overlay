# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libv4l/libv4l-0.7.91.ebuild,v 1.1 2010/05/10 15:07:28 ssuominen Exp $

EAPI=3
inherit multilib toolchain-funcs multilib-native

MY_P=v4l-utils-${PV}

DESCRIPTION="Separate libraries ebuild from upstream v4l-utils package"
HOMEPAGE="http://people.fedoraproject.org/~jwrdegoede/"
SRC_URI="http://people.fedoraproject.org/~jwrdegoede/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

S=${WORKDIR}/${MY_P}

multilib-native_src_compile_internal() {
	tc-export CC
	pushd lib
	emake PREFIX="${EPREFIX}/usr" LIBDIR="${EPREFIX}/usr/$(get_libdir)" \
		CFLAGS="${CFLAGS}" || die
	popd
}

multilib-native_src_install_internal() {
	pushd lib
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" LIBDIR="${EPREFIX}/usr/$(get_libdir)" install || die
	popd
	dodoc ChangeLog README* TODO || die
}
