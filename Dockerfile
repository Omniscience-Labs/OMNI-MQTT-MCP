# Stage 1: Download and extract the correct ngrok binary
FROM debian:bookworm-slim as ngrok_downloader

# Install build dependencies, determine architecture, and download the correct ngrok binary
RUN apt-get update && apt-get install -y wget tar \
    && ARCH=$(dpkg --print-architecture) \
    && echo "Detected architecture: ${ARCH}" \
    && case "${ARCH}" in \
        amd64)   NARCH="amd64" ;; \
        arm64)   NARCH="arm64" ;; \
        armhf)   NARCH="arm" ;; \
        armel)   NARCH="arm" ;; \
        *)       echo "Unsupported architecture by this Dockerfile: ${ARCH}" >&2; exit 1 ;; \
    esac \
    && echo "Downloading ngrok for architecture: ${NARCH}" \
    && wget -q -O /ngrok.tgz "https://ngrok-agent.s3.amazonaws.com/ngrok-v3-stable-linux-${NARCH}.tgz" \
    && tar xvz -C /usr/local/bin -f /ngrok.tgz \
    && chmod +x /usr/local/bin/ngrok \
    && apt-get purge -y --autoremove wget tar \
    && rm -rf /var/lib/apt/lists/*

# Stage 2: Build the main application image
FROM python:3.11-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the ngrok binary from the downloader stage
COPY --from=ngrok_downloader /usr/local/bin/ngrok /usr/local/bin/

# Copy application files
COPY mqtt_mcp_server.py ./
COPY traffic-policy.yml ./
COPY start.sh ./

# Default environment variables
ENV TRANSPORT=sse \
    FASTMCP_HOST=0.0.0.0 \
    FASTMCP_PORT=8000 \
    MQTT_BROKER_ADDRESS=localhost \
    MQTT_PORT=1883 \
    MQTT_CLIENT_ID=mcp-mqtt-client \
    MQTT_USERNAME= \
    MQTT_PASSWORD=

EXPOSE 8000

CMD ["./start.sh"]
