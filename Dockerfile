FROM nvidia/vulkan:1.3-470

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install nodejs -y

WORKDIR /usr/app

COPY package.json package.json
COPY remotion.config.ts remotion.config.ts
COPY tsconfig.json tsconfig.json
COPY render.mjs render.mjs
COPY src src

RUN npm install

RUN apt install -y libglib2.0-0 libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdbus-1-3 libxcomposite1 libxdamage1 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0 libxkbcommon0 libxrandr2 libc6
ENTRYPOINT [ "node", "render.mjs" ]
