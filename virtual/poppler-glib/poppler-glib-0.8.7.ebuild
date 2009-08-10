# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/poppler-glib/poppler-glib-0.8.7.ebuild,v 1.4 2009/04/10 23:21:23 loki_val Exp $

EAPI=2

DESCRIPTION="Virtual package, includes packages that contain libpoppler-glib.so"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="+cairo lib32"

PROPERTIES="virtual"

RDEPEND="~app-text/poppler-bindings-${PV}[gtk,cairo?,lib32?]"
DEPEND="${RDEPEND}"
