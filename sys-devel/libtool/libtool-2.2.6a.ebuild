# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-2.2.6a.ebuild,v 1.3 2008/11/28 22:41:19 ulm Exp $

LIBTOOLIZE="true" #225559
inherit eutils autotools multilib-xlibs

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="vanilla"

RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10.1"
DEPEND="${RDEPEND}
	app-arch/lzma-utils
	sys-apps/help2man"

S=${WORKDIR}/${P%a}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}/${P}-gnuinfo.patch #249168

	if ! use vanilla ; then
		epunt_cxx
		cd libltdl/m4
		epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
		cd ..
		eautoreconf
		cd ..
		eautoreconf
	fi
}

multilib-xlibs_src_install_internal() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	local x
	for x in libtool libtoolize ; do
		help2man ${x} > ${x}.1
		doman ${x}.1 || die
	done

	for x in $(find "${D}" -name config.guess -o -name config.sub) ; do
		rm -f "${x}" ; ln -sf /usr/share/gnuconfig/${x##*/} "${x}"
	done
}
