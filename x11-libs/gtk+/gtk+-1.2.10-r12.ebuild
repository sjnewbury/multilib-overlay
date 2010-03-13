# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtk+/gtk+-1.2.10-r12.ebuild,v 1.15 2008/07/31 22:54:34 eva Exp $

EAPI="2"

GNOME_TARBALL_SUFFIX="gz"
inherit gnome.org eutils toolchain-funcs autotools multilib-native

DESCRIPTION="The GIMP Toolkit"
HOMEPAGE="http://www.gtk.org/"
SRC_URI="${SRC_URI} http://www.ibiblio.org/gentoo/distfiles/gtk+-1.2.10-r8-gentoo.diff.bz2"

LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="nls debug"

# Supported languages and translated documentation
# Be sure all languages are prefixed with a single space!
MY_AVAILABLE_LINGUAS=" az ca cs da de el es et eu fi fr ga gl hr hu it ja ko lt nl nn no pl pt_BR pt ro ru sk sl sr sv tr uk vi"
IUSE="${IUSE} ${MY_AVAILABLE_LINGUAS// / linguas_}"

RDEPEND="=dev-libs/glib-1.2*[lib32?]
	x11-libs/libXi[lib32?]
	x11-libs/libXt[lib32?]"
DEPEND="${RDEPEND}
	x11-proto/inputproto
	x11-proto/xextproto
	nls? ( sys-devel/gettext[lib32?] dev-util/intltool )"

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/${P}-m4.patch
	epatch "${FILESDIR}"/${P}-automake.patch
	epatch "${FILESDIR}"/${P}-cleanup.patch
	epatch "${DISTDIR}"/gtk+-1.2.10-r8-gentoo.diff.bz2
	epatch "${FILESDIR}"/${PN}-1.2-locale_fix.patch
	epatch "${FILESDIR}"/${P}-as-needed.patch
	sed -i '/libtool.m4/,/AM_PROG_NM/d' acinclude.m4 #168198
	eautoreconf
}

multilib-native_src_configure_internal() {
	local myconf=
	use nls || myconf="${myconf} --disable-nls"
	strip-linguas ${MY_AVAILABLE_LINGUAS}

	if use debug ; then
		myconf="${myconf} --enable-debug=yes"
	else
		myconf="${myconf} --enable-debug=minimum"
	fi

	econf \
		--sysconfdir=/etc \
		--with-xinput=xfree \
		--with-x \
		${myconf} || die
}

multilib-native_src_compile_internal() {
	emake CC="$(tc-getCC)" || die
}

multilib-native_src_install_internal() {
	make install DESTDIR="${D}" || die

	dodoc AUTHORS ChangeLog* HACKING
	dodoc NEWS* README* TODO
	docinto docs
	cd docs
	dodoc *.txt *.gif text/*
	dohtml -r html

	#install nice, clean-looking gtk+ style
	insinto /usr/share/themes/Gentoo/gtk
	doins "${FILESDIR}"/gtkrc

	prep_ml_binaries $(find "${D}"usr/bin/ -type f $(for i in $(get_install_abis); do echo "-not -name "*-$i""; done)| sed "s!${D}!!g")
}

multilib-native_pkg_postinst_internal() {
	if [[ -e /etc/X11/gtk/gtkrc ]] ; then
		ewarn "Older versions added /etc/X11/gtk/gtkrc which changed settings for"
		ewarn "all themes it seems.  Please remove it manually as it will not due"
		ewarn "to /env protection."
	fi

	echo ""
	einfo "The old gtkrc is available through the new Gentoo gtk theme."
}
