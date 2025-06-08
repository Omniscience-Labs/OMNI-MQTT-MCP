#!/bin/sh
set -e

# Configure ngrok if token provided
if [ -n "$NGROK_AUTHTOKEN" ]; then
    ngrok config add-authtoken "$NGROK_AUTHTOKEN"
fi

# Default environment variables for MCP server
# These mirror the CLI arguments in mqtt_mcp_server.py
: "${TRANSPORT:=sse}"
: "${FASTMCP_PORT:=8000}"
: "${MQTT_BROKER_ADDRESS:=localhost}"
: "${MQTT_PORT:=1883}"
: "${MQTT_CLIENT_ID:=mcp-mqtt-client}"
# MQTT_USERNAME and MQTT_PASSWORD are optional

# Start ngrok tunnel in background
# Exposes the configured FASTMCP_PORT over HTTP
ngrok http "$FASTMCP_PORT" --log=stdout &

# Start MQTT MCP server with env-configurable CLI arguments
exec python mqtt_mcp_server.py \
    --transport "$TRANSPORT" \
    --broker "$MQTT_BROKER_ADDRESS" \
    --port "$MQTT_PORT" \
    --client-id "$MQTT_CLIENT_ID" \
    ${MQTT_USERNAME:+--username "$MQTT_USERNAME"} \
    ${MQTT_PASSWORD:+--password "$MQTT_PASSWORD"}
