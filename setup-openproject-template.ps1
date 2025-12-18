# OpenProject Template Otomatik Kurulum Scripti
# İSBİR Proje Yönetimi İş Akışı Şablonu
# Kullanım: .\setup-openproject-template.ps1

# ===========================================
# YAPILANDIRMA
# ===========================================

$config = @{
    OpenProjectUrl = "http://localhost:8200"
    ApiBasePath    = "/api/v3"
    Username       = "admin"
    Password       = "1234567890"  # İlk login'den sonra değiştirdiğiniz şifreyi buraya yazın
}

# Base64 encoding for Basic Auth
$credentials = "$($config.Username):$($config.Password)"
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))

$headers = @{
    "Authorization" = "Basic $encodedCredentials"
    "Content-Type"  = "application/json"
}

$baseUrl = "$($config.OpenProjectUrl)$($config.ApiBasePath)"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "OpenProject Template Kurulum Başlatılıyor" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ===========================================
# YARDIMCI FONKSİYONLAR
# ===========================================

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
        Write-Host "HATA: $Endpoint - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
        return $null
    }
}

function Write-Progress-Step {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Step {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# ===========================================
# 1. ÖNCEKİ TEMPLATE'İ KONTROL ET VE SİL
# ===========================================

Write-Host "1. Önceki template kontrolü yapılıyor..." -ForegroundColor Yellow

$existingProjects = Invoke-OpenProjectApi -Endpoint "/projects"
$templateProject = $existingProjects._embedded.elements | Where-Object { $_.identifier -eq "sablon-proje-yonetimi" }

if ($templateProject) {
    Write-Host "   Önceki template bulundu, siliniyor..." -ForegroundColor Yellow
    Invoke-OpenProjectApi -Endpoint "/projects/$($templateProject.id)" -Method "DELETE"
    Start-Sleep -Seconds 2
    Write-Progress-Step "Önceki template silindi"
}

# ===========================================
# 2. ÖZEL ALANLARI OLUŞTUR (Custom Fields)
# ===========================================

Write-Host "`n2. Özel alanlar oluşturuluyor..." -ForegroundColor Yellow

$customFields = @(
    @{
        name        = "Müşteri Adı"
        fieldFormat = "text"
        type        = "ProjectCustomField"
        isRequired  = $true
    },
    @{
        name        = "Müşteri Kodu"
        fieldFormat = "text"
        type        = "ProjectCustomField"
    },
    @{
        name        = "Müşteri İletişim Kişisi"
        fieldFormat = "text"
        type        = "ProjectCustomField"
    },
    @{
        name        = "Proje Talimat No"
        fieldFormat = "text"
        type        = "ProjectCustomField"
        isRequired  = $true
    },
    @{
        name           = "İş Standardı"
        fieldFormat    = "list"
        type           = "ProjectCustomField"
        possibleValues = @("T0", "T1", "T2", "T3", "T1+2", "T2+GÜN", "T3+GÜN")
    },
    @{
        name        = "Toplam Bütçe"
        fieldFormat = "float"
        type        = "ProjectCustomField"
    },
    @{
        name           = "Risk Seviyesi"
        fieldFormat    = "list"
        type           = "WorkPackageCustomField"
        possibleValues = @("Düşük", "Orta", "Yüksek", "Kritik")
    },
    @{
        name           = "Proje Durumu"
        fieldFormat    = "list"
        type           = "ProjectCustomField"
        possibleValues = @("Yeni", "Değerlendirme", "Onay Bekliyor", "Planlama", "Aktif", "Test", "Tamamlandı", "Kapandı")
    }
)

foreach ($field in $customFields) {
    $body = @{
        name        = $field.name
        fieldFormat = $field.fieldFormat
        _type       = "CustomField::$($field.type)"
    }
    
    if ($field.possibleValues) {
        $body.customOptions = @{
            _type    = "Collection"
            elements = @()
        }
        foreach ($value in $field.possibleValues) {
            $body.customOptions.elements += @{ value = $value }
        }
    }
    
    if ($field.isRequired) {
        $body.isRequired = $true
    }
    
    $result = Invoke-OpenProjectApi -Endpoint "/custom_fields" -Method "POST" -Body $body
    if ($result) {
        Write-Progress-Step "Özel alan oluşturuldu: $($field.name)"
    }
}

# ===========================================
# 3. TEMPLATE PROJESİNİ OLUŞTUR
# ===========================================

Write-Host "`n3. Template projesi oluşturuluyor..." -ForegroundColor Yellow

$projectBody = @{
    name        = "ŞABLON: Proje Yönetimi İş Akışı"
    identifier  = "sablon-proje-yonetimi"
    description = "İSBİR proje yönetimi iş akışı şablonu - Yeni projeler için bu projeyi kopyalayın"
    public      = $false
    active      = $true
}

$project = Invoke-OpenProjectApi -Endpoint "/projects" -Method "POST" -Body $projectBody

if ($project) {
    Write-Progress-Step "Template projesi oluşturuldu: $($project.name)"
    $projectId = $project.id
}
else {
    Write-Error-Step "Proje oluşturulamadı!"
    exit 1
}

Start-Sleep -Seconds 2

# ===========================================
# 4. WORK PACKAGE TİPLERİNİ AL
# ===========================================

Write-Host "`n4. Work package tipleri alınıyor..." -ForegroundColor Yellow

$types = Invoke-OpenProjectApi -Endpoint "/types"
$taskType = $types._embedded.elements | Where-Object { $_.name -eq "Task" } | Select-Object -First 1
$milestoneType = $types._embedded.elements | Where-Object { $_.name -eq "Milestone" } | Select-Object -First 1
$phaseType = $types._embedded.elements | Where-Object { $_.name -eq "Phase" } | Select-Object -First 1

if (-not $phaseType) {
    # Phase tipi yoksa Task kullan
    $phaseType = $taskType
    Write-Host "   Phase tipi bulunamadı, Task tipi kullanılacak" -ForegroundColor Yellow
}

Write-Progress-Step "Work package tipleri hazır"

# ===========================================
# 5. WORK PACKAGE'LERI OLUŞTUR
# ===========================================

Write-Host "`n5. Work package'ler oluşturuluyor..." -ForegroundColor Yellow

# Ana Fazlar
$phases = @(
    @{
        subject     = "Faz 1: Müşteri Talebi ve Değerlendirme"
        description = "Müşteri talebinin alınması, teknik şartname hazırlanması ve üretilebilirlik değerlendirmesi"
        startDate   = (Get-Date).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
        children    = @(
            @{
                subject       = "1.1 Müşteri Talebi"
                description   = "E-mail, posta, telefon ile müşteri talebinin alınması"
                estimatedTime = "PT8H"
            },
            @{
                subject       = "1.2 Teknik Şartname ve Tanımlama"
                description   = "Teknik şartname, kalite gereksinimleri, teknik çizimler, prototip hazırlanması"
                estimatedTime = "PT24H"
            },
            @{
                subject       = "1.3 Değerlendirme Süreci"
                description   = "Teknik fizibilite, maliyet ve kaynak uygunluğu değerlendirmesi"
                estimatedTime = "PT24H"
            },
            @{
                subject       = "1.4 Üretilebilirlik Kararı"
                description   = "Projenin üretilebilir olup olmadığına karar verilmesi"
                estimatedTime = "PT8H"
            }
        )
    },
    @{
        subject     = "Faz 2: Proje Değerlendirme Süreci"
        description = "Proje başlangıç belgelerinin hazırlanması ve değerlendirme"
        startDate   = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(12).ToString("yyyy-MM-dd")
        children    = @(
            @{
                subject       = "2.1 Proje Başlangıç Toplantısı"
                description   = "İlk proje toplantısı ve görev dağılımı"
                estimatedTime = "PT4H"
            },
            @{
                subject       = "2.2 Proje Konfesi Hazırlama"
                description   = "Proje konfesi dokümanının oluşturulması"
                estimatedTime = "PT16H"
            },
            @{
                subject       = "2.3 Proje Değerlendirme Raporu"
                description   = "Detaylı değerlendirme raporu hazırlanması"
                estimatedTime = "PT16H"
            }
        )
    },
    @{
        subject     = "Faz 3: Proje Planlama Süreci"
        description = "Kaynaklar, takvim, bütçe, lojistik, kalite ve risk yönetimi planlaması"
        startDate   = (Get-Date).AddDays(12).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(26).ToString("yyyy-MM-dd")
        children    = @(
            @{
                subject       = "3.1 Kaynakların Atanması"
                description   = "İnsan kaynakları ve ekip atamalarının yapılması"
                estimatedTime = "PT16H"
            },
            @{
                subject       = "3.2 Proje Takviminin Oluşturulması"
                description   = "Gantt şeması ve milestone planlaması"
                estimatedTime = "PT24H"
            },
            @{
                subject       = "3.3 Proje Bütçesi"
                description   = "Detaylı bütçe planlaması ve maliyet analizi"
                estimatedTime = "PT24H"
            },
            @{
                subject       = "3.4 Lojistik Destek Yönetimi"
                description   = "Tedarik ve lojistik planlama"
                estimatedTime = "PT16H"
            },
            @{
                subject       = "3.5 Kalite Güvence Planı"
                description   = "Kalite standartları ve test prosedürleri"
                estimatedTime = "PT16H"
            },
            @{
                subject       = "3.6 Risk Yönetimi"
                description   = "Risk tanımlama ve azaltma stratejileri"
                estimatedTime = "PT16H"
            },
            @{
                subject       = "3.7 Proje Yönetim Planı (Çıktı)"
                description   = "Tüm planlama dokümanlarının birleştirilmesi"
                estimatedTime = "PT8H"
            }
        )
    },
    @{
        subject     = "Faz 4: Proje Yürütme/Uygulama"
        description = "Projenin aktif olarak yürütülmesi ve koordinasyon"
        startDate   = (Get-Date).AddDays(26).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(70).ToString("yyyy-MM-dd")
        children    = @(
            @{
                subject       = "4.1 Koordinasyon Yönetimi"
                description   = "Haftalık ekip toplantıları ve koordinasyon"
                estimatedTime = "PT160H"
            },
            @{
                subject       = "4.2 Doküman Yönetimi"
                description   = "Doküman versiyonlama ve arşivleme"
                estimatedTime = "PT40H"
            },
            @{
                subject       = "4.3 Değişiklik/Sapma Kontrolü"
                description   = "Değişiklik talep yönetimi ve sapma analizi"
                estimatedTime = "PT40H"
            },
            @{
                subject       = "4.4 Uygunsuzluk Yönetimi"
                description   = "Uygunsuzluk tespiti ve düzeltici faaliyetler"
                estimatedTime = "PT24H"
            }
        )
    },
    @{
        subject     = "Faz 5: Proje İzleme ve Kontrol"
        description = "Sürekli izleme, kalite kontrol ve performans takibi"
        startDate   = (Get-Date).AddDays(26).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(70).ToString("yyyy-MM-dd")
        children    = @(
            @{
                subject       = "5.1 Kalite Güvence Faaliyetleri"
                description   = "Düzenli kalite denetimleri ve testler"
                estimatedTime = "PT80H"
            },
            @{
                subject       = "5.2 Ara Kontroller"
                description   = "%25, %50, %75 ilerleme kontrolleri"
                estimatedTime = "PT24H"
            },
            @{
                subject       = "5.3 Proje Takvimi Kontrolü"
                description   = "Schedule variance ve critical path izleme"
                estimatedTime = "PT40H"
            },
            @{
                subject       = "5.4 Risk Değerlendirme"
                description   = "İki haftada bir risk gözden geçirme"
                estimatedTime = "PT32H"
            },
            @{
                subject       = "5.5 Proje Toplantıları"
                description   = "Haftalık proje durum toplantıları"
                estimatedTime = "PT40H"
            }
        )
    },
    @{
        subject     = "Faz 6: Proje Kapanış"
        description = "Projenin tamamlanması, teslimat ve kapanış faaliyetleri"
        startDate   = (Get-Date).AddDays(70).ToString("yyyy-MM-dd")
        dueDate     = (Get-Date).AddDays(84).ToString("yyyy-MM-dd")
        children    = @(
            @{
                subject       = "6.1 Final Teslimat"
                description   = "Müşteriye nihai teslimat ve kabul"
                estimatedTime = "PT8H"
            },
            @{
                subject       = "6.2 Dokümantasyon Tamamlama"
                description   = "Tüm proje dokümanlarının hazırlanması"
                estimatedTime = "PT40H"
            },
            @{
                subject       = "6.3 Lessons Learned Toplantısı"
                description   = "Proje değerlendirme ve öğrenilen dersler"
                estimatedTime = "PT4H"
            },
            @{
                subject       = "6.4 Proje Kapanış Raporu"
                description   = "Kapsamlı proje kapanış raporu hazırlanması"
                estimatedTime = "PT24H"
            },
            @{
                subject       = "6.5 Arşivleme"
                description   = "Tüm belgelerin arşivlenmesi"
                estimatedTime = "PT16H"
            }
        )
    }
)

$createdPhases = @{}

foreach ($phase in $phases) {
    Write-Host "   Oluşturuluyor: $($phase.subject)" -ForegroundColor Cyan
    
    # Ana faz oluştur
    $phaseBody = @{
        subject     = $phase.subject
        description = $phase.description
        startDate   = $phase.startDate
        dueDate     = $phase.dueDate
        _links      = @{
            type    = @{
                href = "/api/v3/types/$($phaseType.id)"
            }
            project = @{
                href = "/api/v3/projects/$projectId"
            }
        }
    }
    
    $createdPhase = Invoke-OpenProjectApi -Endpoint "/projects/$projectId/work_packages" -Method "POST" -Body $phaseBody
    
    if ($createdPhase) {
        Write-Progress-Step "Ana faz oluşturuldu: $($phase.subject)"
        $createdPhases[$phase.subject] = $createdPhase.id
        
        Start-Sleep -Milliseconds 500
        
        # Alt görevleri oluştur
        foreach ($child in $phase.children) {
            $childBody = @{
                subject     = $child.subject
                description = $child.description
                _links      = @{
                    type    = @{
                        href = "/api/v3/types/$($taskType.id)"
                    }
                    project = @{
                        href = "/api/v3/projects/$projectId"
                    }
                    parent  = @{
                        href = "/api/v3/work_packages/$($createdPhase.id)"
                    }
                }
            }
            
            if ($child.estimatedTime) {
                $childBody.estimatedTime = $child.estimatedTime
            }
            
            $createdChild = Invoke-OpenProjectApi -Endpoint "/projects/$projectId/work_packages" -Method "POST" -Body $childBody
            
            if ($createdChild) {
                Write-Host "     ✓ Alt görev: $($child.subject)" -ForegroundColor DarkGreen
            }
            
            Start-Sleep -Milliseconds 300
        }
    }
}

# ===========================================
# 6. WİKİ SAYFALARINI OLUŞTUR
# ===========================================

Write-Host "`n6. Wiki sayfaları oluşturuluyor..." -ForegroundColor Yellow

$wikiContent = @"
# Proje Yönetimi Şablonu Kullanım Kılavuzu

## Şablonun Kullanımı

1. **Yeni Proje Başlatma**
   - Projeler menüsünden '+ Proje' tıklayın
   - 'Mevcut projeden kopyala' seçeneğini kullanın
   - Bu şablonu seçin
   - Proje bilgilerini doldurun

2. **Proje Bilgilerini Güncelleme**
   - Proje ayarlarından müşteri bilgilerini girin
   - Özel alanları doldurun (Müşteri Adı, Proje No, vb.)
   - Tarihleri projenize göre ayarlayın

3. **Ekip Atama**
   - Her work package için sorumlu kişileri atayın
   - Proje rollerini belirleyin
   - İzin ayarlarını yapılandırın

## Proje Fazları

### Faz 1: Müşteri Talebi ve Değerlendirme (1 Hafta)
- Müşteri talebinin alınması
- Teknik şartname hazırlanması
- Üretilebilirlik değerlendirmesi
- Karar: Devam/Red

### Faz 2: Proje Değerlendirme (1 Hafta)
- Proje başlangıç belgeleri
- Maliyet analizi
- Onay süreci

### Faz 3: Proje Planlama (2 Hafta)
- Kaynak atama
- Takvim oluşturma
- Bütçe planlama
- Lojistik planlama
- Kalite planlama
- Risk yönetimi

### Faz 4: Proje Yürütme (6-8 Hafta)
- Aktif çalışma
- Koordinasyon
- Doküman yönetimi
- Değişiklik kontrolü

### Faz 5: İzleme ve Kontrol (Paralel)
- Kalite kontrolleri
- Performans izleme
- Risk takibi
- Düzenli toplantılar

### Faz 6: Proje Kapanış (1-2 Hafta)
- Teslimat
- Dokümantasyon
- Lessons learned
- Arşivleme

## Önemli Notlar

- Her fazın başında ilgili dokümanları hazırlayın
- Milestone'ları takip edin
- Değişiklikleri mutlaka kaydedin
- Düzenli toplantıları aksatmayın

## İletişim ve Raporlama

- Haftalık durum raporları
- Aylık yönetim sunumları
- Risk güncellemeleri
- Değişiklik talepleri
"@

# Wiki endpoint project-specific olabilir
# OpenProject API wiki desteği versiyon üzerine değişebilir
# Bu nedenle hata alırsanız manuel eklenebilir

Write-Progress-Step "Wiki içeriği hazır (manuel ekleme gerekebilir)"

# ===========================================
# 7. ÖZET BİLGİ
# ===========================================

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "KURULUM TAMAMLANDI!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Template Bilgileri:" -ForegroundColor Yellow
Write-Host "  Proje Adı: ŞABLON: Proje Yönetimi İş Akışı" -ForegroundColor White
Write-Host "  Proje ID: $projectId" -ForegroundColor White
Write-Host "  URL: $($config.OpenProjectUrl)/projects/sablon-proje-yonetimi" -ForegroundColor White
Write-Host ""
Write-Host "Oluşturulan Öğeler:" -ForegroundColor Yellow
Write-Host "  ✓ $($customFields.Count) Özel Alan" -ForegroundColor Green
Write-Host "  ✓ 6 Ana Faz" -ForegroundColor Green
Write-Host "  ✓ 25+ Alt Görev" -ForegroundColor Green
Write-Host "  ✓ Wiki İçeriği (manuel eklenebilir)" -ForegroundColor Green
Write-Host ""
Write-Host "Sonraki Adımlar:" -ForegroundColor Yellow
Write-Host "  1. Tarayıcıda projeyi kontrol edin" -ForegroundColor White
Write-Host "  2. Gantt görünümünde fazları ve bağımlılıkları inceleyin" -ForegroundColor White
Write-Host "  3. Yeni proje oluştururken bu şablonu kopyalayın" -ForegroundColor White
Write-Host "  4. Wiki sayfasını manuel ekleyin (yukarıdaki içerik)" -ForegroundColor White
Write-Host ""
Write-Host "Şablonu Kullanma:" -ForegroundColor Yellow
Write-Host "  Projeler → + Proje → 'Mevcut projeden kopyala' → Bu şablonu seçin" -ForegroundColor White
Write-Host ""

# Tarayıcıda aç
Write-Host "Tarayıcıda açılıyor..." -ForegroundColor Cyan
Start-Process "$($config.OpenProjectUrl)/projects/sablon-proje-yonetimi"

Write-Host "`nScript tamamlandı! ✓" -ForegroundColor Green
