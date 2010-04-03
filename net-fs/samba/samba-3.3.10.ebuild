# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-fs/samba/samba-3.3.10.ebuild,v 1.1 2010/01/14 12:52:05 patrick Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Meta package for samba-{libs,client,server}"
HOMEPAGE="http://www.samba.org/"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc ~ppc64 ~x86"
IUSE="+client +server"

DEPEND=""
RDEPEND="~net-fs/samba-libs-${PV}[lib32?]
	client? ( ~net-fs/samba-client-${PV} )
	server? ( ~net-fs/samba-server-${PV} )"
