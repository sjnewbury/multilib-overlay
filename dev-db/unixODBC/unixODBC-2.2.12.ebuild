# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/unixODBC/unixODBC-2.2.12.ebuild,v 1.15 2008/06/15 17:33:57 hoffie Exp $

EAPI="1"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
PATCH_VERSION="2.2.12-r0"
PATCH_P="${PN}-${PATCH_VERSION}-patches"

inherit eutils multilib autotools gnuconfig libtool multilib-native

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

DESCRIPTION="ODBC Interface for Linux."
HOMEPAGE="http://www.unixodbc.org/"
SRC_URI="http://www.unixodbc.org/${P}.tar.gz
		mirror://gentoo/${PATCH_P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
IUSE="qt3 gnome"

RDEPEND=">=sys-libs/readline-4.1[$(get_ml_usedeps)?]
		>=sys-libs/ncurses-5.2[$(get_ml_usedeps)?]
		qt3? ( =x11-libs/qt-3*[$(get_ml_usedeps)?] )
		gnome? ( gnome-base/libgnomeui[$(get_ml_usedeps)?] )
		sys-devel/libtool"
DEPEND="${RDEPEND}
	gnome? ( dev-util/cvs )" # see Bug 173256

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${WORKDIR}"/${PATCH_P}/*
	epatch \
		"${FILESDIR}/350-${P}-gODBCConfig-as-needed.patch" \
		"${FILESDIR}/360-${P}-libltdlfixes.patch"

	# Remove bundled libltdl copy
	rm -rf libltdl

	eautoreconf

	if use gnome ; then
		cd gODBCConfig
		touch ChangeLog
		autopoint -f || die "autopoint -f failed"
		eautoreconf --install
	fi
}

ml-native_src_compile() {
	local myconf

	if use qt3 && ! use mips ; then
		myconf="--enable-gui=yes --x-libraries=/usr/$(get_libdir)"
	else
		myconf="--enable-gui=no"
	fi

	econf --host=${CHOST} \
		--prefix=/usr \
		--sysconfdir=/etc/${PN} \
		--libdir=/usr/$(get_libdir) \
		--enable-static \
		--enable-fdb \
		--enable-ltdllib \
		${myconf} || die "econf failed"

	emake -j1 || die "emake failed"

	if use gnome; then
		# Symlink for configure
		ln -s "${S}"/odbcinst/.libs ./lib
		# Symlink for libtool
		ln -s "${S}"/odbcinst/.libs ./lib/.libs

		cd gODBCConfig
		econf --host=${CHOST} \
			--with-odbc="${S}" \
			--enable-static \
			--prefix=/usr \
			--sysconfdir=/etc/${PN} || die "econf gODBCConfig failed"
		ln -s ../depcomp .
		ln -s ../libtool .

		emake || die "emake gODBCConfig failed"

		cd ..
	fi
}

ml-native_src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	if use gnome;
	then
		cd gODBCConfig
		emake DESTDIR="${D}" install || die "emake gODBCConfig install failed"
		cd ..
	fi

	dodoc AUTHORS ChangeLog NEWS README*
	find doc/ -name "Makefile*" -exec rm '{}' \;
	dohtml doc/*
	prepalldocs
}
