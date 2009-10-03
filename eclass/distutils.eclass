# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/distutils.eclass,v 1.64 2009/09/11 20:03:51 arfrever Exp $

# @ECLASS: distutils.eclass
# @MAINTAINER:
# <python@gentoo.org>
#
# Original author: Jon Nelson <jnelson@gentoo.org>
# @BLURB: This eclass allows easier installation of distutils-based python modules
# @DESCRIPTION:
# The distutils eclass is designed to allow easier installation of
# distutils-based python modules and their incorporation into
# the Gentoo Linux system.

inherit eutils multilib python

case "${EAPI:-0}" in
	0|1)
		EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_postrm
		;;
	*)
		EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install pkg_postinst pkg_postrm
		;;
esac

if [[ -z "${DISTUTILS_DISABLE_PYTHON_DEPENDENCY}" ]]; then
	DEPEND="virtual/python"
	RDEPEND="${DEPEND}"
fi
python="python"

# @ECLASS-VARIABLE: DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES
# @DESCRIPTION:
# Set this to use separate source directories for each enabled version of Python.

# @ECLASS-VARIABLE: DISTUTILS_GLOBAL_OPTIONS
# @DESCRIPTION:
# Global options passed to setup.py.

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION:
# Additional DOCS

# @FUNCTION: distutils_src_unpack
# @DESCRIPTION:
# The distutils src_unpack function, this function is exported
distutils_src_unpack() {
	if [[ "${EBUILD_PHASE}" != "unpack" ]]; then
		die "${FUNCNAME}() can be used only in src_unpack() phase"
	fi

	unpack ${A}
	cd "${S}"

	has "${EAPI:-0}" 0 1 && distutils_src_prepare
}

# @FUNCTION: distutils_src_prepare
# @DESCRIPTION:
# The distutils src_prepare function, this function is exported
distutils_src_prepare() {
	if ! has "${EAPI:-0}" 0 1 && [[ "${EBUILD_PHASE}" != "prepare" ]]; then
		die "${FUNCNAME}() can be used only in src_prepare() phase"
	fi

	# Delete ez_setup files to prevent packages from installing
	# setuptools on their own.
	local ez_setup_existence
	[[ -d ez_setup || -f ez_setup.py ]] && ez_setup_existence="1"
	rm -fr ez_setup*
	if [[ "${ez_setup_existence}" == "1" ]]; then
		echo "def use_setuptools(*args, **kwargs): pass" > ez_setup.py
	fi

	if [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		python_copy_sources
	fi
}

# @FUNCTION: distutils_src_compile
# @DESCRIPTION:
# The distutils src_compile function, this function is exported
distutils_src_compile() {
	if [[ "${EBUILD_PHASE}" != "compile" ]]; then
		die "${FUNCNAME}() can be used only in src_compile() phase"
	fi

	if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		if [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
			building() {
				echo "$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@"
				"$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@"
			}
			python_execute_function -s building "$@"
		else
			building() {
				echo "$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "build-${PYTHON_ABI}" "$@"
				"$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "build-${PYTHON_ABI}" "$@"
			}
			python_execute_function building "$@"
		fi
	else
		echo ${python} setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@"
		${python} setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@" || die "Building failed"
	fi
}

# @FUNCTION: distutils_src_install
# @DESCRIPTION:
# The distutils src_install function, this function is exported.
# It also installs the "standard docs" (CHANGELOG, Change*, KNOWN_BUGS, MAINTAINERS,
# PKG-INFO, CONTRIBUTORS, TODO, NEWS, MANIFEST*, README*, and AUTHORS)
distutils_src_install() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	local pylibdir

	# Mark the package to be rebuilt after a python upgrade.
	python_need_rebuild

	if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		if [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
			installation() {
				if [[ ${ABI} != ${DEFAULT_ABI} ]]; then
					python="$(PYTHON)-${ABI}"
				else
					python="$(PYTHON)"
				fi
				einfo Using ${python}
				# need this for python-2.5 + setuptools in cases where
				# a package uses distutils but does not install anything
				# in site-packages. (eg. dev-java/java-config-2.x)
				# - liquidx (14/08/2006)
				pylibdir="$("${python}" -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
				[[ -n "${pylibdir}" ]] && dodir "${pylibdir}"

				echo "${python}" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@"
				"${python}" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@"
			}
			python_execute_function -s installation "$@"
		else
			installation() {
				if [[ ${ABI} != ${DEFAULT_ABI} ]]; then
					python="$(PYTHON)-${ABI}"
				else
					python="$(PYTHON)"
				fi
				einfo Using ${python}
				# need this for python-2.5 + setuptools in cases where
				# a package uses distutils but does not install anything
				# in site-packages. (eg. dev-java/java-config-2.x)
				# - liquidx (14/08/2006)
				pylibdir="$("${python}" -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
				[[ -n "${pylibdir}" ]] && dodir "${pylibdir}"

				echo "${python}" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "build-${PYTHON_ABI}" install --root="${D}" --no-compile "$@"
				"${python}" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "build-${PYTHON_ABI}" install --root="${D}" --no-compile "$@"
			}
			python_execute_function installation "$@"
		fi
	else
		if [[ ${ABI} != ${DEFAULT_ABI} ]]; then
			python="$(PYTHON)-${ABI}"
		else
			python="$(PYTHON)"
		fi
		einfo Using ${python}
		# need this for python-2.5 + setuptools in cases where
		# a package uses distutils but does not install anything
		# in site-packages. (eg. dev-java/java-config-2.x)
		# - liquidx (14/08/2006)
		pylibdir="$(${python} -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
		[[ -n "${pylibdir}" ]] && dodir "${pylibdir}"

		echo ${python} setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@"
		${python} setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@" || die "Installation failed"
	fi

	if [[ -e "${D}usr/local" ]]; then
		die "Illegal installation into /usr/local"
	fi

	local default_docs
	default_docs="AUTHORS Change* CHANGELOG CONTRIBUTORS KNOWN_BUGS MAINTAINERS MANIFEST* NEWS PKG-INFO README* TODO"

	local doc
	for doc in ${default_docs}; do
		[[ -s "${doc}" ]] && dodoc "${doc}"
	done

	if [[ -n "${DOCS}" ]]; then
		dodoc ${DOCS} || die "dodoc failed"
	fi
}

# @FUNCTION: distutils_pkg_postinst
# @DESCRIPTION:
# This is a generic optimization, you should override it if your package
# installs modules in another directory. This function is exported.
distutils_pkg_postinst() {
	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	local pylibdir pymod
	if [[ -z "${PYTHON_MODNAME}" ]]; then
		for pylibdir in "${ROOT}"/usr/$(get_libdir)/python*; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODNAME="${PN}"
			fi
		done
	fi

	if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		for pymod in ${PYTHON_MODNAME}; do
			python_mod_optimize "${pymod}"
		done
	else
		for pymod in ${PYTHON_MODNAME}; do
			python_mod_optimize "$(python_get_sitedir)/${pymod}"
		done
	fi
}

# @FUNCTION: distutils_pkg_postrm
# @DESCRIPTION:
# Generic pyc/pyo cleanup script. This function is exported.
distutils_pkg_postrm() {
	if [[ "${EBUILD_PHASE}" != "postrm" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postrm() phase"
	fi

	local pylibdir pymod
	if [[ -z "${PYTHON_MODNAME}" ]]; then
		for pylibdir in "${ROOT}"/usr/$(get_libdir)/python*; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODNAME="${PN}"
			fi
		done
	fi

	if [[ -n "${PYTHON_MODNAME}" ]]; then
		for pymod in ${PYTHON_MODNAME}; do
			if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
				python_mod_cleanup "${pymod}"
			else
				for pylibdir in "${ROOT}"/usr/$(get_libdir)/python*; do
					if [[ -d "${pylibdir}/site-packages/${pymod}" ]]; then
						python_mod_cleanup "${pylibdir#${ROOT}}/site-packages/${pymod}"
					fi
				done
			fi
		done
	else
		python_mod_cleanup
	fi
}

# @FUNCTION: distutils_python_version
# @DESCRIPTION:
# Calls python_version, so that you can use something like
#  e.g. insinto ${ROOT}/usr/include/python${PYVER}
distutils_python_version() {
	python_version
}

# @FUNCTION: distutils_python_tkinter
# @DESCRIPTION:
# Checks for if tkinter support is compiled into python
distutils_python_tkinter() {
	python_tkinter_exists
}
