# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/orbit/orbit-2.14.16.ebuild,v 1.8 2009/03/05 22:31:19 ranger Exp $

EAPI="2"

inherit gnome2 eutils multilib-native

MY_P="ORBit2-${PV}"
PVP=(${PV//[-\._]/ })
S=${WORKDIR}/${MY_P}

DESCRIPTION="ORBit2 is a high-performance CORBA ORB"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/ORBit2/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.8[$(get_ml_usedeps)?]
	>=dev-libs/libIDL-0.8.2[$(get_ml_usedeps)?]"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.18[$(get_ml_usedeps)?]
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README* TODO"

src_unpack() {
	gnome2_src_unpack

	# Filter out G_DISABLE_DEPRECATED to be future-proof, related to bug 213434
	sed -i -e '/DISABLE_DEPRECATED/d' \
		"${S}/linc2/src/Makefile.am" "${S}/linc2/src/Makefile.in"

	sed -i -e 's:-DG_DISABLE_DEPRECATED::g' \
		"${S}/configure.in" "${S}/configure"
}

ml-native_src_compile() {
	# We need to unset IDL_DIR, which is set by RSI's IDL.  This causes certain
	# files to be not found by autotools when compiling ORBit.  See bug #58540
	# for more information.  Please don't remove -- 8/18/06
	unset IDL_DIR

	gnome2_src_compile
}

src_test() {
	# can fail in parallel, see bug #235994
	emake -j1 check || die "tests failed"
}

ml-native_src_install() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/orbit2-config 
}
