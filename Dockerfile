FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install ngrok
RUN apt-get update && apt-get install -y wget unzip \
    && wget -q -O /tmp/ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
    && unzip -d /usr/local/bin /tmp/ngrok.zip \
    && rm /tmp/ngrok.zip \
    && apt-get purge -y wget unzip \
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
