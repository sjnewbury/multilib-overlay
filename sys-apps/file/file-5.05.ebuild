# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/file/file-5.05.ebuild,v 1.2 2011/01/18 21:36:39 arfrever Exp $

EAPI="2"

PYTHON_DEPEND="python? *"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="*-jython"

inherit eutils distutils libtool flag-o-matic multilib-native

DESCRIPTION="identify a file's format by scanning binary data for patterns"
HOMEPAGE="ftp://ftp.astron.com/pub/file/"
SRC_URI="ftp://ftp.astron.com/pub/file/${P}.tar.gz
	ftp://ftp.gw.com/mirrors/pub/unix/file/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="python"

PYTHON_MODNAME="magic.py"

multilib-native_src_unpack_internal() {
	unpack ${P}.tar.gz
}	

multilib-native_src_prepare_internal() {
	elibtoolize
	epunt_cxx

	# dont let python README kill main README #60043
	mv python/README{,.python}
}

multilib-native_src_configure_internal() {
	# file uses things like strndup() and wcwidth()
	append-flags -D_GNU_SOURCE

	econf || die
}

multilib-native_src_compile_internal() {
	emake || die

	use python && cd python && distutils_src_compile
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog MAINT README

	use python && cd python && distutils_src_install
}

multilib-native_pkg_postinst_internal() {
	use python && distutils_pkg_postinst
}

multilib-native_pkg_postrm_internal() {
	use python && distutils_pkg_postrm
}
