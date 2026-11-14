# Download the AI model (one file, about 2 GB) into the "models" folder.
# curl comes with Windows. "-C -" lets you re-run this to resume if it stops.

curl.exe -L -C - -o models\Llama-3.2-3B-Instruct-Q4_K_M.gguf https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf
