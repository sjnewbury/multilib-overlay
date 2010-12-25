# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/python.eclass,v 1.106 2010/12/24 15:01:09 arfrever Exp $

# @ECLASS: python.eclass
# @MAINTAINER:
# Gentoo Python Project <python@gentoo.org>
# @BLURB: Eclass for Python packages
# @DESCRIPTION:
# The python eclass contains miscellaneous, useful functions for Python packages.

inherit multilib

if ! has "${EAPI:-0}" 0 1 2 3; then
	die "API of python.eclass in EAPI=\"${EAPI}\" not established"
fi

_CPYTHON2_GLOBALLY_SUPPORTED_ABIS=(2.4 2.5 2.6 2.7)
_CPYTHON3_GLOBALLY_SUPPORTED_ABIS=(3.0 3.1 3.2)
_JYTHON_GLOBALLY_SUPPORTED_ABIS=(2.5-jython)
_PYTHON_GLOBALLY_SUPPORTED_ABIS=(${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]} ${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]} ${_JYTHON_GLOBALLY_SUPPORTED_ABIS[@]})

# ================================================================================================
# ===================================== HANDLING OF METADATA =====================================
# ================================================================================================

_python_check_python_abi_matching() {
	if [[ "$#" -ne 2 ]]; then
		die "${FUNCNAME}() requires 2 arguments"
	fi

	if [[ "$2" == *"-cpython" ]]; then
		[[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+$ && "$1" == ${2%-cpython} ]]
	elif [[ "$2" == *"-jython" ]]; then
		[[ "$1" == $2 ]]
	else
		if [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+$ ]]; then
			[[ "$1" == $2 ]]
		elif [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+-jython$ ]]; then
			[[ "${1%-jython}" == $2 ]]
		else
			die "${FUNCNAME}(): Unrecognized Python ABI '$1'"
		fi
	fi
}

# @ECLASS-VARIABLE: PYTHON_DEPEND
# @DESCRIPTION:
# Specification of dependency on dev-lang/python.
# Syntax:
#   PYTHON_DEPEND:             [[!]USE_flag? ]<version_components_group>[ version_components_group]
#   version_components_group:  <major_version[:[minimal_version][:maximal_version]]>
#   major_version:             <2|3|*>
#   minimal_version:           <minimal_major_version.minimal_minor_version>
#   maximal_version:           <maximal_major_version.maximal_minor_version>

_python_parse_PYTHON_DEPEND() {
	local major_version maximal_version minimal_version python_all="0" python_maximal_version python_minimal_version python_versions=() python2="0" python2_maximal_version python2_minimal_version python3="0" python3_maximal_version python3_minimal_version USE_flag= version_components_group version_components_group_regex version_components_groups

	version_components_group_regex="(2|3|\*)(:([[:digit:]]+\.[[:digit:]]+)?(:([[:digit:]]+\.[[:digit:]]+)?)?)?"
	version_components_groups="${PYTHON_DEPEND}"

	if [[ "${version_components_groups}" =~ ^((\!)?[[:alnum:]_-]+\?\ )?${version_components_group_regex}(\ ${version_components_group_regex})?$ ]]; then
		if [[ "${version_components_groups}" =~ ^(\!)?[[:alnum:]_-]+\? ]]; then
			USE_flag="${version_components_groups%\? *}"
			version_components_groups="${version_components_groups#* }"
		fi
		if [[ "${version_components_groups}" =~ ("*".*" "|" *"|^2.*\ (2|\*)|^3.*\ (3|\*)) ]]; then
			die "Invalid syntax of PYTHON_DEPEND: Incorrectly specified groups of versions"
		fi

		version_components_groups="${version_components_groups// /$'\n'}"
		while read version_components_group; do
			major_version="${version_components_group:0:1}"
			minimal_version="${version_components_group:2}"
			minimal_version="${minimal_version%:*}"
			maximal_version="${version_components_group:$((3 + ${#minimal_version}))}"

			if [[ "${major_version}" =~ ^(2|3)$ ]]; then
				if [[ -n "${minimal_version}" && "${major_version}" != "${minimal_version:0:1}" ]]; then
					die "Invalid syntax of PYTHON_DEPEND: Minimal version '${minimal_version}' not in specified group of versions"
				fi
				if [[ -n "${maximal_version}" && "${major_version}" != "${maximal_version:0:1}" ]]; then
					die "Invalid syntax of PYTHON_DEPEND: Maximal version '${maximal_version}' not in specified group of versions"
				fi
			fi

			if [[ "${major_version}" == "2" ]]; then
				python2="1"
				python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}")
				python2_minimal_version="${minimal_version}"
				python2_maximal_version="${maximal_version}"
			elif [[ "${major_version}" == "3" ]]; then
				python3="1"
				python_versions=("${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
				python3_minimal_version="${minimal_version}"
				python3_maximal_version="${maximal_version}"
			else
				python_all="1"
				python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}" "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
				python_minimal_version="${minimal_version}"
				python_maximal_version="${maximal_version}"
			fi

			if [[ -n "${minimal_version}" ]] && ! has "${minimal_version}" "${python_versions[@]}"; then
				die "Invalid syntax of PYTHON_DEPEND: Unrecognized minimal version '${minimal_version}'"
			fi
			if [[ -n "${maximal_version}" ]] && ! has "${maximal_version}" "${python_versions[@]}"; then
				die "Invalid syntax of PYTHON_DEPEND: Unrecognized maximal version '${maximal_version}'"
			fi

			if [[ -n "${minimal_version}" && -n "${maximal_version}" && "${minimal_version}" > "${maximal_version}" ]]; then
				die "Invalid syntax of PYTHON_DEPEND: Minimal version '${minimal_version}' greater than maximal version '${maximal_version}'"
			fi
		done <<< "${version_components_groups}"

		_PYTHON_ATOMS=()

		_append_accepted_versions_range() {
			local accepted_version="0" i
			for ((i = "${#python_versions[@]}"; i >= 0; i--)); do
				if [[ "${python_versions[${i}]}" == "${python_maximal_version}" ]]; then
					accepted_version="1"
				fi
				if [[ "${accepted_version}" == "1" ]]; then
					_PYTHON_ATOMS+=("=dev-lang/python-${python_versions[${i}]}*")
				fi
				if [[ "${python_versions[${i}]}" == "${python_minimal_version}" ]]; then
					accepted_version="0"
				fi
			done
		}

		if [[ "${python_all}" == "1" ]]; then
			if [[ -z "${python_minimal_version}" && -z "${python_maximal_version}" ]]; then
				_PYTHON_ATOMS+=("dev-lang/python")
			else
				python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}" "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
				python_minimal_version="${python_minimal_version:-${python_versions[0]}}"
				python_maximal_version="${python_maximal_version:-${python_versions[${#python_versions[@]}-1]}}"
				_append_accepted_versions_range
			fi
		else
			if [[ "${python3}" == "1" ]]; then
				if [[ -z "${python3_minimal_version}" && -z "${python3_maximal_version}" ]]; then
					_PYTHON_ATOMS+=("=dev-lang/python-3*")
				else
					python_versions=("${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}")
					python_minimal_version="${python3_minimal_version:-${python_versions[0]}}"
					python_maximal_version="${python3_maximal_version:-${python_versions[${#python_versions[@]}-1]}}"
					_append_accepted_versions_range
				fi
			fi
			if [[ "${python2}" == "1" ]]; then
				if [[ -z "${python2_minimal_version}" && -z "${python2_maximal_version}" ]]; then
					_PYTHON_ATOMS+=("=dev-lang/python-2*")
				else
					python_versions=("${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}")
					python_minimal_version="${python2_minimal_version:-${python_versions[0]}}"
					python_maximal_version="${python2_maximal_version:-${python_versions[${#python_versions[@]}-1]}}"
					_append_accepted_versions_range
				fi
			fi
		fi

		unset -f _append_accepted_versions_range

		if [[ "${#_PYTHON_ATOMS[@]}" -gt 1 ]]; then
			DEPEND+="${DEPEND:+ }${USE_flag}${USE_flag:+? ( }|| ( ${_PYTHON_ATOMS[@]} )${USE_flag:+ )}"
			RDEPEND+="${RDEPEND:+ }${USE_flag}${USE_flag:+? ( }|| ( ${_PYTHON_ATOMS[@]} )${USE_flag:+ )}"
		else
			DEPEND+="${DEPEND:+ }${USE_flag}${USE_flag:+? ( }${_PYTHON_ATOMS[@]}${USE_flag:+ )}"
			RDEPEND+="${RDEPEND:+ }${USE_flag}${USE_flag:+? ( }${_PYTHON_ATOMS[@]}${USE_flag:+ )}"
		fi
	else
		die "Invalid syntax of PYTHON_DEPEND"
	fi
}

DEPEND=">=app-admin/eselect-python-20091230"
RDEPEND="${DEPEND}"

if [[ -n "${PYTHON_DEPEND}" ]]; then
	_python_parse_PYTHON_DEPEND
else
	_PYTHON_ATOMS=("dev-lang/python")
fi
unset -f _python_parse_PYTHON_DEPEND

if [[ -n "${NEED_PYTHON}" ]]; then
	eerror "Use PYTHON_DEPEND variable instead of NEED_PYTHON variable."
	die "NEED_PYTHON variable is banned"
fi

# @ECLASS-VARIABLE: PYTHON_USE_WITH
# @DESCRIPTION:
# Set this to a space separated list of USE flags the Python slot in use must be built with.

# @ECLASS-VARIABLE: PYTHON_USE_WITH_OR
# @DESCRIPTION:
# Set this to a space separated list of USE flags of which one must be turned on for the slot in use.

# @ECLASS-VARIABLE: PYTHON_USE_WITH_OPT
# @DESCRIPTION:
# Set this to a name of a USE flag if you need to make either PYTHON_USE_WITH or
# PYTHON_USE_WITH_OR atoms conditional under a USE flag.

#add lib32? to PYTHON_USE_WITH to ensure that 32bit python is build if needed
if [[ "${PN}" != "python" ]]; then
	PYTHON_USE_WITH+="${PYTHON_USE_WITH:+ }lib32?"
fi

if ! has "${EAPI:-0}" 0 1 && [[ -n ${PYTHON_USE_WITH} || -n ${PYTHON_USE_WITH_OR} ]]; then
	_PYTHON_USE_WITH_ATOMS_ARRAY=()
	if [[ -n "${PYTHON_USE_WITH}" ]]; then
		for _PYTHON_ATOM in "${_PYTHON_ATOMS[@]}"; do
			_PYTHON_USE_WITH_ATOMS_ARRAY+=("${_PYTHON_ATOM}[${PYTHON_USE_WITH// /,}]")
		done
	elif [[ -n "${PYTHON_USE_WITH_OR}" ]]; then
		for _USE_flag in ${PYTHON_USE_WITH_OR}; do
			for _PYTHON_ATOM in "${_PYTHON_ATOMS[@]}"; do
				_PYTHON_USE_WITH_ATOMS_ARRAY+=("${_PYTHON_ATOM}[${_USE_flag}]")
			done
		done
		unset _USE_flag
	fi
	if [[ "${#_PYTHON_USE_WITH_ATOMS_ARRAY[@]}" -gt 1 ]]; then
		_PYTHON_USE_WITH_ATOMS="|| ( ${_PYTHON_USE_WITH_ATOMS_ARRAY[@]} )"
	else
		_PYTHON_USE_WITH_ATOMS="${_PYTHON_USE_WITH_ATOMS_ARRAY[@]}"
	fi
	if [[ -n "${PYTHON_USE_WITH_OPT}" ]]; then
		_PYTHON_USE_WITH_ATOMS="${PYTHON_USE_WITH_OPT}? ( ${_PYTHON_USE_WITH_ATOMS} )"
	fi
	DEPEND+=" ${_PYTHON_USE_WITH_ATOMS}"
	RDEPEND+=" ${_PYTHON_USE_WITH_ATOMS}"
	unset _PYTHON_ATOM _PYTHON_USE_WITH_ATOMS _PYTHON_USE_WITH_ATOMS_ARRAY
fi

unset _PYTHON_ATOMS

# ================================================================================================
# =================================== MISCELLANEOUS FUNCTIONS ====================================
# ================================================================================================

_python_implementation() {
	if [[ "${CATEGORY}/${PN}" == "dev-lang/python" ]]; then
		return 0
	elif [[ "${CATEGORY}/${PN}" == "dev-java/jython" ]]; then
		return 0
	else
		return 1
	fi
}

_python_package_supporting_installation_for_multiple_python_abis() {
	if [[ "${EBUILD_PHASE}" == "depend" ]]; then
		die "${FUNCNAME}() cannot be used in global scope"
	fi

	if has "${EAPI:-0}" 0 1 2 3 4; then
		if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			return 0
		else
			return 1
		fi
	else
		die "${FUNCNAME}(): Support for EAPI=\"${EAPI}\" not implemented"
	fi
}

_python_abi-specific_local_scope() {
	[[ " ${FUNCNAME[@]:2} " =~ " "(_python_final_sanity_checks|python_execute_function|python_mod_optimize|python_mod_cleanup)" " ]]
}

_python_initialize_prefix_variables() {
	if has "${EAPI:-0}" 0 1 2; then
		if [[ -n "${ROOT}" && -z "${EROOT}" ]]; then
			EROOT="${ROOT%/}${EPREFIX}/"
		fi
		if [[ -n "${D}" && -z "${ED}" ]]; then
			ED="${D%/}${EPREFIX}/"
		fi
	fi
}

unset PYTHON_SANITY_CHECKS_EXECUTED PYTHON_SKIP_SANITY_CHECKS

_python_initial_sanity_checks() {
	if [[ "$(declare -p PYTHON_SANITY_CHECKS_EXECUTED 2> /dev/null)" != "declare -- PYTHON_SANITY_CHECKS_EXECUTED="* || " ${FUNCNAME[@]:1} " =~ " "(python_set_active_version|python_pkg_setup)" " && -z "${PYTHON_SKIP_SANITY_CHECKS}" ]]; then
		# Ensure that /usr/bin/python and /usr/bin/python-config are valid.
		if [[ "$(readlink "${EPREFIX}/usr/bin/python")" != "python-wrapper" ]]; then
			eerror "'${EPREFIX}/usr/bin/python' is not valid symlink."
			eerror "Use \`eselect python set \${python_interpreter}\` to fix this problem."
			die "'${EPREFIX}/usr/bin/python' is not valid symlink"
		fi
		if [[ "$(<"${EPREFIX}/usr/bin/python-config")" != *"Gentoo python-config wrapper script"* ]]; then
			eerror "'${EPREFIX}/usr/bin/python-config' is not valid script"
			eerror "Use \`eselect python set \${python_interpreter}\` to fix this problem."
			die "'${EPREFIX}/usr/bin/python-config' is not valid script"
		fi
	fi
}

_python_final_sanity_checks() {
	if ! _python_implementation && [[ "$(declare -p PYTHON_SANITY_CHECKS_EXECUTED 2> /dev/null)" != "declare -- PYTHON_SANITY_CHECKS_EXECUTED="* || " ${FUNCNAME[@]:1} " =~ " "(python_set_active_version|python_pkg_setup)" " && -z "${PYTHON_SKIP_SANITY_CHECKS}" ]]; then
		local PYTHON_ABI="${PYTHON_ABI}"
		for PYTHON_ABI in ${PYTHON_ABIS-${PYTHON_ABI}}; do
			# Ensure that appropriate version of Python is installed.
			if ! has_version "$(python_get_implementational_package)"; then
				die "$(python_get_implementational_package) is not installed"
			fi

			# Ensure that EPYTHON variable is respected.
			if [[ "$(EPYTHON="$(PYTHON)" python -c "${_PYTHON_ABI_EXTRACTION_COMMAND}")" != "${PYTHON_ABI}" ]]; then
				eerror "Path to 'python':                 '$(type -p python)'"
				eerror "ABI:                              '${ABI}'"
				eerror "DEFAULT_ABI:                      '${DEFAULT_ABI}'"
				eerror "EPYTHON:                          '$(PYTHON)'"
				eerror "PYTHON_ABI:                       '${PYTHON_ABI}'"
				eerror "Locally active version of Python: '$(EPYTHON="$(PYTHON)" python -c "${_PYTHON_ABI_EXTRACTION_COMMAND}")'"
				die "'python' does not respect EPYTHON variable"
			fi
		done
	fi
	PYTHON_SANITY_CHECKS_EXECUTED="1"
}

# @ECLASS-VARIABLE: PYTHON_COLORS
# @DESCRIPTION:
# User-configurable colored output.
PYTHON_COLORS="${PYTHON_COLORS:-0}"

_python_set_color_variables() {
	if [[ "${PYTHON_COLORS}" != "0" && "${NOCOLOR:-false}" =~ ^(false|no)$ ]]; then
		_BOLD=$'\e[1m'
		_RED=$'\e[1;31m'
		_GREEN=$'\e[1;32m'
		_BLUE=$'\e[1;34m'
		_CYAN=$'\e[1;36m'
		_NORMAL=$'\e[0m'
	else
		_BOLD=
		_RED=
		_GREEN=
		_BLUE=
		_CYAN=
		_NORMAL=
	fi
}

unset PYTHON_PKG_SETUP_EXECUTED

_python_check_python_pkg_setup_execution() {
	[[ " ${FUNCNAME[@]:1} " =~ " "(python_set_active_version|python_pkg_setup)" " ]] && return

	if ! has "${EAPI:-0}" 0 1 2 3 && [[ -z "${PYTHON_PKG_SETUP_EXECUTED}" ]]; then
		die "python_pkg_setup() not called"
	fi
}

# @FUNCTION: python_pkg_setup
# @DESCRIPTION:
# Perform sanity checks and initialize environment.
#
# This function is exported in EAPI 2 and 3 when PYTHON_USE_WITH or PYTHON_USE_WITH_OR variable
# is set and always in EAPI >=4. Calling of this function is mandatory in EAPI >=4.
#
# This function can be used only in pkg_setup() phase.
python_pkg_setup() {
	# Check if phase is pkg_setup().
	[[ "${EBUILD_PHASE}" != "setup" ]] && die "${FUNCNAME}() can be used only in pkg_setup() phase"

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	export JYTHON_SYSTEM_CACHEDIR="1"
	addwrite "${EPREFIX}/var/cache/jython"

	if _python_package_supporting_installation_for_multiple_python_abis; then
		_python_calculate_PYTHON_ABIS
		export EPYTHON="$(PYTHON -f)"
	else
		PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
	fi

	if ! has "${EAPI:-0}" 0 1 && [[ -n "${PYTHON_USE_WITH}" || -n "${PYTHON_USE_WITH_OR}" ]]; then
		if [[ "${PYTHON_USE_WITH_OPT}" ]]; then
			if [[ "${PYTHON_USE_WITH_OPT}" == !* ]]; then
				use ${PYTHON_USE_WITH_OPT#!} && return
			else
				use !${PYTHON_USE_WITH_OPT} && return
			fi
		fi

		python_pkg_setup_check_USE_flags() {
			local python_atom USE_flag
			python_atom="$(python_get_implementational_package)"

			for USE_flag in ${PYTHON_USE_WITH}; do
				if ! has_version "${python_atom}[${USE_flag}]"; then
					eerror "Please rebuild ${python_atom} with the following USE flags enabled: ${PYTHON_USE_WITH}"
					die "Please rebuild ${python_atom} with the following USE flags enabled: ${PYTHON_USE_WITH}"
				fi
			done

			for USE_flag in ${PYTHON_USE_WITH_OR}; do
				if has_version "${python_atom}[${USE_flag}]"; then
					return
				fi
			done

			if [[ ${PYTHON_USE_WITH_OR} ]]; then
				eerror "Please rebuild ${python_atom} with at least one of the following USE flags enabled: ${PYTHON_USE_WITH_OR}"
				die "Please rebuild ${python_atom} with at least one of the following USE flags enabled: ${PYTHON_USE_WITH_OR}"
			fi
		}

		if _python_package_supporting_installation_for_multiple_python_abis; then
			PYTHON_SKIP_SANITY_CHECKS="1" python_execute_function -q python_pkg_setup_check_USE_flags
		else
			python_pkg_setup_check_USE_flags
		fi

		unset -f python_pkg_setup_check_USE_flags
	fi

	PYTHON_PKG_SETUP_EXECUTED="1"
}

if ! has "${EAPI:-0}" 0 1 2 3 || { has "${EAPI:-0}" 2 3 && [[ -n "${PYTHON_USE_WITH}" || -n "${PYTHON_USE_WITH_OR}" ]]; }; then
	EXPORT_FUNCTIONS pkg_setup
else
	EMULTILIB_PYTHON_NOT_EXPORTED+=" pkg_setup"
fi

_PYTHON_SHEBANG_BASE_PART_REGEX='^#![[:space:]]*([^[:space:]]*/usr/bin/env[[:space:]]+)?([^[:space:]]*/)?(jython|python)'

# @FUNCTION: python_convert_shebangs
# @USAGE: [-q|--quiet] [-r|--recursive] [-x|--only-executables] [--] <Python_ABI|Python_version> <file|directory> [files|directories]
# @DESCRIPTION:
# Convert shebangs in specified files. Directories can be specified only with --recursive option.
python_convert_shebangs() {
	_python_check_python_pkg_setup_execution

	local argument file files=() only_executables="0" python_interpreter quiet="0" recursive="0"

	while (($#)); do
		case "$1" in
			-r|--recursive)
				recursive="1"
				;;
			-q|--quiet)
				quiet="1"
				;;
			-x|--only-executables)
				only_executables="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing Python version and files or directories"
	elif [[ "$#" -eq 1 ]]; then
		die "${FUNCNAME}(): Missing files or directories"
	fi

	if [[ -n "$(_python_get_implementation --ignore-invalid "$1")" ]]; then
		python_interpreter="$(PYTHON "$1")"
	else
		python_interpreter="python$1"
	fi
	shift

	for argument in "$@"; do
		if [[ ! -e "${argument}" ]]; then
			die "${FUNCNAME}(): '${argument}' does not exist"
		elif [[ -f "${argument}" ]]; then
			files+=("${argument}")
		elif [[ -d "${argument}" ]]; then
			if [[ "${recursive}" == "1" ]]; then
				while read -d $'\0' -r file; do
					files+=("${file}")
				done < <(find "${argument}" $([[ "${only_executables}" == "1" ]] && echo -perm /111) -type f -print0)
			else
				die "${FUNCNAME}(): '${argument}' is not a regular file"
			fi
		else
			die "${FUNCNAME}(): '${argument}' is not a regular file or a directory"
		fi
	done

	for file in "${files[@]}"; do
		file="${file#./}"
		[[ "${only_executables}" == "1" && ! -x "${file}" ]] && continue

		if [[ "$(head -n1 "${file}")" =~ ${_PYTHON_SHEBANG_BASE_PART_REGEX} ]]; then
			[[ "$(sed -ne "2p" "${file}")" =~ ^"# Gentoo '".*"' wrapper script generated by python_generate_wrapper_scripts()"$ ]] && continue

			if [[ "${quiet}" == "0" ]]; then
				einfo "Converting shebang in '${file}'"
			fi

			sed -e "1s:^#![[:space:]]*\([^[:space:]]*/usr/bin/env[[:space:]]\)\?[[:space:]]*\([^[:space:]]*/\)\?\(jython\|python\)\([[:digit:]]\+\(\.[[:digit:]]\+\)\?\)\?\(\$\|[[:space:]].*\):#!\1\2${python_interpreter}\6:" -i "${file}" || die "Conversion of shebang in '${file}' failed"
		fi
	done
}

# @FUNCTION: python_clean_installation_image
# @USAGE: [-q|--quiet]
# @DESCRIPTION:
# Delete needless files in installation image.
python_clean_installation_image() {
	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local file files=() quiet="0"

	# Check if phase is src_install().
	[[ "${EBUILD_PHASE}" != "install" ]] && die "${FUNCNAME}() can be used only in src_install() phase"

	while (($#)); do
		case "$1" in
			-q|--quiet)
				quiet="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	while read -d $'\0' -r file; do
		files+=("${file}")
	done < <(find "${ED}" "(" -name "*.py[co]" -o -name "*\$py.class" ")" -type f -print0)

	if [[ "${#files[@]}" -gt 0 ]]; then
		if [[ "${quiet}" == "0" ]]; then
			ewarn "Deleting byte-compiled Python modules needlessly generated by build system:"
		fi
		for file in "${files[@]}"; do
			if [[ "${quiet}" == "0" ]]; then
				ewarn " ${file}"
			fi
			rm -f "${file}"

			# Delete empty __pycache__ directories.
			if [[ "${file%/*}" == *"/__pycache__" ]]; then
				rmdir "${file%/*}" 2> /dev/null
			fi
		done
	fi

	python_clean_sitedirs() {
		if [[ -d "${ED}$(python_get_sitedir)" ]]; then
			find "${ED}$(python_get_sitedir)" "(" -name "*.c" -o -name "*.h" -o -name "*.la" ")" -type f -print0 | xargs -0 rm -f
		fi
	}
	if _python_package_supporting_installation_for_multiple_python_abis; then
		python_execute_function -q python_clean_sitedirs
	else
		python_clean_sitedirs
	fi

	unset -f python_clean_sitedirs
}

# ================================================================================================
# =========== FUNCTIONS FOR PACKAGES SUPPORTING INSTALLATION FOR MULTIPLE PYTHON ABIS ============
# ================================================================================================

# @ECLASS-VARIABLE: SUPPORT_PYTHON_ABIS
# @DESCRIPTION:
# Set this in EAPI <= 4 to indicate that current package supports installation for
# multiple Python ABIs.

# @ECLASS-VARIABLE: PYTHON_EXPORT_PHASE_FUNCTIONS
# @DESCRIPTION:
# Set this to export phase functions for the following ebuild phases:
# src_prepare, src_configure, src_compile, src_test, src_install.
if ! has "${EAPI:-0}" 0 1; then
	python_src_prepare() {
		_python_check_python_pkg_setup_execution

		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}() cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi

		if [[ "$#" -ne 0 ]]; then
			die "${FUNCNAME}() does not accept arguments"
		fi

		python_copy_sources
	}

	for python_default_function in src_configure src_compile src_test src_install; do
		eval "python_${python_default_function}() {
			_python_check_python_pkg_setup_execution

			if ! _python_package_supporting_installation_for_multiple_python_abis; then
				die \"\${FUNCNAME}() cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs\"
			fi

			python_execute_function -d -s -- \"\$@\"
		}"
	done
	unset python_default_function

	if [[ -n "${PYTHON_EXPORT_PHASE_FUNCTIONS}" ]]; then
		EXPORT_FUNCTIONS src_prepare src_configure src_compile src_test src_install
	else
		EMULTILIB_PYTHON_NOT_EXPORTED+=" src_prepare src_configure src_compile src_test src_install"
	fi
fi

if has "${EAPI:-0}" 0 1 2 3; then
	unset PYTHON_ABIS
fi

_python_calculate_PYTHON_ABIS() {
	if ! _python_package_supporting_installation_for_multiple_python_abis; then
		die "${FUNCNAME}() cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
	fi

	_python_initial_sanity_checks

	if [[ "$(declare -p PYTHON_ABIS 2> /dev/null)" != "declare -x PYTHON_ABIS="* ]] && has "${EAPI:-0}" 0 1 2 3; then
		local PYTHON_ABI restricted_ABI restricted_ABIs support_ABI supported_PYTHON_ABIS

		restricted_ABIs="${RESTRICT_PYTHON_ABIS// /$'\n'}"

		if [[ "$(declare -p USE_PYTHON 2> /dev/null)" == "declare -x USE_PYTHON="* ]]; then
			local cpython_enabled="0"

			if [[ -z "${USE_PYTHON}" ]]; then
				die "USE_PYTHON variable is empty"
			fi

			for PYTHON_ABI in ${USE_PYTHON}; do
				if ! has "${PYTHON_ABI}" "${_PYTHON_GLOBALLY_SUPPORTED_ABIS[@]}"; then
					die "USE_PYTHON variable contains invalid value '${PYTHON_ABI}'"
				fi

				if has "${PYTHON_ABI}" "${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}" "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}"; then
					cpython_enabled="1"
				fi

				support_ABI="1"
				while read restricted_ABI; do
					if _python_check_python_abi_matching "${PYTHON_ABI}" "${restricted_ABI}"; then
						support_ABI="0"
						break
					fi
				done <<< "${restricted_ABIs}"
				[[ "${support_ABI}" == "1" ]] && export PYTHON_ABIS+="${PYTHON_ABIS:+ }${PYTHON_ABI}"
			done

			if [[ -z "${PYTHON_ABIS//[${IFS}]/}" ]]; then
				die "USE_PYTHON variable does not enable any Python ABI supported by ${CATEGORY}/${PF}"
			fi

			if [[ "${cpython_enabled}" == "0" ]]; then
				die "USE_PYTHON variable does not enable any CPython ABI"
			fi
		else
			local python_version python2_version= python3_version= support_python_major_version

			if ! has_version "dev-lang/python"; then
				die "${FUNCNAME}(): 'dev-lang/python' is not installed"
			fi

			python_version="$("${EPREFIX}/usr/bin/python" -c 'from sys import version_info; print(".".join(str(x) for x in version_info[:2]))')"

			if has_version "=dev-lang/python-2*"; then
				if [[ "$(readlink "${EPREFIX}/usr/bin/python2")" != "python2."* ]]; then
					die "'${EPREFIX}/usr/bin/python2' is not valid symlink"
				fi

				python2_version="$("${EPREFIX}/usr/bin/python2" -c 'from sys import version_info; print(".".join(str(x) for x in version_info[:2]))')"

				for PYTHON_ABI in "${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}"; do
					support_python_major_version="1"
					while read restricted_ABI; do
						if _python_check_python_abi_matching "${PYTHON_ABI}" "${restricted_ABI}"; then
							support_python_major_version="0"
						fi
					done <<< "${restricted_ABIs}"
					[[ "${support_python_major_version}" == "1" ]] && break
				done
				if [[ "${support_python_major_version}" == "1" ]]; then
					while read restricted_ABI; do
						if _python_check_python_abi_matching "${python2_version}" "${restricted_ABI}"; then
							die "Active version of CPython 2 is not supported by ${CATEGORY}/${PF}"
						fi
					done <<< "${restricted_ABIs}"
				else
					python2_version=""
				fi
			fi

			if has_version "=dev-lang/python-3*"; then
				if [[ "$(readlink "${EPREFIX}/usr/bin/python3")" != "python3."* ]]; then
					die "'${EPREFIX}/usr/bin/python3' is not valid symlink"
				fi

				python3_version="$("${EPREFIX}/usr/bin/python3" -c 'from sys import version_info; print(".".join(str(x) for x in version_info[:2]))')"

				for PYTHON_ABI in "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}"; do
					support_python_major_version="1"
					while read restricted_ABI; do
						if _python_check_python_abi_matching "${PYTHON_ABI}" "${restricted_ABI}"; then
							support_python_major_version="0"
						fi
					done <<< "${restricted_ABIs}"
					[[ "${support_python_major_version}" == "1" ]] && break
				done
				if [[ "${support_python_major_version}" == "1" ]]; then
					while read restricted_ABI; do
						if _python_check_python_abi_matching "${python3_version}" "${restricted_ABI}"; then
							die "Active version of CPython 3 is not supported by ${CATEGORY}/${PF}"
						fi
					done <<< "${restricted_ABIs}"
				else
					python3_version=""
				fi
			fi

			if [[ -n "${python2_version}" && "${python_version}" == "2."* && "${python_version}" != "${python2_version}" ]]; then
				eerror "Python wrapper is configured incorrectly or '${EPREFIX}/usr/bin/python2' symlink"
				eerror "is set incorrectly. Use \`eselect python\` to fix configuration."
				die "Incorrect configuration of Python"
			fi
			if [[ -n "${python3_version}" && "${python_version}" == "3."* && "${python_version}" != "${python3_version}" ]]; then
				eerror "Python wrapper is configured incorrectly or '${EPREFIX}/usr/bin/python3' symlink"
				eerror "is set incorrectly. Use \`eselect python\` to fix configuration."
				die "Incorrect configuration of Python"
			fi

			PYTHON_ABIS="${python2_version} ${python3_version}"
			PYTHON_ABIS="${PYTHON_ABIS# }"
			export PYTHON_ABIS="${PYTHON_ABIS% }"
		fi
	fi

	_python_final_sanity_checks
}

_python_prepare_flags() {
	local array=() deleted_flag element flags new_value old_flag old_value operator pattern prefix variable

	for variable in CPPFLAGS CFLAGS CXXFLAGS LDFLAGS; do
		eval "_PYTHON_SAVED_${variable}=\"\${!variable}\""
		for prefix in PYTHON_USER_ PYTHON_; do
			if [[ "$(declare -p ${prefix}${variable} 2> /dev/null)" == "declare -a ${prefix}${variable}="* ]]; then
				eval "array=(\"\${${prefix}${variable}[@]}\")"
				for element in "${array[@]}"; do
					if [[ "${element}" =~ ^([[:alnum:]]|\.|-|\*|\[|\])+\ (\+|-)\ .+ ]]; then
						pattern="${element%% *}"
						element="${element#* }"
						operator="${element%% *}"
						flags="${element#* }"
						if _python_check_python_abi_matching "${PYTHON_ABI}" "${pattern}"; then
							if [[ "${operator}" == "+" ]]; then
								eval "export ${variable}+=\"\${variable:+ }${flags}\""
							elif [[ "${operator}" == "-" ]]; then
								flags="${flags// /$'\n'}"
								old_value="${!variable// /$'\n'}"
								new_value=""
								while read old_flag; do
									while read deleted_flag; do
										if [[ "${old_flag}" == ${deleted_flag} ]]; then
											continue 2
										fi
									done <<< "${flags}"
									new_value+="${new_value:+ }${old_flag}"
								done <<< "${old_value}"
								eval "export ${variable}=\"\${new_value}\""
							fi
						fi
					else
						die "Element '${element}' of ${prefix}${variable} array has invalid syntax"
					fi
				done
			elif [[ -n "$(declare -p ${prefix}${variable} 2> /dev/null)" ]]; then
				die "${prefix}${variable} should be indexed array"
			fi
		done
	done
}

_python_restore_flags() {
	local variable

	for variable in CPPFLAGS CFLAGS CXXFLAGS LDFLAGS; do
		eval "${variable}=\"\${_PYTHON_SAVED_${variable}}\""
		unset _PYTHON_SAVED_${variable}
	done
}

# @FUNCTION: python_execute_function
# @USAGE: [--action-message message] [-d|--default-function] [--failure-message message] [-f|--final-ABI] [--nonfatal] [-q|--quiet] [-s|--separate-build-dirs] [--source-dir source_directory] [--] <function> [arguments]
# @DESCRIPTION:
# Execute specified function for each value of PYTHON_ABIS, optionally passing additional
# arguments. The specified function can use PYTHON_ABI and BUILDDIR variables.
python_execute_function() {
	_python_check_python_pkg_setup_execution

	if ! _python_package_supporting_installation_for_multiple_python_abis; then
		die "${FUNCNAME}() cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
	fi

	_python_set_color_variables

	local action action_message action_message_template= default_function="0" failure_message failure_message_template= final_ABI="0" function iterated_PYTHON_ABIS nonfatal="0" previous_directory previous_directory_stack previous_directory_stack_length PYTHON_ABI quiet="0" return_code separate_build_dirs="0" source_dir=

	while (($#)); do
		case "$1" in
			--action-message)
				action_message_template="$2"
				shift
				;;
			-d|--default-function)
				default_function="1"
				;;
			--failure-message)
				failure_message_template="$2"
				shift
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			--nonfatal)
				nonfatal="1"
				;;
			-q|--quiet)
				quiet="1"
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			--source-dir)
				source_dir="$2"
				shift
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ -n "${source_dir}" && "${separate_build_dirs}" == 0 ]]; then
		die "${FUNCNAME}(): '--source-dir' option can be specified only with '--separate-build-dirs' option"
	fi

	if [[ "${default_function}" == "0" ]]; then
		if [[ "$#" -eq 0 ]]; then
			die "${FUNCNAME}(): Missing function name"
		fi
		function="$1"
		shift

		if [[ -z "$(type -t "${function}")" ]]; then
			die "${FUNCNAME}(): '${function}' function is not defined"
		fi
	else
		if has "${EAPI:-0}" 0 1; then
			die "${FUNCNAME}(): '--default-function' option cannot be used in this EAPI"
		fi

		if [[ "${EBUILD_PHASE}" == "configure" ]]; then
			if has "${EAPI}" 2 3; then
				python_default_function() {
					econf "$@"
				}
			else
				python_default_function() {
					nonfatal econf "$@"
				}
			fi
		elif [[ "${EBUILD_PHASE}" == "compile" ]]; then
			python_default_function() {
				emake "$@"
			}
		elif [[ "${EBUILD_PHASE}" == "test" ]]; then
			python_default_function() {
				if emake -j1 -n check &> /dev/null; then
					emake -j1 check "$@"
				elif emake -j1 -n test &> /dev/null; then
					emake -j1 test "$@"
				fi
			}
		elif [[ "${EBUILD_PHASE}" == "install" ]]; then
			python_default_function() {
				emake DESTDIR="${D}" install "$@"
			}
		else
			die "${FUNCNAME}(): '--default-function' option cannot be used in this ebuild phase"
		fi
		function="python_default_function"
	fi

	# Ensure that python_execute_function() cannot be directly or indirectly called by python_execute_function().
	if _python_abi-specific_local_scope; then
		die "${FUNCNAME}(): Invalid call stack"
	fi

	if [[ "${quiet}" == "0" ]]; then
		[[ "${EBUILD_PHASE}" == "setup" ]] && action="Setting up"
		[[ "${EBUILD_PHASE}" == "unpack" ]] && action="Unpacking"
		[[ "${EBUILD_PHASE}" == "prepare" ]] && action="Preparation"
		[[ "${EBUILD_PHASE}" == "configure" ]] && action="Configuration"
		[[ "${EBUILD_PHASE}" == "compile" ]] && action="Building"
		[[ "${EBUILD_PHASE}" == "test" ]] && action="Testing"
		[[ "${EBUILD_PHASE}" == "install" ]] && action="Installation"
		[[ "${EBUILD_PHASE}" == "preinst" ]] && action="Preinstallation"
		[[ "${EBUILD_PHASE}" == "postinst" ]] && action="Postinstallation"
		[[ "${EBUILD_PHASE}" == "prerm" ]] && action="Preuninstallation"
		[[ "${EBUILD_PHASE}" == "postrm" ]] && action="Postuninstallation"
	fi

	_python_calculate_PYTHON_ABIS
	if [[ "${final_ABI}" == "1" ]]; then
		iterated_PYTHON_ABIS="$(PYTHON -f --ABI)"
	else
		iterated_PYTHON_ABIS="${PYTHON_ABIS}"
	fi
	for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
		_python_prepare_flags

		if [[ "${quiet}" == "0" ]]; then
			if [[ -n "${action_message_template}" ]]; then
				eval "action_message=\"${action_message_template}\""
			else
				action_message="${action} of ${CATEGORY}/${PF} with $(python_get_implementation) $(python_get_version)..."
			fi
			echo " ${_GREEN}*${_NORMAL} ${_BLUE}${action_message}${_NORMAL}"
		fi

		if [[ "${separate_build_dirs}" == "1" ]]; then
			if [[ -n "${source_dir}" ]]; then
				export BUILDDIR="${S}/${source_dir}-${PYTHON_ABI}"
			else
				export BUILDDIR="${S}-${PYTHON_ABI}"
			fi
			pushd "${BUILDDIR}" > /dev/null || die "pushd failed"
		else
			export BUILDDIR="${S}"
		fi

		previous_directory="$(pwd)"
		previous_directory_stack="$(dirs -p)"
		previous_directory_stack_length="$(dirs -p | wc -l)"

		if ! has "${EAPI}" 0 1 2 3 && has "${PYTHON_ABI}" ${FAILURE_TOLERANT_PYTHON_ABIS}; then
			EPYTHON="$(PYTHON)" nonfatal "${function}" "$@"
		else
			EPYTHON="$(PYTHON)" "${function}" "$@"
		fi

		return_code="$?"

		_python_restore_flags

		if [[ "${return_code}" -ne 0 ]]; then
			if [[ -n "${failure_message_template}" ]]; then
				eval "failure_message=\"${failure_message_template}\""
			else
				failure_message="${action} failed with $(python_get_implementation) $(python_get_version) in ${function}() function"
			fi

			if [[ "${nonfatal}" == "1" ]]; then
				if [[ "${quiet}" == "0" ]]; then
					ewarn "${failure_message}"
				fi
			elif [[ "${final_ABI}" == "0" ]] && has "${PYTHON_ABI}" ${FAILURE_TOLERANT_PYTHON_ABIS}; then
				if [[ "${EBUILD_PHASE}" != "test" ]] || ! has test-fail-continue ${FEATURES}; then
					local enabled_PYTHON_ABIS= other_PYTHON_ABI
					for other_PYTHON_ABI in ${PYTHON_ABIS}; do
						[[ "${other_PYTHON_ABI}" != "${PYTHON_ABI}" ]] && enabled_PYTHON_ABIS+="${enabled_PYTHON_ABIS:+ }${other_PYTHON_ABI}"
					done
					export PYTHON_ABIS="${enabled_PYTHON_ABIS}"
				fi
				if [[ "${quiet}" == "0" ]]; then
					ewarn "${failure_message}"
				fi
				if [[ -z "${PYTHON_ABIS}" ]]; then
					die "${function}() function failed with all enabled Python ABIs"
				fi
			else
				die "${failure_message}"
			fi
		fi

		# Ensure that directory stack has not been decreased.
		if [[ "$(dirs -p | wc -l)" -lt "${previous_directory_stack_length}" ]]; then
			die "Directory stack decreased illegally"
		fi

		# Avoid side effects of earlier returning from the specified function.
		while [[ "$(dirs -p | wc -l)" -gt "${previous_directory_stack_length}" ]]; do
			popd > /dev/null || die "popd failed"
		done

		# Ensure that the bottom part of directory stack has not been changed. Restore
		# previous directory (from before running of the specified function) before
		# comparison of directory stacks to avoid mismatch of directory stacks after
		# potential using of 'cd' to change current directory. Restoration of previous
		# directory allows to safely use 'cd' to change current directory in the
		# specified function without changing it back to original directory.
		cd "${previous_directory}"
		if [[ "$(dirs -p)" != "${previous_directory_stack}" ]]; then
			die "Directory stack changed illegally"
		fi

		if [[ "${separate_build_dirs}" == "1" ]]; then
			popd > /dev/null || die "popd failed"
		fi
		unset BUILDDIR
	done

	if [[ "${default_function}" == "1" ]]; then
		unset -f python_default_function
	fi
}

# @FUNCTION: python_copy_sources
# @USAGE: <directory="${S}"> [directory]
# @DESCRIPTION:
# Copy unpacked sources of current package to separate build directory for each Python ABI.
python_copy_sources() {
	_python_check_python_pkg_setup_execution

	if ! _python_package_supporting_installation_for_multiple_python_abis; then
		die "${FUNCNAME}() cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
	fi

	local dir dirs=() PYTHON_ABI

	if [[ "$#" -eq 0 ]]; then
		if [[ "${WORKDIR}" == "${S}" ]]; then
			die "${FUNCNAME}() cannot be used with current value of S variable"
		fi
		dirs=("${S%/}")
	else
		dirs=("$@")
	fi

	_python_calculate_PYTHON_ABIS
	for PYTHON_ABI in ${PYTHON_ABIS}; do
		for dir in "${dirs[@]}"; do
			cp -pr "${dir}" "${dir}-${PYTHON_ABI}" > /dev/null || die "Copying of sources failed"
		done
	done
}

# @FUNCTION: python_generate_wrapper_scripts
# @USAGE: [-E|--respect-EPYTHON] [-f|--force] [-q|--quiet] [--] <file> [files]
# @DESCRIPTION:
# Generate wrapper scripts. Existing files are overwritten only with --force option.
# If --respect-EPYTHON option is specified, then generated wrapper scripts will
# respect EPYTHON variable at run time.
python_generate_wrapper_scripts() {
	_python_check_python_pkg_setup_execution

	if ! _python_package_supporting_installation_for_multiple_python_abis; then
		die "${FUNCNAME}() cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
	fi

	_python_initialize_prefix_variables

	local eselect_python_option file force="0" quiet="0" PYTHON_ABI PYTHON_ABIS_list python2_enabled="0" python3_enabled="0" respect_EPYTHON="0"

	while (($#)); do
		case "$1" in
			-E|--respect-EPYTHON)
				respect_EPYTHON="1"
				;;
			-f|--force)
				force="1"
				;;
			-q|--quiet)
				quiet="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing arguments"
	fi

	_python_calculate_PYTHON_ABIS
	for PYTHON_ABI in "${_CPYTHON2_GLOBALLY_SUPPORTED_ABIS[@]}"; do
		if has "${PYTHON_ABI}" ${PYTHON_ABIS}; then
			python2_enabled="1"
		fi
	done
	for PYTHON_ABI in "${_CPYTHON3_GLOBALLY_SUPPORTED_ABIS[@]}"; do
		if has "${PYTHON_ABI}" ${PYTHON_ABIS}; then
			python3_enabled="1"
		fi
	done

	if [[ "${python2_enabled}" == "1" && "${python3_enabled}" == "1" ]]; then
		eselect_python_option=
	elif [[ "${python2_enabled}" == "1" && "${python3_enabled}" == "0" ]]; then
		eselect_python_option="--python2"
	elif [[ "${python2_enabled}" == "0" && "${python3_enabled}" == "1" ]]; then
		eselect_python_option="--python3"
	else
		die "${FUNCNAME}(): Unsupported environment"
	fi

	PYTHON_ABIS_list="$("$(PYTHON -f)" -c "print(', '.join('\"%s\"' % x for x in reversed('${PYTHON_ABIS}'.split())))")"

	for file in "$@"; do
		if [[ -f "${file}" && "${force}" == "0" ]]; then
			die "${FUNCNAME}(): '${file}' already exists"
		fi

		if [[ "${quiet}" == "0" ]]; then
			einfo "Generating '${file#${ED%/}}' wrapper script"
		fi

		cat << EOF > "${file}"
#!/usr/bin/env python
# Gentoo '${file##*/}' wrapper script generated by python_generate_wrapper_scripts()

import os
import re
import subprocess
import sys

cpython_re = re.compile(r"^python(\d+\.\d+)$")
jython_re = re.compile(r"^jython(\d+\.\d+)$")
python_shebang_re = re.compile(r"^#! *(${EPREFIX}/usr/bin/python|(${EPREFIX})?/usr/bin/env +(${EPREFIX}/usr/bin/)?python)")
python_verification_output_re = re.compile("^GENTOO_PYTHON_TARGET_SCRIPT_PATH supported\n$")

def get_PYTHON_ABI(EPYTHON):
	cpython_matched = cpython_re.match(EPYTHON)
	jython_matched = jython_re.match(EPYTHON)
	if cpython_matched is not None:
		PYTHON_ABI = cpython_matched.group(1)
	elif jython_matched is not None:
		PYTHON_ABI = jython_matched.group(1) + "-jython"
	else:
		PYTHON_ABI = None
	return PYTHON_ABI

EOF
		if [[ "$?" != "0" ]]; then
			die "${FUNCNAME}(): Generation of '$1' failed"
		fi
		if [[ "${respect_EPYTHON}" == "1" ]]; then
			cat << EOF >> "${file}"
EPYTHON = os.environ.get("EPYTHON")
if EPYTHON:
	PYTHON_ABI = get_PYTHON_ABI(EPYTHON)
	if PYTHON_ABI is None:
		sys.stderr.write("EPYTHON variable has unrecognized value '%s'\n" % EPYTHON)
		sys.exit(1)
else:
	try:
		eselect_process = subprocess.Popen(["${EPREFIX}/usr/bin/eselect", "python", "show"${eselect_python_option:+, $(echo "\"")}${eselect_python_option}${eselect_python_option:+$(echo "\"")}], stdout=subprocess.PIPE)
		if eselect_process.wait() != 0:
			raise ValueError
	except (OSError, ValueError):
		sys.stderr.write("Execution of 'eselect python show${eselect_python_option:+ }${eselect_python_option}' failed\n")
		sys.exit(1)

	EPYTHON = eselect_process.stdout.read()
	if not isinstance(EPYTHON, str):
		# Python 3
		EPYTHON = EPYTHON.decode()
	EPYTHON = EPYTHON.rstrip("\n")

	PYTHON_ABI = get_PYTHON_ABI(EPYTHON)
	if PYTHON_ABI is None:
		sys.stderr.write("'eselect python show${eselect_python_option:+ }${eselect_python_option}' printed unrecognized value '%s'\n" % EPYTHON)
		sys.exit(1)

wrapper_script_path = os.path.realpath(sys.argv[0])
target_executable_path = "%s-%s" % (wrapper_script_path, PYTHON_ABI)
if not os.path.exists(target_executable_path):
	sys.stderr.write("'%s' does not exist\n" % target_executable_path)
	sys.exit(1)
EOF
			if [[ "$?" != "0" ]]; then
				die "${FUNCNAME}(): Generation of '$1' failed"
			fi
		else
			cat << EOF >> "${file}"
try:
	eselect_process = subprocess.Popen(["${EPREFIX}/usr/bin/eselect", "python", "show"${eselect_python_option:+, $(echo "\"")}${eselect_python_option}${eselect_python_option:+$(echo "\"")}], stdout=subprocess.PIPE)
	if eselect_process.wait() != 0:
		raise ValueError
except (OSError, ValueError):
	sys.stderr.write("Execution of 'eselect python show${eselect_python_option:+ }${eselect_python_option}' failed\n")
	sys.exit(1)

EPYTHON = eselect_process.stdout.read()
if not isinstance(EPYTHON, str):
	# Python 3
	EPYTHON = EPYTHON.decode()
EPYTHON = EPYTHON.rstrip("\n")

PYTHON_ABI = get_PYTHON_ABI(EPYTHON)
if PYTHON_ABI is None:
	sys.stderr.write("'eselect python show${eselect_python_option:+ }${eselect_python_option}' printed unrecognized value '%s'\n" % EPYTHON)
	sys.exit(1)

wrapper_script_path = os.path.realpath(sys.argv[0])
for PYTHON_ABI in [PYTHON_ABI, ${PYTHON_ABIS_list}]:
	target_executable_path = "%s-%s" % (wrapper_script_path, PYTHON_ABI)
	if os.path.exists(target_executable_path):
		break
else:
	sys.stderr.write("No target script exists for '%s'\n" % wrapper_script_path)
	sys.exit(1)
EOF
			if [[ "$?" != "0" ]]; then
				die "${FUNCNAME}(): Generation of '$1' failed"
			fi
		fi
		cat << EOF >> "${file}"

target_executable = open(target_executable_path, "rb")
target_executable_first_line = target_executable.readline()
if not isinstance(target_executable_first_line, str):
	# Python 3
	target_executable_first_line = target_executable_first_line.decode("utf_8", "replace")

python_shebang_matched = python_shebang_re.match(target_executable_first_line)
target_executable.close()

if python_shebang_matched is not None:
	try:
		python_interpreter_path = "${EPREFIX}/usr/bin/%s" % EPYTHON
		os.environ["GENTOO_PYTHON_TARGET_SCRIPT_PATH_VERIFICATION"] = "1"
		python_verification_process = subprocess.Popen([python_interpreter_path, "-c", "pass"], stdout=subprocess.PIPE)
		del os.environ["GENTOO_PYTHON_TARGET_SCRIPT_PATH_VERIFICATION"]
		if python_verification_process.wait() != 0:
			raise ValueError

		python_verification_output = python_verification_process.stdout.read()
		if not isinstance(python_verification_output, str):
			# Python 3
			python_verification_output = python_verification_output.decode()

		if not python_verification_output_re.match(python_verification_output):
			raise ValueError

		if cpython_re.match(EPYTHON) is not None:
			os.environ["GENTOO_PYTHON_PROCESS_NAME"] = os.path.basename(sys.argv[0])
			os.environ["GENTOO_PYTHON_WRAPPER_SCRIPT_PATH"] = sys.argv[0]
			os.environ["GENTOO_PYTHON_TARGET_SCRIPT_PATH"] = target_executable_path

		if hasattr(os, "execv"):
			os.execv(python_interpreter_path, [python_interpreter_path] + sys.argv)
		else:
			sys.exit(subprocess.Popen([python_interpreter_path] + sys.argv).wait())
	except (KeyboardInterrupt, SystemExit):
		raise
	except:
		pass
	for variable in ("GENTOO_PYTHON_PROCESS_NAME", "GENTOO_PYTHON_WRAPPER_SCRIPT_PATH", "GENTOO_PYTHON_TARGET_SCRIPT_PATH", "GENTOO_PYTHON_TARGET_SCRIPT_PATH_VERIFICATION"):
		if variable in os.environ:
			del os.environ[variable]

if hasattr(os, "execv"):
	os.execv(target_executable_path, sys.argv)
else:
	sys.exit(subprocess.Popen([target_executable_path] + sys.argv[1:]).wait())
EOF
		if [[ "$?" != "0" ]]; then
			die "${FUNCNAME}(): Generation of '$1' failed"
		fi
		fperms +x "${file#${ED%/}}" || die "fperms '${file}' failed"
	done
}

# @ECLASS-VARIABLE: PYTHON_VERSIONED_SCRIPTS
# @DESCRIPTION:
# Array of regular expressions of paths to versioned Python scripts.
# Python scripts in /usr/bin and /usr/sbin are versioned by default.

# @ECLASS-VARIABLE: PYTHON_VERSIONED_EXECUTABLES
# @DESCRIPTION:
# Array of regular expressions of paths to versioned executables (including Python scripts).

# @ECLASS-VARIABLE: PYTHON_NONVERSIONED_EXECUTABLES
# @DESCRIPTION:
# Array of regular expressions of paths to nonversioned executables (including Python scripts).

# @FUNCTION: python_merge_intermediate_installation_images
# @USAGE: [-q|--quiet] [--] <intermediate_installation_images_directory>
# @DESCRIPTION:
# Merge intermediate installation images into installation image.
python_merge_intermediate_installation_images() {
	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local b file files=() intermediate_installation_images_directory PYTHON_ABI quiet="0" regex shebang version_executable wrapper_scripts=() wrapper_scripts_set=()

	# Check if phase is src_install().
	[[ "${EBUILD_PHASE}" != "install" ]] && die "${FUNCNAME}() can be used only in src_install() phase"

	while (($#)); do
		case "$1" in
			-q|--quiet)
				quiet="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	intermediate_installation_images_directory="$1"

	if [[ ! -d "${intermediate_installation_images_directory}" ]]; then
		die "${FUNCNAME}(): Intermediate installation images directory '${intermediate_installation_images_directory}' does not exist"
	fi

	_python_calculate_PYTHON_ABIS
	if [[ "$(PYTHON -f --ABI)" == 3.* ]]; then
		b="b"
	fi

	while read -d $'\0' -r file; do
		files+=("${file}")
	done < <("$(PYTHON -f)" -c \
"import os
import sys

if hasattr(sys.stdout, 'buffer'):
	# Python 3
	stdout = sys.stdout.buffer
else:
	# Python 2
	stdout = sys.stdout

files_set = set()

os.chdir(${b}'${intermediate_installation_images_directory}')

for PYTHON_ABI in ${b}'${PYTHON_ABIS}'.split():
	for root, dirs, files in os.walk(PYTHON_ABI + ${b}'${EPREFIX}'):
		root = root[len(PYTHON_ABI + ${b}'${EPREFIX}')+1:]
		files_set.update(root + ${b}'/' + file for file in files)

for file in sorted(files_set):
	stdout.write(file)
	stdout.write(${b}'\x00')" || die "${FUNCNAME}(): Failure of extraction of files in intermediate installation images")

	for PYTHON_ABI in ${PYTHON_ABIS}; do
		if [[ ! -d "${intermediate_installation_images_directory}/${PYTHON_ABI}" ]]; then
			die "${FUNCNAME}(): Intermediate installation image for Python ABI '${PYTHON_ABI}' does not exist"
		fi

		pushd "${intermediate_installation_images_directory}/${PYTHON_ABI}${EPREFIX}" > /dev/null || die "pushd failed"

		for file in "${files[@]}"; do
			version_executable="0"
			for regex in "/usr/bin/.*" "/usr/sbin/.*" "${PYTHON_VERSIONED_SCRIPTS[@]}"; do
				if [[ "/${file}" =~ ^${regex}$ ]]; then
					version_executable="1"
					break
				fi
			done
			for regex in "${PYTHON_VERSIONED_EXECUTABLES[@]}"; do
				if [[ "/${file}" =~ ^${regex}$ ]]; then
					version_executable="2"
					break
				fi
			done
			if [[ "${version_executable}" != "0" ]]; then
				for regex in "${PYTHON_NONVERSIONED_EXECUTABLES[@]}"; do
					if [[ "/${file}" =~ ^${regex}$ ]]; then
						version_executable="0"
						break
					fi
				done
			fi

			[[ "${version_executable}" == "0" || ! -x "${file}" ]] && continue

			shebang="$(head -n1 "${file}")" || die "Extraction of shebang from '${file}' failed"

			if [[ "${version_executable}" == "2" ]]; then
				wrapper_scripts+=("${ED}${file}")
			elif [[ "${version_executable}" == "1" ]]; then
				if [[ "${shebang}" =~ ${_PYTHON_SHEBANG_BASE_PART_REGEX}([[:digit:]]+(\.[[:digit:]]+)?)?($|[[:space:]]+) ]]; then
					wrapper_scripts+=("${ED}${file}")
				else
					version_executable="0"
				fi
			fi

			[[ "${version_executable}" == "0" ]] && continue

			if [[ -e "${file}-${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): '${EPREFIX}/${file}-${PYTHON_ABI}' already exists"
			fi

			mv "${file}" "${file}-${PYTHON_ABI}" || die "Renaming of '${file}' failed"

			if [[ "${shebang}" =~ ${_PYTHON_SHEBANG_BASE_PART_REGEX}[[:digit:]]*($|[[:space:]]+) ]]; then
				python_convert_shebangs $([[ "${quiet}" == "1" ]] && echo --quiet) "${PYTHON_ABI}" "${file}-${PYTHON_ABI}"
			fi
		done

		popd > /dev/null || die "popd failed"

		cp -fr --preserve=all "${intermediate_installation_images_directory}/${PYTHON_ABI}/"* "${ED}" || die "Merging of intermediate installation image for Python ABI '${PYTHON_ABI} into installation image failed"
	done

	if [[ "${#wrapper_scripts[@]}" -ge 1 ]]; then
		rm -f "${T}/python_wrapper_scripts"

		for file in "${wrapper_scripts[@]}"; do
			echo -n "${file}" >> "${T}/python_wrapper_scripts"
			echo -en "\x00" >> "${T}/python_wrapper_scripts"
		done

		while read -d $'\0' -r file; do
			wrapper_scripts_set+=("${file}")
		done < <("$(PYTHON -f)" -c \
"import sys

if hasattr(sys.stdout, 'buffer'):
	# Python 3
	stdout = sys.stdout.buffer
else:
	# Python 2
	stdout = sys.stdout

files = set(open('${T}/python_wrapper_scripts', 'rb').read().rstrip(${b}'\x00').split(${b}'\x00'))

for file in sorted(files):
	stdout.write(file)
	stdout.write(${b}'\x00')" || die "${FUNCNAME}(): Failure of extraction of set of wrapper scripts")

		python_generate_wrapper_scripts $([[ "${quiet}" == "1" ]] && echo --quiet) "${wrapper_scripts_set[@]}"
	fi
}

# ================================================================================================
# ========= FUNCTIONS FOR PACKAGES NOT SUPPORTING INSTALLATION FOR MULTIPLE PYTHON ABIS ==========
# ================================================================================================

unset EPYTHON PYTHON_ABI

# @FUNCTION: python_set_active_version
# @USAGE: <Python_ABI|2|3>
# @DESCRIPTION:
# Set locally active version of Python.
# If Python_ABI argument is specified, then version of Python corresponding to Python_ABI is used.
# If 2 argument is specified, then active version of CPython 2 is used.
# If 3 argument is specified, then active version of CPython 3 is used.
#
# This function can be used only in pkg_setup() phase.
python_set_active_version() {
	# Check if phase is pkg_setup().
	[[ "${EBUILD_PHASE}" != "setup" ]] && die "${FUNCNAME}() can be used only in pkg_setup() phase"

	if _python_package_supporting_installation_for_multiple_python_abis; then
		die "${FUNCNAME}() cannot be used in ebuilds of packages supporting installation for multiple Python ABIs"
	fi

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	_python_initial_sanity_checks

	if [[ -z "${PYTHON_ABI}" ]]; then
		if [[ -n "$(_python_get_implementation --ignore-invalid "$1")" ]]; then
			# PYTHON_ABI variable is intended to be used only in ebuilds/eclasses,
			# so it does not need to be exported to subprocesses.
			PYTHON_ABI="$1"
			if ! _python_implementation && ! has_version "$(python_get_implementational_package)"; then
				die "${FUNCNAME}(): '$(python_get_implementational_package)' is not installed"
			fi
			export EPYTHON="$(PYTHON "$1")"
		elif [[ "$1" == "2" ]]; then
			if ! _python_implementation && ! has_version "=dev-lang/python-2*"; then
				die "${FUNCNAME}(): '=dev-lang/python-2*' is not installed"
			fi
			export EPYTHON="$(PYTHON -2)"
			PYTHON_ABI="${EPYTHON#python}"
			PYTHON_ABI="${PYTHON_ABI%%-*}"
		elif [[ "$1" == "3" ]]; then
			if ! _python_implementation && ! has_version "=dev-lang/python-3*"; then
				die "${FUNCNAME}(): '=dev-lang/python-3*' is not installed"
			fi
			export EPYTHON="$(PYTHON -3)"
			PYTHON_ABI="${EPYTHON#python}"
			PYTHON_ABI="${PYTHON_ABI%%-*}"
		else
			die "${FUNCNAME}(): Unrecognized argument '$1'"
		fi
	fi

	_python_final_sanity_checks

	# python-updater checks PYTHON_REQUESTED_ACTIVE_VERSION variable.
	PYTHON_REQUESTED_ACTIVE_VERSION="$1"
}

# @FUNCTION: python_need_rebuild
# @DESCRIPTION: Mark current package for rebuilding by python-updater after
# switching of active version of Python.
python_need_rebuild() {
	_python_check_python_pkg_setup_execution

	if _python_package_supporting_installation_for_multiple_python_abis; then
		die "${FUNCNAME}() cannot be used in ebuilds of packages supporting installation for multiple Python ABIs"
	fi

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	export PYTHON_NEED_REBUILD="$(PYTHON --ABI)"
}

# ================================================================================================
# ======================================= GETTER FUNCTIONS =======================================
# ================================================================================================

_PYTHON_ABI_EXTRACTION_COMMAND='import platform
import sys
sys.stdout.write(".".join(str(x) for x in sys.version_info[:2]))
if platform.system()[:4] == "Java":
	sys.stdout.write("-jython")'

_python_get_implementation() {
	local ignore_invalid="0"

	while (($#)); do
		case "$1" in
			--ignore-invalid)
				ignore_invalid="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	if [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+$ ]]; then
		echo "CPython"
	elif [[ "$1" =~ ^[[:digit:]]+\.[[:digit:]]+-jython$ ]]; then
		echo "Jython"
	else
		if [[ "${ignore_invalid}" == "0" ]]; then
			die "${FUNCNAME}(): Unrecognized Python ABI '$1'"
		fi
	fi
}

# @FUNCTION: PYTHON
# @USAGE: [-2] [-3] [--ABI] [-a|--absolute-path] [-f|--final-ABI] [--] <Python_ABI="${PYTHON_ABI}">
# @DESCRIPTION:
# Print filename of Python interpreter for specified Python ABI. If Python_ABI argument
# is ommitted, then PYTHON_ABI environment variable must be set and is used.
# If -2 option is specified, then active version of CPython 2 is used.
# If -3 option is specified, then active version of CPython 3 is used.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
# -2, -3 and --final-ABI options and Python_ABI argument cannot be specified simultaneously.
# If --ABI option is specified, then only specified Python ABI is printed instead of
# filename of Python interpreter.
# If --absolute-path option is specified, then absolute path to Python interpreter is printed.
# --ABI and --absolute-path options cannot be specified simultaneously.
PYTHON() {
	_python_check_python_pkg_setup_execution

	local ABI_output="0" absolute_path_output="0" final_ABI="0" PYTHON_ABI="${PYTHON_ABI}" python_interpreter python2="0" python3="0"

	while (($#)); do
		case "$1" in
			-2)
				python2="1"
				;;
			-3)
				python3="1"
				;;
			--ABI)
				ABI_output="1"
				;;
			-a|--absolute-path)
				absolute_path_output="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "${ABI_output}" == "1" && "${absolute_path_output}" == "1" ]]; then
		die "${FUNCNAME}(): '--ABI' and '--absolute-path' options cannot be specified simultaneously"
	fi

	if [[ "$((${python2} + ${python3} + ${final_ABI}))" -gt 1 ]]; then
		die "${FUNCNAME}(): '-2', '-3' or '--final-ABI' options cannot be specified simultaneously"
	fi

	if [[ "$#" -eq 0 ]]; then
		if [[ "${final_ABI}" == "1" ]]; then
			if ! _python_package_supporting_installation_for_multiple_python_abis; then
				die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
			fi
			_python_calculate_PYTHON_ABIS
			PYTHON_ABI="${PYTHON_ABIS##* }"
		elif [[ "${python2}" == "1" ]]; then
			PYTHON_ABI="$(eselect python show --python2 --ABI)"
			if [[ -z "${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): Active version of CPython 2 not set"
			elif [[ "${PYTHON_ABI}" != "2."* ]]; then
				die "${FUNCNAME}(): Internal error in \`eselect python show --python2\`"
			fi
		elif [[ "${python3}" == "1" ]]; then
			PYTHON_ABI="$(eselect python show --python3 --ABI)"
			if [[ -z "${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): Active version of CPython 3 not set"
			elif [[ "${PYTHON_ABI}" != "3."* ]]; then
				die "${FUNCNAME}(): Internal error in \`eselect python show --python3\`"
			fi
		elif _python_package_supporting_installation_for_multiple_python_abis; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="$("${EPREFIX}/usr/bin/python" -c "${_PYTHON_ABI_EXTRACTION_COMMAND}")"
			if [[ -z "${PYTHON_ABI}" ]]; then
				die "${FUNCNAME}(): Failure of extraction of locally active version of Python"
			fi
		fi
	elif [[ "$#" -eq 1 ]]; then
		if [[ "${final_ABI}" == "1" ]]; then
			die "${FUNCNAME}(): '--final-ABI' option and Python ABI cannot be specified simultaneously"
		fi
		if [[ "${python2}" == "1" ]]; then
			die "${FUNCNAME}(): '-2' option and Python ABI cannot be specified simultaneously"
		fi
		if [[ "${python3}" == "1" ]]; then
			die "${FUNCNAME}(): '-3' option and Python ABI cannot be specified simultaneously"
		fi
		PYTHON_ABI="$1"
	else
		die "${FUNCNAME}(): Invalid usage"
	fi

	if [[ "${ABI_output}" == "1" ]]; then
		echo -n "${PYTHON_ABI}"
		return
	else
		if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
			python_interpreter="python${PYTHON_ABI}"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
			python_interpreter="jython${PYTHON_ABI%-jython}"
		fi

		if [[ "${absolute_path_output}" == "1" ]]; then
			echo -n "${EPREFIX}/usr/bin/${python_interpreter}"
		else
			echo -n "${python_interpreter}"
		fi
	fi

	if [[ -n "${ABI}" && "${ABI}" != "${DEFAULT_ABI}" && "${DEFAULT_ABI}" != "default" ]]; then
		echo -n "-${ABI}"
	fi
}

# @FUNCTION: python_get_implementation
# @USAGE: [-f|--final-ABI]
# @DESCRIPTION:
# Print name of Python implementation.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_implementation() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_package_supporting_installation_for_multiple_python_abis; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	echo "$(_python_get_implementation "${PYTHON_ABI}")"
}

# @FUNCTION: python_get_implementational_package
# @USAGE: [-f|--final-ABI]
# @DESCRIPTION:
# Print category, name and slot of package providing Python implementation.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_implementational_package() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_package_supporting_installation_for_multiple_python_abis; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "${EAPI:-0}" == "0" ]]; then
		if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
			echo "=dev-lang/python-${PYTHON_ABI}*"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
			echo "=dev-java/jython-${PYTHON_ABI%-jython}*"
		fi
	else
		if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
			echo "dev-lang/python:${PYTHON_ABI}"
		elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
			echo "dev-java/jython:${PYTHON_ABI%-jython}"
		fi
	fi
}

# @FUNCTION: python_get_includedir
# @USAGE: [-b|--base-path] [-f|--final-ABI]
# @DESCRIPTION:
# Print path to Python include directory.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_includedir() {
	_python_check_python_pkg_setup_execution

	local base_path="0" final_ABI="0" prefix PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-b|--base-path)
				base_path="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${base_path}" == "0" ]]; then
		prefix="/"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_package_supporting_installation_for_multiple_python_abis; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		echo "${prefix}usr/include/python${PYTHON_ABI}"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		echo "${prefix}usr/share/jython-${PYTHON_ABI%-jython}/Include"
	fi
}

# @FUNCTION: python_get_libdir
# @USAGE: [-b|--base-path] [-f|--final-ABI]
# @DESCRIPTION:
# Print path to Python library directory.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_libdir() {
	_python_check_python_pkg_setup_execution

	local base_path="0" final_ABI="0" prefix PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-b|--base-path)
				base_path="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${base_path}" == "0" ]]; then
		prefix="/"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_package_supporting_installation_for_multiple_python_abis; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		echo "${prefix}usr/$(get_libdir)/python${PYTHON_ABI}"
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		echo "${prefix}usr/share/jython-${PYTHON_ABI%-jython}/Lib"
	fi
}

# @FUNCTION: python_get_sitedir
# @USAGE: [-b|--base-path] [-f|--final-ABI]
# @DESCRIPTION:
# Print path to Python site-packages directory.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_sitedir() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" options=()

	while (($#)); do
		case "$1" in
			-b|--base-path)
				options+=("$1")
				;;
			-f|--final-ABI)
				final_ABI="1"
				options+=("$1")
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi
	else
		if _python_package_supporting_installation_for_multiple_python_abis && ! _python_abi-specific_local_scope; then
			die "${FUNCNAME}() should be used in ABI-specific local scope"
		fi
	fi

	echo "$(python_get_libdir "${options[@]}")/site-packages"
}

# @FUNCTION: python_get_library
# @USAGE: [-b|--base-path] [-f|--final-ABI] [-l|--linker-option]
# @DESCRIPTION:
# Print path to Python library.
# If --base-path option is specified, then path not prefixed with "/" is printed.
# If --linker-option is specified, then "-l${library}" linker option is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_library() {
	_python_check_python_pkg_setup_execution

	local base_path="0" final_ABI="0" linker_option="0" prefix PYTHON_ABI="${PYTHON_ABI}"

	while (($#)); do
		case "$1" in
			-b|--base-path)
				base_path="1"
				;;
			-f|--final-ABI)
				final_ABI="1"
				;;
			-l|--linker-option)
				linker_option="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "${base_path}" == "0" ]]; then
		prefix="/"
	fi

	if [[ "${base_path}" == "1" && "${linker_option}" == "1" ]]; then
		die "${FUNCNAME}(): '--base-path' and '--linker-option' options cannot be specified simultaneously"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi
		PYTHON_ABI="$(PYTHON -f --ABI)"
	else
		if _python_package_supporting_installation_for_multiple_python_abis; then
			if ! _python_abi-specific_local_scope; then
				die "${FUNCNAME}() should be used in ABI-specific local scope"
			fi
		else
			PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"
		fi
	fi

	if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
		if [[ "${linker_option}" == "1" ]]; then
			echo "-lpython${PYTHON_ABI}"
		else
			echo "${prefix}usr/$(get_libdir)/libpython${PYTHON_ABI}$(get_libname)"
		fi
	elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
		die "${FUNCNAME}(): Jython does not have shared library"
	fi
}

# @FUNCTION: python_get_version
# @USAGE: [-f|--final-ABI] [--full] [--major] [--minor] [--micro]
# @DESCRIPTION:
# Print Python version.
# --full, --major, --minor and --micro options cannot be specified simultaneously.
# If --full, --major, --minor and --micro options are not specified, then "${major_version}.${minor_version}" is printed.
# If --final-ABI option is specified, then final ABI from the list of enabled ABIs is used.
python_get_version() {
	_python_check_python_pkg_setup_execution

	local final_ABI="0" full="0" major="0" minor="0" micro="0" python_command

	while (($#)); do
		case "$1" in
			-f|--final-ABI)
				final_ABI="1"
				;;
			--full)
				full="1"
				;;
			--major)
				major="1"
				;;
			--minor)
				minor="1"
				;;
			--micro)
				micro="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				die "${FUNCNAME}(): Invalid usage"
				;;
		esac
		shift
	done

	if [[ "$((${full} + ${major} + ${minor} + ${micro}))" -gt 1 ]]; then
		die "${FUNCNAME}(): '--full', '--major', '--minor' or '--micro' options cannot be specified simultaneously"
	fi

	if [[ "${full}" == "1" ]]; then
		python_command="from sys import version_info; print('.'.join(str(x) for x in version_info[:3]))"
	elif [[ "${major}" == "1" ]]; then
		python_command="from sys import version_info; print(version_info[0])"
	elif [[ "${minor}" == "1" ]]; then
		python_command="from sys import version_info; print(version_info[1])"
	elif [[ "${micro}" == "1" ]]; then
		python_command="from sys import version_info; print(version_info[2])"
	else
		if [[ -n "${PYTHON_ABI}" && "${final_ABI}" == "0" ]]; then
			if [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "CPython" ]]; then
				echo "${PYTHON_ABI}"
			elif [[ "$(_python_get_implementation "${PYTHON_ABI}")" == "Jython" ]]; then
				echo "${PYTHON_ABI%-jython}"
			fi
			return
		fi
		python_command="from sys import version_info; print('.'.join(str(x) for x in version_info[:2]))"
	fi

	if [[ "${final_ABI}" == "1" ]]; then
		if ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--final-ABI' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi
		"$(PYTHON -f)" -c "${python_command}"
	else
		if _python_package_supporting_installation_for_multiple_python_abis && ! _python_abi-specific_local_scope; then
			die "${FUNCNAME}() should be used in ABI-specific local scope"
		fi
		"$(PYTHON ${PYTHON_ABI})" -c "${python_command}"
	fi
}

# ================================================================================================
# ================================ FUNCTIONS FOR RUNNING OF TESTS ================================
# ================================================================================================

# @ECLASS-VARIABLE: PYTHON_TEST_VERBOSITY
# @DESCRIPTION:
# User-configurable verbosity of tests of Python modules.
# Supported values: 0, 1, 2, 3, 4.
PYTHON_TEST_VERBOSITY="${PYTHON_TEST_VERBOSITY:-1}"

_python_test_hook() {
	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi

	if _python_package_supporting_installation_for_multiple_python_abis && [[ "$(type -t "${FUNCNAME[3]}_$1_hook")" == "function" ]]; then
		"${FUNCNAME[3]}_$1_hook"
	fi
}

# @FUNCTION: python_execute_nosetests
# @USAGE: [-P|--PYTHONPATH PYTHONPATH] [-s|--separate-build-dirs] [--] [arguments]
# @DESCRIPTION:
# Execute nosetests for all enabled Python ABIs.
# In ebuilds of packages supporting installation for multiple Python ABIs, this function calls
# python_execute_nosetests_pre_hook() and python_execute_nosetests_post_hook(), if they are defined.
python_execute_nosetests() {
	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local PYTHONPATH_template= separate_build_dirs=

	while (($#)); do
		case "$1" in
			-P|--PYTHONPATH)
				PYTHONPATH_template="$2"
				shift
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	python_test_function() {
		local evaluated_PYTHONPATH

		eval "evaluated_PYTHONPATH=\"${PYTHONPATH_template}\""

		_python_test_hook pre

		if [[ -n "${evaluated_PYTHONPATH}" ]]; then
			echo ${_BOLD}PYTHONPATH="${evaluated_PYTHONPATH}" nosetests --verbosity="${PYTHON_TEST_VERBOSITY}" "$@"${_NORMAL}
			PYTHONPATH="${evaluated_PYTHONPATH}" nosetests --verbosity="${PYTHON_TEST_VERBOSITY}" "$@" || return "$?"
		else
			echo ${_BOLD}nosetests --verbosity="${PYTHON_TEST_VERBOSITY}" "$@"${_NORMAL}
			nosetests --verbosity="${PYTHON_TEST_VERBOSITY}" "$@" || return "$?"
		fi

		_python_test_hook post
	}
	if _python_package_supporting_installation_for_multiple_python_abis; then
		python_execute_function ${separate_build_dirs:+-s} python_test_function "$@"
	else
		if [[ -n "${separate_build_dirs}" ]]; then
			die "${FUNCNAME}(): Invalid usage"
		fi
		python_test_function "$@" || die "Testing failed"
	fi

	unset -f python_test_function
}

# @FUNCTION: python_execute_py.test
# @USAGE: [-P|--PYTHONPATH PYTHONPATH] [-s|--separate-build-dirs] [--] [arguments]
# @DESCRIPTION:
# Execute py.test for all enabled Python ABIs.
# In ebuilds of packages supporting installation for multiple Python ABIs, this function calls
# python_execute_py.test_pre_hook() and python_execute_py.test_post_hook(), if they are defined.
python_execute_py.test() {
	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local PYTHONPATH_template= separate_build_dirs=

	while (($#)); do
		case "$1" in
			-P|--PYTHONPATH)
				PYTHONPATH_template="$2"
				shift
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	python_test_function() {
		local evaluated_PYTHONPATH

		eval "evaluated_PYTHONPATH=\"${PYTHONPATH_template}\""

		_python_test_hook pre

		if [[ -n "${evaluated_PYTHONPATH}" ]]; then
			echo ${_BOLD}PYTHONPATH="${evaluated_PYTHONPATH}" py.test $([[ "${PYTHON_TEST_VERBOSITY}" -ge 2 ]] && echo -v) "$@"${_NORMAL}
			PYTHONPATH="${evaluated_PYTHONPATH}" py.test $([[ "${PYTHON_TEST_VERBOSITY}" -ge 2 ]] && echo -v) "$@" || return "$?"
		else
			echo ${_BOLD}py.test $([[ "${PYTHON_TEST_VERBOSITY}" -gt 1 ]] && echo -v) "$@"${_NORMAL}
			py.test $([[ "${PYTHON_TEST_VERBOSITY}" -gt 1 ]] && echo -v) "$@" || return "$?"
		fi

		_python_test_hook post
	}
	if _python_package_supporting_installation_for_multiple_python_abis; then
		python_execute_function ${separate_build_dirs:+-s} python_test_function "$@"
	else
		if [[ -n "${separate_build_dirs}" ]]; then
			die "${FUNCNAME}(): Invalid usage"
		fi
		python_test_function "$@" || die "Testing failed"
	fi

	unset -f python_test_function
}

# @FUNCTION: python_execute_trial
# @USAGE: [-P|--PYTHONPATH PYTHONPATH] [-s|--separate-build-dirs] [--] [arguments]
# @DESCRIPTION:
# Execute trial for all enabled Python ABIs.
# In ebuilds of packages supporting installation for multiple Python ABIs, this function
# calls python_execute_trial_pre_hook() and python_execute_trial_post_hook(), if they are defined.
python_execute_trial() {
	_python_check_python_pkg_setup_execution
	_python_set_color_variables

	local PYTHONPATH_template= separate_build_dirs=

	while (($#)); do
		case "$1" in
			-P|--PYTHONPATH)
				PYTHONPATH_template="$2"
				shift
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	python_test_function() {
		local evaluated_PYTHONPATH

		eval "evaluated_PYTHONPATH=\"${PYTHONPATH_template}\""

		_python_test_hook pre

		if [[ -n "${evaluated_PYTHONPATH}" ]]; then
			echo ${_BOLD}PYTHONPATH="${evaluated_PYTHONPATH}" trial $([[ "${PYTHON_TEST_VERBOSITY}" -ge 4 ]] && echo --spew) "$@"${_NORMAL}
			PYTHONPATH="${evaluated_PYTHONPATH}" trial $([[ "${PYTHON_TEST_VERBOSITY}" -ge 4 ]] && echo --spew) "$@" || return "$?"
		else
			echo ${_BOLD}trial $([[ "${PYTHON_TEST_VERBOSITY}" -ge 4 ]] && echo --spew) "$@"${_NORMAL}
			trial $([[ "${PYTHON_TEST_VERBOSITY}" -ge 4 ]] && echo --spew) "$@" || return "$?"
		fi

		_python_test_hook post
	}
	if _python_package_supporting_installation_for_multiple_python_abis; then
		python_execute_function ${separate_build_dirs:+-s} python_test_function "$@"
	else
		if [[ -n "${separate_build_dirs}" ]]; then
			die "${FUNCNAME}(): Invalid usage"
		fi
		python_test_function "$@" || die "Testing failed"
	fi

	unset -f python_test_function
}

# ================================================================================================
# ======================= FUNCTIONS FOR HANDLING OF BYTE-COMPILED MODULES ========================
# ================================================================================================

# @FUNCTION: python_enable_pyc
# @DESCRIPTION:
# Tell Python to automatically recompile modules to .pyc/.pyo if the
# timestamps/version stamps have changed.
python_enable_pyc() {
	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	unset PYTHONDONTWRITEBYTECODE
}

# @FUNCTION: python_disable_pyc
# @DESCRIPTION:
# Tell Python not to automatically recompile modules to .pyc/.pyo
# even if the timestamps/version stamps do not match. This is done
# to protect sandbox.
python_disable_pyc() {
	_python_check_python_pkg_setup_execution

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	export PYTHONDONTWRITEBYTECODE="1"
}

_python_clean_compiled_modules() {
	_python_initialize_prefix_variables
	_python_set_color_variables

	[[ "${FUNCNAME[1]}" =~ ^(python_mod_optimize|python_mod_cleanup)$ ]] || die "${FUNCNAME}(): Invalid usage"

	local base_module_name compiled_file compiled_files=() dir path py_file root

	# Strip trailing slash from EROOT.
	root="${EROOT%/}"

	for path in "$@"; do
		compiled_files=()
		if [[ -d "${path}" ]]; then
			while read -d $'\0' -r compiled_file; do
				compiled_files+=("${compiled_file}")
			done < <(find "${path}" "(" -name "*.py[co]" -o -name "*\$py.class" ")" -print0)

			if [[ "${EBUILD_PHASE}" == "postrm" ]]; then
				# Delete empty child directories.
				find "${path}" -type d | sort -r | while read -r dir; do
					if rmdir "${dir}" 2> /dev/null; then
						echo "${_CYAN}<<< ${dir}${_NORMAL}"
					fi
				done
			fi
		elif [[ "${path}" == *.py ]]; then
			base_module_name="${path##*/}"
			base_module_name="${base_module_name%.py}"
			if [[ -d "${path%/*}/__pycache__" ]]; then
				while read -d $'\0' -r compiled_file; do
					compiled_files+=("${compiled_file}")
				done < <(find "${path%/*}/__pycache__" "(" -name "${base_module_name}.*.py[co]" -o -name "${base_module_name}\$py.class" ")" -print0)
			fi
			compiled_files+=("${path}c" "${path}o" "${path%.py}\$py.class")
		fi

		for compiled_file in "${compiled_files[@]}"; do
			[[ ! -f "${compiled_file}" ]] && continue
			dir="${compiled_file%/*}"
			dir="${dir##*/}"
			if [[ "${compiled_file}" == *.py[co] ]]; then
				if [[ "${dir}" == "__pycache__" ]]; then
					base_module_name="${compiled_file##*/}"
					base_module_name="${base_module_name%.*py[co]}"
					base_module_name="${base_module_name%.*}"
					py_file="${compiled_file%__pycache__/*}${base_module_name}.py"
				else
					py_file="${compiled_file%[co]}"
				fi
				if [[ "${EBUILD_PHASE}" == "postinst" ]]; then
					[[ -f "${py_file}" && "${compiled_file}" -nt "${py_file}" ]] && continue
				else
					[[ -f "${py_file}" ]] && continue
				fi
				echo "${_BLUE}<<< ${compiled_file%[co]}[co]${_NORMAL}"
				rm -f "${compiled_file%[co]}"[co]
			elif [[ "${compiled_file}" == *\$py.class ]]; then
				if [[ "${dir}" == "__pycache__" ]]; then
					base_module_name="${compiled_file##*/}"
					base_module_name="${base_module_name%\$py.class}"
					py_file="${compiled_file%__pycache__/*}${base_module_name}.py"
				else
					py_file="${compiled_file%\$py.class}.py"
				fi
				if [[ "${EBUILD_PHASE}" == "postinst" ]]; then
					[[ -f "${py_file}" && "${compiled_file}" -nt "${py_file}" ]] && continue
				else
					[[ -f "${py_file}" ]] && continue
				fi
				echo "${_BLUE}<<< ${compiled_file}${_NORMAL}"
				rm -f "${compiled_file}"
			else
				die "${FUNCNAME}(): Unrecognized file type: '${compiled_file}'"
			fi

			# Delete empty parent directories.
			dir="${compiled_file%/*}"
			while [[ "${dir}" != "${root}" ]]; do
				if rmdir "${dir}" 2> /dev/null; then
					echo "${_CYAN}<<< ${dir}${_NORMAL}"
				else
					break
				fi
				dir="${dir%/*}"
			done
		done
	done
}

# @FUNCTION: python_mod_optimize
# @USAGE: [--allow-evaluated-non-sitedir-paths] [-d directory] [-f] [-l] [-q] [-x regular_expression] [--] <file|directory> [files|directories]
# @DESCRIPTION:
# Byte-compile specified Python modules.
# -d, -f, -l, -q and -x options passed to this function are passed to compileall.py.
#
# This function can be used only in pkg_postinst() phase.
python_mod_optimize() {
	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	# Check if phase is pkg_postinst().
	[[ "${EBUILD_PHASE}" != "postinst" ]] && die "${FUNCNAME}() can be used only in pkg_postinst() phase"

	if ! has "${EAPI:-0}" 0 1 2 || _python_package_supporting_installation_for_multiple_python_abis || _python_implementation || [[ "${CATEGORY}/${PN}" == "sys-apps/portage" ]]; then
		# PYTHON_ABI variable cannot be local in packages not supporting installation for multiple Python ABIs.
		local allow_evaluated_non_sitedir_paths="0" dir dirs=() evaluated_dirs=() evaluated_files=() file files=() iterated_PYTHON_ABIS options=() other_dirs=() other_files=() previous_PYTHON_ABI="${PYTHON_ABI}" return_code root site_packages_dirs=() site_packages_files=()

		if _python_package_supporting_installation_for_multiple_python_abis; then
			if has "${EAPI:-0}" 0 1 2 3 && [[ -z "${PYTHON_ABIS}" ]]; then
				die "${FUNCNAME}(): python_pkg_setup() or python_execute_function() not called"
			fi
			iterated_PYTHON_ABIS="${PYTHON_ABIS}"
		else
			if has "${EAPI:-0}" 0 1 2 3; then
				iterated_PYTHON_ABIS="${PYTHON_ABI:=$(PYTHON --ABI)}"
			else
				iterated_PYTHON_ABIS="${PYTHON_ABI}"
			fi
		fi

		# Strip trailing slash from EROOT.
		root="${EROOT%/}"

		while (($#)); do
			case "$1" in
				--allow-evaluated-non-sitedir-paths)
					allow_evaluated_non_sitedir_paths="1"
					;;
				-l|-f|-q)
					options+=("$1")
					;;
				-d|-x)
					options+=("$1" "$2")
					shift
					;;
				--)
					shift
					break
					;;
				-*)
					die "${FUNCNAME}(): Unrecognized option '$1'"
					;;
				*)
					break
					;;
			esac
			shift
		done

		if [[ "${allow_evaluated_non_sitedir_paths}" == "1" ]] && ! _python_package_supporting_installation_for_multiple_python_abis; then
			die "${FUNCNAME}(): '--allow-evaluated-non-sitedir-paths' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
		fi

		if [[ "$#" -eq 0 ]]; then
			die "${FUNCNAME}(): Missing files or directories"
		fi

		while (($#)); do
			if [[ "$1" =~ ^($|(\.|\.\.|/)($|/)) ]]; then
				die "${FUNCNAME}(): Invalid argument '$1'"
			elif ! _python_implementation && [[ "$1" =~ ^/usr/lib(32|64)?/python[[:digit:]]+\.[[:digit:]]+ ]]; then
				die "${FUNCNAME}(): Paths of directories / files in site-packages directories must be relative to site-packages directories"
			elif [[ "$1" =~ ^/ ]]; then
				if _python_package_supporting_installation_for_multiple_python_abis; then
					if [[ "${allow_evaluated_non_sitedir_paths}" != "1" ]]; then
						die "${FUNCNAME}(): Absolute paths cannot be used in ebuilds of packages supporting installation for multiple Python ABIs"
					fi
					if [[ "$1" != *\$* ]]; then
						die "${FUNCNAME}(): '$1' has invalid syntax"
					fi
					if [[ "$1" == *.py ]]; then
						evaluated_files+=("$1")
					else
						evaluated_dirs+=("$1")
					fi
				else
					if [[ -d "${root}$1" ]]; then
						other_dirs+=("${root}$1")
					elif [[ -f "${root}$1" ]]; then
						other_files+=("${root}$1")
					elif [[ -e "${root}$1" ]]; then
						eerror "${FUNCNAME}(): '${root}$1' is not a regular file or a directory"
					else
						eerror "${FUNCNAME}(): '${root}$1' does not exist"
					fi
				fi
			else
				for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
					if [[ -d "${root}$(python_get_sitedir)/$1" ]]; then
						site_packages_dirs+=("$1")
						break
					elif [[ -f "${root}$(python_get_sitedir)/$1" ]]; then
						site_packages_files+=("$1")
						break
					elif [[ -e "${root}$(python_get_sitedir)/$1" ]]; then
						eerror "${FUNCNAME}(): '$1' is not a regular file or a directory"
					else
						eerror "${FUNCNAME}(): '$1' does not exist"
					fi
				done
			fi
			shift
		done

		# Set additional options.
		options+=("-q")

		for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
			if ((${#site_packages_dirs[@]})) || ((${#site_packages_files[@]})) || ((${#evaluated_dirs[@]})) || ((${#evaluated_files[@]})); then
				return_code="0"
				ebegin "Compilation and optimization of Python modules for $(python_get_implementation) $(python_get_version)"
				if ((${#site_packages_dirs[@]})) || ((${#evaluated_dirs[@]})); then
					for dir in "${site_packages_dirs[@]}"; do
						dirs+=("${root}$(python_get_sitedir)/${dir}")
					done
					for dir in "${evaluated_dirs[@]}"; do
						eval "dirs+=(\"\${root}${dir}\")"
					done
					"$(PYTHON)" "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${dirs[@]}" || return_code="1"
					if [[ "$(_python_get_implementation "${PYTHON_ABI}")" != "Jython" ]]; then
						"$(PYTHON)" -O "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${dirs[@]}" &> /dev/null || return_code="1"
					fi
					_python_clean_compiled_modules "${dirs[@]}"
				fi
				if ((${#site_packages_files[@]})) || ((${#evaluated_files[@]})); then
					for file in "${site_packages_files[@]}"; do
						files+=("${root}$(python_get_sitedir)/${file}")
					done
					for file in "${evaluated_files[@]}"; do
						eval "files+=(\"\${root}${file}\")"
					done
					"$(PYTHON)" "${root}$(python_get_libdir)/py_compile.py" "${files[@]}" || return_code="1"
					if [[ "$(_python_get_implementation "${PYTHON_ABI}")" != "Jython" ]]; then
						"$(PYTHON)" -O "${root}$(python_get_libdir)/py_compile.py" "${files[@]}" &> /dev/null || return_code="1"
					fi
					_python_clean_compiled_modules "${files[@]}"
				fi
				eend "${return_code}"
			fi
			unset dirs files
		done

		if _python_package_supporting_installation_for_multiple_python_abis; then
			# Restore previous value of PYTHON_ABI.
			if [[ -n "${previous_PYTHON_ABI}" ]]; then
				PYTHON_ABI="${previous_PYTHON_ABI}"
			else
				unset PYTHON_ABI
			fi
		fi

		if ((${#other_dirs[@]})) || ((${#other_files[@]})); then
			return_code="0"
			ebegin "Compilation and optimization of Python modules placed outside of site-packages directories for $(python_get_implementation) $(python_get_version)"
			if ((${#other_dirs[@]})); then
				"$(PYTHON ${PYTHON_ABI})" "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${other_dirs[@]}" || return_code="1"
				if [[ "$(_python_get_implementation "${PYTHON_ABI}")" != "Jython" ]]; then
					"$(PYTHON ${PYTHON_ABI})" -O "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${other_dirs[@]}" &> /dev/null || return_code="1"
				fi
				_python_clean_compiled_modules "${other_dirs[@]}"
			fi
			if ((${#other_files[@]})); then
				"$(PYTHON ${PYTHON_ABI})" "${root}$(python_get_libdir)/py_compile.py" "${other_files[@]}" || return_code="1"
				if [[ "$(_python_get_implementation "${PYTHON_ABI}")" != "Jython" ]]; then
					"$(PYTHON ${PYTHON_ABI})" -O "${root}$(python_get_libdir)/py_compile.py" "${other_files[@]}" &> /dev/null || return_code="1"
				fi
				_python_clean_compiled_modules "${other_files[@]}"
			fi
			eend "${return_code}"
		fi
	else
		# Deprecated part of python_mod_optimize()
		# ewarn
		# ewarn "Deprecation Warning: Usage of ${FUNCNAME}() in packages not supporting installation"
		# ewarn "for multiple Python ABIs in EAPI <=2 is deprecated and will be disallowed on 2011-06-01."
		# ewarn "Use EAPI >=3 and call ${FUNCNAME}() with paths having appropriate syntax."
		# ewarn "The ebuild needs to be fixed. Please report a bug, if it has not been already reported."
		# ewarn

		local myroot mydirs=() myfiles=() myopts=() return_code="0"

		# strip trailing slash
		myroot="${EROOT%/}"

		# respect EROOT and options passed to compileall.py
		while (($#)); do
			case "$1" in
				-l|-f|-q)
					myopts+=("$1")
					;;
				-d|-x)
					myopts+=("$1" "$2")
					shift
					;;
				--)
					shift
					break
					;;
				-*)
					die "${FUNCNAME}(): Unrecognized option '$1'"
					;;
				*)
					break
					;;
			esac
			shift
		done

		if [[ "$#" -eq 0 ]]; then
			die "${FUNCNAME}(): Missing files or directories"
		fi

		while (($#)); do
			if [[ "$1" =~ ^($|(\.|\.\.|/)($|/)) ]]; then
				die "${FUNCNAME}(): Invalid argument '$1'"
			elif [[ -d "${myroot}/${1#/}" ]]; then
				mydirs+=("${myroot}/${1#/}")
			elif [[ -f "${myroot}/${1#/}" ]]; then
				myfiles+=("${myroot}/${1#/}")
			elif [[ -e "${myroot}/${1#/}" ]]; then
				eerror "${FUNCNAME}(): ${myroot}/${1#/} is not a regular file or directory"
			else
				eerror "${FUNCNAME}(): ${myroot}/${1#/} does not exist"
			fi
			shift
		done

		# set additional opts
		myopts+=(-q)

		PYTHON_ABI="${PYTHON_ABI:-$(PYTHON --ABI)}"

		ebegin "Compilation and optimization of Python modules for $(python_get_implementation) $(python_get_version)"
		if ((${#mydirs[@]})); then
			"$(PYTHON ${PYTHON_ABI})" "${myroot}$(python_get_libdir)/compileall.py" "${myopts[@]}" "${mydirs[@]}" || return_code="1"
			"$(PYTHON ${PYTHON_ABI})" -O "${myroot}$(python_get_libdir)/compileall.py" "${myopts[@]}" "${mydirs[@]}" &> /dev/null || return_code="1"
			_python_clean_compiled_modules "${mydirs[@]}"
		fi

		if ((${#myfiles[@]})); then
			"$(PYTHON ${PYTHON_ABI})" "${myroot}$(python_get_libdir)/py_compile.py" "${myfiles[@]}" || return_code="1"
			"$(PYTHON ${PYTHON_ABI})" -O "${myroot}$(python_get_libdir)/py_compile.py" "${myfiles[@]}" &> /dev/null || return_code="1"
			_python_clean_compiled_modules "${myfiles[@]}"
		fi

		eend "${return_code}"
	fi
}

# @FUNCTION: python_mod_cleanup
# @USAGE: [--allow-evaluated-non-sitedir-paths] [--] <file|directory> [files|directories]
# @DESCRIPTION:
# Delete orphaned byte-compiled Python modules corresponding to specified Python modules.
#
# This function can be used only in pkg_postrm() phase.
python_mod_cleanup() {
	_python_check_python_pkg_setup_execution
	_python_initialize_prefix_variables

	local allow_evaluated_non_sitedir_paths="0" dir iterated_PYTHON_ABIS PYTHON_ABI="${PYTHON_ABI}" root search_paths=() sitedir

	# Check if phase is pkg_postrm().
	[[ "${EBUILD_PHASE}" != "postrm" ]] && die "${FUNCNAME}() can be used only in pkg_postrm() phase"

	if _python_package_supporting_installation_for_multiple_python_abis; then
		if has "${EAPI:-0}" 0 1 2 3 && [[ -z "${PYTHON_ABIS}" ]]; then
			die "${FUNCNAME}(): python_pkg_setup() or python_execute_function() not called"
		fi
		iterated_PYTHON_ABIS="${PYTHON_ABIS}"
	else
		if has "${EAPI:-0}" 0 1 2 3; then
			iterated_PYTHON_ABIS="${PYTHON_ABI:-$(PYTHON --ABI)}"
		else
			iterated_PYTHON_ABIS="${PYTHON_ABI}"
		fi
	fi

	# Strip trailing slash from EROOT.
	root="${EROOT%/}"

	while (($#)); do
		case "$1" in
			--allow-evaluated-non-sitedir-paths)
				allow_evaluated_non_sitedir_paths="1"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "${allow_evaluated_non_sitedir_paths}" == "1" ]] && ! _python_package_supporting_installation_for_multiple_python_abis; then
		die "${FUNCNAME}(): '--allow-evaluated-non-sitedir-paths' option cannot be used in ebuilds of packages not supporting installation for multiple Python ABIs"
	fi

	if [[ "$#" -eq 0 ]]; then
		die "${FUNCNAME}(): Missing files or directories"
	fi

	if ! has "${EAPI:-0}" 0 1 2 || _python_package_supporting_installation_for_multiple_python_abis || _python_implementation || [[ "${CATEGORY}/${PN}" == "sys-apps/portage" ]]; then
		while (($#)); do
			if [[ "$1" =~ ^($|(\.|\.\.|/)($|/)) ]]; then
				die "${FUNCNAME}(): Invalid argument '$1'"
			elif ! _python_implementation && [[ "$1" =~ ^/usr/lib(32|64)?/python[[:digit:]]+\.[[:digit:]]+ ]]; then
				die "${FUNCNAME}(): Paths of directories / files in site-packages directories must be relative to site-packages directories"
			elif [[ "$1" =~ ^/ ]]; then
				if _python_package_supporting_installation_for_multiple_python_abis; then
					if [[ "${allow_evaluated_non_sitedir_paths}" != "1" ]]; then
						die "${FUNCNAME}(): Absolute paths cannot be used in ebuilds of packages supporting installation for multiple Python ABIs"
					fi
					if [[ "$1" != *\$* ]]; then
						die "${FUNCNAME}(): '$1' has invalid syntax"
					fi
					for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
						eval "search_paths+=(\"\${root}$1\")"
					done
				else
					search_paths+=("${root}$1")
				fi
			else
				for PYTHON_ABI in ${iterated_PYTHON_ABIS}; do
					search_paths+=("${root}$(python_get_sitedir)/$1")
				done
			fi
			shift
		done
	else
		# Deprecated part of python_mod_cleanup()
		# ewarn
		# ewarn "Deprecation Warning: Usage of ${FUNCNAME}() in packages not supporting installation"
		# ewarn "for multiple Python ABIs in EAPI <=2 is deprecated and will be disallowed on 2011-06-01."
		# ewarn "Use EAPI >=3 and call ${FUNCNAME}() with paths having appropriate syntax."
		# ewarn "The ebuild needs to be fixed. Please report a bug, if it has not been already reported."
		# ewarn

		search_paths=("${@#/}")
		search_paths=("${search_paths[@]/#/${root}/}")
	fi

	_python_clean_compiled_modules "${search_paths[@]}"
}

# ================================================================================================
# ===================================== DEPRECATED FUNCTIONS =====================================
# ================================================================================================

# Scheduled for deletion on 2011-01-01.
python_version() {
	eerror "Use PYTHON() instead of python variable. Use python_get_*() instead of PYVER* variables."
	die "${FUNCNAME}() is banned"
}

# Scheduled for deletion on 2011-01-01.
python_mod_exists() {
	eerror "Use USE dependencies and/or has_version() instead of ${FUNCNAME}()."
	die "${FUNCNAME}() is banned"
}

# Scheduled for deletion on 2011-01-01.
python_tkinter_exists() {
	eerror "Use PYTHON_USE_WITH=\"xml\" and python_pkg_setup() instead of ${FUNCNAME}()."
	die "${FUNCNAME}() is banned"
}

# Scheduled for deletion on 2011-04-01.
python_mod_compile() {
	eerror "Use python_mod_optimize() instead of ${FUNCNAME}()."
	die "${FUNCNAME}() is banned"
}
