# Assign Teams to Work Packages - Simple Version
$Token = "72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679"
$Cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("apikey:$Token"))
$Headers = @{
    "Authorization" = "Basic $Cred"
    "Content-Type"  = "application/json"
}
$Base = "http://localhost:8200/api/v3"
$ProjectId = 3

Write-Host "Assigning teams..."

# Get work packages
$WPs = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Headers $Headers

# Get team group IDs
$Groups = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/available_assignees" -Headers $Headers
$PM = ($Groups._embedded.elements | Where-Object { $_.name -match "Proje" }).id
$Tech = ($Groups._embedded.elements | Where-Object { $_.name -match "Teknik" }).id
$Quality = ($Groups._embedded.elements | Where-Object { $_.name -match "Kalite" }).id
$Finance = ($Groups._embedded.elements | Where-Object { $_.name -match "Finans" }).id
$Logistics = ($Groups._embedded.elements | Where-Object { $_.name -match "Lojistik" }).id

Write-Host "Groups: PM=$PM Tech=$Tech Quality=$Quality Finance=$Finance Logistics=$Logistics"

# Assignment map: task keyword -> team ID
$Map = @{
    "Musteri"        = $PM
    "Sartname"       = $Tech
    "Degerlendirme"  = $PM
    "Uretilebirlik"  = $PM
    "Toplanti"       = $PM
    "Konfes"         = $Tech
    "Rapor"          = $PM
    "Kaynak"         = $PM
    "Takvim"         = $PM
    "Butce"          = $Finance
    "Lojistik"       = $Logistics
    "Kalite Plani"   = $Quality
    "Risk"           = $PM
    "Yonetim"        = $PM
    "Koordinasyon"   = $PM
    "Dokuman"        = $Tech
    "Degisiklik"     = $PM
    "Uygunsuzluk"    = $Quality
    "Kalite Guvence" = $Quality
    "Kontrol"        = $PM
    "Teslimat"       = $Logistics
    "Lessons"        = $PM
    "Arsiv"          = $Tech
}

$Count = 0
foreach ($WP in $WPs._embedded.elements) {
    $Assigned = $false
    foreach ($Keyword in $Map.Keys) {
        if ($WP.subject -like "*$Keyword*") {
            $TeamId = $Map[$Keyword]
            $Body = "{`"_links`":{`"assignee`":{`"href`":`"/api/v3/principals/$TeamId`"}}}"
            try {
                Invoke-RestMethod -Uri "$Base/work_packages/$($WP.id)" -Method PATCH -Headers $Headers -Body $Body | Out-Null
                Write-Host "  $($WP.subject) -> Team $TeamId" -ForegroundColor Green
                $Count++
                $Assigned = $true
                break
            }
            catch {
                Write-Host "  Failed: $($WP.subject)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "`nAssigned $Count work packages"
