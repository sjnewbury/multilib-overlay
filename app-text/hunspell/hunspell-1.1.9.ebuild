# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/hunspell/hunspell-1.1.9.ebuild,v 1.10 2008/07/26 10:59:17 armin76 Exp $

EAPI="2"

inherit eutils multilib autotools multilib-native

DESCRIPTION="Hunspell spell checker - an improved replacement for myspell in OOo."
SUBREL=""
SRC_URI="mirror://sourceforge/${PN}/${P}${SUBREL}.tar.gz"
HOMEPAGE="http://hunspell.sourceforge.net/"

SLOT="0"
LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
IUSE="ncurses readline"
KEYWORDS="alpha amd64 ~hppa ia64 ppc ~ppc64 sparc x86"

DEPEND="readline? ( sys-libs/readline[lib32?] )
	ncurses? ( sys-libs/ncurses[lib32?] )
	sys-devel/gettext[lib32?]"
RDEPEND="${DEPEND}"

multilib-native_src_prepare_internal() {
	cd "${S}"
	sed -i -e 's:tail +:tail -n +:' "${S}"/tests/test.sh ||\
		die "Failed to fix-up tail for POSIX compliance"
	# Upstream package creates executables 'example', 'munch'
	# and 'unmunch' which are too generic to be placed in
	# /usr/bin - this patch prefixes them with 'hunspell-'.
	# It modifies a Makefile.am file, hence autoreconf.
	epatch "${FILESDIR}"/hunspell-1.1.5-renameexes.patch
	eautoreconf -f
}

multilib-native_src_configure_internal() {
	# I wanted to put the include files in /usr/include/hunspell
	# but this means the openoffice build won't find them.
	econf \
		$(use_with readline readline) \
		$(use_with ncurses ui) \
		|| die "econf failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO license.hunspell || die "installing docs failed"
	# hunspell is derived from myspell
	dodoc AUTHORS.myspell README.myspell license.myspell || die "installing myspell docs failed"

	# Upstream install has a few problems - rather than try to figure out
	# what's broken in the build system, just fix things up manually.

	# These are included by hunspell.hxx, but aren't installed by the install
	# script.
	insinto /usr/include/hunspell/
	doins license.myspell license.hunspell config.h

	# These are in the wrong place.
	mv "${D}"/usr/include/munch.h "${D}"/usr/include/hunspell/munch.h
	mv "${D}"/usr/include/unmunch.h "${D}"/usr/include/hunspell/unmunch.h

	# Libraries include the version in their name, so make a sensible
	# default symlink.  They should probably be libhunspell.so.1.1 etc.
	dodir /usr/$(get_libdir)
	cd "${D}"/usr/$(get_libdir)
	ln -s libhunspell-1.1.so.0.0.0 libhunspell.so
}

pkg_postinst() {
	elog "To use this package you will also need a dictionary."
	elog "Hunspell uses myspell format dictionaries; find them"
	elog "in the app-dicts category as myspell-<LANG>."
}
