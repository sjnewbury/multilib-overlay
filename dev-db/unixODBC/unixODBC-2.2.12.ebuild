# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/unixODBC/unixODBC-2.2.12.ebuild,v 1.16 2010/03/22 08:35:49 ssuominen Exp $

EAPI="2"

PATCH_VERSION="2.2.12-r0"
PATCH_P="${PN}-${PATCH_VERSION}-patches"

inherit eutils multilib autotools gnuconfig libtool multilib-native

DESCRIPTION="ODBC Interface for Linux."
HOMEPAGE="http://www.unixodbc.org/"
SRC_URI="http://www.unixodbc.org/${P}.tar.gz
		mirror://gentoo/${PATCH_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
IUSE="gnome"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"

RDEPEND=">=sys-libs/readline-4.1[lib32?]
	>=sys-libs/ncurses-5.2[lib32?]
	gnome? ( gnome-base/libgnomeui[lib32?] )
	sys-devel/libtool[lib32?]"
DEPEND="${RDEPEND}
	gnome? ( dev-util/cvs )" # see Bug 173256

multilib-native_src_prepare_internal() {
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

multilib-native_src_configure_internal() {
	local myconf="--enable-gui=no"

	econf --host=${CHOST} \
		--prefix=/usr \
		--sysconfdir=/etc/${PN} \
		--libdir=/usr/$(get_libdir) \
		--enable-static \
		--enable-fdb \
		--enable-ltdllib \
		${myconf} || die "econf failed"

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
		cd ..
	fi
}

multilib-native_src_compile_internal() {
	emake -j1 || die "emake failed"

	if use gnome; then
		cd gODBCConfig
		emake || die "emake gODBCConfig failed"
		cd ..
	fi
}

multilib-native_src_install_internal() {
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
