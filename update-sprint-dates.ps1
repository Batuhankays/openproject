# Update Sprint Dates for Copied Projects
# Usage: .\update-sprint-dates.ps1 -ProjectIdentifier "my-new-project" -ApiToken "your-token"

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectIdentifier,
    
    [Parameter(Mandatory = $false)]
    [string]$ApiToken = "72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679"
)

$Cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("apikey:$ApiToken"))
$Headers = @{
    "Authorization" = "Basic $Cred"
    "Content-Type"  = "application/json"
}
$Base = "http://localhost:8200/api/v3"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Sprint Date Updater" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Project: $ProjectIdentifier" -ForegroundColor Yellow

# Get project
try {
    $Project = Invoke-RestMethod -Uri "$Base/projects/$ProjectIdentifier" -Headers $Headers
    Write-Host "Found: $($Project.name)`n" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Project '$ProjectIdentifier' not found!`n" -ForegroundColor Red
    Write-Host "Make sure you've copied the template first." -ForegroundColor Yellow
    exit 1
}

# Get all versions
try {
    $Versions = Invoke-RestMethod -Uri "$Base/projects/$($Project.id)/versions" -Headers $Headers
}
catch {
    Write-Host "ERROR: Could not fetch versions!`n" -ForegroundColor Red
    exit 1
}

if ($Versions.total -eq 0) {
    Write-Host "No versions found. Sprint versions may not have been copied.`n" -ForegroundColor Yellow
    exit 0
}

Write-Host "Updating sprint dates to current...`n" -ForegroundColor Yellow

$Updated = 0
foreach ($Version in $Versions._embedded.elements) {
    if ($Version.name -match "Sprint (\d+)") {
        $SprintNum = [int]$Matches[1]
        
        # Calculate dates: Sprint 1 starts today, each sprint is 14 days
        $StartDate = (Get-Date).AddDays(($SprintNum - 1) * 14).ToString("yyyy-MM-dd")
        $EndDate = (Get-Date).AddDays($SprintNum * 14 - 1).ToString("yyyy-MM-dd")
        
        # Update version
        $Body = @{
            name          = "Sprint $SprintNum"
            startDate     = $StartDate
            effectiveDate = $EndDate
        } | ConvertTo-Json
        
        try {
            $UpdateUri = "$Base/versions/$($Version.id)"
            Invoke-RestMethod -Uri $UpdateUri -Method PATCH -Headers $Headers -Body $Body | Out-Null
            Write-Host "  Sprint $SprintNum`: $StartDate to $EndDate" -ForegroundColor Green
            $Updated++
        }
        catch {
            Write-Host "  ERROR updating Sprint $SprintNum" -ForegroundColor Red
        }
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
if ($Updated -gt 0) {
    Write-Host "SUCCESS! Updated $Updated sprint(s)" -ForegroundColor Green
}
else {
    Write-Host "No sprints were updated" -ForegroundColor Yellow
}
Write-Host "========================================`n" -ForegroundColor Cyan
