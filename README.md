# boon-apt — BooN-OS-Paketquelle

Offizielles APT-Repository für BooN-OS-eigene Pakete (z. B. **BooN Transfer**),
ausgeliefert über GitHub Pages: `https://boondocksulfur.github.io/boon-apt`

BooN-OS bringt diese Quelle ab Werk mit (v0.24+). Manuelle Einrichtung auf
einem Debian-13-System:

```bash
curl -fsSL https://boondocksulfur.github.io/boon-apt/boon-os-archive-key.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/boon-os-archive-keyring.gpg

sudo tee /etc/apt/sources.list.d/boon-os.sources > /dev/null << 'EOF'
Types: deb
URIs: https://boondocksulfur.github.io/boon-apt
Suites: trixie
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/boon-os-archive-keyring.gpg
EOF

sudo apt update
```

Signiert mit dem **BooN-OS Signing Key**
`B6AC 0F64 EFAA C092 C0FB C30C F910 6F5C 7DB0 7765`.

## Pflege (Maintainer)

Neues/aktualisiertes .deb nach `pool/main/<anfangsbuchstabe>/<paket>/` legen,
dann:

```bash
./update-repo.sh   # erzeugt Packages/Release und signiert (InRelease + Release.gpg)
git add -A && git commit && git push
```

GitHub Pages liefert `main` direkt aus (`.nojekyll` verhindert
Jekyll-Filterung).
