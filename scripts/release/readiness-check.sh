#!/usr/bin/env bash

set -euo pipefail

tag="${1:-}"
notes_file="${2:-CHANGELOG.md}"

if [[ -z "$tag" ]]; then
  echo "usage: readiness-check.sh <tag> [release-notes-file]" >&2
  exit 1
fi

if ! [[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "tag must follow semver format like v1.2.3" >&2
  exit 1
fi

if [[ ! -f "$notes_file" ]]; then
  echo "release notes file not found: $notes_file" >&2
  exit 1
fi

if ! grep -q "$tag" "$notes_file"; then
  echo "release notes do not contain an entry for $tag" >&2
  exit 1
fi

echo "release readiness checks passed for $tag"
