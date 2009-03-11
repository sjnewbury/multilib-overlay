# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/fribidi/fribidi-0.10.9.ebuild,v 1.1 2007/12/11 22:48:06 matsuu Exp $

inherit multilib-xlibs

DESCRIPTION="A free implementation of the unicode bidirectional algorithm"
HOMEPAGE="http://fribidi.org/"
SRC_URI="http://fribidi.org/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE=""

multilib-xlibs_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc ${S}/AUTHORS ${S}/NEWS ${S}/README ${S}/ChangeLog ${S}/THANKS ${S}/TODO
}
