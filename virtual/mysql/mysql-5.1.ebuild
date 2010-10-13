# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-5.1.ebuild,v 1.16 2010/09/28 18:48:17 grobian Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ~ia64 ppc ~ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd ~x64-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
# TODO: add mysql-cluster here
RDEPEND="|| (
	=dev-db/mysql-${PV}*[lib32?]
	=dev-db/mysql-community-${PV}*
	=dev-db/mariadb-${PV}*
)"
