# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/wine/wine-1.1.12.ebuild,v 1.4 2009/08/26 21:57:56 vapier Exp $

EAPI="1"

inherit eutils flag-o-matic multilib

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://source.winehq.org/git/wine.git"
	inherit git
	SRC_URI=""
else
	MY_P="${PN}-${PV/_/-}"
	SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"
	S=${WORKDIR}/${MY_P}
fi

GV="0.9.0"
DESCRIPTION="free implementation of Windows(tm) on Unix"
HOMEPAGE="http://www.winehq.org/"
SRC_URI="${SRC_URI}
	gecko? ( mirror://sourceforge/wine/wine_gecko-${GV}.cab )"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="-* amd64 x86 ~x86-fbsd"
# Don't add lib32 to IUSE -- otherwise it can be turned off, which would make no
# sense!  package.use.force doesn't work in overlay profiles...
IUSE="alsa cups dbus esd +gecko gnutls hal jack jpeg lcms ldap nas ncurses +opengl oss samba scanner xml +X"
RESTRICT="test" #72375

# There isn't really a better way of doing these dependencies without messing up
# the metadata cache :(
RDEPEND="amd64? (
		>=media-libs/freetype-2.0.0[lib32]
		dev-lang/perl[lib32]
		alsa? ( media-libs/alsa-lib[lib32] )
		cups? ( net-print/cups[lib32] )
		dbus? ( sys-apps/dbus[lib32] )
		esd? ( media-sound/esound[lib32] )
		gnutls? ( net-libs/gnutls[lib32] )
		hal? ( sys-apps/hal[lib32] )
		jack? ( media-sound/jack-audio-connection-kit[lib32] )
		jpeg? ( media-libs/jpeg[lib32] )
		ldap? ( net-nds/openldap[lib32] )
		lcms? ( media-libs/lcms[lib32] )
		nas? ( media-libs/nas[lib32] )
		ncurses? ( >=sys-libs/ncurses-5.2[lib32] )
		opengl? ( virtual/opengl[lib32] )
		samba? ( >=net-fs/samba-3.0.25[lib32] )
		scanner? ( media-gfx/sane-backends[lib32] )
		X? (
			x11-libs/libXcursor[lib32]
			x11-libs/libXrandr[lib32]
			x11-libs/libXi[lib32]
			x11-libs/libXmu[lib32]
			x11-libs/libXxf86vm[lib32]
		)
		xml? ( dev-libs/libxml2[lib32] dev-libs/libxslt[lib32] )
	)
	>=media-libs/freetype-2.0.0
	dev-lang/perl
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	dbus? ( sys-apps/dbus )
	esd? ( media-sound/esound )
	gnutls? ( net-libs/gnutls )
	hal? ( sys-apps/hal )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg? ( media-libs/jpeg )
	ldap? ( net-nds/openldap )
	lcms? ( media-libs/lcms )
	nas? ( media-libs/nas )
	ncurses? ( >=sys-libs/ncurses-5.2 )
	opengl? ( virtual/opengl )
	samba? ( >=net-fs/samba-3.0.25 )
	scanner? ( media-gfx/sane-backends )
	X? (
		x11-libs/libXcursor
		x11-libs/libXrandr
		x11-libs/libXi
		x11-libs/libXmu
		x11-libs/libXxf86vm
	)
	xml? ( dev-libs/libxml2 dev-libs/libxslt )
	media-fonts/corefonts
	dev-perl/XML-Simple
	X? ( x11-apps/xmessage )"
DEPEND="${RDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
	)
	sys-devel/bison
	sys-devel/flex"

pkg_setup() {
	use alsa || return 0
	if ! built_with_use --missing true media-libs/alsa-lib midi ; then
		eerror "You must build media-libs/alsa-lib with USE=midi"
		die "please re-emerge media-libs/alsa-lib with USE=midi"
	fi
}

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
	else
		unpack ${MY_P}.tar.bz2
	fi
	cd "${S}"

	epatch "${FILESDIR}"/wine-gentoo-no-ssp.patch #66002
	epatch_user #282735
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785
}

config_cache() {
	local h ans="no"
	use $1 && ans="yes"
	shift
	for h in "$@" ; do
		[[ ${h} == *.h ]] \
			&& h=header_${h} \
			|| h=lib_${h}
		export ac_cv_${h//[:\/.]/_}=${ans}
	done
}

src_compile() {
	export LDCONFIG=/bin/true
	use esd     || export ac_cv_path_ESDCONFIG=""
	use scanner || export ac_cv_path_sane_devel="no"
	config_cache jack jack/jack.h
	config_cache cups cups/cups.h
	config_cache alsa alsa/asoundlib.h sys/asoundlib.h asound:snd_pcm_open
	config_cache nas audio/audiolib.h audio/soundlib.h
	config_cache xml libxml/parser.h libxslt/pattern.h libxslt/transform.h
	config_cache ldap ldap.h lber.h
	config_cache dbus dbus/dbus.h
	config_cache hal hal/libhal.h
	config_cache jpeg jpeglib.h
	config_cache oss sys/soundcard.h machine/soundcard.h soundcard.h
	config_cache lcms lcms.h

	strip-flags

	use amd64 && multilib_toolchain_setup x86

	#	$(use_enable amd64 win64)
	econf \
		--sysconfdir=/etc/wine \
		$(use_with gnutls) \
		$(use_with ncurses curses) \
		$(use_with opengl) \
		$(use_with X x) \
		|| die "configure failed"

	emake -j1 depend || die "depend"
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

pkg_postinst() {
	elog "~/.wine/config is now deprecated.  For configuration either use"
	elog "winecfg or regedit HKCU\\Software\\Wine"
}
