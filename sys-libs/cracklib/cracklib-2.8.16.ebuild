# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/cracklib/cracklib-2.8.16.ebuild,v 1.12 2010/08/02 03:11:33 jer Exp $

EAPI="3"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils distutils libtool toolchain-funcs multilib-native

MY_P=${P/_}
DESCRIPTION="Password Checking Library"
HOMEPAGE="http://sourceforge.net/projects/cracklib"
SRC_URI="mirror://sourceforge/cracklib/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="nls python"

RDEPEND="sys-libs/zlib[lib32?]"
DEPEND="${RDEPEND}
	python? ( dev-python/setuptools[lib32?] )"

S=${WORKDIR}/${MY_P}

PYTHON_MODNAME="cracklib.py"
do_python() {
	pushd python > /dev/null || die
	distutils_src_${EBUILD_PHASE}
	popd > /dev/null
}

multilib-native_pkg_setup_internal() {
	# workaround #195017
	if has unmerge-orphans ${FEATURES} && has_version "<${CATEGORY}/${PN}-2.8.10" ; then
		eerror "Upgrade path is broken with FEATURES=unmerge-orphans"
		eerror "Please run: FEATURES=-unmerge-orphans emerge cracklib"
		die "Please run: FEATURES=-unmerge-orphans emerge cracklib"
	fi

	use python && python_pkg_setup
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${PN}-2.8.15-no-nls.patch
	epatch "${FILESDIR}"/${P}-python.patch
	elibtoolize #269003
	use python && do_python
}

multilib-native_src_configure_internal() {
	econf \
		--with-default-dict='$(libdir)/cracklib_dict' \
		--without-python \
		$(use_enable nls)
}

multilib-native_src_compile_internal() {
	default
	use python && do_python
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"
	rm -r "${ED}"/usr/share/cracklib

	use python && do_python

	# move shared libs to /
	gen_usr_ldscript -a crack

	insinto /usr/share/dict
	doins dicts/cracklib-small || die "word dict"

	dodoc AUTHORS ChangeLog NEWS README*
}

multilib-native_pkg_postinst_internal() {
	if [[ ${ROOT} == "/" ]] ; then
		ebegin "Regenerating cracklib dictionary"
		create-cracklib-dict /usr/share/dict/* > /dev/null
		eend $?
	fi

	use python && distutils_pkg_postinst
}

multilib-native_pkg_postrm_internal() {
	use python && distutils_pkg_postrm
}
