# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libical/libical-0.27-r1.ebuild,v 1.1 2008/10/03 09:07:01 s4t4n Exp $

inherit multilib-native

DESCRIPTION="a implementation of basic iCAL protocols from citadel, previously known as aurore."
HOMEPAGE="http://www.citadel.org"
SRC_URI="http://easyinstall.citadel.org/${P}.tar.gz"

LICENSE="|| ( MPL-1.1 LGPL-2 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE=""

multilib-native_src_compile_internal() {
	# Fix 66377
	LDFLAGS="${LDFLAGS} -lpthread" econf || die "Configuration failed"
	emake || die "Compilation failed"
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TEST THANKS TODO doc/*.txt
}
