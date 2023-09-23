import { test, expect } from "@playwright/test";

test("It should take a snapshot of the GPU Chrome page", async ({ page }) => {
  await page.goto("chrome://gpu", { waitUntil: "domcontentloaded" });
  await page.screenshot({ path: "gpu.png" });

  const outerHtmls = await page.$$eval("body", (el) => el.outerHtml);
  console.log(outerHtmls);
  await expect(
    page.locator("text=Graphics Feature Status").first()
  ).toBeVisible();
});
