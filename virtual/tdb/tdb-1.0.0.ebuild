# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/tdb/tdb-1.0.0.ebuild,v 1.1 2009/10/09 17:19:47 patrick Exp $

EAPI="2"

DESCRIPTION="Virtual for tdb"
HOMEPAGE="http://tdb.samba.org/"
SRC_URI=""
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc64 ~x86"
IUSE="lib32"
RDEPEND="|| ( net-fs/samba-libs[tdb,lib32?] sys-libs/tdb[lib32?] )"
DEPEND=""
