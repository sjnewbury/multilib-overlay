# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxml2/libxml2-2.7.7.ebuild,v 1.13 2010/08/09 04:09:07 zmedico Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit libtool flag-o-matic eutils python multilib-native

DESCRIPTION="Version 2 of the library to manipulate XML files"
HOMEPAGE="http://www.xmlsoft.org/"

LICENSE="MIT"
SLOT="2"
KEYWORDS="alpha amd64 arm hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug doc examples ipv6 python readline test"

XSTS_HOME="http://www.w3.org/XML/2004/xml-schema-test-suite"
XSTS_NAME_1="xmlschema2002-01-16"
XSTS_NAME_2="xmlschema2004-01-14"
XSTS_TARBALL_1="xsts-2002-01-16.tar.gz"
XSTS_TARBALL_2="xsts-2004-01-14.tar.gz"

SRC_URI="ftp://xmlsoft.org/${PN}/${P}.tar.gz
	test? (
		${XSTS_HOME}/${XSTS_NAME_1}/${XSTS_TARBALL_1}
		${XSTS_HOME}/${XSTS_NAME_2}/${XSTS_TARBALL_2} )"

RDEPEND="sys-libs/zlib[lib32?]
	python? ( || ( <dev-lang/python-3[xml,lib32?] ( <dev-lang/python-3[lib32?] dev-python/pyxml ) ) )
	readline? ( sys-libs/readline[lib32?] )"

DEPEND="${RDEPEND}
	hppa? ( >=sys-devel/binutils-2.15.92.0.2 )"

multilib-native_pkg_setup_internal() {
	if use python; then
		python_pkg_setup
	fi
}

multilib-native_src_unpack_internal() {
	# ${A} isn't used to avoid unpacking of test tarballs into $WORKDIR,
	# as they are needed as tarballs in ${S}/xstc instead and not unpacked
	unpack ${P}.tar.gz
	cd "${S}"

	if use test; then
		cp "${DISTDIR}/${XSTS_TARBALL_1}" \
			"${DISTDIR}/${XSTS_TARBALL_2}" \
			"${S}"/xstc/ \
			|| die "Failed to install test tarballs"
	fi
}

multilib-native_src_prepare_internal() {
	epunt_cxx

	# Please do not remove, as else we get references to PORTAGE_TMPDIR
	# in /usr/lib/python?.?/site-packages/libxml2mod.la among things.
	elibtoolize

	# Python bindings are built/tested/installed manually.
	sed -e "s/@PYTHON_SUBDIR@//" -i Makefile.in || die "sed failed"
}

multilib-native_src_configure_internal() {
	# USE zlib support breaks gnome2
	# (libgnomeprint for instance fails to compile with
	# fresh install, and existing) - <azarah@gentoo.org> (22 Dec 2002).

	# The meaning of the 'debug' USE flag does not apply to the --with-debug
	# switch (enabling the libxml2 debug module). See bug #100898.

	# --with-mem-debug causes unusual segmentation faults (bug #105120).

	local myconf="--with-zlib
		--with-html-subdir=${PF}/html
		--docdir=/usr/share/doc/${PF}
		$(use_with debug run-debug)
		$(use_with python)
		$(use_with readline)
		$(use_with readline history)
		$(use_enable ipv6)"

	# filter seemingly problematic CFLAGS (#26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	econf ${myconf}
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
	emake DESTDIR="${D}" \
		EXAMPLES_DIR=/usr/share/doc/${PF}/examples \
		install || die "Installation failed"

	if use python; then
		installation() {
			emake DESTDIR="${D}" \
				PYTHON_SITE_PACKAGES="$(python_get_sitedir)" \
				docsdir=/usr/share/doc/${PF}/python \
				exampledir=/usr/share/doc/${PF}/python/examples \
				install
		}
		python_execute_function -s --source-dir python installation

		python_clean_installation_image
	fi

	rm -rf "${D}"/usr/share/doc/${P}
	dodoc AUTHORS ChangeLog Copyright NEWS README* TODO* || die "dodoc failed"

	if ! use python; then
		rm -rf "${D}"/usr/share/doc/${PF}/python
		rm -rf "${D}"/usr/share/doc/${PN}-python-${PV}
	fi

	if ! use doc; then
		rm -rf "${D}"/usr/share/gtk-doc
		rm -rf "${D}"/usr/share/doc/${PF}/html
	fi

	if ! use examples; then
		rm -rf "${D}/usr/share/doc/${PF}/examples"
		rm -rf "${D}/usr/share/doc/${PF}/python/examples"
	fi

	prep_ml_binaries /usr/bin/xml2-config
}

multilib-native_pkg_postinst_internal() {
	if use python; then
		python_mod_optimize drv_libxml2.py libxml2.py
	fi

	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [ "${ROOT}" != "/" ]
	then
		elog "Skipping XML catalog creation for stage building (bug #208887)."
	else
		# need an XML catalog, so no-one writes to a non-existent one
		CATALOG="${ROOT}etc/xml/catalog"

		# we dont want to clobber an existing catalog though,
		# only ensure that one is there
		# <obz@gentoo.org>
		if [ ! -e ${CATALOG} ]; then
			[ -d "${ROOT}etc/xml" ] || mkdir -p "${ROOT}etc/xml"
			/usr/bin/xmlcatalog --create > ${CATALOG}
			einfo "Created XML catalog in ${CATALOG}"
		fi
	fi
}

multilib-native_pkg_postrm_internal() {
	if use python; then
		python_mod_cleanup drv_libxml2.py libxml2.py
	fi
}
