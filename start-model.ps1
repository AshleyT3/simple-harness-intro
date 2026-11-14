# Start the AI model as a local server at http://127.0.0.1:8080
#   -m       the model file
#   -c 8192  context size in tokens (how much text it can keep in mind at once)
# Leave this window open while you use the model. Ctrl+C stops it.

llama-server -m models\Llama-3.2-3B-Instruct-Q4_K_M.gguf -c 8192 --port 8080
