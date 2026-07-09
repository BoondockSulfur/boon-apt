#!/usr/bin/env bash
#
# BooN-OS APT-Repo — Metadaten erzeugen und signieren.
#
# Ablauf: neue/aktualisierte .debs nach pool/main/<x>/<paket>/ legen,
# dieses Skript ausführen, committen, pushen — GitHub Pages liefert das
# Repo unter https://boondocksulfur.github.io/boon-apt aus.
#
# Signiert wird mit dem BooN-OS Signing Key (ohne Passphrase, liegt im
# GPG-Home des Build-Rechners; Backup: ~/boon-os-signing-key-BACKUP-PRIVAT.asc).
#
set -euo pipefail
cd "$(dirname "$0")"

KEY_FPR="B6AC0F64EFAAC092C0FBC30CF9106F5C7DB07765"
DIST="trixie"
ARCH="amd64"
BIN_DIR="dists/${DIST}/main/binary-${ARCH}"

mkdir -p "${BIN_DIR}"

# Paket-Index: apt-ftparchive läuft vom Repo-Root, damit die
# Filename:-Einträge relativ bleiben (pool/main/...).
apt-ftparchive --arch "${ARCH}" packages pool > "${BIN_DIR}/Packages"
gzip -9 -kf "${BIN_DIR}/Packages"

# Release mit den Feldern, die apt für Origin-Pinning und
# Fehlermeldungen anzeigt.
apt-ftparchive \
    -o "APT::FTPArchive::Release::Origin=BooN-OS" \
    -o "APT::FTPArchive::Release::Label=BooN-OS" \
    -o "APT::FTPArchive::Release::Suite=${DIST}" \
    -o "APT::FTPArchive::Release::Codename=${DIST}" \
    -o "APT::FTPArchive::Release::Architectures=${ARCH}" \
    -o "APT::FTPArchive::Release::Components=main" \
    -o "APT::FTPArchive::Release::Description=BooN-OS package repository" \
    release "dists/${DIST}" > "dists/${DIST}/Release"

# Beide Signatur-Formen: InRelease (inline, von modernem apt bevorzugt)
# und Release.gpg (detached, Fallback).
gpg --batch --yes --default-key "${KEY_FPR}" \
    --clearsign -o "dists/${DIST}/InRelease" "dists/${DIST}/Release"
gpg --batch --yes --default-key "${KEY_FPR}" \
    -abs -o "dists/${DIST}/Release.gpg" "dists/${DIST}/Release"

echo "OK: $(grep -c '^Package:' "${BIN_DIR}/Packages") Paket(e) im Index, Release signiert (${KEY_FPR})."
