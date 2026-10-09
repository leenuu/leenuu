#!/usr/bin/env bash
# 스네이크 SVG에서 아래쪽 진행 바(먹은 칸이 쌓이는 막대)를 지운다. snk에는 이를 끄는 옵션이 없다.
#   - 막대를 그리는 <rect class="u ..."> 를 모두 지운다
#   - 막대가 있던 맨 아래 한 줄(16px)만큼 그림 높이를 줄인다 (192 -> 176)
# 이미 지운 파일에 다시 돌려도 바뀌지 않는다.
# snk의 출력 형식이 달라져 막대가 남거나 높이가 맞지 않으면 실패한다 (그러면 커밋 단계로 넘어가지 않는다).
# 사용법: strip-snake-progress.sh <svg>...
set -euo pipefail

for svg in "$@"; do
  sed -E -i.bak \
    -e 's#<rect class="u [^>]*/>##g' \
    -e 's#^(<svg viewBox="-?[0-9]+ -?[0-9]+ [0-9]+ )192(" width="[0-9]+" height=")192"#\1176\2176"#' \
    "$svg"
  rm -f "$svg.bak"
  if grep -q 'class="u ' "$svg" || ! grep -Eq '^<svg viewBox="-?[0-9]+ -?[0-9]+ [0-9]+ 176" width="[0-9]+" height="176"' "$svg"; then
    echo "$svg: snk 출력 형식이 예상과 달라 진행 바를 지우지 못했습니다" >&2
    exit 1
  fi
done
