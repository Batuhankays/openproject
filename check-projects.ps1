# Check existing projects and create boards
$token = "382db85caaf02801d8412adbbc9d41cbde9a1388950298e6f43c1bee5b4bd317"
$credentials = "apikey:$token"
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))

$headers = @{
    "Authorization" = "Basic $encodedCredentials"
    "Content-Type"  = "application/json"
}

$baseUrl = "http://localhost:8200/api/v3"

Write-Host "Checking existing projects..." -ForegroundColor Cyan

try {
    $projects = Invoke-RestMethod -Uri "$baseUrl/projects" -Headers $headers
    
    Write-Host "`nExisting Projects:" -ForegroundColor Yellow
    foreach ($proj in $projects._embedded.elements) {
        Write-Host "  - $($proj.name) (ID: $($proj.id), Identifier: $($proj.identifier))" -ForegroundColor White
    }
    
    # Find the template project
    $template = $projects._embedded.elements | Where-Object { $_.identifier -eq "sablon-proje-yonetimi" }
    
    if ($template) {
        Write-Host "`nTemplate project found!" -ForegroundColor Green
        Write-Host "  ID: $($template.id)" -ForegroundColor White
        Write-Host "  Name: $($template.name)" -ForegroundColor White
        
        # Check work packages
        $wps = Invoke-RestMethod -Uri "$baseUrl/projects/$($template.id)/work_packages" -Headers $headers
        Write-Host "`n  Work Packages: $($wps.total)" -ForegroundColor White
    }
    else {
        Write-Host "`nWARNING: Template project not found!" -ForegroundColor Red
    }
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
