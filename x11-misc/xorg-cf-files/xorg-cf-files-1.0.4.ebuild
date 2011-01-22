# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xorg-cf-files/xorg-cf-files-1.0.4.ebuild,v 1.1 2011/01/15 18:13:58 scarabeus Exp $

EAPI=3

inherit xorg-2 multilib-native

DESCRIPTION="Old Imake-related build files"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

multilib-native_src_install_internal() {
	xorg-2_src_install
	echo "#define ManDirectoryRoot /usr/share/man" >> ${D}/usr/$(get_libdir)/X11/config/host.def
	sed -i -e "s/LibDirName *lib$/LibDirName $(get_libdir)/" "${D}"/usr/$(get_libdir)/X11/config/Imake.tmpl || die "failed libdir sed"

}
