const { test, expect } = require('@playwright/test');

const SHOTS = '../../reports/character-journeys/screenshots';

test.describe('Journey 2 — 박사무관 (공공기관 정책 담당)', () => {
  test('use-cases → public 케이스 → 문의 폼 제출', async ({ page }) => {
    const uniq = Date.now();
    const email = `park.policy+${uniq}@nipa.go.kr`;

    await test.step('Step 1 — 산업별 활용 페이지 진입', async () => {
      await page.goto('/ko/use-cases');
      await expect(page.locator('a[href*="/cases/public"]').first()).toBeVisible();
      await page.screenshot({ path: `${SHOTS}/j2-park-s1-usecases.png` });
    });

    await test.step('Step 2 — 공공 케이스 상세 진입', async () => {
      await page.goto('/ko/cases/public');
      await expect(page).toHaveTitle(/공공|정책|시나리오|광역시/);
      await page.screenshot({ path: `${SHOTS}/j2-park-s2-case-public.png` });
    });

    await test.step('Step 3 — 문의 폼 작성', async () => {
      await page.goto('/ko/contact');
      await page.fill('[name="contact_inquiry[name]"]', '박사무관');
      await page.fill('[name="contact_inquiry[email]"]', email);
      await page.fill('[name="contact_inquiry[company]"]', 'NIPA 정보통신산업진흥원');
      await page.selectOption('[name="contact_inquiry[industry]"]', 'public_sector');
      await page.fill('[name="contact_inquiry[message]"]', 'EU AI Act 대응 + XAI 의무화 검토 중. 광역시 청년정책 시뮬레이션 케이스 추가 자료 요청드립니다.');
      await page.check('[name="contact_inquiry[consent]"]');
      await page.screenshot({ path: `${SHOTS}/j2-park-s3-contact-filled.png` });
    });

    await test.step('Step 4 — 문의 폼 제출 + 정상 접수 메시지 확인', async () => {
      await page.click('form[action*="/contact"] input[type="submit"], form[action*="/contact"] button[type="submit"]');
      await expect(page.locator('body')).toContainText('문의가 정상 접수되었습니다');
      await page.screenshot({ path: `${SHOTS}/j2-park-s4-contact-success.png` });
    });
  });
});
