# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/kpathsea/kpathsea-6.0.0_p20100722.ebuild,v 1.7 2010/12/15 18:38:42 aballier Exp $

EAPI=3

inherit texlive-common multilib-native

TEXMFD_VERSION="2"

DESCRIPTION="Library implementing generic path searching, configuration, and TeX-specific file searching"
HOMEPAGE="http://tug.org/texlive/"
SRC_URI="mirror://gentoo/texlive-${PV#*_p}-source.tar.xz
	mirror://gentoo/${PN}-texmf.d-${TEXMFD_VERSION}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~x86"
IUSE="doc source static-libs"

DEPEND="!<app-text/texlive-core-2010
	!app-text/ptex"
RDEPEND="${DEPEND}"

S=${WORKDIR}/texlive-${PV#*_p}-source/texk/${PN}

TL_VERSION=2010
EXTRA_TL_MODULES="kpathsea"
EXTRA_TL_DOC_MODULES="kpathsea.doc"

for i in ${EXTRA_TL_MODULES} ; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${TL_VERSION}.tar.xz"
done

SRC_URI="${SRC_URI} doc? ( "
for i in ${EXTRA_TL_DOC_MODULES} ; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${TL_VERSION}.tar.xz"
done
SRC_URI="${SRC_URI} ) "

multilib-native_src_configure_internal() {
	# Too many regexps use A-Z a-z constructs, what causes problems with locales
	# that don't have the same alphabetical order than ascii. Bug #347798
	# So we set LC_ALL to C in order to avoid problems.
	export LC_ALL=C

	econf \
		$(use_enable static-libs static)
}

multilib-native_src_install_internal() {
	emake DESTDIR="${D}" web2cdir="/usr/share/texmf/web2c" install || die
	find "${D}" -name '*.la' -delete

	dodir /usr/share # just in case
	cp -pR "${WORKDIR}"/texmf "${D}/usr/share/" || die "failed to install texmf trees"
	if use source ; then
		cp -pR "${WORKDIR}"/tlpkg "${D}/usr/share/" || die "failed to install tlpkg files"
	fi

	# The default configuration expects it to be world writable, bug #266680
	# People can still change it with texconfig though.
	dodir /var/cache/fonts
	fperms 1777 /var/cache/fonts

	# Take care of fmtutil.cnf and texmf.cnf
	dodir /etc/texmf/{fmtutil.d,texmf.d}

	# Remove default texmf.cnf to ship our own, greatly based on texlive dvd's
	# texmf.cnf
	# It will also be generated from /etc/texmf/texmf.d files by texmf-update
	rm -f "${D}${TEXMF_PATH}/web2c/texmf.cnf"

	insinto /etc/texmf/texmf.d
	doins "${WORKDIR}/texmf.d/"*.cnf || die "failed to install texmf.d configuration files"

	# Remove fmtutil.cnf, it will be regenerated from /etc/texmf/fmtutil.d files
	# by texmf-update
	rm -f "${D}${TEXMF_PATH}/web2c/fmtutil.cnf"

	if is_final_abi ; then
		dosym /etc/texmf/web2c/fmtutil.cnf ${TEXMF_PATH}/web2c/fmtutil.cnf
		dosym /etc/texmf/web2c/texmf.cnf ${TEXMF_PATH}/web2c/texmf.cnf
	fi

	# Keep it as that's where the formats will go
	keepdir /var/lib/texmf

	dodoc BUGS ChangeLog NEWS PROJECTS README || die
}

multilib-native_pkg_postinst_internal() {
	etexmf-update
}

multilib-native_pkg_postrm_internal() {
	etexmf-update
}
