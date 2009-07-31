# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-4.1.ebuild,v 1.5 2008/12/14 20:15:11 klausman Exp $

inherit multilib

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE="http://dev.mysql.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm hppa ia64 mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="$(get_ml_useflags)"

DEPEND=""
RDEPEND="=dev-db/mysql-${PV}*[$(get_ml_usedeps)]"
