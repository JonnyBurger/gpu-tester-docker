FROM nvidia/vulkan:1.2.133-450

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install nodejs -y

COPY gpu.spec.js gpu.spec.js
COPY package.json package.json
COPY playwright.config.js playwright.config.js


RUN npm install

RUN PLAYWRIGHT_BROWSERS_PATH=/tests/.cache/ms-playwright npx playwright install chromium
RUN apt install -y libglib2.0-0 libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdbus-1-3 libxcomposite1 libxdamage1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0
RUN PLAYWRIGHT_BROWSERS_PATH=/tests/.cache/ms-playwright npx playwright test gpu.spec.js
