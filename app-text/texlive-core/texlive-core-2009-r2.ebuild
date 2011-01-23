# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/texlive-core/texlive-core-2009-r2.ebuild,v 1.1 2010/06/20 12:15:17 aballier Exp $

EAPI=2

inherit eutils flag-o-matic toolchain-funcs libtool texlive-common multilib-native

PATCHLEVEL="18"
TEXMFD_VERSION="1"

DESCRIPTION="A complete TeX distribution"
HOMEPAGE="http://tug.org/texlive/"
SLOT="0"
LICENSE="GPL-2 LPPL-1.3c TeX"

SRC_URI="mirror://gentoo/${P}.tar.xz"

# Fetch patches
SRC_URI="${SRC_URI} mirror://gentoo/${PN}-patches-${PATCHLEVEL}.tar.xz
	mirror://gentoo/${P}-texmf.d-${TEXMFD_VERSION}.tar.xz"

TL_CORE_BINEXTRA_MODULES="a2ping asymptote bibtex8 ctie cweb dtl dvi2tty dviasm dvicopy dvidvi dviljk dvipng dvipos findhyph fragmaster hyphenex lacheck latex2man latexdiff latexmk listings-ext mkind-english mkjobtexmf patgen pdfcrop pdftools pkfix pkfix-helper purifyeps seetexk synctex texcount texdiff texdirflatten texdoc texloganalyser texware tie tpic2pdftex web collection-binextra"
TL_CORE_BINEXTRA_DOC_MODULES="a2ping.doc asymptote.doc bibtex8.doc ctie.doc cweb.doc dvicopy.doc dviljk.doc dvipng.doc dvipos.doc findhyph.doc fragmaster.doc latex2man.doc latexdiff.doc latexmk.doc listings-ext.doc mkjobtexmf.doc patgen.doc pdfcrop.doc pdftools.doc pkfix.doc pkfix-helper.doc purifyeps.doc synctex.doc texcount.doc texdiff.doc texdirflatten.doc texdoc.doc texloganalyser.doc texware.doc tie.doc tpic2pdftex.doc web.doc"
TL_CORE_BINEXTRA_SRC_MODULES="hyphenex.source listings-ext.source mkjobtexmf.source"

TL_CORE_EXTRA_MODULES="tetex texlive.infra kpathsea hyphen-base dvips texconfig gsftopk ${TL_CORE_BINEXTRA_MODULES}"
TL_CORE_EXTRA_DOC_MODULES="tetex.doc texlive.infra.doc kpathsea.doc dvips.doc texconfig.doc gsftopk.doc ${TL_CORE_BINEXTRA_DOC_MODULES}"
TL_CORE_EXTRA_SRC_MODULES="${TL_CORE_BINEXTRA_SRC_MODULES}"

for i in ${TL_CORE_EXTRA_MODULES}; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${PV}.tar.xz"
done

SRC_URI="${SRC_URI} doc? ( "
for i in ${TL_CORE_EXTRA_DOC_MODULES}; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${PV}.tar.xz"
done
SRC_URI="${SRC_URI} )"
SRC_URI="${SRC_URI} source? ( "
for i in ${TL_CORE_EXTRA_SRC_MODULES}; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${PV}.tar.xz"
done
SRC_URI="${SRC_URI} )"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="X doc source tk"

MODULAR_X_DEPEND="X? (
				x11-libs/libXmu[lib32?]
				x11-libs/libXp[lib32?]
				x11-libs/libXpm[lib32?]
				x11-libs/libICE[lib32?]
				x11-libs/libSM[lib32?]
				x11-libs/libXaw[lib32?]
				x11-libs/libXfont[lib32?]
	)"

COMMON_DEPEND="${MODULAR_X_DEPEND}
	!app-text/ptex
	!app-text/tetex
	!<app-text/texlive-2007
	!app-text/xetex
	!<dev-texlive/texlive-basic-2009
	!app-text/xdvipdfmx
	!app-text/dvibook
	sys-libs/zlib[lib32?]
	app-text/teckit
	media-libs/silgraphite
	>=media-libs/libpng-1.2.43-r2:0[lib32?]
	>=app-text/poppler-0.12.3-r3[lib32?]
	media-libs/freetype:2[lib32?]
	media-libs/fontconfig[lib32?]"

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig[lib32?]
	sys-apps/ed
	sys-devel/flex[lib32?]
	app-arch/xz-utils[lib32?]"

RDEPEND="${COMMON_DEPEND}
	tk? ( dev-perl/perl-tk )"

# texdoc needs luatex.
PDEPEND=">=dev-tex/luatex-0.45"

S="${WORKDIR}/texlive-20091107-source"

multilib-native_src_unpack_internal() {
	local i s
	for i in ${A}
	do
		s="${DISTDIR%/}/${i}"
		einfo "Unpacking ${s} to ${PWD}"
		test -s "${s}" || die "${s} does not exist"
		xz -dc -- "${s}" | tar xof - || die "Unpacking ${s} failed"
	done
	cd "${S}"
	mv "${WORKDIR}"/texmf* "${S}" || die "failed to move texmf files"
}

multilib-native_src_prepare_internal() {
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/patches"

	elibtoolize
}

multilib-native_src_configure_internal() {
	# Too many regexps use A-Z a-z constructs, what causes problems with locales
	# that don't have the same alphabetical order than ascii. Bug #242430
	# So we set LC_ALL to C in order to avoid problems.
	export LC_ALL=C
	tc-export CC CXX AR
	econf \
		--bindir=/usr/bin \
		--datadir="${S}" \
		--with-system-freetype2 \
		--with-freetype2-include=/usr/include \
		--with-system-zlib \
		--with-system-libpng \
		--with-system-xpdf \
		--with-system-teckit \
		--with-teckit-includes=/usr/include/teckit \
		--with-system-graphite \
		--without-texinfo \
		--disable-dialog \
		--disable-multiplatform \
		--enable-epsfwin \
		--enable-mftalkwin \
		--enable-regiswin \
		--enable-tektronixwin \
		--enable-unitermwin \
		--with-ps=gs \
		--disable-psutils \
		--disable-t1utils \
		--enable-ipc \
		--enable-xetex \
		--disable-dvipng \
		--disable-dvipdfmx \
		--enable-xdvipdfmx \
		--disable-lcdf-typetools \
		--disable-pdfopen \
		--disable-ps2eps \
		--disable-detex \
		--disable-ttf2pk \
		--disable-tex4htk \
		--disable-cjkutils \
		--disable-xdvik \
		--disable-xindy \
		--disable-luatex \
		--disable-dvi2tty \
		--disable-vlna \
		--disable-largefile \
		--enable-shared \
		--disable-native-texlive-build \
		$(use_with X x)
}

multilib-native_src_compile_internal() {
	emake SHELL=/bin/sh texmf=${TEXMF_PATH:-/usr/share/texmf} || die "emake failed"

	# Mimic updmap --syncwithtrees to enable only fonts installed
	# Code copied from updmap script
	for i in `egrep '^(Mixed)?Map' "texmf/web2c/updmap.cfg" | sed 's@.* @@'`; do
		texlive-common_is_file_present_in_texmf "$i" || echo "$i"
	done > "${T}/updmap_update"
	{
		sed 's@/@\\/@g; s@^@/^MixedMap[     ]*@; s@$@$/s/^/#! /@' <"${T}/updmap_update"
		sed 's@/@\\/@g; s@^@/^Map[  ]*@; s@$@$/s/^/#! /@' <"${T}/updmap_update"
	} > "${T}/updmap_update2"
	sed -f "${T}/updmap_update2" "texmf/web2c/updmap.cfg" >	"${T}/updmap_update3"\
		&& cat "${T}/updmap_update3" > "texmf/web2c/updmap.cfg"
}

src_test() {
	ewarn "Due to modular layout of texlive ebuilds,"
	ewarn "It would not make much sense to use tests into the ebuild"
	ewarn "And tests would fail anyway"
	ewarn "Alternatively you can try to compile any tex file"
	ewarn "Tex warnings should be considered as errors and reported"
	ewarn "You can also run fmtutil-sys --all and check for errors/warnings there"
}

multilib-native_src_install_internal() {
	dodir ${TEXMF_PATH:-/usr/share/texmf}/web2c
	emake DESTDIR="${D}" texmf="${D}${TEXMF_PATH:-/usr/share/texmf}" run_texlinks="true" run_mktexlsr="true" install || die "install failed"

	dodir /usr/share # just in case
	cp -pR texmf{,-dist} "${D}/usr/share/" || die "failed to install texmf trees"
	if use source ; then
		cp -pR "${WORKDIR}"/tlpkg "${D}/usr/share/" || die "failed to install tlpkg files"
	fi

	newsbin "${FILESDIR}/texmf-update2009" texmf-update

	# When X is disabled mf-nowin doesn't exist but some scripts expect it to
	# exist. Instead, it is called mf, so we symlink it to please everything.
	use X || dosym mf /usr/bin/mf-nowin

	docinto texk
	cd "${S}/texk"
	dodoc ChangeLog README || die "failed to install texk docs"

	docinto kpathsea
	cd "${S}/texk/kpathsea"
	dodoc BUGS ChangeLog NEWS PROJECTS README || die "failed to install kpathsea docs"

	docinto dviljk
	cd "${S}/texk/dviljk"
	dodoc ChangeLog README NEWS || die "failed to install dviljk docs"

	docinto dvipsk
	cd "${S}/texk/dvipsk"
	dodoc ChangeLog README || die "failed to install dvipsk docs"

	docinto makeindexk
	cd "${S}/texk/makeindexk"
	dodoc ChangeLog NEWS NOTES README || die "failed to install makeindexk docs"

	docinto ps2pkm
	cd "${S}/texk/ps2pkm"
	dodoc ChangeLog README README.14m || die "failed to install ps2pkm docs"

	docinto web2c
	cd "${S}/texk/web2c"
	dodoc ChangeLog NEWS PROJECTS README || die "failed to install web2c docs"

	use doc || rm -rf "${D}/usr/share/texmf/doc"
	use doc || rm -rf "${D}/usr/share/texmf-dist/doc"

	dodir /var/cache/fonts
	# The default configuration expects it to be world writable, bug #266680
	# People can still change it with texconfig though.
	fperms 1777 /var/cache/fonts

	dodir /etc/env.d
	echo 'CONFIG_PROTECT_MASK="/etc/texmf/web2c /etc/texmf/language.dat.d /etc/texmf/language.def.d /etc/texmf/updmap.d"' > "${D}/etc/env.d/98texlive"
	# populate /etc/texmf
	keepdir /etc/texmf/web2c

	# take care of updmap.cfg, fmtutil.cnf and texmf.cnf
	dodir /etc/texmf/{updmap.d,fmtutil.d,texmf.d,language.dat.d,language.def.d}

	# Remove fmtutil.cnf, it will be regenerated from /etc/texmf/fmtutil.d files
	# by texmf-update
	rm -f "${D}${TEXMF_PATH}/web2c/fmtutil.cnf"

	# Remove default texmf.cnf to ship our own, greatly based on texlive dvd's
	# texmf.cnf
	# It will also be generated from /etc/texmf/texmf.d files by texmf-update
	rm -f "${D}${TEXMF_PATH}/web2c/texmf.cnf"

	insinto /etc/texmf/texmf.d
	doins "${S}/texmf.d/"*.cnf || die "failed to install texmf.d configuration files"

	mv "${D}${TEXMF_PATH}/web2c/updmap.cfg"	"${D}/etc/texmf/updmap.d/00updmap.cfg" || die "moving updmap.cfg failed"

	texlive-common_handle_config_files

	keepdir /usr/share/texmf-site

	dosym /etc/texmf/web2c/fmtutil.cnf ${TEXMF_PATH}/web2c/fmtutil.cnf
	dosym /etc/texmf/web2c/texmf.cnf ${TEXMF_PATH}/web2c/texmf.cnf
	dosym /etc/texmf/web2c/updmap.cfg ${TEXMF_PATH}/web2c/updmap.cfg

	# the virtex symlink is not installed
	# The links has to be relative, since the targets
	# is not present at this stage and MacOS doesn't
	# like non-existing targets
	dosym tex /usr/bin/virtex
	dosym pdftex /usr/bin/pdfvirtex

	# Keep it as that's where the formats will go
	keepdir /var/lib/texmf

	# Remove texdoctk if we don't want it
	if ! use tk ; then
		rm -f "${D}/usr/bin/texdoctk" "${D}/usr/share/texmf/scripts/tetex/texdoctk.pl" "${D}/usr/share/man/man1/texdoctk.1" || die "failed to remove texdoc tk!"
	fi

	# Rename mpost to leave room for mplib
	mv "${D}/usr/bin/mpost" "${D}/usr/bin/mpost-${P}"
	dosym "mpost-${P}" /usr/bin/mpost

	# Ditto for pdftex
	mv "${D}/usr/bin/pdftex" "${D}/usr/bin/pdftex-${P}"
	dosym "pdftex-${P}" /usr/bin/pdftex
}

multilib-native_pkg_preinst_internal() {
	# Remove stray files to keep the upgrade path sane
	if has_version =app-text/texlive-core-2007* ; then
		for i in pdftex/pdflatex aleph/aleph aleph/lamed omega/lambda omega/omega xetex/xetex xetex/xelatex tex/tex pdftex/etex pdftex/pdftex pdftex/pdfetex ; do
			for j in log fmt ; do
				local file="${ROOT}/var/lib/texmf/web2c/${i}.${j}"
				if [ -f "${file}" ] ; then
					elog "Removing stray ${file} from TeXLive 2007 install."
					rm -f "${file}"
				fi
			done
		done
		for j in base log ; do
			local file="${ROOT}/var/lib/texmf/web2c/metafont/mf.${j}"
			if [ -f "${file}" ] ; then
				elog "Removing stray ${file} from TeXLive 2007 install."
				rm -f "${file}"
			fi
		done
	fi
}

multilib-native_pkg_postinst_internal() {
	if [ "$ROOT" = "/" ] ; then
		/usr/sbin/texmf-update
	fi

	elog
	elog "If you have configuration files in /etc/texmf to merge,"
	elog "please update them and run /usr/sbin/texmf-update."
	elog
	ewarn "If you are migrating from an older TeX distribution"
	ewarn "Please make sure you have read:"
	ewarn "http://www.gentoo.org/proj/en/tex/texlive-migration-guide.xml"
	ewarn "in order to avoid possible problems"
	elog
	elog "TeXLive has been split in various ebuilds. If you are missing a"
	elog "package to process your TeX documents, you can install"
	elog "dev-tex/texmfind to easily search for them."
	elog
}
