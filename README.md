# Ollama Multi GPU
Run the same model on the multi GPUs using Ollama


## Service if you are using SH version
```
[Unit]
Description=Ollama Multi-GPU Service
After=network.target
# Add a delay using sleep
ExecStartPre=/bin/sleep 30

[Service]
Type=simple
User=root
Group=root
ExecStart=/home/user/scripts/ollama_multi.sh
WorkingDirectory=/home/user/scripts
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

## Docker
Just copy docker-composer.yml and change the configs:
- container_name
- OLLAMA_HOST - increse the port number for each GPU
- ROCR_VISIBLE_DEVICES

