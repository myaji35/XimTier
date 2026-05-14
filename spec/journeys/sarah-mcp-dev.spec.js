const { test, expect } = require('@playwright/test');

const SHOTS = '../../reports/character-journeys/screenshots';

test.describe('Journey 3 — Sarah (Anthropic MCP Developer)', () => {
  test('EN landing → platform-api → demo request (English)', async ({ page }) => {
    const uniq = Date.now();
    const email = `sarah.lee+${uniq}@anthropic-dev.example`;

    await test.step('Step 1 — EN 랜딩 진입 (lang=en)', async () => {
      await page.goto('/en');
      await expect(page.locator('html')).toHaveAttribute('lang', 'en');
      await page.screenshot({ path: `${SHOTS}/j3-sarah-s1-en-landing.png` });
    });

    await test.step('Step 2 — Platform API / MCP 페이지 진입', async () => {
      await page.goto('/en/platform-api');
      await expect(page.locator('body')).toContainText(/MCP/i);
      await page.screenshot({ path: `${SHOTS}/j3-sarah-s2-platform-api.png` });
    });

    await test.step('Step 3 — EN 데모 신청 폼 작성', async () => {
      await page.goto('/en/demo');
      await page.fill('[name="demo_request[name]"]', 'Sarah Lee');
      await page.fill('[name="demo_request[email]"]', email);
      await page.fill('[name="demo_request[company]"]', 'Independent MCP Developer');
      await page.fill('[name="demo_request[role]"]', 'Open Source Engineer');
      await page.selectOption('[name="demo_request[industry]"]', 'other');
      await page.fill('[name="demo_request[data_description]"]', 'Looking for a Wolfram-Alpha-style MCP calculation server. Want to evaluate XimTier endpoints for plugin registration.');
      await page.check('[name="demo_request[consent]"]');
      await page.screenshot({ path: `${SHOTS}/j3-sarah-s3-demo-filled.png` });
    });

    await test.step('Step 4 — 제출 → EN 대시보드 도착', async () => {
      await page.click('form[action="/en/demo"] button[type="submit"]');
      await expect(page).toHaveURL(/\/en\/dashboard$/);
      await page.screenshot({ path: `${SHOTS}/j3-sarah-s4-en-dashboard.png` });
    });
  });
});
