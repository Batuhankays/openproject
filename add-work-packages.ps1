# Add work packages to existing template project
$token = "72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679"
$credentials = "apikey:$token"
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))

$headers = @{
    "Authorization" = "Basic $encodedCredentials"
    "Content-Type"  = "application/json"
}

$baseUrl = "http://localhost:8200/api/v3"
$projectIdentifier = "sablon-proje-yonetimi"

Write-Host "Adding work packages to existing project..." -ForegroundColor Cyan

# Get project
$project = Invoke-RestMethod -Uri "$baseUrl/projects/$projectIdentifier" -Headers $headers
Write-Host "Project found: $($project.name) (ID: $($project.id))" -ForegroundColor Green

# Get types
$types = Invoke-RestMethod -Uri "$baseUrl/types" -Headers $headers
$taskType = $types._embedded.elements | Where-Object { $_.name -eq "Task" } | Select-Object -First 1

Write-Host "Creating work packages..." -ForegroundColor Yellow

$phases = @(
    @{
        subject     = "Faz 1: Musteri Talebi ve Degerlendirme"
        description = "Musteri talebinin alinmasi ve uretilebirlik degerlendirmesi"
        startDate   = (Get-Date).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
        children    = @(
            @{ subject = "Musteri Talebi"; description = "Talep alinmasi" },
            @{ subject = "Teknik Sartname"; description = "Sartname hazirlama" },
            @{ subject = "Degerlendirme"; description = "Teknik ve mali degerlendirme" },
            @{ subject = "Uretilebirlik Karari"; description = "Uretim karari" }
        )
    },
    @{
        subject     = "Faz 2: Proje Degerlendirme"
        description = "Proje baslangic belgelerinin hazirlanmasi"
        startDate   = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(12).ToString("yyyy-MM-dd")
        children    = @(
            @{ subject = "Proje Baslangic Toplantisi"; description = "Ilk toplanti" },
            @{ subject = "Proje Konfesi"; description = "Konfes hazirlanmasi" },
            @{ subject = "Degerlendirme Raporu"; description = "Detayli degerlendirme" }
        )
    },
    @{
        subject     = "Faz 3: Proje Planlama"
        description = "Kaynaklar, takvim, butce planlamasi"
        startDate   = (Get-Date).AddDays(12).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(26).ToString("yyyy-MM-dd")
        children    = @(
            @{ subject = "Kaynak Atamasi"; description = "Insan kaynaklari" },
            @{ subject = "Takvim Olusturma"; description = "Gantt planlama" },
            @{ subject = "Butce Plani"; description = "Maliyet analizi" },
            @{ subject = "Lojistik Planlama"; description = "Tedarik planlama" },
            @{ subject = "Kalite Plani"; description = "Kalite standartlari" },
            @{ subject = "Risk Yonetimi"; description = "Risk tanimlama" },
            @{ subject = "Proje Yonetim Plani"; description = "Tum planlarin birlesmesi" }
        )
    },
    @{
        subject     = "Faz 4: Proje Yurutme"
        description = "Projenin aktif yurutulmesi"
        startDate   = (Get-Date).AddDays(26).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(70).ToString("yyyy-MM-dd")
        children    = @(
            @{ subject = "Koordinasyon Yonetimi"; description = "Haftalik toplanti" },
            @{ subject = "Dokuman Yonetimi"; description = "Versiyon kontrolu" },
            @{ subject = "Degisiklik Kontrolu"; description = "Degisiklik yonetimi" },
            @{ subject = "Uygunsuzluk Yonetimi"; description = "Uygunsuzluk tespiti" }
        )
    },
    @{
        subject     = "Faz 5: Izleme ve Kontrol"
        description = "Surekli izleme ve performans takibi"
        startDate   = (Get-Date).AddDays(26).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(70).ToString("yyyy-MM-dd")
        children    = @(
            @{ subject = "Kalite Guvence"; description = "Kalite denetimleri" },
            @{ subject = "Ara Kontroller"; description = "Ilerleme kontrolleri" },
            @{ subject = "Takvim Kontrolu"; description = "Schedule izleme" },
            @{ subject = "Risk Degerlendirme"; description = "Risk gozden gecirme" },
            @{ subject = "Proje Toplantilari"; description = "Haftalik toplanti" }
        )
    },
    @{
        subject     = "Faz 6: Proje Kapanis"
        description = "Teslimat ve kapanis faaliyetleri"
        startDate   = (Get-Date).AddDays(70).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(84).ToString("yyyy-MM-dd")
        children    = @(
            @{ subject = "Final Teslimat"; description = "Musteriye teslimat" },
            @{ subject = "Dokumantasyon"; description = "Belge tamamlama" },
            @{ subject = "Lessons Learned"; description = "Degerlendirme toplantisi" },
            @{ subject = "Kapanis Raporu"; description = "Kapanis raporu hazirlama" },
            @{ subject = "Arsivleme"; description = "Belge arsivleme" }
        )
    }
)

$totalCreated = 0
foreach ($phase in $phases) {
    Write-Host "`n  Creating: $($phase.subject)" -ForegroundColor Cyan
    
    $phaseBody = @{
        subject     = $phase.subject
        description = $phase.description
        startDate   = $phase.startDate
        dueDate     = $phase.dueDate
        _links      = @{
            type    = @{ href = "/api/v3/types/$($taskType.id)" }
            project = @{ href = "/api/v3/projects/$($project.id)" }
        }
    }
    
    try {
        $createdPhase = Invoke-RestMethod -Uri "$baseUrl/projects/$($project.id)/work_packages" -Method POST -Body ($phaseBody | ConvertTo-Json -Depth 10) -Headers $headers
        $totalCreated++
        Write-Host "    ✓ Phase created" -ForegroundColor Green
        
        Start-Sleep -Milliseconds 300
        
        foreach ($child in $phase.children) {
            $childBody = @{
                subject     = $child.subject
                description = $child.description
                _links      = @{
                    type    = @{ href = "/api/v3/types/$($taskType.id)" }
                    project = @{ href = "/api/v3/projects/$($project.id)" }
                    parent  = @{ href = "/api/v3/work_packages/$($createdPhase.id)" }
                }
            }
            
            $createdChild = Invoke-RestMethod -Uri "$baseUrl/projects/$($project.id)/work_packages" -Method POST -Body ($childBody | ConvertTo-Json -Depth 10) -Headers $headers
            $totalCreated++
            Write-Host "      - $($child.subject)" -ForegroundColor DarkGreen
            
            Start-Sleep -Milliseconds 200
        }
    }
    catch {
        Write-Host "    ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "COMPLETED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Created $totalCreated work packages" -ForegroundColor White
Write-Host "Project: http://localhost:8200/projects/$projectIdentifier" -ForegroundColor White
