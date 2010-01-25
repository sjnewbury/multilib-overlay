# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/xz-utils/xz-utils-9999.ebuild,v 1.5 2010/01/15 03:19:43 vapier Exp $

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

EAPI="2"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://ctrl.tukaani.org/xz.git"
	inherit git autotools
	SRC_URI=""
	EXTRA_DEPEND="sys-devel/gettext dev-util/cvs >=sys-devel/libtool-2" #272880 286068
else
	MY_P="${PN/-utils}-${PV/_}"
	SRC_URI="http://tukaani.org/xz/${MY_P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
	S=${WORKDIR}/${MY_P}
	EXTRA_DEPEND=
fi

inherit eutils multilib-native

DESCRIPTION="utils for managing LZMA compressed files"
HOMEPAGE="http://tukaani.org/xz/"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="nls static-libs +threads"

RDEPEND="!app-arch/lzma
	!app-arch/lzma-utils
	!<app-arch/p7zip-4.57"
DEPEND="${RDEPEND}
	${EXTRA_DEPEND}"

if [[ ${PV} == "9999" ]] ; then
multilib-native_src_prepare_internal() {
	eautopoint
	eautoreconf
}
fi

multilib-native_src_configure_internal() {
	econf \
		--enable-dynamic=yes \
		$(use_enable nls) \
		$(use_enable threads) \
		$(use_enable static-libs static)
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die
	rm "${D}"/usr/share/doc/xz/COPYING* || die
	mv "${D}"/usr/share/doc/{xz,${PF}} || die
	prepalldocs
	dodoc AUTHORS ChangeLog NEWS README THANKS
}
