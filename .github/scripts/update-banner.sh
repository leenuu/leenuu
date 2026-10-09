#!/usr/bin/env bash
# README를 계절에 맞게 바꾸고, 고른 계절 이름을 출력한다.
#   - 배너 gif와 alt            banner-<계절>.gif" alt="<계절>"
#   - 제목·구분선 그림          assets/ui/*-<계절>.svg
#   - 계절 색을 쓰는 스택 뱃지  img.shields.io/badge/<이름>-<계절 색>  (뒤의 ?logo=... 는 있어도 없어도 된다)
#     (네 계절 색 중 하나를 쓰는 뱃지만 바뀐다. 다른 색으로 둔 뱃지는 건드리지 않는다)
# 바꾼 뒤 README가 가리키는 그림이 저장소에 없으면 README를 되돌리고 실패한다.
# 사용법: update-banner.sh [월(1-12)]   월을 생략하면 한국 시간 기준 이번 달
set -euo pipefail

readme=README.md
# KST-9는 시간대 데이터가 없는 환경에서도 한국 시간으로 계산된다 (POSIX 형식).
month="${1:-$(TZ=KST-9 date +%m)}"

# 계절별 스택 뱃지 색: 그 계절 배너에서 뽑았고 흰 글자 대비가 4.5:1 이상이다.
spring_accent=CB325F
summer_accent=0B7A9E
autumn_accent=C4502B
winter_accent=2D66DC

case "$month" in
  3|03|4|04|5|05)    season=spring; alt=Spring; accent=$spring_accent ;;
  6|06|7|07|8|08)    season=summer; alt=Summer; accent=$summer_accent ;;
  9|09|10|11)        season=autumn; alt=Autumn; accent=$autumn_accent ;;
  12|1|01|2|02)      season=winter; alt=Winter; accent=$winter_accent ;;
  *) echo "월은 1-12여야 합니다: $month" >&2; exit 1 ;;
esac

if ! grep -Eq 'banner-(spring|summer|autumn|winter)\.gif" alt="[A-Za-z]+"' "$readme"; then
  echo "$readme 에서 배너 이미지(banner-<계절>.gif\" alt=\"...\")를 찾지 못했습니다" >&2
  exit 1
fi

# 뱃지 규칙은 둘이다: 색 바로 뒤에 ?가 오는 흔한 형태, 그리고 ?가 없거나 .svg가 붙은 형태.
sed -E -i.bak \
  -e "s#banner-(spring|summer|autumn|winter)\.gif\" alt=\"[A-Za-z]+\"#banner-${season}.gif\" alt=\"${alt}\"#" \
  -e "s#(assets/ui/[A-Za-z0-9_-]+)-(spring|summer|autumn|winter)\.svg#\1-${season}.svg#g" \
  -e "s#(img\.shields\.io/badge/[^\"?]*-)(${spring_accent}|${summer_accent}|${autumn_accent}|${winter_accent})\?#\1${accent}?#gI" \
  -e "s#(img\.shields\.io/badge/[^?\"')<>[:space:]]*-)(${spring_accent}|${summer_accent}|${autumn_accent}|${winter_accent})((\.svg)?([?\"')<>[:space:]]|\$))#\1${accent}\3#gI" \
  "$readme"

missing=0
for ref in $(grep -oE 'assets/(banner-[a-z]+\.gif|ui/[A-Za-z0-9_-]+\.svg)' "$readme" | sort -u); do
  if [ ! -f "$ref" ]; then
    echo "$readme 가 없는 파일을 가리킵니다: $ref" >&2
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then
  mv "$readme.bak" "$readme"
  exit 1
fi
rm -f "$readme.bak"

echo "$season"
