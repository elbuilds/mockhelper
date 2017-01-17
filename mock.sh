#!/usr/bin/env bash
# ==============================================================================
# Usage: ./mock.sh [outdir] [package...]
# ==============================================================================
set -ex

MOCKCHAIN='mockchain'
CONFIG='elbuilds-7-x86_64'

LANG=en_US.UTF-8 && {
  _outdir=$1 && shift
  _srpms=$@

  test -d "$_outdir"
  command "$MOCKCHAIN" -r "$CONFIG" -l "$_outdir" --recurse ${_srpms[@]}
  # No need to deal with return value because '-e' has set.
}

