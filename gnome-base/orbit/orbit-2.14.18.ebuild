# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/orbit/orbit-2.14.18.ebuild,v 1.8 2010/09/11 18:41:14 josejx Exp $

EAPI="2"
GCONF_DEBUG="no"

inherit gnome2 toolchain-funcs multilib-native

MY_P="ORBit2-${PV}"
PVP=(${PV//[-\._]/ })
S=${WORKDIR}/${MY_P}

DESCRIPTION="ORBit2 is a high-performance CORBA ORB"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/ORBit2/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="alpha amd64 arm ia64 ~mips ppc ~ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.8[lib32?]
	>=dev-libs/libIDL-0.8.2[lib32?]"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.18[lib32?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README* TODO"

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	# Fix wrong process kill, bug #268142
	sed "s:killall lt-timeout-server:killall timeout-server:" \
		-i test/timeout.sh || die "sed failed"
}

multilib-native_src_compile_internal() {
	# We need to unset IDL_DIR, which is set by RSI's IDL.  This causes certain
	# files to be not found by autotools when compiling ORBit.  See bug #58540
	# for more information.  Please don't remove -- 8/18/06
	unset IDL_DIR

	# We need to use the hosts IDL compiler if cross-compiling, bug #262741
	if tc-is-cross-compiler; then
		# check that host version is present and executable
		[ -x /usr/bin/orbit-idl-2 ] || die "Please emerge ~${CATEGORY}/${P} on the host system first"
		G2CONF="${G2CONF} --with-idl-compiler=/usr/bin/orbit-idl-2"
	fi

	# Parallel build fails from time to time, bug #273031
	MAKEOPTS="${MAKEOPTS} -j1"
	gnome2_src_compile
}

src_test() {
	# can fail in parallel, see bug #235994
	emake -j1 check || die "tests failed"
}

multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/orbit2-config
}
