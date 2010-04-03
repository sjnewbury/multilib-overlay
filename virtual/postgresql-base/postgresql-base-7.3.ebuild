# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/postgresql-base/postgresql-base-7.3.ebuild,v 1.3 2010/01/11 11:16:48 ulm Exp $

EAPI="2"

inherit multilib-native

DESCRIPTION="Virtual for PostgreSQL base (clients + libraries)"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="${PV}"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86"
IUSE=""

RDEPEND="|| ( =dev-db/libpq-${PV}* dev-db/postgresql-base:${SLOT}[lib32?] )"
