# Add Descriptions to Work Packages
$Token = "72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679"
$Cred = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("apikey:$Token"))
$Headers = @{
    "Authorization" = "Basic $Cred"
    "Content-Type"  = "application/json"
}
$Base = "http://localhost:8200/api/v3"
$ProjectId = 3

Write-Host "Adding descriptions to work packages..."

# Get all work packages
$WPs = Invoke-RestMethod -Uri "$Base/projects/$ProjectId/work_packages" -Headers $Headers

# Description mapping with team recommendations
$Descriptions = @{
    "Musteri Talebi"     = "Receive and document initial customer requirements via email or phone. TEAM: Proje Muduru"
    "Teknik Sartname"    = "Prepare technical specifications document based on customer requirements. TEAM: Teknik Ekip"
    "Degerlendirme"      = "Technical and financial feasibility assessment. TEAM: Proje Muduru + Finans"
    "Uretilebirlik"      = "Final production decision and go/no-go approval. TEAM: Proje Muduru"
    
    "Toplanti"           = "Project kickoff meeting with all stakeholders. TEAM: Proje Muduru"
    "Konfes"             = "Project charter and scope definition. TEAM: Teknik Ekip"
    "Rapor"              = "Detailed evaluation report and project baseline. TEAM: Proje Muduru"
    
    "Kaynak"             = "Human resource allocation and team formation. TEAM: Proje Muduru"
    "Takvim"             = "Gantt chart and milestone planning. TEAM: Proje Muduru"
    "Butce"              = "Budget planning and cost analysis. TEAM: Finans Ekibi"
    "Lojistik"           = "Supply chain and procurement planning. TEAM: Lojistik Ekibi"
    "Kalite Plani"       = "Quality standards and acceptance criteria. TEAM: Kalite Ekibi"
    "Risk"               = "Risk identification and mitigation planning. TEAM: Proje Muduru"
    "Yonetim"            = "Comprehensive project management plan assembly. TEAM: Proje Muduru"
    
    "Koordinasyon"       = "Weekly coordination meetings and status updates. TEAM: Proje Muduru"
    "Dokuman"            = "Document management and version control. TEAM: Teknik Ekip"
    "Degisiklik"         = "Change request management and approval. TEAM: Proje Muduru"
    "Uygunsuzluk"        = "Non-conformance identification and corrective action. TEAM: Kalite Ekibi"
    
    "Kalite Guvence"     = "Quality audits and inspections. TEAM: Kalite Ekibi"
    "Kontrol"            = "Progress monitoring and performance tracking. TEAM: Proje Muduru"
    "Risk Degerlendirme" = "Ongoing risk review and assessment. TEAM: Proje Muduru"
    
    "Teslimat"           = "Final delivery to customer. TEAM: Lojistik Ekibi"
    "Dokumantasyon"      = "Documentation completion and handover. TEAM: Teknik Ekip"
    "Lessons"            = "Lessons learned workshop and retrospective. TEAM: Proje Muduru"
    "Kapanis"            = "Project closure report preparation. TEAM: Proje Muduru"
    "Arsiv"              = "Document archiving and storage. TEAM: Teknik Ekip"
}

$UpdatedCount = 0

foreach ($WP in $WPs._embedded.elements) {
    $Subject = $WP.subject
    
    # Find matching description
    $Description = $null
    foreach ($Key in $Descriptions.Keys) {
        if ($Subject -like "*$Key*") {
            $Description = $Descriptions[$Key]
            break
        }
    }
    
    if ($Description) {
        $Body = "{`"description`":{`"raw`":`"$Description`"}}"
        
        try {
            Invoke-RestMethod -Uri "$Base/work_packages/$($WP.id)" -Method PATCH -Headers $Headers -Body $Body | Out-Null
            Write-Host "  Updated: $Subject" -ForegroundColor Green
            $UpdatedCount++
        }
        catch {
            Write-Host "  Failed: $Subject - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`nUpdated $UpdatedCount work package descriptions"
