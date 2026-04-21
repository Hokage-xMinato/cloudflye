FROM kasmweb/desktop:1.16.0-rolling-daily

ENV DEBIAN_FRONTEND=noninteractive

# Switch to root for all system installs
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.10 \
        python3.10-venv \
        python3.10-dev \
        python3-pip \
        wget \
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

RUN wget -q https://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_126.0.6478.126-1_amd64.deb && \
    apt-get install -y --fix-broken ./google-chrome-stable_126.0.6478.126-1_amd64.deb && \
    rm google-chrome-stable_126.0.6478.126-1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN chown -R 1000:1000 /app

USER 1000

RUN python3.10 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

COPY --chown=1000:1000 . .

RUN /app/venv/bin/pip install --no-cache-dir -e .

RUN wget -q https://github.com/zetxtech/wssocks/releases/download/v1.4.2/wssocks-linux-amd64 -O /app/wssocks && \
    chmod +x /app/wssocks

USER root
COPY docker_startup.sh /
RUN chmod +x /docker_startup.sh

EXPOSE 7860

USER 1000

CMD ["/docker_startup.sh", "-K", "$CLIENT_KEY", "-P", "7860", "-M", "2", "-H", "0.0.0.0", "-T", "30"]
