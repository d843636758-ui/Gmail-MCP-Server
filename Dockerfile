FROM node:20-slim

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Copy source files and config first
COPY tsconfig.json ./
COPY src ./src

# Install dependencies (which will trigger build via prepare script)
RUN npm ci

# Create directory for credentials and config
RUN mkdir -p /gmail-server /root/.gmail-mcp

# Set environment variables
ENV NODE_ENV=production
ENV GMAIL_CREDENTIALS_PATH=/gmail-server/credentials.json
ENV GMAIL_OAUTH_PATH=/root/.gmail-mcp/gcp-oauth.keys.json

# 暴露端口
EXPOSE 3000

# 创建启动脚本，从环境变量生成密钥文件后启动
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "$GMAIL_OAUTH_JSON" > /root/.gmail-mcp/gcp-oauth.keys.json' >> /start.sh && \
    echo 'exec node dist/index.js' >> /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]
