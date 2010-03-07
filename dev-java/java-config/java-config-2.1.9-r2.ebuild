# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-config/java-config-2.1.9-r2.ebuild,v 1.4 2010/02/26 19:26:02 arfrever Exp $

inherit fdo-mime gnome2-utils distutils eutils multilib-native

DESCRIPTION="Java environment configuration tool"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm ~ia64 ~ppc ~ppc64 x86 ~x86-fbsd"
IUSE=""

DEPEND="dev-lang/python"
RDEPEND="${DEPEND}
	>=dev-java/java-config-wrapper-0.15"

PYTHON_MODNAME="java_config_2"

multilib-native_src_unpack_internal() {
	distutils_src_unpack

	cd "${S}"
	epatch "${FILESDIR}/${P}.patch"
	epatch "${FILESDIR}/${PF}.patch"
}

multilib-native_src_install_internal() {
	distutils_src_install

	insinto /usr/share/java-config-2/config/
	newins config/jdk-defaults-${ARCH}.conf jdk-defaults.conf || die "arch config not found"
}

pkg_postrm() {
	distutils_pkg_postrm
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
