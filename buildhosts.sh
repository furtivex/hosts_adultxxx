#!/usr/bin/env bash
# ===================================================
# BuildHosts
# Created by Furtivex
# Linux Portable Version 1.0.4
# ===================================================

set -euo pipefail
IFS=$'\n\t'

# --- [INITIAL SETUP] ----------------------------------
# Go to script directory
cd "$(dirname "$0")"

# Define paths
githubD="$HOME/Documents/GitHub/hosts_adultxxx"
hostsD="/etc/hosts"

# Ensure GitHub directory exists
mkdir -p "$githubD"

# Display title
echo "BuildHosts by Furtivex - Version 1.0.4"
echo

# --- [DNS SERVICE DETECTION & STOP] -------------------
stop_dns() {
    echo "[*] Attempting to stop DNS caching service..."
    if command -v systemctl >/dev/null 2>&1; then
        for svc in systemd-resolved dnsmasq nscd unbound; do
            if systemctl list-unit-files 2>/dev/null | grep -q "$svc"; then
                sudo systemctl stop "$svc" 2>/dev/null || true
                sudo systemctl disable "$svc" 2>/dev/null || true
            fi
        done
    elif command -v rc-service >/dev/null 2>&1; then
        for svc in dnsmasq nscd unbound; do
            sudo rc-service "$svc" stop 2>/dev/null || true
        done
    elif command -v sv >/dev/null 2>&1; then
        for svc in dnsmasq nscd unbound; do
            sudo sv down "$svc" 2>/dev/null || true
        done
    fi
}

start_dns() {
    echo "[*] Re-enabling DNS caching service..."
    if command -v systemctl >/dev/null 2>&1; then
        for svc in systemd-resolved dnsmasq nscd unbound; do
            if systemctl list-unit-files 2>/dev/null | grep -q "$svc"; then
                sudo systemctl enable "$svc" 2>/dev/null || true
                sudo systemctl start "$svc" 2>/dev/null || true
            fi
        done
    elif command -v rc-service >/dev/null 2>&1; then
        for svc in dnsmasq nscd unbound; do
            sudo rc-service "$svc" start 2>/dev/null || true
        done
    elif command -v sv >/dev/null 2>&1; then
        for svc in dnsmasq nscd unbound; do
            sudo sv up "$svc" 2>/dev/null || true
        done
    fi
}

flush_dns() {
    echo "[*] Flushing DNS cache..."
    if command -v resolvectl >/dev/null 2>&1; then
        sudo resolvectl flush-caches
    elif command -v systemd-resolve >/dev/null 2>&1; then
        sudo systemd-resolve --flush-caches
    elif command -v rndc >/dev/null 2>&1; then
        sudo rndc flush
    elif command -v nscd >/dev/null 2>&1; then
        sudo nscd -i hosts
    elif command -v dscacheutil >/dev/null 2>&1; then
        # macOS fallback
        sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
    fi
}

# --- [BUILD HOSTS FILE] -------------------------------
stop_dns
sleep 2

tmpdir=$(mktemp -d)

# Normalize encoding and line endings to UTF-8 text
dos2unix "$githubD/hosts" 2>/dev/null || \
tr -d '\r' < "$githubD/hosts" > "$githubD/hosts.tmp" && mv "$githubD/hosts.tmp" "$githubD/hosts"

# Process hosts file
grep -Ev '^#' "$githubD/hosts" > "$tmpdir/repairhosts1"
sed -E 's/(0\.0\.0\.0 )?https?:\/\///; s/(\/|:443)$//' "$tmpdir/repairhosts1" > "$tmpdir/repairhosts2"
sed -E '/^0\.0\.0\.0/!s/(.*)/0.0.0.0 \1/' "$tmpdir/repairhosts2" > "$tmpdir/repairhosts3"
sort -fu "$tmpdir/repairhosts3" > "$tmpdir/repairhosts4"
sed -E 's/\"//g' "$tmpdir/repairhosts4" > "$tmpdir/repairhosts5"

# Header
cat <<'EOF' > "$tmpdir/repairhosts1"
# Title: furtivex/hosts_adultxxx
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Hosts file for browsing porn
# Filters out ads, banners, redirects and more
# Raw: https://raw.githubusercontent.com/furtivex/hosts_adultxxx/master/hosts
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 127.0.0.1 localhost
# ::1 localhost
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EOF

# Append cleaned entries
cat "$tmpdir/repairhosts5" >> "$tmpdir/repairhosts1"

# Replace target hosts files
cp -f "$tmpdir/repairhosts1" "$githubD/hosts"
sudo cp -f "$tmpdir/repairhosts1" "$hostsD"

# Cleanup
rm -rf "$tmpdir"

# --- [POST-OPERATIONS] -------------------------------
start_dns
sleep 2
flush_dns

# Kill git if running BONUS: sudo ufw deny from 172.240.208.0/21
pkill -f git || true

echo
echo "[✔] Hosts successfully rebuilt and DNS cache flushed."
