# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/postgresql-base/postgresql-base-7.3.ebuild,v 1.2 2008/05/19 07:15:47 dev-zero Exp $

EAPI="2"

DESCRIPTION="Virtual for PostgreSQL base (clients + libraries)"
HOMEPAGE="http://www.postgresql.org/"
SRC_URI=""

LICENSE="as-is"
SLOT="${PV}"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86"
IUSE="lib32"

RDEPEND="|| ( =dev-db/libpq-${PV}*[lib32?] dev-db/postgresql-base:${SLOT}[lib32?] )"
