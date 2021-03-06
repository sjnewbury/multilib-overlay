# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-glib/dbus-glib-0.82.ebuild,v 1.1 2009/11/07 20:00:54 eva Exp $

EAPI="2"

inherit autotools eutils bash-completion git multilib-native

DESCRIPTION="D-Bus bindings for glib"
HOMEPAGE="http://dbus.freedesktop.org/"
#SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/dbus/${PN}"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS=""
IUSE="bash-completion debug doc test"

RDEPEND=">=sys-apps/dbus-1.1[lib32?]
	>=dev-libs/glib-2.10[lib32?]
	>=dev-libs/expat-1.95.8[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]
	doc? (
		app-doc/doxygen
		app-text/xmlto
		>=dev-util/gtk-doc-1.4 )"

BASH_COMPLETION_NAME="dbus"

multilib-native_src_prepare_internal() {
	# description ?
	epatch "${FILESDIR}"/${PN}-introspection.patch
	gtkdocize
	eautoreconf
}

multilib-native_src_configure_internal() {
	econf \
		--localstatedir=/var \
		$(use_enable bash-completion) \
		$(use_enable debug verbose-mode) \
		$(use_enable debug checks) \
		$(use_enable debug asserts) \
		$(use_enable doc doxygen-docs) \
		$(use_enable doc gtk-doc) \
		$(use_enable test tests) \
		$(use_with test test-socket-dir "${T}"/dbus-test-socket)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog HACKING NEWS README || die "dodoc failed."

	# FIXME: We need --with-bash-completion-dir
	if use bash-completion ; then
		dobashcompletion "${D}"/etc/bash_completion.d/dbus-bash-completion.sh
		rm -rf "${D}"/etc/bash_completion.d || die "rm failed"
	fi
}
