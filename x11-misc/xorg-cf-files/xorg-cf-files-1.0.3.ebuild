# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xorg-cf-files/xorg-cf-files-1.0.3.ebuild,v 1.1 2009/10/15 12:50:10 scarabeus Exp $

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular multilib-native

DESCRIPTION="Old Imake-related build files"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND=""

multilib-native_src_install_internal() {
	x-modular_src_install
	echo "#define ManDirectoryRoot /usr/share/man" >> ${D}/usr/$(get_libdir)/X11/config/host.def
	sed -i -e "s/LibDirName *lib$/LibDirName $(get_libdir)/" "${D}"/usr/$(get_libdir)/X11/config/Imake.tmpl || die "failed libdir sed"
}
