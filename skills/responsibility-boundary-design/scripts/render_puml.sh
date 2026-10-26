#!/usr/bin/env bash
# .puml を SVG にレンダリングする。
# 使い方: bash render_puml.sh <input.puml> <output.svg>
# 初回のみ plantuml.jar を ~/.cache/plantuml/ にダウンロードする。
set -euo pipefail

IN="${1:?usage: render_puml.sh <input.puml> <output.svg>}"
OUT="${2:?usage: render_puml.sh <input.puml> <output.svg>}"

CACHE_DIR="${HOME}/.cache/plantuml"
JAR="${CACHE_DIR}/plantuml.jar"
JAR_URL="https://github.com/plantuml/plantuml/releases/download/v1.2025.2/plantuml-1.2025.2.jar"

if ! command -v java >/dev/null 2>&1; then
  echo "ERROR: java が見つかりません。SVG生成をスキップし、HTMLには .puml のソースを埋め込んでください。" >&2
  exit 3
fi

if [ ! -f "$JAR" ]; then
  mkdir -p "$CACHE_DIR"
  echo "plantuml.jar をダウンロードしています..." >&2
  if ! curl -sSfL -o "$JAR" "$JAR_URL"; then
    rm -f "$JAR"
    echo "ERROR: plantuml.jar を取得できませんでした(ネットワーク制限の可能性)。" >&2
    echo "       SVG生成をスキップし、HTMLには .puml のソースをコードブロックとして埋め込み、" >&2
    echo "       外部レンダラでの表示をユーザに案内してください。" >&2
    exit 4
  fi
fi

TMPDIR_R="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_R"' EXIT

java -Dfile.encoding=UTF-8 -jar "$JAR" -charset UTF-8 -tsvg -o "$TMPDIR_R" "$IN"

BASE="$(basename "${IN%.*}")"
if [ ! -f "${TMPDIR_R}/${BASE}.svg" ]; then
  echo "ERROR: レンダリングに失敗しました。.puml の構文を確認してください。" >&2
  echo "       skinparam のブロック形式(skinparam rectangle { ... })は構文エラーになります。" >&2
  exit 5
fi

mkdir -p "$(dirname "$OUT")"
cp "${TMPDIR_R}/${BASE}.svg" "$OUT"
echo "OK: ${OUT}"
