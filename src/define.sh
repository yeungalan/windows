#!/usr/bin/env bash
set -Eeuo pipefail

: "${VERSION:=""}"
: "${LANGUAGE:=""}"
: "${REGION:=""}"
: "${KEYBOARD:=""}"

parseVersion() {
  VERSION="flex"
  return 0
}

parseLanguage() {
  [ -z "$LANGUAGE" ] && LANGUAGE="en"
  return 0
}
