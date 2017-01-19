#!/usr/bin/env bash
# ==============================================================================
# Usage: RELEASEVER=7 ./dispatch.sh <mockchain-outdir> <elbuilds-rootdir>
# ==============================================================================
set -ex

RELEASEVER=${RELEASEVER:-7}
DISTFLAG='.elbuilds'
COPYLOG=1

DIST=$(rpm --eval %{dist})
KEY_DIR='pki/rpm-gpg'
KEY_FILE='RPM-GPG-KEY-elbuilds'
NAME_FMT='%{name}'
VER_FMT='%{version}'
REL_FMT='%{release}'

{
  _outdir="$1"
  _rootdir="$2"
  _spkgsdir="${_rootdir}/${RELEASEVER}/Source/SPackages"
  _pkgsdir="${_rootdir}/${RELEASEVER}/x86_64/Packages"
  _dirs=( )

  echo "$DIST" | grep "$DISTFLAG"
  test -d "$_outdir"
  test -d "$_rootdir"
  test -r "${_rootdir}/${KEY_DIR}/${KEY_FILE}"

  _dirs=( $(find "$_outdir" -type f -name 'success' | xargs -I {} dirname {} ) )
  for _dir in ${_dirs[@]}
  do
    _log="${_dir}/build.log"
    _srpm=$(find "$_dir" -type f -name '*src.rpm')
    _rpms=( $(find "$_dir" -type f  \
              | grep -P '(?<!\.src).rpm' | grep -v -- '-debuginfo-') )
    _name=$(rpm -qp --qf "$NAME_FMT" "$_srpm")
    _ver=$(rpm -qp --qf "$VER_FMT" "$_srpm")
    _rel=$(rpm -qp --qf "$REL_FMT" "$_srpm" | grep -oP '^\d+?(?=\.)')
    _subdir="${_name}/${_ver}-${_rel}"

    if [[ ! -d "${_spkgsdir}/${_subdir}" && -n "$_srpm" ]]
    then
      mkdir -p "${_spkgsdir}/${_subdir}"
      cp -f "$_srpm" "${_spkgsdir}/${_subdir}"
    fi

    if [[ ! -d "${_pkgsdir}/${_subdir}" && ${#_rpms[@]} > 0 ]]
    then
      mkdir -p "${_pkgsdir}/${_subdir}"
      cp -f ${_rpms[@]} "${_pkgsdir}/${_subdir}"

      if [[ 1 == "$COPYLOG" ]]
      then
        cp -f "$_log" "${_pkgsdir}/${_subdir}"
      fi
    fi
  done

  # No need to deal with return value because '-e' has set.
} 2>&1 | tee dispatch.log

