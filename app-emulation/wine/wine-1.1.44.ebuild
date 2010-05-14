# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/wine/wine-1.1.44.ebuild,v 1.1 2010/05/12 03:32:52 vapier Exp $

EAPI="2"

AUTOTOOLS_AUTO_DEPEND="no"
inherit eutils flag-o-matic multilib autotools

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

pulse_patches() { echo "$1"/winepulse-{0.36,0.35-configure.ac,0.34-winecfg}.patch ; }
GV="1.0.0-x86"
DESCRIPTION="free implementation of Windows(tm) on Unix"
HOMEPAGE="http://www.winehq.org/"
SRC_URI="${SRC_URI}
	gecko? ( mirror://sourceforge/wine/wine_gecko-${GV}.cab )
	pulseaudio? ( `pulse_patches http://art.ified.ca/downloads/winepulse` )"

LICENSE="LGPL-2.1"
SLOT="0"
# Don't add lib32 to IUSE -- otherwise it can be turned off, which would make no
# sense!  package.use.force doesn't work in overlay profiles...
IUSE="alsa capi cups custom-cflags dbus esd fontconfig +gecko gnutls gphoto2 gsm hal jack jpeg lcms ldap mp3 nas ncurses openal +opengl oss +perl png pulseaudio samba scanner ssl test +threads +truetype win64 +X xcomposite xinerama xml"
RESTRICT="test" #72375

# There isn't really a better way of doing these dependencies without messing up
# the metadata cache :(
RDEPEND="amd64? ( !win64? (
		truetype? ( >=media-libs/freetype-2.0.0[lib32] media-fonts/corefonts )
		perl? ( dev-lang/perl[lib32] dev-perl/XML-Simple )
		alsa? ( media-libs/alsa-lib[lib32] )
		capi? ( net-dialup/capi4k-utils )
		cups? ( net-print/cups[lib32] )
		dbus? ( sys-apps/dbus[lib32] )
		esd? ( media-sound/esound[lib32] )
		fontconfig? ( media-libs/fontconfig[lib32?] )
		gphoto2? ( media-libs/libgphoto2[lib32?] )
		gnutls? ( net-libs/gnutls[lib32] )
		gsm? ( media-sound/gsm[lib32] )
		hal? ( sys-apps/hal[lib32] )
		jack? ( media-sound/jack-audio-connection-kit[lib32] )
		jpeg? ( media-libs/jpeg[lib32] )
		ldap? ( net-nds/openldap[lib32] )
		lcms? ( media-libs/lcms[lib32] )
		mp3? ( media-sound/mpg123[lib32] )
		nas? ( media-libs/nas[lib32] )
		ncurses? ( >=sys-libs/ncurses-5.2[lib32] )
		openal? ( media-libs/openal[lib32?] )
		opengl? ( virtual/opengl[lib32] )
		png? ( media-libs/libpng[lib32] )
		pulseaudio? ( media-sound/pulseaudio ${AUTOTOOLS_DEPEND} )
		samba? ( >=net-fs/samba-3.0.25[lib32] )
		scanner? ( media-gfx/sane-backends[lib32] )
		ssl? ( dev-libs/openssl[lib32] )
		X? (
			x11-libs/libXcursor[lib32]
			x11-libs/libXrandr[lib32]
			x11-libs/libXi[lib32]
			x11-libs/libXmu[lib32]
			x11-libs/libXxf86vm[lib32]
		)
		xcomposite? ( x11-libs/libXcomposite[lib32] )
		xinerama? ( x11-libs/libXinerama[lib32] )
		xml? ( dev-libs/libxml2[lib32] dev-libs/libxslt[lib32] )
	) )
	truetype? ( >=media-libs/freetype-2.0.0 media-fonts/corefonts )
	perl? ( dev-lang/perl dev-perl/XML-Simple )
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	dbus? ( sys-apps/dbus )
	esd? ( media-sound/esound )
	gnutls? ( net-libs/gnutls )
	gsm? ( media-sound/gsm )
	hal? ( sys-apps/hal )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg? ( media-libs/jpeg )
	ldap? ( net-nds/openldap )
	lcms? ( media-libs/lcms )
	mp3? ( media-sound/mpg123 )
	nas? ( media-libs/nas )
	ncurses? ( >=sys-libs/ncurses-5.2 )
	opengl? ( virtual/opengl )
	png? ( media-libs/libpng )
	samba? ( >=net-fs/samba-3.0.25 )
	scanner? ( media-gfx/sane-backends )
	ssl? ( dev-libs/openssl )
	X? (
		x11-libs/libXcursor
		x11-libs/libXrandr
		x11-libs/libXi
		x11-libs/libXmu
		x11-libs/libXxf86vm
	)
	xcomposite? ( x11-libs/libXcomposite )
	xinerama? ( x11-libs/libXinerama )
	xml? ( dev-libs/libxml2 dev-libs/libxslt )
	dev-perl/XML-Simple
	X? ( x11-apps/xmessage )
	win64? ( >=sys-devel/gcc-4.4.0 )"
DEPEND="${RDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
	)
	xinerama? ( x11-proto/xineramaproto )
	sys-devel/bison
	sys-devel/flex"

src_unpack() {
	if [[ $(( $(gcc-major-version) * 100 + $(gcc-minor-version) )) -lt 404 ]] ; then
		use win64 && die "you need gcc-4.4+ to build 64bit wine"
	fi

	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
	else
		unpack ${MY_P}.tar.bz2
	fi
}

src_prepare() {
	if use pulseaudio ; then
		EPATCH_OPTS=-p1 epatch `pulse_patches "${DISTDIR}"`
		eautoreconf
	fi
	epatch "${FILESDIR}"/${PN}-1.1.15-winegcc.patch #260726
	epatch_user #282735
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785
}

src_configure() {
	export LDCONFIG=/bin/true

	use custom-cflags || strip-flags
	use amd64 && ! use win64 && multilib_toolchain_setup x86

	econf \
		--sysconfdir=/etc/wine \
		$(use_with alsa) \
		$(use_with capi) \
		$(use_with lcms cms) \
		$(use_with cups) \
		$(use_with ncurses curses) \
		$(use_with esd) \
		$(use_with fontconfig) \
		$(use_with gnutls) \
		$(use_with gphoto2 gphoto) \
		$(use_with gsm) \
		$(! use dbus && echo --without-hal || use_with hal) \
		$(use_with jack) \
		$(use_with jpeg) \
		$(use_with ldap) \
		$(use_with mp3 mpg123) \
		$(use_with nas) \
		$(use_with openal) \
		$(use_with opengl) \
		$(use_with ssl openssl) \
		$(use_with oss) \
		$(use_with png) \
		$(use_with threads pthread) \
		$(use_with pulseaudio pulse) \
		$(use_with scanner sane) \
		$(use_enable test tests) \
		$(use_with truetype freetype) \
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
	if ! use perl ; then
		rm "${D}"/usr/bin/{wine{dump,maker},function_grep.pl} "${D}"/usr/share/man/man1/wine{dump,maker}.1 || die
	fi
}

pkg_postinst() {
	paxctl -psmr "${ROOT}"/usr/bin/wine{,-preloader} 2>/dev/null #255055
}
