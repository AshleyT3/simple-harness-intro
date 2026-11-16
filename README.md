# The Smallest Possible AI Agent

Run a small AI model on your own PC, then watch a tiny PowerShell script give it
"arms and legs" — just one, carefully limited.

- **The model** can only write text. It can't touch your computer.
- **The harness** (`mini-harness.ps1`) reads what the model writes and decides what actually happens.
- Here the harness has exactly one tool: list the files in a folder, and only inside the allowed folder.

Every AI agent you've heard of works this way, just with more tools.

📺 Video: [How an AI Harness Works: PowerShell + a Local LLM (llama.cpp)](https://www.youtube.com/watch?v=blFjc03h_Cc)

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

This is a small model (about 2 GB), released in 2024, that runs on an ordinary PC.
Larger and newer models are far more capable; this one keeps the mechanics easy to see.

### Verify the download

Download only from the repo above, and watch for lookalike repo names.
Then check the file's SHA256 hash:

```powershell
Get-FileHash models\Llama-3.2-3B-Instruct-Q4_K_M.gguf -Algorithm SHA256
```

Expected:

```
6C1A2B41161032677BE168D354123594C0E6E67D2B9227C84F296AD037C728FF
```

It should also match the SHA256 shown on the file's page on Hugging Face.

### Using a different model

You can swap in another model, as long as it is:

- **A text-generation model**, not an image, audio, or embedding model.
- **An instruct (chat) version**, not a "base" model. Base models don't follow the system prompt well.
- **In GGUF format**, which is what llama.cpp runs.

Download it into `models\`, then change the filename after `-m` in `start-model.ps1`.
The same download advice applies: use a source you trust, and verify the hash.
How reliably a model writes the `TOOL:` line varies; larger models usually do better.

## License

The scripts in this repo are MIT licensed. See [LICENSE](LICENSE).
