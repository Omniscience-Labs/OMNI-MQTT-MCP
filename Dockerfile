FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install ngrok
RUN apt-get update && apt-get install -y wget tar \
    && ARCH=$(dpkg --print-architecture) \
    && case $ARCH in \
        amd64)   NARCH="amd64" ;; \
        arm64)  NARCH="arm64" ;; \
        *)        echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; \
    esac \
    && wget -q -O /tmp/ngrok.tgz "https://ngrok-agent.s3.amazonaws.com/ngrok-v3-stable-linux-${NARCH}.tgz" \
    && tar xvz -C /usr/local/bin -f /tmp/ngrok.tgz \
    && rm /tmp/ngrok.tgz \
    && apt-get purge -y wget tar \
    && apt-get autoremove -y && apt-get clean

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
