const config = {
  use: {
    channel: "chromium",
    launchOptions: {
      args: [
        "--enable-features=Vulkan,UseSkiaRenderer",
        "--use-vulkan=swiftshader",
        "--enable-unsafe-webgpu",
        "--disable-vulkan-fallback-to-gl-for-testing",
        "--dignore-gpu-blocklist",
        "--use-angle=vulkan",
      ],
    },
  },
};
module.exports = config;
