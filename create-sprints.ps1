# Create Sprint Versions
$Token = "72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679"
$Cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("apikey:$Token"))
$Headers = @{
    "Authorization" = "Basic $Cred"
    "Content-Type"  = "application/json"
}
$Base = "http://localhost:8200/api/v3"
$ProjectId = 3

Write-Host "Creating sprint versions..." -ForegroundColor Green

# Sprint 1
$StartDate = (Get-Date).ToString("yyyy-MM-dd")
$EndDate = (Get-Date).AddDays(14).ToString("yyyy-MM-dd")
$Body = "{`"name`":`"Sprint 1`",`"startDate`":`"$StartDate`",`"endDate`":`"$EndDate`",`"_links`":{`"definingProject`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$V1 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/versions" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Sprint 1 (ID: $($V1.id))" -Fore groundColor Cyan

# Sprint 2
$StartDate = (Get-Date).AddDays(14).ToString("yyyy-MM-dd")
$EndDate = (Get-Date).AddDays(28).ToString("yyyy-MM-dd")
$Body = "{`"name`":`"Sprint 2`",`"startDate`":`"$StartDate`",`"endDate`":`"$EndDate`",`"_links`":{`"definingProject`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$V2 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/versions" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Sprint 2 (ID: $($V2.id))" -ForegroundColor Cyan

# Sprint 3
$StartDate = (Get-Date).AddDays(28).ToString("yyyy-MM-dd")
$EndDate = (Get-Date).AddDays(42).ToString("yyyy-MM-dd")
$Body = "{`"name`":`"Sprint 3`",`"startDate`":`"$StartDate`",`"endDate`":`"$EndDate`",`"_links`":{`"definingProject`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$V3 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/versions" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Sprint 3 (ID: $($V3.id))" -ForegroundColor Cyan

# Sprint 4
$StartDate = (Get-Date).AddDays(42).ToString("yyyy-MM-dd")
$EndDate = (Get-Date).AddDays(56).ToString("yyyy-MM-dd")
$Body = "{`"name`":`"Sprint 4`",`"startDate`":`"$StartDate`",`"endDate`":`"$EndDate`",`"_links`":{`"definingProject`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$V4 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/versions" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Sprint 4 (ID: $($V4.id))" -ForegroundColor Cyan

Write-Host "`nDONE! Created 4 sprint versions." -ForegroundColor Green
