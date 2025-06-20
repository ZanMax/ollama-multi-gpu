#!/bin/bash
# This script pre-loads a specified model into multiple Ollama instances.
# It first runs a simple prompt to warm up the model, then sets keep_alive to -1.

# --- Configuration ---
MODEL_TO_LOAD="mistral-small:latest"
PORTS=(11500 11501 11502 11503 11504)
# ---------------------

echo "--- Starting model pre-loading ---"
echo "Model to load: ${MODEL_TO_LOAD}"
echo ""

for port in "${PORTS[@]}"; do
  echo "[Port ${port}] Sending warm-up prompt..."

  curl -s http://localhost:${port}/api/generate -d '{
    "model": "'"${MODEL_TO_LOAD}"'",
    "prompt": "Return a random digit from 0 to 10."
  }' > /dev/null

  if [ $? -eq 0 ]; then
    echo "[Port ${port}] Warm-up prompt sent."

    echo "[Port ${port}] Setting keep_alive to -1..."
    curl -s http://localhost:${port}/api/generate -d '{
      "model": "'"${MODEL_TO_LOAD}"'",
      "keep_alive": -1
    }' > /dev/null

    if [ $? -eq 0 ]; then
      echo "[Port ${port}] keep_alive set successfully."
    else
      echo "[Port ${port}] Error: Failed to set keep_alive."
    fi
  else
    echo "[Port ${port}] Error: Failed to send warm-up prompt. Is the service running?"
  fi

  echo ""
done

echo "--- Pre-loading process complete. ---"
