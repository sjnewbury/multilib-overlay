# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/libidn/libidn-1.15.ebuild,v 1.3 2009/06/30 20:19:22 jer Exp $

EAPI="2"

inherit java-pkg-opt-2 mono elisp-common multilib-native

DESCRIPTION="Internationalized Domain Names (IDN) implementation"
HOMEPAGE="http://www.gnu.org/software/libidn/"
SRC_URI="mirror://gnu/libidn/${P}.tar.gz"

LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="doc emacs java mono nls"

COMMON_DEPEND="emacs? ( virtual/emacs )
	mono? ( >=dev-lang/mono-0.95 )"
DEPEND="${COMMON_DEPEND}
	nls? ( >=sys-devel/gettext-0.17[lib32?] )
	java? ( >=virtual/jdk-1.4 dev-java/gjdoc )"
RDEPEND="${COMMON_DEPEND}
	nls? ( virtual/libintl )
	java? ( >=virtual/jre-1.4 )"

SITEFILE=50${PN}-gentoo.el

src_unpack() {
	unpack ${A}
	# bundled, with wrong bytecode
	rm "${S}/java/${P}.jar" || die
}

ml-native_src_configure() {
	econf \
		$(use_enable nls) \
		$(use_enable java) \
		$(use_enable mono csharp mono) \
		--with-lispdir="${SITELISP}/${PN}" \
		--with-packager="Gentoo" \
		--with-packager-version="r${PR}" \
		--with-packager-bug-reports="https://bugs.gentoo.org" \
		|| die
}

ml-native_src_compile() {
	emake || die

	if use emacs; then
		elisp-compile src/*.el || die
	fi
}

ml-native_src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog FAQ NEWS README THANKS TODO || die

	if use emacs; then
		# *.el are installed by the build system
		elisp-install ${PN} src/*.elc || die
		elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
	else
		rm -rf "${D}/usr/share/emacs"
	fi

	if use doc ; then
		dohtml -r doc/reference/html/* || die
	fi

	if use java ; then
		java-pkg_newjar java/${P}.jar ${PN}.jar || die
		rm -rf "${D}"/usr/share/java || die

		if use doc ; then
			[[ -d "${D}"/usr/share/doc/"${P}"/html ]] || java-pkg_dojavadoc doc/java
		fi
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
