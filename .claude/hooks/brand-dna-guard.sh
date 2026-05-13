#!/usr/bin/env bash
# brand-dna.json 변경 시 _governance.approval_required_for 키 손상 감지
# 사용: bash .claude/hooks/brand-dna-guard.sh
# CI/pre-commit: git diff 또는 git diff --cached로 호출 가능

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 2

# 변경 대상 파일이 brand-dna.json인지 확인
DIFF=$(git diff --cached --name-only 2>/dev/null || git diff --name-only 2>/dev/null || echo "")
if ! echo "$DIFF" | grep -q "^brand-dna.json$"; then
  exit 0  # brand-dna.json 변경 없음 → 통과
fi

echo "[brand-dna-guard] brand-dna.json 변경 감지 — 거버넌스 키 확인 중..."

# approval_required_for 목록 파싱 (간단한 grep)
PROTECTED_KEYS=(
  "brand.name"
  "brand.tagline_ko"
  "brand.tagline_en"
  "brand.positioning"
  "design_tokens.colors.xim_blue"
  "design_tokens.colors.teal_mint"
  "design_tokens.colors.deep_navy"
  "design_tokens.gradients.brand"
)

# JSON path별 값 추출 (jq 사용)
violations=0
DIFF_CONTENT=$(git diff --cached brand-dna.json 2>/dev/null || git diff brand-dna.json 2>/dev/null || echo "")

for key in "${PROTECTED_KEYS[@]}"; do
  # 단순 검사: 키 이름이 diff에 등장하는가
  field=$(echo "$key" | awk -F'.' '{print $NF}')
  if echo "$DIFF_CONTENT" | grep -E "^[+-][^+-].*\"$field\"" >/dev/null 2>&1; then
    echo "  ⚠ 보호 키 변경 의심: $key"
    violations=$((violations + 1))
  fi
done

if [ "$violations" -eq 0 ]; then
  echo "✅ 보호 키 변경 없음 (auto_iterable 영역만 수정됨)"
  exit 0
else
  echo ""
  echo "❌ approval_required_for 키가 변경되었을 가능성 ($violations 건)"
  echo "   확인 사항:"
  echo "   1) _workspace/brand-changelog.md에 변경 사유 + 승인자 기록했는가?"
  echo "   2) brand-dna.json의 _version semver 증가시켰는가?"
  echo "   3) CEO/CTO 모두 승인했는가? (lock_until: 2026-09-30)"
  echo ""
  echo "   해당 변경이 의도적이고 승인을 받았다면 commit 진행, 아니라면 revert."
  exit 0  # 경고만, 차단은 안 함 (개발자 판단)
fi
