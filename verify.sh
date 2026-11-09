#!/usr/bin/env bash
set -euo pipefail
manifest=${1:?manifest}; want=${2:?sha256 manifest}; ref=${3:?image@sha256:...}; pub=${4:-}
got=$(sha256sum "$manifest" | cut -d' ' -f1)
[ "$got" = "$want" ] || { echo "GAGAL: hash manifest $got != $want"; exit 1; }
digest=${ref#*@}
grep -q "@${digest}" "$manifest" || { echo "GAGAL: manifest tidak mengacu digest $digest"; exit 1; }
if grep -E 'image:' "$manifest" | grep -vq '@sha256:'; then echo "GAGAL: ada image tanpa digest"; exit 1; fi
if [ -n "$pub" ]; then cosign verify --key "$pub" "$ref" >/dev/null && echo "tanda tangan image valid"; fi
echo "OK: manifest dan image sesuai pengumuman"
