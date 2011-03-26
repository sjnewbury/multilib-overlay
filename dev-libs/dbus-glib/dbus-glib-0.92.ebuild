# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/dbus-glib/dbus-glib-0.92.ebuild,v 1.11 2011/03/22 20:05:27 ranger Exp $

EAPI=2

inherit eutils bash-completion multilib-native

DESCRIPTION="D-Bus bindings for glib"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="bash-completion debug doc static-libs test"

RDEPEND=">=sys-apps/dbus-1.4.1[lib32?]
	>=dev-libs/glib-2.26[lib32?]
	>=dev-libs/expat-1.95.8[lib32?]"
DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	sys-devel/gettext[lib32?]
	doc? (
		app-doc/doxygen
		app-text/xmlto
		>=dev-util/gtk-doc-1.4 )"

# out of sources build directory
BD=${WORKDIR}/${P}-build
# out of sources build dir for make check
TBD=${WORKDIR}/${P}-tests-build

BASHCOMPLETION_NAME="dbus"

multilib-native_src_prepare_internal() {
	# Apply upstream patch to fix build with FEATURES="userpriv", bug #
	epatch "${FILESDIR}/${P}-userpriv-fix.patch"
}

multilib-native_src_configure_internal() {
	local my_conf

	my_conf="--localstatedir=/var
		$(use_enable bash-completion)
		$(use_enable debug verbose-mode)
		$(use_enable debug asserts)
		$(use_enable doc doxygen-docs)
		$(use_enable static-libs static)
		$(use_enable doc gtk-doc)
		--with-html-dir=/usr/share/doc/${PF}/html"

	mkdir "${BD}-${ABI}"
	cd "${BD}-${ABI}"
	einfo "Running configure in ${BD}-${ABI}"
	ECONF_SOURCE="${S}" econf ${my_conf}

	if use test; then
		mkdir "${TBD}-${ABI}"
		cd "${TBD}-${ABI}"
		einfo "Running configure in ${TBD}-${ABI}"
		ECONF_SOURCE="${S}" econf \
			${my_conf} \
			$(use_enable test checks) \
			$(use_enable test tests) \
			$(use_enable test asserts) \
			$(use_with test test-socket-dir "${T}"/dbus-test-socket)
	fi
}

multilib-native_src_compile_internal() {
	cd "${BD}-${ABI}"
	einfo "Running make in ${BD}-${ABI}"
	emake || die

	if use test; then
		cd "${TBD}-${ABI}"
		einfo "Running make in ${TBD}-${ABI}"
		emake || die
	fi
}

src_test() {
	cd "${TBD}-${ABI}"
	emake check || die
}

multilib-native_src_install_internal() {
	dodoc AUTHORS ChangeLog HACKING NEWS README || die

	cd "${BD}-${ABI}"
	emake DESTDIR="${D}" install || die

	# FIXME: We need --with-bash-completion-dir
	if use bash-completion ; then
		dobashcompletion "${D}"/etc/bash_completion.d/dbus-bash-completion.sh
		rm -rf "${D}"/etc/bash_completion.d || die
	fi

	find "${D}" -name '*.la' -exec rm -f '{}' +
}
