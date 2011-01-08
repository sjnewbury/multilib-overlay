# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/mysql/mysql-5.1.ebuild,v 1.22 2011/01/07 23:57:45 robbat2 Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Virtual for MySQL client or database"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd ~x64-macos ~x86-macos ~x86-solaris"
IUSE="embedded static"

DEPEND=""
# TODO: add mysql-cluster here
RDEPEND="|| (
	=dev-db/mysql-${PV}*[embedded=,static=,lib32?]
	=dev-db/mariadb-${PV}*[embedded=,static=]
)"
