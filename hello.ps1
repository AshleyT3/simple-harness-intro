# Send one message to the local AI model and print its answer.
# (Start the model first with start-model.ps1)

$request = @{
    messages = @(
        @{ role = "user"; content = "Hello, how are you? Who are you?" }
    )
} | ConvertTo-Json -Depth 5

$response = Invoke-RestMethod -Uri "http://127.0.0.1:8080/v1/chat/completions" -Method Post -ContentType "application/json" -Body $request

Write-Host $response.choices[0].message.content
