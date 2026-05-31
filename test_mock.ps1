$baseUrl = "https://mock.apidog.com/m1/1212435-1208182-1270861/api"

function Test-Endpoint {
    param(
        [string]$Method,
        [string]$Path,
        [string]$Body = $null
    )
    
    $url = "$baseUrl$Path"
    Write-Host "========================================="
    Write-Host "Testing: $Method $Path"
    
    try {
        if ($Body) {
            $response = Invoke-RestMethod -Method $Method -Uri $url -ContentType "application/json" -Body $Body -ErrorAction Stop
        } else {
            $response = Invoke-RestMethod -Method $Method -Uri $url -ContentType "application/json" -ErrorAction Stop
        }
        
        $json = $response | ConvertTo-Json -Depth 10
        Write-Host "Status: Success"
        Write-Host $json
    } catch {
        Write-Host "Status: Failed"
        Write-Host $_.Exception.Message
        if ($_.ErrorDetails) {
            Write-Host $_.ErrorDetails.Message
        }
    }
    Write-Host ""
}

Test-Endpoint -Method GET -Path "/meetings/1"
Test-Endpoint -Method POST -Path "/meetings/1/leave" -Body '{"participantId": "1"}'
Test-Endpoint -Method POST -Path "/meetings/1/end" -Body '{}'
Test-Endpoint -Method GET -Path "/meetings/1/participants"
Test-Endpoint -Method POST -Path "/meetings/1/participants/1/consent" -Body '{"recordingConsent": true}'
Test-Endpoint -Method DELETE -Path "/meetings/1/participants/1"
Test-Endpoint -Method GET -Path "/meetings/1/invitations"
Test-Endpoint -Method POST -Path "/meetings/1/invitations/project-members" -Body '{"memberIds": ["1"], "role": "PARTICIPANT"}'
Test-Endpoint -Method POST -Path "/meetings/1/invitations/stakeholders" -Body '{"role": "PARTICIPANT", "stakeholderIds": ["1"]}'
Test-Endpoint -Method POST -Path "/meetings/1/invitations/guests" -Body '{"role": "PARTICIPANT", "guests": [{"displayName": "Guest", "email": "guest@test.com"}], "expiresAt": "2026-06-01T00:00:00.000Z"}'
Test-Endpoint -Method POST -Path "/meetings/1/invitations/1/resend" -Body '{}'
Test-Endpoint -Method DELETE -Path "/meetings/1/invitations/1"
Test-Endpoint -Method POST -Path "/meetings/1/recordings/start" -Body '{"uploadMode": "CHUNKED", "mimeType": "audio/webm"}'
Test-Endpoint -Method POST -Path "/recordings/1/stop" -Body '{"durationSeconds": 10, "lastChunkIndex": 1}'
Test-Endpoint -Method GET -Path "/recordings/1"
Test-Endpoint -Method GET -Path "/projects/1/members"
Test-Endpoint -Method GET -Path "/projects/1/stakeholders"
