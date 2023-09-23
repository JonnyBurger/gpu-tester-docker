"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.openBrowser =
  exports.internalOpenBrowser =
  exports.killAllBrowsers =
    void 0;
const node_1 = require("./browser/node");
const get_local_browser_executable_1 = require("./get-local-browser-executable");
const get_video_threads_flag_1 = require("./get-video-threads-flag");
const log_level_1 = require("./log-level");
const validate_opengl_renderer_1 = require("./validate-opengl-renderer");
const validRenderers = ["swangle", "angle", "egl", "swiftshader", "vulkan"];
const getOpenGlRenderer = (option) => {
  const renderer =
    option !== null && option !== void 0
      ? option
      : validate_opengl_renderer_1.DEFAULT_OPENGL_RENDERER;
  (0, validate_opengl_renderer_1.validateOpenGlRenderer)(renderer);
  if (renderer === "swangle") {
    return [`--use-gl=angle`, `--use-angle=swiftshader`];
  }
  if (renderer === "vulkan") {
    return [
      "--use-angle=vulkan",
      "--disable-vulkan-fallback-to-gl-for-testing",
      "--dignore-gpu-blocklist",
    ];
  }
  if (renderer === null) {
    return [];
  }
  return [`--use-gl=${renderer}`];
};
const browserInstances = [];
const killAllBrowsers = async () => {
  for (const browser of browserInstances) {
    try {
      await browser.close(true, "info", false);
    } catch (err) {}
  }
};
exports.killAllBrowsers = killAllBrowsers;
const internalOpenBrowser = async ({
  browser,
  browserExecutable,
  chromiumOptions,
  forceDeviceScaleFactor,
  indent,
  viewport,
  logLevel,
}) => {
  var _a, _b;
  // @ts-expect-error Firefox
  if (browser === "firefox") {
    throw new TypeError(
      "Firefox supported is not yet turned on. Stay tuned for the future."
    );
  }
  await (0, get_local_browser_executable_1.ensureLocalBrowser)(
    browserExecutable
  );
  const executablePath = (0,
  get_local_browser_executable_1.getLocalBrowserExecutable)(browserExecutable);
  const customGlRenderer = getOpenGlRenderer(
    (_a = chromiumOptions.gl) !== null && _a !== void 0 ? _a : null
  );
  const browserInstance = await node_1.puppeteer.launch({
    executablePath,
    dumpio: (0, log_level_1.isEqualOrBelowLogLevel)(logLevel, "verbose"),
    logLevel,
    indent,
    args: [
      "about:blank",
      "--headless",
      "--enable-features=Vulkan,UseSkiaRenderer",
      "--use-vulkan=swiftshader",
      "--enable-unsafe-webgpu",
      "--disable-vulkan-fallback-to-gl-for-testing",
      "--dignore-gpu-blocklist",
      "--use-angle=vulkan",
    ].filter(Boolean),
    defaultViewport:
      viewport !== null && viewport !== void 0
        ? viewport
        : {
            height: 720,
            width: 1280,
            deviceScaleFactor: 1,
          },
  });
  const pages = await browserInstance.pages(logLevel, indent);
  await pages[0].close();
  browserInstances.push(browserInstance);
  return browserInstance;
};
exports.internalOpenBrowser = internalOpenBrowser;
/**
 * @description Opens a Chrome or Chromium browser instance.
 * @see [Documentation](https://www.remotion.dev/docs/renderer/open-browser)
 */
const openBrowser = (browser, options) => {
  const {
    browserExecutable,
    chromiumOptions,
    forceDeviceScaleFactor,
    shouldDumpIo,
  } = options !== null && options !== void 0 ? options : {};
  return (0, exports.internalOpenBrowser)({
    browser,
    browserExecutable:
      browserExecutable !== null && browserExecutable !== void 0
        ? browserExecutable
        : null,
    chromiumOptions:
      chromiumOptions !== null && chromiumOptions !== void 0
        ? chromiumOptions
        : {},
    forceDeviceScaleFactor,
    indent: false,
    viewport: null,
    logLevel: shouldDumpIo ? "verbose" : "info",
  });
};
exports.openBrowser = openBrowser;
