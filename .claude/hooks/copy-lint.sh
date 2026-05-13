#!/usr/bin/env bash
# XimTier 카피 lint — 금지어 검출 (design.md §9 Copy Principles)
# 사용: bash .claude/hooks/copy-lint.sh
# CI: 발견 시 exit 1

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 2

FORBIDDEN_KO="혁신적|최첨단|차세대|획기적|업계 최고|월드 클래스"
FORBIDDEN_EN="game-changing|revolutionary|cutting-edge|world-class|next-gen|paradigm shift"

violations=0

scan() {
  local pattern="$1"; local label="$2"
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    echo "  ❌ [$label] $line"
    violations=$((violations + 1))
  done < <(grep -rIn -E "$pattern" config/locales/ 2>/dev/null || true)
}

echo "[copy-lint] config/locales/ 스캔 시작..."

echo ""
echo "한글 금지어:"
scan "$FORBIDDEN_KO" "ko"

echo ""
echo "영문 금지어:"
scan "$FORBIDDEN_EN" "en"

echo ""
if [ "$violations" -eq 0 ]; then
  echo "✅ 카피 lint 통과 (금지어 0건)"
  exit 0
else
  echo "❌ 카피 lint 실패: 금지어 $violations 건 발견"
  echo "   대안: '수치 먼저', 단언 톤, '구체적 증거'로 대체 (design.md §9)"
  exit 1
fi
