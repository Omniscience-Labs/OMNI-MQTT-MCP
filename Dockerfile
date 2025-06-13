FROM python:3.11-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

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
