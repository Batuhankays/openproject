# OpenProject Template Otomatik Kurulum Scripti
# Kullanim: powershell -ExecutionPolicy Bypass -File .\setup-template.ps1

# YAPILANDIRMA
$config = @{
    OpenProjectUrl = "http://localhost:8200"
    ApiBasePath    = "/api/v3"
    ApiToken       = "72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679"
}

# OpenProject API uses 'apikey' as username and token as password
$credentials = "apikey:$($config.ApiToken)"
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))

$headers = @{
    "Authorization" = "Basic $encodedCredentials"
    "Content-Type"  = "application/json; charset=utf-8"
}

$baseUrl = "$($config.OpenProjectUrl)$($config.ApiBasePath)"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "OpenProject Template Kurulum Baslatiyor" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

function Invoke-OpenProjectApi {
    param(
        [string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body = $null
    )
    
    $url = "$baseUrl$Endpoint"
    
    try {
        $params = @{
            Uri     = $url
            Method  = $Method
            Headers = $headers
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        Write-Host "HATA: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# 1. TEMPLATE PROJESINI OLUSTUR
Write-Host "`n1. Template projesi olusturuluyor..." -ForegroundColor Yellow

$projectBody = @{
    name        = "SABLON: Proje Yonetimi"
    identifier  = "sablon-proje-yonetimi"
    description = "Proje yonetimi sablonu"
    public      = $false
}

$project = Invoke-OpenProjectApi -Endpoint "/projects" -Method "POST" -Body $projectBody

if ($project) {
    Write-Host "OK: Template projesi olusturuldu" -ForegroundColor Green
    $projectId = $project.id
}
else {
    Write-Host "HATA: Proje olusturulamadi!" -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 2

# 2. WORK PACKAGE TIPLERINI AL
Write-Host "`n2. Work package tipleri aliniyor..." -ForegroundColor Yellow

$types = Invoke-OpenProjectApi -Endpoint "/types"
$taskType = $types._embedded.elements | Where-Object { $_.name -eq "Task" } | Select-Object -First 1
$milestoneType = $types._embedded.elements | Where-Object { $_.name -eq "Milestone" } | Select-Object -First 1

Write-Host "OK: Tipler hazir (Task ID: $($taskType.id))" -ForegroundColor Green

# 3. FAZLARI VE GOREVLERI OLUSTUR
Write-Host "`n3. Fazlar ve gorevler olusturuluyor..." -ForegroundColor Yellow

$phases = @(
    @{
        subject     = "Faz 1: Musteri Talebi ve Degerlendirme"
        description = "Musteri talebinin alinmasi ve uretilebirlik degerlendirmesi"
        startDate   = (Get-Date).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
        children    = @(
            @{ subject = "Musteri Talebi"; description = "E-mail, telefon ile talep alinmasi" },
            @{ subject = "Teknik Sartname"; description = "Teknik sartname hazirlama" },
            @{ subject = "Degerlendirme"; description = "Teknik ve mali degerlendirme" },
            @{ subject = "Uretilebirlik Karari"; description = "Uretim karari verilmesi" }
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
            @{ subject = "Kaynak Atamasi"; description = "Insan kaynaklari atamasi" },
            @{ subject = "Takvim Olusturma"; description = "Gantt ve milestone planlama" },
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
            @{ subject = "Koordinasyon Yonetimi"; description = "Haftalik toplanti koordinasyonu" },
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

$totalTasks = 0
foreach ($phase in $phases) {
    Write-Host "  Olusturuluyor: $($phase.subject)" -ForegroundColor Cyan
    
    $phaseBody = @{
        subject     = $phase.subject
        description = $phase.description
        startDate   = $phase.startDate
        dueDate     = $phase.dueDate
        _links      = @{
            type    = @{ href = "/api/v3/types/$($taskType.id)" }
            project = @{ href = "/api/v3/projects/$projectId" }
        }
    }
    
    $createdPhase = Invoke-OpenProjectApi -Endpoint "/projects/$projectId/work_packages" -Method "POST" -Body $phaseBody
    
    if ($createdPhase) {
        $totalTasks++
        Write-Host "    OK: Ana faz olusturuldu" -ForegroundColor Green
        
        Start-Sleep -Milliseconds 500
        
        foreach ($child in $phase.children) {
            $childBody = @{
                subject     = $child.subject
                description = $child.description
                _links      = @{
                    type    = @{ href = "/api/v3/types/$($taskType.id)" }
                    project = @{ href = "/api/v3/projects/$projectId" }
                    parent  = @{ href = "/api/v3/work_packages/$($createdPhase.id)" }
                }
            }
            
            $createdChild = Invoke-OpenProjectApi -Endpoint "/projects/$projectId/work_packages" -Method "POST" -Body $childBody
            
            if ($createdChild) {
                $totalTasks++
                Write-Host "      - $($child.subject)" -ForegroundColor DarkGreen
            }
            
            Start-Sleep -Milliseconds 300
        }
    }
}

# SONUC
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "KURULUM TAMAMLANDI!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Toplam $totalTasks adet work package olusturuldu" -ForegroundColor White
Write-Host "Proje URL: $($config.OpenProjectUrl)/projects/sablon-proje-yonetimi" -ForegroundColor White
Write-Host ""
Write-Host "Kullanim:" -ForegroundColor Yellow
Write-Host "  1. Tarayicida projeyi kontrol edin" -ForegroundColor White
Write-Host "  2. Yeni proje olusturmak icin bu sablonu kopyalayin" -ForegroundColor White
Write-Host ""

Start-Process "$($config.OpenProjectUrl)/projects/sablon-proje-yonetimi"

Write-Host "Tarayici aciliyor..." -ForegroundColor Cyan
Write-Host "Script tamamlandi!" -ForegroundColor Green
