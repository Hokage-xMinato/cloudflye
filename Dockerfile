FROM kasmweb/desktop:1.16.0-rolling-daily-ubuntu-jammy

ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        python3-dev \
        python3-pip \
        wget \
        curl \
        gnupg \
        ca-certificates \
        libx11-xcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libxss1 \
        libxtst6 \
        libnss3 \
        libatk-bridge2.0-0 \
        libgtk-3-0 \
        x11-apps \
        fonts-liberation \
        libappindicator3-1 \
        libu2f-udev \
        libvulkan1 \
        libdrm2 \
        xdg-utils \
        xvfb \
        libasound2 \
        libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# Remove any existing broken Chrome repo/key entries from base image
RUN rm -f /etc/apt/sources.list.d/google-chrome*.list \
          /etc/apt/sources.list.d/google*.list \
          /usr/share/keyrings/google-chrome*.gpg \
          /etc/apt/trusted.gpg.d/google*.gpg

# Add fresh Chrome repo with correct key
RUN curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | \
        gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
        > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN chown -R 1000:1000 /app

USER 1000

RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

COPY --chown=1000:1000 . .

RUN /app/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /app/venv/bin/pip install --no-cache-dir -e .

RUN wget -q https://github.com/zetxtech/wssocks/releases/download/v1.4.2/wssocks-linux-amd64 -O /app/wssocks && \
    chmod +x /app/wssocks

USER root
COPY docker_startup.sh /
RUN chmod +x /docker_startup.sh

EXPOSE 7860

USER 1000

CMD ["/docker_startup.sh", "-K", "$CLIENT_KEY", "-P", "7860", "-M", "2", "-H", "0.0.0.0", "-T", "30"]
