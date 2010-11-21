# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxslt/libxslt-1.1.26.ebuild,v 1.13 2010/11/14 23:02:20 arfrever Exp $

EAPI="2"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit autotools eutils python toolchain-funcs multilib-native

DESCRIPTION="XSLT libraries and tools"
HOMEPAGE="http://www.xmlsoft.org/"
SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="crypt debug python"

DEPEND=">=dev-libs/libxml2-2.6.27[lib32?]
	crypt?  ( >=dev-libs/libgcrypt-1.1.42[lib32?] )"

multilib-native_pkg_setup_internal() {
	if use python; then
		python_pkg_setup
	fi
}

multilib-native_src_prepare_internal() {
	epatch "${FILESDIR}"/libxslt.m4-${P}.patch \
		"${FILESDIR}"/${PN}-1.1.23-parallel-install.patch \
		"${FILESDIR}"/${P}-undefined.patch

	# Python bindings are built/tested/installed manually.
	sed -e "s/@PYTHON_SUBDIR@//" -i Makefile.am || die "sed failed"

	eautoreconf
	epunt_cxx
}

multilib-native_src_configure_internal() {
	# libgcrypt is missing pkg-config file, so fixing cross-compile
	# here. see bug 267503.
	if tc-is-cross-compiler; then
		export LIBGCRYPT_CONFIG="${SYSROOT}/usr/bin/libgcrypt-config"
	fi

	econf \
		--disable-dependency-tracking \
		--with-html-dir=/usr/share/doc/${PF} \
		--with-html-subdir=html \
		$(use_with crypt crypto) \
		$(use_with python) \
		$(use_with debug) \
		$(use_with debug mem-debug)
}

multilib-native_src_compile_internal() {
	default

	if use python; then
		python_copy_sources python
		building() {
			emake PYTHON_INCLUDES="$(python_get_includedir)" \
				PYTHON_SITE_PACKAGES="$(python_get_sitedir)"
		}
		python_execute_function -s --source-dir python building
	fi
}

src_test() {
	default

	if use python; then
		testing() {
			emake test
		}
		python_execute_function -s --source-dir python testing
	fi
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" install || die

	if use python; then
		installation() {
			emake DESTDIR="${D}" \
				PYTHON_SITE_PACKAGES="$(python_get_sitedir)" \
				install
		}
		python_execute_function -s --source-dir python installation

		python_clean_installation_image
	fi

	mv -vf "${D}"/usr/share/doc/${PN}-python-${PV} \
		"${D}"/usr/share/doc/${PF}/python
	dodoc AUTHORS ChangeLog FEATURES NEWS README TODO || die

	prep_ml_binaries /usr/bin/xslt-config
}

multilib-native_pkg_postinst_internal() {
	if use python; then
		python_mod_optimize libxslt.py
	fi
}

multilib-native_pkg_postrm_internal() {
	if use python; then
		python_mod_cleanup libxslt.py
	fi
}
