# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-3.4.5.ebuild,v 1.1 2010/01/19 18:59:45 patrick Exp $

EAPI="2"

DESCRIPTION="Meta package for samba-{libs,client,server}"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="+client +server lib32"

DEPEND=""
RDEPEND="~net-fs/samba-libs-${PV}[lib32?]
	client? ( ~net-fs/samba-client-${PV} )
	server? ( ~net-fs/samba-server-${PV} )"
