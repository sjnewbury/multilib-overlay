# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-1.19.ebuild,v 1.10 2011/02/26 18:18:37 arfrever Exp $

EAPI="3"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.* *-jython"

inherit autotools eutils multilib python multilib-native

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="http://www.littlecms.com/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="jpeg python static-libs tiff zlib"

RDEPEND="tiff? ( media-libs/tiff[lib32?] )
	jpeg? ( virtual/jpeg[lib32?] )
	zlib? ( sys-libs/zlib[lib32?] )
	python? ( dev-lang/python[lib32?] )"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-1.3.31 )"

multilib-native_pkg_setup_internal() {
	if use python; then
		python_pkg_setup
	fi
}

multilib-native_src_prepare_internal() {
	# Python bindings are built/installed manually.
	sed -e "/SUBDIRS =/s/ python//" -i Makefile.am

	epatch "${FILESDIR}/${P}-disable_static_modules.patch"

	eautoreconf

	# run swig to regenerate lcms_wrap.cxx and lcms.py (bug #148728)
	if use python; then
		cd python
		./swig_lcms || die
	fi
}

multilib-native_src_configure_internal() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_with jpeg) \
		$(use_with python) \
		$(use_with tiff) \
		$(use_with zlib)
}

multilib-native_src_compile_internal() {
	default

	if use python; then
		python_copy_sources python

		building() {
			emake \
				LCMS_PYEXECDIR="$(python_get_sitedir)" \
				LCMS_PYINCLUDE="$(python_get_includedir)" \
				LCMS_PYLIB="$(python_get_libdir)" \
				PYTHON_VERSION="$(python_get_version)"
		}
		python_execute_function -s --source-dir python building
	fi
}

multilib-native_src_install_internal() {
	emake \
		DESTDIR="${D}" \
		BINDIR="${D}"/usr/bin \
		libdir=/usr/$(get_libdir) \
		install || die

	if use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				LCMS_PYEXECDIR="$(python_get_sitedir)" \
				LCMS_PYLIB="$(python_get_libdir)" \
				PYTHON_VERSION="$(python_get_version)" \
				install
		}
		python_execute_function -s --source-dir python installation

		python_clean_installation_image
	fi

	insinto /usr/share/lcms/profiles
	doins testbed/*.icm

	dodoc AUTHORS README* INSTALL NEWS doc/*

	find "${D}" -name '*.la' -exec rm -f '{}' +
}

multilib-native_pkg_postinst_internal() {
	if use python; then
		python_mod_optimize lcms.py
	fi
}

multilib-native_pkg_postrm_internal() {
	if use python; then
		python_mod_cleanup lcms.py
	fi
}
