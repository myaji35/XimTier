const { test, expect } = require('@playwright/test');

const SHOTS = '../../reports/character-journeys/screenshots';

test.describe('Journey 1 — 김상무 (제조 SME 임원)', () => {
  test('landing → IR download → demo request → 본인 대시보드', async ({ page }) => {
    const uniq = Date.now();
    const email = `kim.exec+${uniq}@hyundai-sme.example`;

    await test.step('Step 1 — KO 랜딩 진입', async () => {
      await page.goto('/ko');
      await expect(page).toHaveTitle(/XimTier/);
      await page.screenshot({ path: `${SHOTS}/j1-kim-s1-landing.png` });
    });

    await test.step('Step 2 — IR 다운로드 페이지 진입', async () => {
      await page.goto('/ko/company/investors');
      await expect(page.locator('#download_email')).toBeVisible();
      await page.screenshot({ path: `${SHOTS}/j1-kim-s2-investors.png` });
    });

    await test.step('Step 3 — IR 폼 작성 및 제출', async () => {
      await page.fill('#download_name', '김상무');
      await page.fill('#download_email', email);
      await page.fill('#download_company', '현대 정밀공업');
      await page.fill('#download_role', '경영지원실 상무');
      await page.screenshot({ path: `${SHOTS}/j1-kim-s3-form-filled.png` });
      await page.click('input[type="submit"][name="commit"]');
      await expect(page).toHaveURL(/sent=1/);
      await page.screenshot({ path: `${SHOTS}/j1-kim-s4-ir-success.png` });
    });

    await test.step('Step 4 — 데모 신청 폼 작성 및 제출 → 자동 가입 + 대시보드 진입', async () => {
      await page.goto('/ko/demo');
      await page.fill('[name="demo_request[name]"]', '김상무');
      await page.fill('[name="demo_request[email]"]', email);
      await page.fill('[name="demo_request[company]"]', '현대 정밀공업');
      await page.fill('[name="demo_request[role]"]', '경영지원실 상무');
      await page.selectOption('[name="demo_request[industry]"]', 'manufacturing');
      await page.fill('[name="demo_request[data_description]"]', '6개월치 공정 로그 CSV. 불량률 1.5% 미만 변수 조합 탐색.');
      await page.check('[name="demo_request[consent]"]');
      await page.screenshot({ path: `${SHOTS}/j1-kim-s5-demo-filled.png` });
      await page.click('form[action="/ko/demo"] button[type="submit"]');
      await expect(page).toHaveURL(/\/ko\/dashboard$/);
      await expect(page.locator('body')).toContainText(/대기|PENDING|신청|접수/i);
      await page.screenshot({ path: `${SHOTS}/j1-kim-s6-dashboard.png` });
    });
  });
});
