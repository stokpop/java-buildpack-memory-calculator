#!/usr/bin/env bash
# Adds an empty "## vX.Y.Z+1" section above the newest one in RELEASE_NOTES.md, after a release.
# Usage: next-notes.sh <released version> [notes file]   (e.g. 4.3.0)
#
# Prints the new version and edits the file only when the newest heading is the released version. If it is
# anything else, for example because a larger jump was already added by hand, it prints nothing and changes
# nothing. The section is left empty on purpose: release-notes.sh fails on an empty section, so the next
# release cannot go out until someone writes its notes.
set -euo pipefail

VERSION=$1
FILE=${2:-"$(dirname "${BASH_SOURCE[0]}")/../../RELEASE_NOTES.md"}

TOP=$(sed -nE 's/^## v([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' "${FILE}" | head -1)
if [[ "${TOP}" != "${VERSION}" ]]; then
  echo "newest heading is ${TOP:+v}${TOP:-missing}, not v${VERSION}: nothing to add" >&2
  exit 0
fi

IFS=. read -r major minor patch <<< "${VERSION}"
NEXT="${major}.${minor}.$((patch + 1))"

TMP=$(mktemp)
awk -v next_heading="## v${NEXT}" '!done && /^## v/ { print next_heading; print ""; done = 1 } { print }' "${FILE}" > "${TMP}"
cat "${TMP}" > "${FILE}"
rm -f "${TMP}"

echo "${NEXT}"
