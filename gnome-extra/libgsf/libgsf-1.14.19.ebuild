# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/libgsf/libgsf-1.14.19.ebuild,v 1.10 2011/03/23 08:21:45 nirbheek Exp $

EAPI="3"
GCONF_DEBUG="no"
PYTHON_DEPEND="python? 2:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.[45] 3.* *-jython"

inherit autotools eutils gnome2 python multilib multilib-native

DESCRIPTION="The GNOME Structured File Library"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${SRC_URI}
	mirror://gentoo/gnome-mplayer-0.9.6-gconf-2.m4.tgz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 doc gnome gtk python thumbnail"

RDEPEND="
	>=dev-libs/glib-2.16:2[lib32?]
	>=dev-libs/libxml2-2.4.16:2[lib32?]
	sys-libs/zlib[lib32?]
	bzip2? ( app-arch/bzip2[lib32?] )
	gnome? ( >=gnome-base/libbonobo-2[lib32?] )
	gtk? ( x11-libs/gtk+:2[lib32?] )
	python? (
		>=dev-python/pygobject-2.10:2[lib32?]
		>=dev-python/pygtk-2.10:2[lib32?] )
	thumbnail? ( >=gnome-base/gconf-2:2[lib32?] )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig[lib32?]
	>=dev-util/intltool-0.35.0
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1 )"

PDEPEND="gnome? ( || (
	media-gfx/imagemagick
	media-gfx/graphicsmagick[imagemagick] ) )"

DOCS="AUTHORS BUGS ChangeLog HACKING NEWS README TODO"

multilib-native_pkg_setup_internal() {
	G2CONF="${G2CONF}
		--with-gio
		--disable-static
		$(use_with bzip2 bz2)
		$(use_with gnome gnome-vfs)
		$(use_with gnome bonobo)
		$(use_with python)
		$(use_with gtk gdk-pixbuf)
		$(use_with thumbnail gconf)"

	if use python; then
		python_pkg_setup
	fi
}

multilib-native_src_prepare_internal() {
	gnome2_src_prepare

	cp "${WORKDIR}/gnome-mplayer-0.9.6-gconf-2.m4" m4/ \
		|| die "failed to copy gconf macro"

	# Fix gconf automagic, bug #289856
	epatch "${FILESDIR}/${PN}-1.14.16-gconf-automagic.patch"

	# Fix useless variable in toplevel Makefile.am, bug #298813
	epatch "${FILESDIR}/${PN}-1.14.16-automake-fixes.patch"

	# Fix build with FEATURES="stricter"
	epatch "${FILESDIR}/${PN}-1.14.19-missing-declaration.patch"

	# Python bindings are built/installed manually.
	sed -e "/SUBDIRS += python/d" -i Makefile.am

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf

	# disable pyc compiling
	mv py-compile py-compile.orig
	ln -s $(type -P true) py-compile
}

multilib-native_src_compile_internal() {
	gnome2_src_compile

	if use python; then
		python_copy_sources python

		building() {
			emake \
				PYTHON_INCLUDES="-I$(python_get_includedir)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)"
		}
		python_execute_function -s --source-dir python building
	fi
}

multilib-native_src_install_internal() {
	gnome2_src_install

	if use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)" \
				install
		}
		python_execute_function -s --source-dir python installation

		python_clean_installation_image
	fi
}

multilib-native_pkg_preinst_internal() {
	gnome2_pkg_preinst
	preserve_old_lib /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib /usr/$(get_libdir)/libgsf-gnome-1.so.1
}

multilib-native_pkg_postinst_internal() {
	gnome2_pkg_postinst

	if use python; then
		python_mod_optimize gsf
	fi

	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-1.so.1
	preserve_old_lib_notify /usr/$(get_libdir)/libgsf-gnome-1.so.1
}

multilib-native_pkg_postrm_internal() {
	gnome2_pkg_postrm

	if use python; then
		python_mod_cleanup gsf
	fi
}
