# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/glib-2.24.1-r1.ebuild,v 1.7 2010/08/31 12:58:59 pacho Exp $

EAPI="2"

inherit autotools gnome.org libtool eutils flag-o-matic multilib-native

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug doc fam hardened selinux xattr"

RDEPEND="virtual/libiconv
	xattr? ( sys-apps/attr[lib32?] )
	fam? ( virtual/fam[lib32?] )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16[lib32?]
	>=sys-devel/gettext-0.11[lib32?]
	>=dev-util/gtk-doc-am-1.13
	doc? (
		>=dev-libs/libxslt-1.0[lib32?]
		>=dev-util/gtk-doc-1.13
		~app-text/docbook-xml-dtd-4.1.2 )"
# eautoreconf needs gtk-doc-am
# XXX: Consider adding test? ( sys-devel/gdb ); assert-msg-test tries to use it

multilib-native_src_prepare_internal() {
	if use ppc64 && use hardened ; then
		replace-flags -O[2-3] -O1
		epatch "${FILESDIR}/glib-2.6.3-testglib-ssp.patch"
	fi

	if use ia64 ; then
		# Only apply for < 4.1
		local major=$(gcc-major-version)
		local minor=$(gcc-minor-version)
		if (( major < 4 || ( major == 4 && minor == 0 ) )); then
			epatch "${FILESDIR}/glib-2.10.3-ia64-atomic-ops.patch"
		fi
	fi

	# Don't fail gio tests when ran without userpriv, upstream bug 552912
	# This is only a temporary workaround, remove as soon as possible
	epatch "${FILESDIR}/${PN}-2.18.1-workaround-gio-test-failure-without-userpriv.patch"

	# Fix gmodule issues on fbsd; bug #184301
	epatch "${FILESDIR}"/${PN}-2.12.12-fbsd.patch

	# Don't check for python, hence removing the build-time python dep.
	# We remove the gdb python scripts in src_install due to bug 291328
	epatch "${FILESDIR}/${PN}-2.24-punt-python-check.patch"

	# Fix test failure when upgrading from 2.22 to 2.24, upstream bug 621368
	epatch "${FILESDIR}/${PN}-2.24-assert-test-failure.patch"

	# Do not try to remove files on live filesystem, bug #XXX ?
	sed 's:^\(.*"/desktop-app-info/delete".*\):/*\1*/:' \
		-i "${S}"/gio/tests/desktop-app-info.c || die "sed failed"

	# Needed for the punt-python-check patch.
	# Also needed to prevent croscompile failures, see bug #267603
	eautoreconf

	[[ ${CHOST} == *-freebsd* ]] && elibtoolize
}

multilib-native_src_configure_internal() {
	local myconf

	epunt_cxx

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	# -- compnerd (3/27/06)
	use debug && myconf="--enable-debug"

	# Always build static libs, see #153807
	# Always use internal libpcre, bug #254659
	econf ${myconf}                 \
		  $(use_enable xattr)       \
		  $(use_enable doc man)     \
		  $(use_enable doc gtk-doc) \
		  $(use_enable fam)         \
		  $(use_enable selinux)     \
		  --enable-static           \
		  --enable-regex            \
		  --with-pcre=internal      \
		  --with-threads=posix
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "Installation failed"

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${D}/usr/lib/charset.alias"

	# Don't install gdb python macros, bug 291328
	rm -rf "${D}/usr/share/gdb/" "${D}/usr/share/glib-2.0/gdb/"

	dodoc AUTHORS ChangeLog* NEWS* README || die "dodoc failed"
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	export XDG_CONFIG_DIRS=/etc/xdg
	export XDG_DATA_DIRS=/usr/local/share:/usr/share
	export XDG_DATA_HOME="${T}"
	emake check || die "tests failed"
}
