# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

MY_PN="ecj"
DMF="R-${PV}-200802211800"
S="${WORKDIR}"

DESCRIPTION="Eclipse Compiler for Java"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://download.eclipse.org/eclipse/downloads/drops/${DMF}/${MY_PN}src.zip"

IUSE="gcj java6"

LICENSE="EPL-1.0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
SLOT="3.3"

CDEPEND=">=app-admin/eselect-ecj-0.3
	gcj? ( sys-devel/gcc )"
DEPEND="${CDEPEND}
	!gcj? ( !java6? ( >=virtual/jdk-1.4 )
		java6? ( >=virtual/jdk-1.6 ) )"
RDEPEND="${CDEPEND}
	!gcj? ( !java6? ( >=virtual/jre-1.4 )
		java6? ( >=virtual/jre-1.6 ) )"

pkg_setup() {
	if use gcj ; then
		if ! built_with_use sys-devel/gcc gcj ; then
			eerror "Building with gcj requires that gcj was compiled as part of gcc.";
			eerror "Please rebuild sys-devel/gcc with USE=\"gcj\"";
			die "Rebuild sys-devel/gcc with gcj support"
		fi
	else
		java-pkg-2_pkg_setup
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}" || die

	# These have their own package.
	rm -f org/eclipse/jdt/core/JDTCompilerAdapter.java || die
	rm -fr org/eclipse/jdt/internal/antadapter || die

	if use gcj || ! use java6 ; then
		rm -fr org/eclipse/jdt/internal/compiler/{apt,tool}/ || die
	fi
}

src_compile() {
	local javac_opts javac java jar

#	javac_opts="$(java-pkg_javac-args) -encoding ISO-8859-1"
	javac="$(java-config -c)"
	java="$(java-config -J)"
	jar="$(java-config -j)"

	mkdir -p bootstrap || die
	cp -a org bootstrap || die
	cd "${S}/bootstrap" || die

	einfo "bootstrapping ${MY_PN} with ${javac} ..."
	${javac} ${javac_opts} $(find org/ -name '*.java') || die
	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' |\
		xargs ${jar} cf ${MY_PN}.jar

	cd "${S}" || die
	einfo "building ${MY_PN} with bootstrapped ${MY_PN} ..."
	${java} -classpath bootstrap/${MY_PN}.jar \
		org.eclipse.jdt.internal.compiler.batch.Main \
		${javac_opts} -nowarn org || die
	find org/ -name '*.class' -o -name '*.properties' -o -name '*.rsc' |\
		xargs ${jar} cf ${MY_PN}.jar

	if use gcj ; then
		einfo "Building native ${MY_PN} binary ..."
		java-pkg_donative org
		java-pkg_donative-bin \
			org.eclipse.jdt.internal.compiler.batch.Main \
			${MY_PN}-${SLOT}-native
	fi
}

src_install() {
	if use gcj ; then
		dobin build/${MY_PN}-${SLOT}-native

		# Don't complain when doing dojar below.
		JAVA_PKG_WANT_SOURCE=1.4
		JAVA_PKG_WANT_TARGET=1.4

		java-pkg_skip-cachejar 2000 ${MY_PN}
	fi

	java-pkg_dolauncher ${MY_PN}-${SLOT} --main \
			org.eclipse.jdt.internal.compiler.batch.Main

	java-pkg_dojar ${MY_PN}.jar
}

pkg_postinst() {
	einfo "To get the Compiler Adapter of ECJ for ANT..."
	einfo " # emerge ant-eclipse-ecj"
	echo
	einfo "To select between slots of ECJ..."
	einfo " # eselect ecj"

	eselect ecj update ecj-${SLOT}
}

pkg_postrm() {
	eselect ecj update
}
