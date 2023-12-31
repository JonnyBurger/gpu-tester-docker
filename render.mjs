import { bundle } from "@remotion/bundler";
import { renderMedia, selectComposition } from "@remotion/renderer";
import { createRequire } from "node:module";
import { execSync, spawnSync } from "node:child_process";
import { VERSION } from "remotion/version";
const require = createRequire(import.meta.url);

console.log({ VERSION });

execSync("vulkaninfo", { stdio: "inherit" });

const bundled = await bundle({
  entryPoint: require.resolve("./src/index.ts"),
  // If you have a Webpack override, make sure to import it here
  webpackOverride: (config) => config,
});
const composition = await selectComposition({
  serveUrl: bundled,
  id: "MyComp",
});

console.log("Starting to render composition");
await renderMedia({
  codec: "h264",
  composition,
  serveUrl: bundled,
  outputLocation: `out/${composition.id}.mp4`,
  logLevel: "verbose",
  onProgress: (i) => {
    console.log(i.renderedFrames);
  },
  onDownload: (i) => {
    console.log(i);
    return ({ percent }) => {
      // console.log({percent});
    };
  },
  timeoutInMilliseconds: 90000,
  chromiumOptions: {
    gl: "vulkan",
    enableMultiProcessOnLinux: true,
  },
});
console.log(`Rendered composition ${composition.id}.`);
