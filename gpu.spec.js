import { test, expect } from "@playwright/test";

test("It should take a snapshot of the GPU Chrome page", async ({ page }) => {
  await page.goto("chrome://gpu", { waitUntil: "domcontentloaded" });
  await page.screenshot({ path: "gpu.png" });
  await new Promise((resolve) => setTimeout(resolve, 1000));
  const aHandle = await page.evaluateHandle(() => document.body);
  const resultHandle = await page.evaluateHandle(
    (body) => body.outerHTML,
    aHandle
  );
  console.log(await resultHandle.jsonValue());
});
