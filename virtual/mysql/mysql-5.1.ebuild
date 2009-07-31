# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-5.1.ebuild,v 1.3 2006/11/23 15:57:58 chtekk Exp $

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE="http://dev.mysql.com"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="lib32"

DEPEND=""
RDEPEND="|| (
	=dev-db/mysql-${PV}*[$(get_ml_usedeps)?]
	=dev-db/mysql-community-${PV}*[$(get_ml_usedeps)?]
)"
