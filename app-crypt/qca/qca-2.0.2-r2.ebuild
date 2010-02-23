# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/qca/qca-2.0.2-r2.ebuild,v 1.12 2010/01/13 18:44:41 abcd Exp $

EAPI="2"

inherit eutils multilib qt4-r2

DESCRIPTION="Qt Cryptographic Architecture (QCA)"
HOMEPAGE="http://delta.affinix.com/qca/"
SRC_URI="http://delta.affinix.com/download/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="alpha amd64 ~arm hppa ia64 ppc ppc64 sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="aqua debug doc examples"
RESTRICT="test"

DEPEND="x11-libs/qt-core:4[debug?]"
RDEPEND="${DEPEND}
	!<app-crypt/qca-1.0-r3:0
"

src_prepare() {
	epatch "${FILESDIR}"/${P}-pcfilespath.patch

	use aqua && sed -i \
		-e "s|QMAKE_LFLAGS_SONAME =.*|QMAKE_LFLAGS_SONAME = -Wl,-install_name,|g" \
		src/src.pro
}

qca_do_pri() {
	local buildtype=release
	einfo "Manually generating $1 to avoid calling qconf-generated ./configure, bug 305905"

	use debug && buildtype=debug

	sed "${FILESDIR}"/$1.in \
		-e "s:@PN@:${PN}${PV:0:1}:" \
		-e "s:@PREFIX@:${EPREFIX}/usr:" \
		-e "s:@BINDIR@:${EPREFIX}/usr/bin:" \
		-e "s:@INCDIR@:${EPREFIX}/usr/include:" \
		-e "s:@LIBDIR@:${EPREFIX}/usr/${_libdir}:" \
		-e "s:@DATADIR@:${EPREFIX}/usr/share:" \
		-e "s:@BUILDTYPE@:${buildtype}:" \
		-e "s:@QTDATADIR@:${EPREFIX}/usr/share/qt4:" \
		> "${S}"/$1 \
		|| die "Failed to install and preprocess $1"
}

src_configure() {
	use prefix || EPREFIX=

	_libdir=$(get_libdir)

	# fix multilib/ABI issues by avoiding nasty black magic of sys-devel/qconf ;-)
	for pri in app conf; do
		qca_do_pri ${pri}.pri
	done

	# prepare crypto.prf:
	echo "QCA_LIBDIR = /usr/${_libdir}/${PN}${PV:0:1}" >> crypto.prf || die
	echo "QCA_INCDIR = /usr/include/${PN}${PV:0:1}" >> crypto.prf || die
	cat crypto.prf.in >> crypto.prf || die

	# Ensure proper rpath
	export EXTRA_QMAKE_RPATH="${EPREFIX}/usr/${_libdir}/qca2"

	eqmake4 QMAKE_LIBDIR_QT="/usr/$(get_libdir)/qt4"
}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "emake install failed"
	dodoc README TODO || die "dodoc failed"

	cat <<-EOF > "${WORKDIR}"/44qca2
	LDPATH="${EPREFIX}/usr/${_libdir}/qca2"
	EOF
	doenvd "${WORKDIR}"/44qca2 || die

	if use doc; then
		dohtml "${S}"/apidocs/html/* || die "Failed to install documentation"
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/
		doins -r "${S}"/examples || die "Failed to install examples"
	fi

	# add the proper rpath for packages that do CONFIG += crypto
	echo "QMAKE_RPATHDIR += \"${EPREFIX}/usr/${_libdir}/qca2\"" >> \
		"${D%/}${EPREFIX}/usr/share/qt4/mkspecs/features/crypto.prf" \
		|| die "failed to add rpath to crypto.prf"
}
