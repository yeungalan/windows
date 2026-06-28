#!/usr/bin/env bash
set -Eeuo pipefail

FLEX_JSON="https://dl.google.com/dl/edgedl/chromeos/recovery/cloudready_recovery.json"
FLEX_BIN="$STORAGE/data.img"

downloadFlex() {

  local url zip_file bin_file tmp_dir
  tmp_dir="$STORAGE/tmp"

  html "Downloading ChromeOS Flex..."
  info "Fetching ChromeOS Flex recovery manifest..."

  local json
  json=$(curl -sfL "$FLEX_JSON") || {
    error "Failed to fetch ChromeOS Flex recovery manifest from Google!" && return 1
  }

  url=$(echo "$json" | jq -r '[.[] | select(.channel == "stable-channel")] | last | .url // empty')

  if [ -z "$url" ] || [ "$url" = "null" ]; then
    url=$(echo "$json" | jq -r '.[0].url // empty')
  fi

  if [ -z "$url" ] || [ "$url" = "null" ]; then
    error "Could not determine ChromeOS Flex download URL from manifest!" && return 1
  fi

  info "Downloading ChromeOS Flex from: $url"
  html "Downloading ChromeOS Flex (this may take a while)..."

  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"
  zip_file="$tmp_dir/chromeos_flex.zip"

  if ! curl -L "$url" -o "$zip_file" --progress-bar; then
    error "Failed to download ChromeOS Flex!" && return 1
  fi

  info "Extracting ChromeOS Flex image..."
  html "Extracting ChromeOS Flex image..."

  if ! unzip -q "$zip_file" -d "$tmp_dir/" "*.bin"; then
    error "Failed to extract ChromeOS Flex archive!" && return 1
  fi

  bin_file=$(find "$tmp_dir" -maxdepth 1 -name "*.bin" -print -quit)

  if [ -z "$bin_file" ]; then
    error "No .bin file found in ChromeOS Flex archive!" && return 1
  fi

  info "Installing ChromeOS Flex disk image to storage..."
  html "Preparing ChromeOS Flex disk image..."

  mv -f "$bin_file" "$FLEX_BIN"
  rm -rf "$tmp_dir"

  return 0
}

######################################

# Force raw format so the base image's disk.sh treats our file as-is
DISK_FMT="raw"

if [ -f "$FLEX_BIN" ] && [ -s "$FLEX_BIN" ]; then
  info "ChromeOS Flex disk image already present, skipping download."
  return 0
fi

if ! downloadFlex; then
  exit 1
fi

html "ChromeOS Flex image ready, starting VM..."
return 0
