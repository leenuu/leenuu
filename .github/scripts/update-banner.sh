#!/usr/bin/env bash
# README 배너를 계절에 맞는 gif로 바꾸고, 고른 계절 이름을 출력한다.
# 사용법: update-banner.sh [월(1-12)]   월을 생략하면 한국 시간 기준 이번 달
set -euo pipefail

readme=README.md
month="${1:-$(TZ=Asia/Seoul date +%m)}"

case "$month" in
  3|03|4|04|5|05)    season=spring; alt=Spring ;;
  6|06|7|07|8|08)    season=summer; alt=Summer ;;
  9|09|10|11)        season=autumn; alt=Autumn ;;
  12|1|01|2|02)      season=winter; alt=Winter ;;
  *) echo "월은 1-12여야 합니다: $month" >&2; exit 1 ;;
esac

if ! grep -Eq 'banner-(spring|summer|autumn|winter)\.gif' "$readme"; then
  echo "$readme 에서 배너 이미지를 찾지 못했습니다" >&2
  exit 1
fi

sed -E -i.bak \
  "s#banner-(spring|summer|autumn|winter)\.gif\" alt=\"[A-Za-z]+\"#banner-${season}.gif\" alt=\"${alt}\"#" \
  "$readme"
rm -f "$readme.bak"

echo "$season"
