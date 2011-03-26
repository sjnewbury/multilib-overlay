# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/talloc/talloc-2.0.5.ebuild,v 1.5 2011/03/16 14:50:33 ssuominen Exp $

EAPI=3
PYTHON_DEPEND="python? 2:2.6"
inherit waf-utils python multilib-native

DESCRIPTION="Samba talloc library"
HOMEPAGE="http://talloc.samba.org/"
SRC_URI="http://samba.org/ftp/${PN}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="compat python"

RDEPEND="!!<sys-libs/talloc-2.0.5"
DEPEND="dev-libs/libxslt[lib32?]
	|| ( dev-lang/python:2.7[lib32?] dev-lang/python:2.6[lib32?] )"

WAF_BINARY="${S}/buildtools/bin/waf"

multilib-native_pkg_setup_internal() {
	# Make sure the build system will use the right python
	python_set_active_version 2
	python_pkg_setup
}

multilib-native_src_configure_internal() {
	local extra_opts=""

	use compat && extra_opts+=" --enable-talloc-compat1"
	use python || extra_opts+=" --disable-python"
	waf-utils_src_configure \
		${extra_opts}
}
