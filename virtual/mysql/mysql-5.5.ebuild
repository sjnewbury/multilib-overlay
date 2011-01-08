# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-5.5.ebuild,v 1.3 2011/01/07 01:16:05 jmbsvicetto Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86
~sparc-fbsd ~x86-fbsd"
IUSE="embedded static"

DEPEND=""
# TODO: add Drizzle and MariaDB here
RDEPEND="|| (
	=dev-db/mysql-${PV}*[embedded=,static=,lib32?]
)"
