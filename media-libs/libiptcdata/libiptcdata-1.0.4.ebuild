# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libiptcdata/libiptcdata-1.0.4.ebuild,v 1.11 2010/08/27 18:58:29 armin76 Exp $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils python multilib-native

DESCRIPTION="library for manipulating the International Press Telecommunications
Council (IPTC) metadata"
HOMEPAGE="http://libiptcdata.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ia64 ppc ~ppc64 sparc x86"
IUSE="doc examples nls python"

RDEPEND="python? ( dev-lang/python[lib32?] )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.13.1[lib32?] )
	doc? ( >=dev-util/gtk-doc-1 )"

multilib-native_pkg_setup_internal() {
	if use python; then
		python_pkg_setup
	fi
}

multilib-native_src_prepare_internal() {
	# Python bindings are built/tested/installed manually.
	sed -e '/SUBDIRS =/s/$(MAYBE_PYTHONLIB)//' -i Makefile.in || die "sed failed"
}

multilib-native_src_configure_internal() {
	econf \
		$(use_enable nls) \
		$(use_enable python) \
		$(use_enable doc gtk-doc)
}

multilib-native_src_compile_internal() {
	default

	if use python; then
		python_copy_sources python
		building() {
			emake PYTHON_CPPFLAGS=-I$(python_get_includedir) \
				pyexecdir=$(python_get_sitedir)
		}
		python_execute_function -s --source-dir python building
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die "emake install failed."

	if use python; then
		installation() {
			emake DESTDIR="${D}" pyexecdir=$(python_get_sitedir) install
		}
		python_execute_function -s --source-dir python installation
		python_clean_installation_image
	fi

	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed."

	if use examples; then
		insinto /usr/share/doc/${PF}/python
		doins python/README || die "doins failed"
		doins -r python/examples || die "doins 2 failed"
	fi

	find "${D}" -name '*.la' -delete || die "failed to remove *.la files"
}

multilib-native_pkg_postinst_internal() {
	elog "This version of ${PN} has stopped installing .la files. This may"
	elog "cause compilation failures in other packages. To fix this problem,"
	elog "install dev-util/lafilefixer and run:"
	elog "  lafilefixer --justfixit"
}
