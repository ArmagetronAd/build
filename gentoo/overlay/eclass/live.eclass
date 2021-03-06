EXPORT_FUNCTIONS pkg_postinst pkg_preinst src_unpack

live_svn_currentrev() {
	local RHome="$(
	  unset HOME
	  echo -n ~
	)"
	# NOTE: we use $(which sed) to pass QA checks
	HOME="$RHome" \
	LC_ALL=C svn info "${1}" |
	 "$(which sed)" '
		s,^Last Changed Rev: \([0-9]\+\)$,\1,
		t
		d
	'
}

live_svn_currentrevlist() {
	local rl= repo_uri repo thisrev
	for repo in "${ESVN_REPO_URI[@]}"; do
		repo_uri="$(subversion__get_repository_uri "${repo}")"
		thisrev="$(live_svn_currentrev "${repo_uri}")"
		[ -z "$thisrev" ] && return
		rl="$rl:$thisrev"
	done
	echo "${rl:1}"
}

live_want_update() {
	__live_why=
	if [ -z "${LIVE_UPDATES}" ]; then
		local LIVE_UPDATES
		if has ManualSCM ${FEATURES}; then
			LIVE_UPDATES=manual
		elif [ "${SUBVERSION_REVBUMP}" = 'no' ]; then
			LIVE_UPDATES=never
		else
			LIVE_UPDATES=revision
		fi
	fi
	
	[ "${LIVE_UPDATES}" = 'never' ] &&
		return 1 # always false
	
	# Disable caching to get LIVE_UPDATES changes effective
	addwrite "${BASH_SOURCE[0]}"
	if ! touch "${BASH_SOURCE[0]}" 2>/dev/null; then
		__live_why=-userpriv
		return 0 # always true, because userpriv prevents conditionals
	fi
	
	[ "${LIVE_UPDATES}" = 'manual' ] &&
		return 1 # always false
	
	local VDBROOT="${ROOT}/var/db/pkg"
	[ -d "${VDBROOT}" ] || return 0	# always update if no VDB
	
	local ENVFILE="${VDBROOT}/${CATEGORY}/${P}/environment.bz2"
	[ -a "${ENVFILE}" ] || return 1	# false if no existing install
	[ -r "${ENVFILE}" ] || return 0	# always update if can't read VDB
	
	[ "${LIVE_UPDATES}" = 'always' ] &&
		__live_why='-Always' &&
		return 0 # always true
	
	# Then/Now logic
	local Then Now
	
	case "${LIVE_UPDATES}" in
	revision)
		Then="$(bzgrep -m1 '^__live_revision=' "${ENVFILE}" | cut -d'=' -f'2-')"
		Now="$(live_svn_currentrevlist)"
		__live_why="-r${Now}"
		;;
	date*)
		local format='%F'
		[ -n "${LIVE_UPDATES:4}" ] && format=+"${LIVE_UPDATES:4}"
		Then="$(date -d"$(eval "$(bzgrep -m1 '^__live_date=' "${ENVFILE}")"; echo "${__live_date}")" "+${format}")"
		Now="$(date "+${format}")"
		__live_why="-date${Now/ /_}"
		;;
	esac
	
	[ -z "${Now}" ] && return 1 # false if we can't figure it out
	[ "${Then}" != "${Now}" ]
	return $?
}

live_record_build() {
	__live_date="$(TZ=UTC LC_ALL=C date)"
	unset __live_revision
}
live_record_repo() {
	local repo_uri="$(subversion__get_wc_path "${1}")"
	local wc_path="$(subversion__get_wc_path "${repo_uri}")"
	local lcr="$(live_svn_currentrev "${wc_path}")"
	__live_revision="${__live_revision}${__live_revision+:}${lcr}"
}

live_src_unpack() {
	local repo
	live_record_build
	for repo in "${ESVN_REPO_URI[@]}"; do
		subversion_fetch "${repo}" || die "${ESVN}: unknown problem occurred in subversion_fetch for ${repo}."
		live_record_repo "${repo}"
	done
	subversion_bootstrap || die "${ESVN}: unknown problem occurred in subversion_bootstrap."
}

live() {
	# Activate Live if appropriate
	if [ "$EBUILD_PHASE" == 'depend' ]; then
	 live_want_update &&
	 IUSE="$IUSE z~Live${__live_why}"
	# 'z~' to make sure it's listed last :)
	fi
	
	true
}

live_pkg_postinst() {
	touch "${BASH_SOURCE[0]}" 2>/dev/null || true
	[ "$SUBVERSION_REVBUMP" == "no" ] && return
	has ManualSCM ${FEATURES} && return
	[ "${LIVE_UPDATES}" = 'never' ] && return
	[ "${LIVE_UPDATES}" = 'manual' ] && return
	ewarn
	ewarn "${CATEGORY}/${P} supports automatic remerging."
	ewarn
	ewarn 'This feature is UNSUPPORTED by Gentoo, please DO NOT report ANY'
	ewarn ' related bugs to them, but rather to us via the forum:'
	ewarn '        http://forums.armagetronad.net'
	ewarn
	ewarn 'To control how often your live packages are updates, set'
	ewarn ' the LIVE_UPDATES variable in your make.conf to:'
	ewarn '        manual   - Disables this feature'
	ewarn '        revision - Update when there is a new revision'
	ewarn '        date     - Update every day'
	ewarn '        date%Y%m - Update once a month'
	ewarn '                   (other variants also possible)'
	ewarn '        always   - Always treat as an update'
	ewarn
	ewarn 'If you use FEATURES=userpriv, then packages will always be'
	ewarn ' updated unless you set LIVE_UPDATES=never and remerge.'
	ewarn
	ebeep 5
}

live_pkg_preinst() {
	touch "${BASH_SOURCE[0]}" 2>/dev/null || true
}
