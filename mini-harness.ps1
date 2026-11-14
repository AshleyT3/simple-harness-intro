# ==========================================================================
#  mini-harness.ps1  -  the smallest possible AI "agent"
#
#  The AI model can only write text. It cannot touch your computer.
#  This script (the "harness") is its arms and legs - and we only give it ONE:
#
#      list_files  -  list what is in a folder (inside the allowed folder only)
#
#  The model ASKS by writing a special line:   TOOL: list_files <folder>
#  The harness reads that line and decides. Anything else is refused.
#
#  Start the model first with start-model.ps1, then run this script.
#  Type "exit" to quit.
# ==========================================================================

$ServerUrl     = "http://127.0.0.1:8080/v1/chat/completions"
$AllowedFolder = (Get-Location).Path      # the model may only look inside this folder
$MaxToolUses   = 5                        # stop the model if it keeps asking for tools


# --------------------------------------------------------------------------
#  1. Instructions for the model. This is just text it reads.
#     It tells the model what it may ask for, and how to ask.
# --------------------------------------------------------------------------
$Instructions = @"
You are a helpful assistant running on the user's computer.

You have ONE tool. It lists the files in a folder. To use it, reply with exactly this one line and nothing else:
TOOL: list_files <folder>

Use . for the current folder. The harness will send you a message starting with TOOL RESULT. Use it to answer the user.
Only use the tool when the user asks about files. For anything else, just answer normally.
"@


# --------------------------------------------------------------------------
#  2. The tool itself - real PowerShell code that the HARNESS runs, never the model.
#     It checks the folder is inside the allowed folder before doing anything.
# --------------------------------------------------------------------------
function List-Files($folder) {

    if (-not $folder) { $folder = "." }

    # Work out the full path the model is asking about
    $fullPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($AllowedFolder, $folder))

    # The guard: is it inside the allowed folder?
    $isInside = ($fullPath -eq $AllowedFolder) -or
                $fullPath.StartsWith($AllowedFolder + "\", [System.StringComparison]::OrdinalIgnoreCase)

    if (-not $isInside) {
        return "REFUSED: '$folder' is outside the allowed folder."
    }

    if (-not (Test-Path $fullPath -PathType Container)) {
        return "There is no folder named '$folder'."
    }

    $names = Get-ChildItem $fullPath | ForEach-Object { $_.Name }
    if (-not $names) { return "(the folder is empty)" }
    return ($names -join "`n")
}


# --------------------------------------------------------------------------
#  3. Send the whole conversation so far to the model, get its reply (text).
# --------------------------------------------------------------------------
function Ask-Model($messages) {

    $request = @{ messages = $messages } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri $ServerUrl -Method Post -ContentType "application/json" -Body $request
    return $response.choices[0].message.content
}


# --------------------------------------------------------------------------
#  4. The loop: you ask -> model answers, or asks for a tool -> harness decides.
# --------------------------------------------------------------------------

# The conversation. The model remembers nothing on its own,
# so we send ALL of this every time.
$Messages = @(
    @{ role = "system"; content = $Instructions }
)

Write-Host "Mini harness ready. Allowed folder: $AllowedFolder" -ForegroundColor Cyan
Write-Host "Type 'exit' to quit." -ForegroundColor Cyan

while ($true) {

    Write-Host ""
    $question = Read-Host "You"
    if ($question -eq "exit") { break }

    $Messages += @{ role = "user"; content = $question }
    $toolUses = 0

    while ($true) {

        $reply = Ask-Model $Messages
        $Messages += @{ role = "assistant"; content = $reply }

        # Is the model asking for a tool? (Does its reply start with "TOOL:"?)
        $firstLine = ($reply.Trim() -split "`n")[0].Trim()

        if (-not $firstLine.StartsWith("TOOL:")) {
            # No - this is the model's answer to you.
            Write-Host "AI: $reply" -ForegroundColor Green
            break
        }

        # Yes. Only the TOOL line counts. (Small models sometimes keep writing
        # and invent a result - we ignore anything after the TOOL line.)
        Write-Host "  [model asks harness: $firstLine]" -ForegroundColor DarkYellow

        $toolUses++
        if ($toolUses -gt $MaxToolUses) {
            Write-Host "  [harness: too many tool requests - stopping]" -ForegroundColor Red
            break
        }

        # Split "TOOL: list_files <folder>" into the tool name and the folder
        $parts    = $firstLine.Substring(5).Trim() -split " ", 2
        $toolName = $parts[0]
        $folder   = if ($parts.Count -gt 1) { $parts[1] } else { "." }

        # The harness decides what really happens
        if ($toolName -eq "list_files") {
            $result = List-Files $folder
        }
        else {
            $result = "REFUSED: there is no tool named '$toolName'."
        }

        Write-Host "  [harness replies: $($result -replace "`n", ', ')]" -ForegroundColor DarkYellow

        # Hand the result back to the model, then let it continue
        $Messages += @{ role = "user"; content = "TOOL RESULT:`n$result" }
    }
}
