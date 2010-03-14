# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/tdb/tdb-1.1.5.ebuild,v 1.4 2009/11/04 11:30:39 patrick Exp $

EAPI="2"

inherit confutils eutils multilib-native

DESCRIPTION="Samba tdb"
HOMEPAGE="http://tdb.samba.org/"
SRC_URI="http://samba.org/ftp/tdb/${P}.tar.gz"
LICENSE="GPL-3"
IUSE="python tools tdbtest"
SLOT="0"
KEYWORDS="~amd64 ~hppa ~ppc64 ~x86"

DEPEND="
	!<net-fs/samba-libs-3.4
	"
RDEPEND="${DEPEND}"

BINPROGS="bin/tdbdump bin/tdbtool bin/tdbbackup"

multilib-native_src_prepare_internal() {

	./autogen.sh || die "autogen.sh failed"

	sed -i \
		-e 's|SHLD_FLAGS = @SHLD_FLAGS@|SHLD_FLAGS = @SHLD_FLAGS@ @LDFLAGS@|' \
		-e 's|CC = @CC@|CC = @CC@\
LDFLAGS = @LDFLAGS@|' \
		Makefile.in || die "sed failed"

}

multilib-native_src_configure_internal() {

	econf \
		--sysconfdir=/etc/samba \
		--localstatedir=/var \
		--enable-largefile \
		$(use_enable python) \
	|| die "econf failed"

}

multilib-native_src_compile_internal() {

	emake dirs || die "emake dirs failed"
	emake showflags || die "emake showflags failed"
	emake shared-build || die "emake shared-build failed"
	if use tools ; then emake ${BINPROGS} || die "emake binaries failed"; fi
	if use python ; then emake build-python || die "emake build-python failed"; fi
	if use tdbtest ; then make bin/tdbtest || die "emake tdbtest failed"; fi

}

multilib-native_src_install_internal() {

	dolib.a sharedbuild/lib/libtdb.a
	dolib.so sharedbuild/lib/libtdb.so

	if use python || use tools ; then
		emake install DESTDIR="${D}" || die "emake install failed"
	fi

	if ! use tools ; then
		for prog in ${BINPROGS} ; do
			rm -f "${D}/usr/${prog}"
		done
	fi

	if use tdbtest ; then
		dobin bin/tdbtest
	fi

}
