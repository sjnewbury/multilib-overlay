# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboil/liboil-0.3.15.ebuild,v 1.10 2009/03/08 07:39:21 kumba Exp $

EAPI="2"

inherit flag-o-matic multilib-native

DESCRIPTION="library of simple functions that are optimized for various CPUs"
HOMEPAGE="http://liboil.freedesktop.org/"
SRC_URI="http://liboil.freedesktop.org/download/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0.3"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND="=dev-libs/glib-2*[lib32?]"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )"

multilib-native_src_configure_internal() {
	strip-flags
	filter-flags -O?
	append-flags -O2
	econf --disable-dependency-tracking \
		$(use_enable doc gtk-doc) || die "econf failed."
}

multilib-native_src_compile_internal() {
	emake -j1 || die "emake failed."
}

multilib-native_src_install_internal() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS BUG-REPORTING HACKING NEWS README
}
