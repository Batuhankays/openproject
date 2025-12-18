# Simple work package creator - no special chars
$Token = "72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679"
$Cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("apikey:$Token"))
$Headers = @{
    "Authorization" = "Basic $Cred"
    "Content-Type"  = "application/json"
}
$Base = "http://localhost:8200/api/v3"
$ProjectId = 3
$TypeId = 1

Write-Host "Creating 34 work packages..." -ForegroundColor Green

# Phase 1
$Body = "{`"subject`":`"Faz 1: Musteri Talebi`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$P1 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Faz 1 (ID: $($P1.id))" -ForegroundColor Cyan

# Children for Phase 1
$Names = @("Musteri Talebi", "Teknik Sartname", "Degerlendirme", "Uretilebirlik")
foreach ($N in $Names) {
    $Body = "{`"subject`":`"$N`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"},`"parent`":{`"href`":`"/api/v3/work_packages/$($P1.id)`"}}}"
    Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body | Out-Null
    Write-Host "  - $N" -ForegroundColor DarkGreen
}

# Phase 2
$Body = "{`"subject`":`"Faz 2: Proje Degerlendirme`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$P2 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Faz 2 (ID: $($P2.id))" -ForegroundColor Cyan

$Names = @("Toplanti", "Konfes", "Rapor")
foreach ($N in $Names) {
    $Body = "{`"subject`":`"$N`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"},`"parent`":{`"href`":`"/api/v3/work_packages/$($P2.id)`"}}}"
    Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body | Out-Null
    Write-Host "  - $N" -ForegroundColor DarkGreen
}

# Phase 3
$Body = "{`"subject`":`"Faz 3: Planlama`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$P3 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Faz 3 (ID: $($P3.id))" -ForegroundColor Cyan

$Names = @("Kaynak", "Takvim", "Butce", "Lojistik", "Kalite", "Risk", "Yonetim")
foreach ($N in $Names) {
    $Body = "{`"subject`":`"$N`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"},`"parent`":{`"href`":`"/api/v3/work_packages/$($P3.id)`"}}}"
    Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body | Out-Null
    Write-Host "  - $N" -ForegroundColor DarkGreen
}

# Phase 4
$Body = "{`"subject`":`"Faz 4: Yurutme`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$P4 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Faz 4 (ID: $($P4.id))" -ForegroundColor Cyan

$Names = @("Koordinasyon", "Dokuman", "Degisiklik", "Uygunsuzluk")
foreach ($N in $Names) {
    $Body = "{`"subject`":`"$N`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"},`"parent`":{`"href`":`"/api/v3/work_packages/$($P4.id)`"}}}"
    Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body | Out-Null
    Write-Host "  - $N" -ForegroundColor DarkGreen
}

# Phase 5
$Body = "{`"subject`":`"Faz 5: Izleme`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$P5 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Faz 5 (ID: $($P5.id))" -ForegroundColor Cyan

$Names = @("Kalite", "Kontrol", "Takvim", "Risk", "Toplanti")
foreach ($N in $Names) {
    $Body = "{`"subject`":`"$N`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"},`"parent`":{`"href`":`"/api/v3/work_packages/$($P5.id)`"}}}"
    Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body | Out-Null
    Write-Host "  - $N" -ForegroundColor DarkGreen
}

# Phase 6
$Body = "{`"subject`":`"Faz 6: Kapanis`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"}}}"
$P6 = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body
Write-Host "Created: Faz 6 (ID: $($P6.id))" -ForegroundColor Cyan

$Names = @("Teslimat", "Dokuman", "Lessons", "Rapor", "Arsiv")
foreach ($N in $Names) {
    $Body = "{`"subject`":`"$N`",`"_links`":{`"type`":{`"href`":`"/api/v3/types/$TypeId`"},`"project`":{`"href`":`"/api/v3/projects/$ProjectId`"},`"parent`":{`"href`":`"/api/v3/work_packages/$($P6.id)`"}}}"
    Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Method POST -Headers $Headers -Body $Body | Out-Null
    Write-Host "  - $N" -ForegroundColor DarkGreen
}

Write-Host "`nDONE! Created 34 work packages." -ForegroundColor Green
Write-Host "Check: http://localhost:8200/projects/sablon-proje-yonetimi/work_packages" -ForegroundColor White
