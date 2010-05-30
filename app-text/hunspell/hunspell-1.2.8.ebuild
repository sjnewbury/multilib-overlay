# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/hunspell/hunspell-1.2.8.ebuild,v 1.11 2010/04/06 17:08:52 abcd Exp $

EAPI="2"

inherit eutils multilib autotools flag-o-matic multilib-native

MY_P=${PN}-${PV/_beta/b}

DESCRIPTION="Hunspell spell checker - an improved replacement for myspell in OOo."
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
HOMEPAGE="http://hunspell.sourceforge.net/"

SLOT="0"
LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
IUSE="ncurses nls readline"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ppc64 ~sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

DEPEND="readline? ( sys-libs/readline[lib32?] )
	ncurses? ( sys-libs/ncurses[lib32?] )
	sys-devel/gettext[lib32?]"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

multilib-native_src_prepare_internal() {
	# Upstream package creates some executables which names are too generic
	# to be placed in /usr/bin - this patch prefixes them with 'hunspell-'.
	# It modifies a Makefile.am file, hence eautoreconf.
	epatch "${FILESDIR}"/${PN}-1.2.2-renameexes.patch
	eautoreconf
}

multilib-native_src_configure_internal() {
	# missing somehow, and I am too lazy to fix it properly
	[[ ${CHOST} == *-darwin* ]] && append-libs -liconv

	# I wanted to put the include files in /usr/include/hunspell
	# but this means the openoffice build won't find them.
	econf \
		$(use_enable nls) \
		$(use_with ncurses ui) \
		$(use_with readline readline)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO license.hunspell || die "installing docs failed"
	# hunspell is derived from myspell
	dodoc AUTHORS.myspell README.myspell license.myspell || die "installing myspell docs failed"
}

multilib-native_pkg_postinst_internal() {
	elog "To use this package you will also need a dictionary."
	elog "Hunspell uses myspell format dictionaries; find them"
	elog "in the app-dicts category as myspell-<LANG>."
}
