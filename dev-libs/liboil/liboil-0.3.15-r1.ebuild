# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboil/liboil-0.3.15-r1.ebuild,v 1.1 2009/03/08 12:04:58 eva Exp $

EAPI="2"

inherit flag-o-matic multilib-native

DESCRIPTION="library of simple functions that are optimized for various CPUs"
HOMEPAGE="http://liboil.freedesktop.org/"
SRC_URI="http://liboil.freedesktop.org/download/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0.3"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc +examples test"

RDEPEND="examples? ( =dev-libs/glib-2*[$(get_ml_usedeps)?] )"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1 )"

ml-native_src_prepare() {
	if ! use examples; then
		sed "s/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/" \
			-i Makefile.am Makefile.in || die "sed failed."
	fi

	if ! use test; then
		sed "s/^\(SUBDIRS =.*\)testsuite\(.*\)$/\1\2/" \
			-i Makefile.am Makefile.in || die "sed failed."
	fi

}

ml-native_src_configure() {
	strip-flags
	filter-flags -O?
	append-flags -O2
	econf --disable-dependency-tracking \
		$(use_enable doc gtk-doc)
}

ml-native_src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS BUG-REPORTING HACKING NEWS README || die "dodoc failed."
}

pkg_postinst() {
	if ! use examples; then
		ewarn "You have disabled examples USE flag. Beware that upstream might"
		ewarn "want the output of some utilities that are only built with"
		ewarn "USE='examples' if you report bugs to them."
	fi
}
