# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/speex/speex-1.2_rc1.ebuild,v 1.8 2009/12/11 19:59:55 ranger Exp $

EAPI="2"

inherit autotools eutils flag-o-matic multilib-native

MY_P=${P/_} ; MY_P=${MY_P/_p/.}

DESCRIPTION="Audio compression format designed for speech."
HOMEPAGE="http://www.speex.org"
SRC_URI="http://downloads.xiph.org/releases/speex/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="ogg sse"

RDEPEND="ogg? ( media-libs/libogg[lib32?] )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-configure.patch

	sed -i -e 's:noinst_PROGRAMS:check_PROGRAMS:' \
		"${S}"/libspeex/Makefile.am \
		|| die "unable to disable tests building"
	eautoreconf
}

multilib-native_src_configure_internal() {
	append-flags -D_FILE_OFFSET_BITS=64

	econf $(use_enable sse) $(use_enable ogg)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" docdir="/usr/share/doc/${PF}" \
		install || die "emake install failed."

	dodoc AUTHORS ChangeLog NEWS README* TODO
}
