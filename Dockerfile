FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1  \
    libgles2  \
    libxcb1-dev \
    wget \
    vulkan-tools \
    && rm -rf /var/lib/apt/lists/*

# Download the Vulkan SDK and extract the headers, loaders, layers and binary utilities
RUN wget -q --show-progress \
    --progress=bar:force:noscroll \
    https://sdk.lunarg.com/sdk/download/latest/linux/vulkan_sdk.tar.gz \
    -O /tmp/vulkansdk-linux-x86_64-1.3.261.1.tar.gz \ 
    && echo "Installing Vulkan SDK 1.3.261.1" \
    && mkdir -p /opt/vulkan \
    && tar -xf /tmp/vulkansdk-linux-x86_64-1.3.261.1.tar.gz -C /opt/vulkan \
    && mkdir -p /usr/local/include/ && cp -ra /opt/vulkan/1.3.261.1/x86_64/include/* /usr/local/include/ \
    && mkdir -p /usr/local/lib && cp -ra /opt/vulkan/1.3.261.1/x86_64/lib/* /usr/local/lib/ \
    && cp -a /opt/vulkan/1.3.261.1/x86_64/lib/libVkLayer_*.so /usr/local/lib \
    && mkdir -p /usr/local/share/vulkan/explicit_layer.d \
    && cp /opt/vulkan/1.3.261.1/x86_64/etc/vulkan/explicit_layer.d/VkLayer_*.json /usr/local/share/vulkan/explicit_layer.d \
    && mkdir -p /usr/local/share/vulkan/registry \
    && cp -a /opt/vulkan/1.3.261.1/x86_64/share/vulkan/registry/* /usr/local/share/vulkan/registry \
    && cp -a /opt/vulkan/1.3.261.1/x86_64/bin/* /usr/local/bin \
    && ldconfig \
    && rm /tmp/vulkansdk-linux-x86_64-1.3.261.1.tar.gz && rm -rf /opt/vulkan

# Setup the required capabilities for the container runtime    
ENV NVIDIA_DRIVER_CAPABILITIES compute,graphics,utility

RUN wget https://us.download.nvidia.com/tesla/535.104.05/nvidia-driver-local-repo-ubuntu2204-535.104.05_1.0-1_amd64.deb
RUN dpkg -i nvidia-driver-local-repo-ubuntu2204-535.104.05_1.0-1_amd64.deb
RUN cp /var/nvidia-driver-local-repo-ubuntu2204-535.104.05/nvidia-driver-local-62140ACB-keyring.gpg /usr/share/keyrings/
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install cuda-drivers

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install nodejs -y
RUN apt-get install -y libvulkan1


WORKDIR /usr/app

COPY package.json package.json
COPY remotion.config.ts remotion.config.ts
COPY tsconfig.json tsconfig.json
COPY src src

RUN npm install

COPY open-browser.js node_modules/@remotion/renderer/dist/open-browser.js

COPY nvidia_icd.json /etc/vulkan/icd.d/nvidia_icd.json

RUN apt install -y libglib2.0-0 libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdbus-1-3 libxcomposite1 libxdamage1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 libxkbcommon0 libxrandr2 libc6 libnvidia-gl-440
COPY render.mjs render.mjs

RUN PLAYWRIGHT_BROWSERS_PATH=/tests/.cache/ms-playwright npx playwright install chromium
RUN PLAYWRIGHT_BROWSERS_PATH=/tests/.cache/ms-playwright npx playwright test gpu.spec.js


ENTRYPOINT [ "node", "render.mjs" ]
