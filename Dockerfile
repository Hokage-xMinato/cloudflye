# Use the official Ubuntu image as the base image
FROM kasmweb/desktop:1.16.0-rolling-daily

# Set environment variables to avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages — must run as root (default)
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
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
        libcurl4 \
        libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# Add Google Chrome repository and install Google Chrome
RUN wget https://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_126.0.6478.126-1_amd64.deb && \
    dpkg -i google-chrome-stable_126.0.6478.126-1_amd64.deb && \
    rm google-chrome-stable_126.0.6478.126-1_amd64.deb

# Set up a working directory and give user 1000 ownership
WORKDIR /app
RUN chown -R 1000:1000 /app

# Switch to non-root user for app setup
USER 1000

# Create and activate virtual environment
RUN python3.10 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Copy application files
COPY --chown=1000:1000 . .

# Install Python dependencies in venv
RUN /app/venv/bin/pip install -e .

# Download wssocks and make it executable
RUN wget https://github.com/zetxtech/wssocks/releases/download/v1.4.2/wssocks-linux-amd64 -O /app/wssocks && \
    chmod +x /app/wssocks

# Switch back to root to copy and chmod the startup script
USER root
COPY docker_startup.sh /
RUN chmod +x /docker_startup.sh

# Expose the port for the FastAPI server
EXPOSE 7860

# Switch back to user 1000 for runtime (if desired)
USER 1000

# Default command
CMD ["/docker_startup.sh", "-K", "$CLIENT_KEY", "-P", "7860", "-M", "2", "-H", "0.0.0.0", "-T", "30"]
