# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/distutils.eclass,v 1.76 2010/07/17 23:03:29 arfrever Exp $

# @ECLASS: distutils.eclass
# @MAINTAINER:
# Gentoo Python Project <python@gentoo.org>
#
# Original author: Jon Nelson <jnelson@gentoo.org>
# @BLURB: Eclass for packages with build systems using Distutils
# @DESCRIPTION:
# The distutils eclass defines phase functions for packages with build systems using Distutils.

inherit multilib python

case "${EAPI:-0}" in
	0|1)
		EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_postrm
		;;
	*)
		EXPORT_FUNCTIONS src_prepare src_compile src_install pkg_postinst pkg_postrm
		;;
esac

if [[ -z "$(declare -p PYTHON_DEPEND 2> /dev/null)" ]]; then
	if [[ $(number_abis) -gt 1 ]] ; then
		DEPEND="dev-lang/python[lib32?]"
	else
		DEPEND="dev-lang/python"
	fi
	RDEPEND="${DEPEND}"
fi

# 'python' variable is deprecated. Use PYTHON() instead.
if has "${EAPI:-0}" 0 1 2 && [[ -z "${SUPPORT_PYTHON_ABIS}" ]]; then
	python="python"
else
	python="die"
fi

# @ECLASS-VARIABLE: DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES
# @DESCRIPTION:
# Set this to use separate source directories for each enabled version of Python.

# @ECLASS-VARIABLE: DISTUTILS_SETUP_FILES
# @DESCRIPTION:
# Paths to setup files.

# @ECLASS-VARIABLE: DISTUTILS_GLOBAL_OPTIONS
# @DESCRIPTION:
# Global options passed to setup files.

# @ECLASS-VARIABLE: DISTUTILS_SRC_TEST
# @DESCRIPTION:
# Type of test command used by distutils_src_test().
# IUSE and DEPEND are automatically adjusted, unless DISTUTILS_DISABLE_TEST_DEPENDENCY is set.
# Valid values:
#   setup.py
#   nosetests
#   py.test
#   trial [arguments]

# @ECLASS-VARIABLE: DISTUTILS_DISABLE_TEST_DEPENDENCY
# @DESCRIPTION:
# Disable modification of IUSE and DEPEND caused by setting of DISTUTILS_SRC_TEST.

if [[ -n "${DISTUTILS_SRC_TEST}" && ! "${DISTUTILS_SRC_TEST}" =~ ^(setup\.py|nosetests|py\.test|trial(\ .*)?)$ ]]; then
	die "'DISTUTILS_SRC_TEST' variable has unsupported value '${DISTUTILS_SRC_TEST}'"
fi

if [[ -z "${DISTUTILS_DISABLE_TEST_DEPENDENCY}" ]]; then
	if [[ "${DISTUTILS_SRC_TEST}" == "nosetests" ]]; then
		IUSE="test"
		DEPEND+="${DEPEND:+ }test? ( dev-python/nose )"
	elif [[ "${DISTUTILS_SRC_TEST}" == "py.test" ]]; then
		IUSE="test"
		DEPEND+="${DEPEND:+ }test? ( dev-python/py )"
	# trial requires an argument, which is usually equal to "${PN}".
	elif [[ "${DISTUTILS_SRC_TEST}" =~ ^trial(\ .*)?$ ]]; then
		IUSE="test"
		DEPEND+="${DEPEND:+ }test? ( dev-python/twisted )"
	fi
fi

if [[ -n "${DISTUTILS_SRC_TEST}" ]]; then
	EXPORT_FUNCTIONS src_test
fi

# @ECLASS-VARIABLE: DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS
# @DESCRIPTION:
# Set this to disable renaming of Python scripts containing versioned shebangs
# and generation of wrapper scripts.

# @ECLASS-VARIABLE: DISTUTILS_NONVERSIONED_PYTHON_SCRIPTS
# @DESCRIPTION:
# List of paths to Python scripts, relative to ${ED}, which are excluded from
# renaming and generation of wrapper scripts.

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION:
# Additional documentation files installed by distutils_src_install().

_distutils_get_build_dir() {
	if [[ -n "${SUPPORT_PYTHON_ABIS}" && -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		echo "build-${PYTHON_ABI}"
	else
		echo "build"
	fi
}

_distutils_get_PYTHONPATH() {
	if [[ -n "${SUPPORT_PYTHON_ABIS}" && -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		ls -d build-${PYTHON_ABI}/lib* 2> /dev/null
	else
		ls -d build/lib* 2> /dev/null
	fi
}

_distutils_hook() {
	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi
	if [[ "$(type -t "distutils_src_${EBUILD_PHASE}_$1_hook")" == "function" ]]; then
		"distutils_src_${EBUILD_PHASE}_$1_hook"
	fi
}

# @FUNCTION: distutils_src_unpack
# @DESCRIPTION:
# The distutils src_unpack function. This function is exported.
distutils_src_unpack() {
	if ! has "${EAPI:-0}" 0 1; then
		die "${FUNCNAME}() cannot be used in this EAPI"
	fi

	if [[ "${EBUILD_PHASE}" != "unpack" ]]; then
		die "${FUNCNAME}() can be used only in src_unpack() phase"
	fi

	unpack ${A}
	cd "${S}"

	distutils_src_prepare
}

# @FUNCTION: distutils_src_prepare
# @DESCRIPTION:
# The distutils src_prepare function. This function is exported.
distutils_src_prepare() {
	if ! has "${EAPI:-0}" 0 1 && [[ "${EBUILD_PHASE}" != "prepare" ]]; then
		die "${FUNCNAME}() can be used only in src_prepare() phase"
	fi

	# Delete ez_setup files to prevent packages from installing Setuptools on their own.
	local ez_setup_existence="0"
	[[ -d ez_setup || -f ez_setup.py ]] && ez_setup_existence="1"
	rm -fr ez_setup*
	if [[ "${ez_setup_existence}" == "1" ]]; then
		echo "def use_setuptools(*args, **kwargs): pass" > ez_setup.py
	fi

	# Delete distribute_setup files to prevent packages from installing Distribute on their own.
	local distribute_setup_existence="0"
	[[ -d distribute_setup || -f distribute_setup.py ]] && distribute_setup_existence="1"
	rm -fr distribute_setup*
	if [[ "${distribute_setup_existence}" == "1" ]]; then
		echo "def use_setuptools(*args, **kwargs): pass" > distribute_setup.py
	fi

	if [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		python_copy_sources
	fi
}

# @FUNCTION: distutils_src_compile
# @DESCRIPTION:
# The distutils src_compile function. This function is exported.
# In ebuilds of packages supporting installation for multiple versions of Python, this function
# calls distutils_src_compile_pre_hook() and distutils_src_compile_post_hook(), if they are defined.
distutils_src_compile() {
	if [[ "${EBUILD_PHASE}" != "compile" ]]; then
		die "${FUNCNAME}() can be used only in src_compile() phase"
	fi

	_python_set_color_variables

	if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		distutils_building() {
			_distutils_hook pre

			local setup_file
			for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
				echo ${_BOLD}"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "$(_distutils_get_build_dir)" "$@"${_NORMAL}
				"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "$(_distutils_get_build_dir)" "$@" || return "$?"
			done

			_distutils_hook post
		}
		python_execute_function ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} distutils_building "$@"
	else
		local setup_file
		for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
			echo ${_BOLD}"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@"${_NORMAL}
			"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@" || die "Building failed"
		done
	fi
}

_distutils_src_test_hook() {
	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 arguments"
	fi

	if [[ -z "${SUPPORT_PYTHON_ABIS}" ]]; then
		return
	fi

	if [[ "$(type -t "distutils_src_test_pre_hook")" == "function" ]]; then
		eval "python_execute_$1_pre_hook() {
			distutils_src_test_pre_hook
		}"
	fi

	if [[ "$(type -t "distutils_src_test_post_hook")" == "function" ]]; then
		eval "python_execute_$1_post_hook() {
			distutils_src_test_post_hook
		}"
	fi
}

# @FUNCTION: distutils_src_test
# @DESCRIPTION:
# The distutils src_test function. This function is exported, when DISTUTILS_SRC_TEST variable is set.
# In ebuilds of packages supporting installation for multiple versions of Python, this function
# calls distutils_src_test_pre_hook() and distutils_src_test_post_hook(), if they are defined.
distutils_src_test() {
	if [[ "${EBUILD_PHASE}" != "test" ]]; then
		die "${FUNCNAME}() can be used only in src_test() phase"
	fi

	_python_set_color_variables

	if [[ "${DISTUTILS_SRC_TEST}" == "setup.py" ]]; then
		if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			distutils_testing() {
				_distutils_hook pre

				local setup_file
				for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
					echo ${_BOLD}PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") test "$@"${_NORMAL}
					PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") test "$@" || return "$?"
				done

				_distutils_hook post
			}
			python_execute_function ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} distutils_testing "$@"
		else
			local setup_file
			for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
				echo ${_BOLD}PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" test "$@"${_NORMAL}
				PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" test "$@" || die "Testing failed"
			done
		fi
	elif [[ "${DISTUTILS_SRC_TEST}" == "nosetests" ]]; then
		_distutils_src_test_hook nosetests

		python_execute_nosetests -P '$(_distutils_get_PYTHONPATH)' ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} -- "$@"
	elif [[ "${DISTUTILS_SRC_TEST}" == "py.test" ]]; then
		_distutils_src_test_hook py.test

		python_execute_py.test -P '$(_distutils_get_PYTHONPATH)' ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} -- "$@"
	# trial requires an argument, which is usually equal to "${PN}".
	elif [[ "${DISTUTILS_SRC_TEST}" =~ ^trial(\ .*)?$ ]]; then
		local trial_arguments
		if [[ "${DISTUTILS_SRC_TEST}" == "trial "* ]]; then
			trial_arguments="${DISTUTILS_SRC_TEST#trial }"
		else
			trial_arguments="${PN}"
		fi

		_distutils_src_test_hook trial

		python_execute_trial -P '$(_distutils_get_PYTHONPATH)' ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} -- ${trial_arguments} "$@"
	else
		die "'DISTUTILS_SRC_TEST' variable has unsupported value '${DISTUTILS_SRC_TEST}'"
	fi
}

# @FUNCTION: distutils_src_install
# @DESCRIPTION:
# The distutils src_install function. This function is exported.
# In ebuilds of packages supporting installation for multiple versions of Python, this function
# calls distutils_src_install_pre_hook() and distutils_src_install_post_hook(), if they are defined.
# It also installs some standard documentation files (AUTHORS, Change*, CHANGELOG, CONTRIBUTORS,
# KNOWN_BUGS, MAINTAINERS, MANIFEST*, NEWS, PKG-INFO, README*, TODO).
distutils_src_install() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	if is_final_abi || (! has_multilib_profile); then
		if [ -n "${PYTHON_SLOT_VERSION}" ] ; then
			python=python${PYTHON_SLOT_VERSION}
		else
			python=python
		fi
	else
		[[ -z $(get_abi_var SETARCH_ARCH ${ABI}) ]] && die "SETARCH_ARCH_${ABI} is missing in your portage profile take a look at http://wiki.github.com/sjnewbury/multilib-overlay to get further information"
		if [ -n "${PYTHON_SLOT_VERSION}" ] ; then
			python="setarch $(get_abi_var SETARCH_ARCH ${ABI}) python${PYTHON_SLOT_VERSION}-${ABI}"
		elif [[ -n "${PYTHON}" ]]; then
			python="setarch $(get_abi_var SETARCH_ARCH ${ABI}) ${PYTHON}"
		else
			python="setarch $(get_abi_var SETARCH_ARCH ${ABI}) python"
		fi	
	fi
	einfo Using ${python}

	_python_initialize_prefix_variables
	_python_set_color_variables

	if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		if [[ -z "${DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS}" && "${BASH_VERSINFO[0]}" -ge 4 ]]; then
			declare -A wrapper_scripts=()

			rename_scripts_with_versioned_shebangs() {
				if [[ -d "${ED}usr/bin" ]]; then
					cd "${ED}usr/bin"

					local nonversioned_file file
					for file in *; do
						if [[ -f "${file}" && ! "${file}" =~ [[:digit:]]+\.[[:digit:]](-jython)?+$ && "$(head -n1 "${file}")" =~ ^'#!'.*(python|jython-)[[:digit:]]+\.[[:digit:]]+ ]]; then
							for nonversioned_file in "${DISTUTILS_NONVERSIONED_PYTHON_SCRIPTS[@]}"; do
								[[ "${nonversioned_file}" == "/usr/bin/${file}" ]] && continue 2
							done
							mv "${file}" "${file}-${PYTHON_ABI}" || die "Renaming of '${file}' failed"
							wrapper_scripts+=(["${ED}usr/bin/${file}"]=)
						fi
					done
				fi
			}
		fi

		distutils_installation() {
			_distutils_hook pre

			local setup_file
			for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
				echo ${_BOLD}"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") install --root="${D}" --no-compile "$@"${_NORMAL}
				"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") install --root="${D}" --no-compile "$@" || return "$?"
			done

			if [[ -z "${DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS}" && "${BASH_VERSINFO[0]}" -ge 4 ]]; then
				rename_scripts_with_versioned_shebangs
			fi

			_distutils_hook post
		}
		python_execute_function ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} distutils_installation "$@"

		if [[ -z "${DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS}" && "${#wrapper_scripts[@]}" -ne 0 && "${BASH_VERSINFO[0]}" -ge 4 ]]; then
			python_generate_wrapper_scripts "${!wrapper_scripts[@]}"
		fi
		unset wrapper_scripts
	else
		# Mark the package to be rebuilt after a Python upgrade.
		python_need_rebuild

		local setup_file
		for setup_file in "${DISTUTILS_SETUP_FILES[@]-setup.py}"; do
			echo ${_BOLD}"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@"${_NORMAL}
			"$(PYTHON)" "${setup_file}" "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@" || die "Installation failed"
		done
	fi

	if [[ -e "${ED}usr/local" ]]; then
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
# The distutils pkg_postinst function. This function is exported.
# When PYTHON_MODNAME variable is set, then this function calls python_mod_optimize() with modules
# specified in PYTHON_MODNAME variable. Otherwise it calls python_mod_optimize() with module, whose
# name is equal to name of current package, if this module exists.
distutils_pkg_postinst() {
	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	_python_initialize_prefix_variables

	local pylibdir pymod
	if [[ -z "$(declare -p PYTHON_MODNAME 2> /dev/null)" ]]; then
		for pylibdir in "${EROOT}"usr/$(get_libdir)/python* "${EROOT}"/usr/share/jython-*/Lib; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODNAME="${PN}"
			fi
		done
	fi

	if has "${EAPI:-0}" 0 1 2; then
		if is_final_abi || (! has_multilib_profile); then
			if [ -n "${PYTHON_SLOT_VERSION}" ] ; then
				python=python${PYTHON_SLOT_VERSION}
			else
				python=python
			fi
		else
			[[ -z $(get_abi_var SETARCH_ARCH ${ABI}) ]] && die "SETARCH_ARCH_${ABI} is missing in your portage profile take a look at http://wiki.github.com/sjnewbury/multilib-overlay to get further information"
			if [ -n "${PYTHON_SLOT_VERSION}" ] ; then
				python="setarch $(get_abi_var SETARCH_ARCH ${ABI}) python${PYTHON_SLOT_VERSION}-${ABI}"
			elif [[ -n "${PYTHON}" ]]; then
				python="setarch $(get_abi_var SETARCH_ARCH ${ABI}) ${PYTHON}"
			else
				python="setarch $(get_abi_var SETARCH_ARCH ${ABI}) python"
			fi	
		fi
	else
		python="die"
	fi
	einfo Using ${python}
	if [[ -n "${PYTHON_MODNAME}" ]]; then
		if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			python_mod_optimize ${PYTHON_MODNAME}
		else
			for pymod in ${PYTHON_MODNAME}; do
				python_mod_optimize "$(python_get_sitedir)/${pymod}"
			done
		fi
	fi
}

# @FUNCTION: distutils_pkg_postrm
# @DESCRIPTION:
# The distutils pkg_postrm function. This function is exported.
# When PYTHON_MODNAME variable is set, then this function calls python_mod_cleanup() with modules
# specified in PYTHON_MODNAME variable. Otherwise it calls python_mod_cleanup() with module, whose
# name is equal to name of current package, if this module exists.
distutils_pkg_postrm() {
	if [[ "${EBUILD_PHASE}" != "postrm" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postrm() phase"
	fi

	_python_initialize_prefix_variables

	local pylibdir pymod
	if [[ -z "$(declare -p PYTHON_MODNAME 2> /dev/null)" ]]; then
		for pylibdir in "${EROOT}"usr/$(get_libdir)/python* "${EROOT}"/usr/share/jython-*/Lib; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODNAME="${PN}"
			fi
		done
	fi

	if [[ -n "${PYTHON_MODNAME}" ]]; then
		if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			python_mod_cleanup ${PYTHON_MODNAME}
		else
			for pymod in ${PYTHON_MODNAME}; do
				for pylibdir in "${EROOT}"usr/$(get_libdir)/python*; do
					if [[ -d "${pylibdir}/site-packages/${pymod}" ]]; then
						python_mod_cleanup "${pylibdir#${EROOT%/}}/site-packages/${pymod}"
					fi
				done
			done
		fi
	fi
}

# Scheduled for deletion on 2011-01-01.
distutils_python_version() {
	eerror "Use PYTHON() instead of python variable. Use python_get_*() instead of PYVER* variables."
	die "${FUNCNAME}() is banned"
}

# Scheduled for deletion on 2011-01-01.
distutils_python_tkinter() {
	eerror "Use PYTHON_USE_WITH=\"xml\" and python_pkg_setup() instead of ${FUNCNAME}()."
	die "${FUNCNAME}() is banned"
}
