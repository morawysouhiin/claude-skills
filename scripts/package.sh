#!/usr/bin/env bash
# skills/ 配下の各スキルを、Claude にアップロードできるZIPにまとめて dist/ に出力する。
# ZIPの中身はスキル名のフォルダ1つ（例: idea-validation-flow-html/SKILL.md）。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="${ROOT}/dist"
rm -rf "$DIST"
mkdir -p "$DIST"

cd "${ROOT}/skills"
for dir in */; do
  name="${dir%/}"
  [ -f "${name}/SKILL.md" ] || continue
  zip -qr -X "${DIST}/${name}.zip" "$name" -x '*.DS_Store'
  echo "OK: dist/${name}.zip"
done
