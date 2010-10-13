# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/libsmbios/libsmbios-2.2.26.ebuild,v 1.1 2010/09/28 15:33:23 polynomial-c Exp $

EAPI=2
PYTHON_DEPEND="python? *:2.4"

inherit python flag-o-matic autotools multilib-native

DESCRIPTION="Provide access to (SM)BIOS information"
HOMEPAGE="http://linux.dell.com/libsmbios/main/index.html"
SRC_URI="http://linux.dell.com/libsmbios/download/libsmbios/${P}/${P}.tar.bz2"

LICENSE="GPL-2 OSL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="doc graphviz nls python test"

RDEPEND="dev-libs/libxml2[lib32?]
	sys-libs/zlib[lib32?]
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9.0[lib32?]
	doc? ( app-doc/doxygen )
	graphviz? ( media-gfx/graphviz[lib32?] )
	nls? ( sys-devel/gettext[lib32?] )
	test? ( >=dev-util/cppunit-1.9.6[lib32?] )"

multilib-native_src_prepare_internal() {
	rm pkg/py-compile
	ln -s "$(type -P true)" pkg/py-compile || die
	eautoreconf
}

multilib-native_src_configure_internal() {
	#Remove -O3 for bug #290097
	replace-flags -O3 -O2
	econf \
		$(use_enable doc doxygen) \
		$(use_enable graphviz) \
		$(use_enable nls) \
		$(use_enable python) || die
}

multilib-native_src_install_internal() {
	emake install DESTDIR="${D}" || die "emake install failed"

	rm -rf "${D}etc/yum"
	rm -rf "${D}usr/lib/yum-plugins"
	if ! use python ; then
		rmdir "${D}libsmbios_c" "${D}usr/share/smbios-utils"
		rm -rf "${D}etc"
	fi

	insinto /usr/include/
	doins -r src/include/smbios/

	dodoc AUTHORS ChangeLog NEWS README TODO
}

multilib-native_pkg_postinst_internal() {
	use python && python_mod_optimize /usr/share/smbios-utils
}

multilib-native_pkg_postrm_internal() {
	use python && python_mod_cleanup /usr/share/smbios-utils
}
