FROM python:3.11-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install ngrok
# This version uses curl and a more robust tar command to prevent extraction errors.
RUN apt-get update && apt-get install -y curl tar \
    && ARCH=$(dpkg --print-architecture) \
    && echo "Detected architecture: ${ARCH}" \
    && case "${ARCH}" in \
        amd64)   NARCH="amd64" ;; \
        arm64)   NARCH="arm64" ;; \
        armhf)   NARCH="arm" ;; \
        armel)   NARCH="arm" ;; \
        *)       echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
    esac \
    && echo "Downloading ngrok for architecture: ${NARCH}" \
    && curl -L -o /tmp/ngrok.tgz "https://ngrok-agent.s3.amazonaws.com/ngrok-v3-stable-linux-${NARCH}.tgz" \
    && tar xvf /tmp/ngrok.tgz -C /usr/local/bin \
    && chmod +x /usr/local/bin/ngrok \
    && apt-get purge -y --autoremove curl tar \
    && rm -rf /var/lib/apt/lists/* \
    && rm /tmp/ngrok.tgz

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
