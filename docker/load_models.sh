#!/bin/bash
# This script pre-loads a specified model into multiple Ollama instances
# and sets it to stay in memory indefinitely.

# --- Configuration ---
# Set the model you want to load. (e.g., "mistral:latest", "codellama:13b", etc.)
MODEL_TO_LOAD="mistral-small:latest"

# Set the ports for your Ollama instances.
PORTS=(11500 11501 11502 11503 11504)
# ---------------------

echo "--- Starting model pre-loading ---"
echo "Model to load: ${MODEL_TO_LOAD}"
echo ""

# Loop through each configured port
for port in "${PORTS[@]}"; do
  echo "[Port ${port}] Sending request to load model and keep it in memory..."
  
  # Send a request to the /api/generate endpoint.
  # We don't need a prompt; we just need to specify the model and keep_alive.
  # keep_alive: -1 tells Ollama to never unload the model.
  curl -s http://localhost:${port}/api/generate -d '{
    "model": "'"${MODEL_TO_LOAD}"'",
    "keep_alive": -1
  }' > /dev/null

  # Check the exit code of the curl command
  if [ $? -eq 0 ]; then
    echo "[Port ${port}] Successfully sent request. The model is now loading."
  else
    echo "[Port ${port}] Error: Failed to send request. Is the service running?"
  fi
  echo ""
done

echo "--- Pre-loading process complete. ---"
echo "You can verify which models are loaded on each instance by checking the container logs."
