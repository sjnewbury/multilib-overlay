# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-auth/polkit/polkit-0.96.ebuild,v 1.9 2010/07/20 15:08:26 jer Exp $

EAPI="2"

inherit autotools eutils multilib pam multilib-native

DESCRIPTION="Policy framework for controlling privileges for system-wide services"
HOMEPAGE="http://hal.freedesktop.org/docs/PolicyKit"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.gz
!pam? ( mirror://gentoo/${P}-shadow-support.patch.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE="debug doc examples expat nls pam introspection"

RDEPEND=">=dev-libs/glib-2.21.4[lib32?]
	>=dev-libs/eggdbus-0.6[lib32?]
	pam? ( virtual/pam[lib32?] )
	expat? ( dev-libs/expat[lib32?] )
	introspection? ( dev-libs/gobject-introspection[lib32?] )"
DEPEND="${RDEPEND}
	!!>=sys-auth/policykit-0.92
	dev-libs/libxslt[lib32?]
	app-text/docbook-xsl-stylesheets
	>=dev-util/pkgconfig-0.18[lib32?]
	>=dev-util/intltool-0.36
	>=dev-util/gtk-doc-am-1.13
	doc? ( >=dev-util/gtk-doc-1.13 )"
PDEPEND=">=sys-auth/consolekit-0.4[policykit]"
# gtk-doc-am-1.13 needed for eautoreconf

multilib-native_pkg_setup_internal() {
	enewgroup polkituser
	enewuser polkituser -1 "-1" /dev/null polkituser
}

multilib-native_src_prepare_internal() {
	if ! use pam; then
		# Experimental shadow support, bug 291116
		epatch "${WORKDIR}/${P}-shadow-support.patch"
		eautoreconf
	fi
}

multilib-native_src_configure_internal() {
	local conf

	if use expat; then
		conf="${conf} --with-expat=/usr"
	fi

	if use pam; then
		conf="${conf} --with-authfw=pam
			--with-pam-module-dir=$(getpam_mod_dir)"
	else
		conf="${conf} --with-authfw=shadow"
	fi

	# We define libexecdir due to fdo bug #22951
	# easier to maintain than patching everything
	econf ${conf} \
		--disable-ansi \
		--disable-examples \
		--enable-fast-install \
		--enable-libtool-lock \
		--enable-man-pages \
		--disable-dependency-tracking \
		--with-os-type=gentoo \
		--localstatedir=/var \
		--libexecdir='${exec_prefix}/libexec/polkit-1' \
		$(use_enable debug verbose-mode) \
		$(use_enable doc gtk-doc) \
		$(use_enable nls) \
		$(use_enable introspection)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc NEWS README AUTHORS ChangeLog || die "dodoc failed"

	# We disable example compilation above, and handle it here
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins src/examples/{*.c,*.policy*}
	fi

	# Need to keep a few directories around...
	diropts -m0700 -o root -g polkituser
	keepdir /var/run/polkit-1
	keepdir /var/lib/polkit-1
}
