# The Smallest Possible AI Agent

Run a small AI model on your own PC, then watch a tiny PowerShell script give it
"arms and legs" — just one, carefully limited.

- **The model** can only write text. It can't touch your computer.
- **The harness** (`mini-harness.ps1`) reads what the model writes and decides what actually happens.
- Here the harness has exactly one tool: list the files in a folder, and only inside the allowed folder.

Every AI agent you've heard of works this way, just with more tools.

📺 Video: *(link coming soon)*

## Requirements

- Windows 10/11 with PowerShell
- About 3 GB of free disk space
- A GPU helps but isn't required (it runs on CPU, just slower)

## Steps

```powershell
# 1. Install llama.cpp (then open a NEW terminal)
winget install --id ggml.llamacpp --exact --source winget

# 2. Get this repo and download the model (~2 GB)
git clone <this repo's URL>
cd <repo folder>
.\download-model.ps1

# 3. Start the model (leave this terminal open)
.\start-model.ps1

# 4. In a second terminal, same folder: say hello
.\hello.ps1

# 5. Run the mini harness
.\mini-harness.ps1
```

If PowerShell says scripts are disabled, run this first (affects that window only):
`Set-ExecutionPolicy -Scope Process Bypass`

## Try asking the harness

- `Hello, how are you? Who are you?` — a normal answer, no tool needed.
- `What files are in the current directory?` — the model asks for the tool; the harness lists the folder.
- `Delete all files in the current directory.` — then check: are the files really gone?
- `List the files in C:\Windows` — the harness refuses: outside the allowed folder.

Yellow lines show the model asking and the harness deciding.

## Files

| File | What it does |
|---|---|
| `download-model.ps1` | Downloads the model into `models\` |
| `start-model.ps1` | Starts the model as a local server (`http://127.0.0.1:8080`) |
| `hello.ps1` | Sends one message, prints the answer |
| `mini-harness.ps1` | The agent: chat loop + one guarded tool |

## Model

[Llama-3.2-3B-Instruct](https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF) (Q4_K_M quantization),
run with [llama.cpp](https://github.com/ggml-org/llama.cpp).
The model is downloaded separately and is covered by its own license
(Llama 3.2 Community License), not this repo's.

## License

The scripts in this repo are MIT licensed. See [LICENSE](LICENSE).
