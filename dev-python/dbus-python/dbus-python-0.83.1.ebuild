# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux"

EAPI="2"
PYTHON_DEFINE_DEFAULT_FUNCTIONS="1"
SUPPORT_PYTHON_ABIS="1"

inherit multilib python multilib-native

DESCRIPTION="Python bindings for the D-Bus messagebus."
HOMEPAGE="http://www.freedesktop.org/wiki/Software/DBusBindings \
http://dbus.freedesktop.org/doc/dbus-python/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="doc examples test"

RDEPEND=">=dev-lang/python-2.4.4-r5[lib32?]
	>=dev-python/pyrex-0.9.3-r2[lib32?]
	>=dev-libs/dbus-glib-0.71[lib32?]
	>=sys-apps/dbus-1.1.1[lib32?]"
DEPEND="${RDEPEND}
	doc? ( =dev-python/epydoc-3* )
	test? ( dev-python/pygobject[lib32?] )
	dev-util/pkgconfig[lib32?]"
RESTRICT_PYTHON_ABIS="3.*"

multilib-native_src_prepare_internal() {
	# Disable compiling of .pyc files.
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile

	# Workaround testsuite issues
	epatch "${FILESDIR}/${PN}-0.83.1-workaround-broken-test.patch"

	python_src_prepare
}

multilib-native_src_configure_internal() {
	use prefix || EPREFIX=

	configuration() {
		econf \
			--docdir="${EPREFIX}"/usr/share/doc/dbus-python-${PV} \
			$(use_enable doc api-docs)
	}
	python_execute_function -s configuration
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	python_src_test
}

multilib-native_src_install_internal() {
	python_src_install

	if use doc; then
		# Install documentation only once.
		documentation_installed="0"
		install_documentation() {
			[[ "${documentation_installed}" == "1" ]] && return
			dohtml api/* || return 1
			documentation_installed="1"
		}
		python_execute_function -q -s install_documentation
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/
		doins -r examples || die
	fi
}

multilib-native_pkg_postinst_internal() {
	python_mod_optimize dbus
}

multilib-native_pkg_postrm_internal() {
	python_mod_cleanup
}
