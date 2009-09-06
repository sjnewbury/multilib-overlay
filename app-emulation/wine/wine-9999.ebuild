# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/wine/wine-9999.ebuild,v 1.41 2009/08/27 11:41:32 vapier Exp $

EAPI="2"

inherit multilib

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://source.winehq.org/git/wine.git"
	inherit git
	SRC_URI=""
	KEYWORDS=""
else
	MY_P="${PN}-${PV/_/-}"
	SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"
	KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
	S=${WORKDIR}/${MY_P}
fi

GV="0.9.1"
DESCRIPTION="free implementation of Windows(tm) on Unix"
HOMEPAGE="http://www.winehq.org/"
SRC_URI="${SRC_URI}
	gecko? ( mirror://sourceforge/wine/wine_gecko-${GV}.cab )"

LICENSE="LGPL-2.1"
SLOT="0"
# Don't add lib32 to IUSE -- otherwise it can be turned off!
IUSE="alsa cups dbus esd +gecko gnutls hal jack jpeg lcms ldap nas ncurses +opengl oss png samba scanner ssl test win64 +X xcomposite xinerama xml"
RESTRICT="test" #72375

WINE_IS_LIB32=
use amd64 && ! use win64 && WINE_IS_LIB32="[lib32]"

RDEPEND=">=media-libs/freetype-2.0.0${WINE_IS_LIB32}
	media-fonts/corefonts
	dev-lang/perl${WINE_IS_LIB32}
	dev-perl/XML-Simple
	ncurses? ( >=sys-libs/ncurses-5.2${WINE_IS_LIB32} )
	jack? ( media-sound/jack-audio-connection-kit${WINE_IS_LIB32} )
	dbus? ( sys-apps/dbus${WINE_IS_LIB32} )
	gnutls? ( net-libs/gnutls${WINE_IS_LIB32} )
	hal? ( sys-apps/hal${WINE_IS_LIB32} )
	X? (
		x11-libs/libXcursor${WINE_IS_LIB32}
		x11-libs/libXrandr${WINE_IS_LIB32}
		x11-libs/libXi${WINE_IS_LIB32}
		x11-libs/libXmu${WINE_IS_LIB32}
		x11-libs/libXxf86vm${WINE_IS_LIB32}
		x11-apps/xmessage
	)
	alsa? ( media-libs/alsa-lib${WINE_IS_LIB32} )
	esd? ( media-sound/esound${WINE_IS_LIB32} )
	nas? ( media-libs/nas${WINE_IS_LIB32} )
	cups? ( net-print/cups${WINE_IS_LIB32} )
	opengl? ( virtual/opengl${WINE_IS_LIB32} )
	jpeg? ( media-libs/jpeg${WINE_IS_LIB32} )
	ldap? ( net-nds/openldap${WINE_IS_LIB32} )
	lcms? ( media-libs/lcms${WINE_IS_LIB32} )
	samba? ( >=net-fs/samba-3.0.25${WINE_IS_LIB32} )
	xml? ( dev-libs/libxml2${WINE_IS_LIB32} dev-libs/libxslt${WINE_IS_LIB32} )
	scanner? ( media-gfx/sane-backends )
	ssl? ( dev-libs/openssl${WINE_IS_LIB32} )
	png? ( media-libs/libpng${WINE_IS_LIB32} )
	win64? ( >=sys-devel/gcc-4.4.0 )"
DEPEND="${RDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
	)
	sys-devel/bison
	sys-devel/flex"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
	else
		unpack ${MY_P}.tar.bz2
	fi
}

src_prepare() {
	epatch_user #282735
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785
}

src_configure() {
	export LDCONFIG=/bin/true

	use amd64 && ! use win64 && multilib_toolchain_setup x86

	# XXX: should check out these flags too:
	#	audioio capi fontconfig freetype gphoto
	econf \
		--sysconfdir=/etc/wine \
		$(use_with alsa) \
		$(use_with cups) \
		$(use_with esd) \
		$(use_with gnutls) \
		$(! use dbus && echo --without-hal || use_with hal) \
		$(use_with jack) \
		$(use_with jpeg) \
		$(use_with lcms cms) \
		$(use_with ldap) \
		$(use_with nas) \
		$(use_with ncurses curses) \
		$(use_with opengl) \
		$(use_with oss) \
		$(use_with png) \
		$(use_with scanner sane) \
		$(use_with ssl openssl) \
		$(use_enable test tests) \
		$(use_enable win64) \
		$(use_with X x) \
		$(use_with xcomposite) \
		$(use_with xinerama) \
		$(use_with xml) \
		$(use_with xml xslt) \
		|| die "configure failed"

	emake -j1 depend || die "depend"
}

src_compile() {
	emake all || die "all"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS README
	if use gecko ; then
		insinto /usr/share/wine/gecko
		doins "${DISTDIR}"/wine_gecko-${GV}.cab || die
	fi
}
