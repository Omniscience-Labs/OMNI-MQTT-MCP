# Stage 1: Download and extract the correct ngrok binary
FROM debian:bookworm-slim as ngrok_downloader

# Docker's automatic platform ARG
ARG TARGETARCH

# Install wget, determine ngrok architecture, download, and make executable
RUN apt-get update && apt-get install -y wget tar \
    && case ${TARGETARCH} in \
        amd64)   NARCH="amd64" ;; \
        arm64)  NARCH="arm64" ;; \
        arm) NARCH="arm" ;; \
        *)        echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && wget -q -O /ngrok.tgz "https://ngrok-agent.s3.amazonaws.com/ngrok-v3-stable-linux-${NARCH}.tgz" \
    && tar xvz -C /usr/local/bin -f /ngrok.tgz \
    && chmod +x /usr/local/bin/ngrok \
    && apt-get purge -y wget tar \
    && apt-get autoremove -y && apt-get clean \
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
