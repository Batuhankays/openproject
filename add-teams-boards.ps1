# OpenProject - Ekip ve Board Kurulum Scripti
# Kullanim: powershell -ExecutionPolicy Bypass -File .\add-teams-boards.ps1

$config = @{
    OpenProjectUrl    = "http://localhost:8200"
    ApiBasePath       = "/api/v3"
    ApiToken          = "382db85caaf02801d8412adbbc9d41cbde9a1388950298e6f43c1bee5b4bd317"
    ProjectIdentifier = "sablon-proje-yonetimi"
}

$credentials = "apikey:$($config.ApiToken)"
$encodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($credentials))

$headers = @{
    "Authorization" = "Basic $encodedCredentials"
    "Content-Type"  = "application/json; charset=utf-8"
}

$baseUrl = "$($config.OpenProjectUrl)$($config.ApiBasePath)"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Ekip ve Board Kurulumu Baslatiyor" -ForegroundColor Cyan
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

# 1. KULLANICI GRUPLARI OLUSTUR
Write-Host "`n1. Kullanici gruplari olusturuluyor..." -ForegroundColor Yellow

# OpenProject'te gruplar genellikle elle olusturulur
# Bunun yerine roller (roles) kullanacagiz

# 2. ROLLERI AL
Write-Host "`n2. Mevcut roller aliniyor..." -ForegroundColor Yellow

$roles = Invoke-OpenProjectApi -Endpoint "/roles"

if ($roles) {
    Write-Host "OK: Roller alindi" -ForegroundColor Green
    
    # Ornek kullanicilar olustur (demo icin)
    Write-Host "`n3. Demo kullanicilari olusturuluyor..." -ForegroundColor Yellow
    
    $demoUsers = @(
        @{
            login     = "proje.muduru"
            firstName = "Proje"
            lastName  = "Muduru"
            email     = "proje.muduru@company.com"
            admin     = $false
        },
        @{
            login     = "teknik.ekip"
            firstName = "Teknik"
            lastName  = "Ekip Lideri"
            email     = "teknik.ekip@company.com"
            admin     = $false
        },
        @{
            login     = "kalite.muduru"
            firstName = "Kalite"
            lastName  = "Muduru"
            email     = "kalite@company.com"
            admin     = $false
        },
        @{
            login     = "finans.muduru"
            firstName = "Finans"
            lastName  = "Muduru"
            email     = "finans@company.com"
            admin     = $false
        },
        @{
            login     = "lojistik.koordinator"
            firstName = "Lojistik"
            lastName  = "Koordinator"
            email     = "lojistik@company.com"
            admin     = $false
        }
    )
    
    $createdUsers = @{}
    
    foreach ($user in $demoUsers) {
        $userBody = @{
            login     = $user.login
            firstName = $user.firstName
            lastName  = $user.lastName
            email     = $user.email
            admin     = $user.admin
            password  = "Demo1234!"  # Ilk giris icin gecici sifre
            _links    = @{
                status = @{
                    href = "/api/v3/statuses/1"  # Active
                }
            }
        }
        
        $created = Invoke-OpenProjectApi -Endpoint "/users" -Method "POST" -Body $userBody
        
        if ($created) {
            Write-Host "  OK: Kullanici olusturuldu: $($user.login)" -ForegroundColor Green
            $createdUsers[$user.login] = $created.id
        }
        
        Start-Sleep -Milliseconds 500
    }
}

# 3. PROJEYI AL
Write-Host "`n4. Template projesi aliniyor..." -ForegroundColor Yellow

$project = Invoke-OpenProjectApi -Endpoint "/projects/$($config.ProjectIdentifier)"

if ($project) {
    Write-Host "OK: Proje bulundu: $($project.name)" -ForegroundColor Green
    $projectId = $project.id
    
    # 4. KULLANICILARI PROJEYE EKLE
    Write-Host "`n5. Kullanicilar projeye ekleniyor..." -ForegroundColor Yellow
    
    # Manager rol (genellikle ID 4)
    $managerRole = $roles._embedded.elements | Where-Object { $_.name -like "*Manager*" -or $_.name -like "*Yonetici*" } | Select-Object -First 1
    $memberRole = $roles._embedded.elements | Where-Object { $_.name -like "*Member*" -or $_.name -like "*Uye*" } | Select-Object -First 1
    
    if (-not $managerRole) { $managerRole = $roles._embedded.elements[0] }
    if (-not $memberRole) { $memberRole = $roles._embedded.elements[1] }
    
    # Proje yonetici olarak ekle
    if ($createdUsers.ContainsKey("proje.muduru")) {
        $memberBody = @{
            _links = @{
                project   = @{ href = "/api/v3/projects/$projectId" }
                principal = @{ href = "/api/v3/users/$($createdUsers['proje.muduru'])" }
                roles     = @(
                    @{ href = "/api/v3/roles/$($managerRole.id)" }
                )
            }
        }
        
        $member = Invoke-OpenProjectApi -Endpoint "/memberships" -Method "POST" -Body $memberBody
        if ($member) {
            Write-Host "  OK: Proje Muduru eklendi" -ForegroundColor Green
        }
    }
    
    # Diger kullanicilari uye olarak ekle
    $otherUsers = @("teknik.ekip", "kalite.muduru", "finans.muduru", "lojistik.koordinator")
    
    foreach ($userLogin in $otherUsers) {
        if ($createdUsers.ContainsKey($userLogin)) {
            $memberBody = @{
                _links = @{
                    project   = @{ href = "/api/v3/projects/$projectId" }
                    principal = @{ href = "/api/v3/users/$($createdUsers[$userLogin])" }
                    roles     = @(
                        @{ href = "/api/v3/roles/$($memberRole.id)" }
                    )
                }
            }
            
            $member = Invoke-OpenProjectApi -Endpoint "/memberships" -Method "POST" -Body $memberBody
            if ($member) {
                Write-Host "  OK: $userLogin eklendi" -ForegroundColor Green
            }
        }
        
        Start-Sleep -Milliseconds 300
    }
    
    # 5. WORK PACKAGE'LERE ATAMA YAP
    Write-Host "`n6. Work package'lere sorumlu ataniyor..." -ForegroundColor Yellow
    
    $workPackages = Invoke-OpenProjectApi -Endpoint "/projects/$projectId/work_packages"
    
    if ($workPackages) {
        $wps = $workPackages._embedded.elements
        
        # Faz 1 gorevleri - Proje Muduru
        $faz1WPs = $wps | Where-Object { $_.subject -like "*Musteri*" -or $_.subject -like "*Teknik*" }
        foreach ($wp in $faz1WPs | Select-Object -First 3) {
            if ($createdUsers.ContainsKey("proje.muduru")) {
                $updateBody = @{
                    _links = @{
                        assignee = @{ href = "/api/v3/users/$($createdUsers['proje.muduru'])" }
                    }
                }
                Invoke-OpenProjectApi -Endpoint "/work_packages/$($wp.id)" -Method "PATCH" -Body $updateBody | Out-Null
            }
        }
        
        # Planlama fazı - ilgili kisiler
        $planlamaWPs = $wps | Where-Object { $_.subject -like "*Kaynak*" -or $_.subject -like "*Butce*" }
        foreach ($wp in $planlamaWPs | Select-Object -First 2) {
            if ($createdUsers.ContainsKey("finans.muduru")) {
                $updateBody = @{
                    _links = @{
                        assignee = @{ href = "/api/v3/users/$($createdUsers['finans.muduru'])" }
                    }
                }
                Invoke-OpenProjectApi -Endpoint "/work_packages/$($wp.id)" -Method "PATCH" -Body $updateBody | Out-Null
            }
        }
        
        Write-Host "OK: Atamalar tamamlandi" -ForegroundColor Green
    }
}

# SONUC
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "KURULUM TAMAMLANDI!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Olusturulan Demo Kullanicilar:" -ForegroundColor Yellow
Write-Host "  - proje.muduru (Proje Muduru)" -ForegroundColor White
Write-Host "  - teknik.ekip (Teknik Ekip Lideri)" -ForegroundColor White
Write-Host "  - kalite.muduru (Kalite Muduru)" -ForegroundColor White
Write-Host "  - finans.muduru (Finans Muduru)" -ForegroundColor White
Write-Host "  - lojistik.koordinator (Lojistik Koordinator)" -ForegroundColor White
Write-Host ""
Write-Host "Gecici Sifre (hepsi icin): Demo1234!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Board Olusturma:" -ForegroundColor Yellow
Write-Host "  Board'lar OpenProject UI'dan olusturulmalidir:" -ForegroundColor White
Write-Host "  1. Projeye gidin" -ForegroundColor White
Write-Host "  2. Sol menu -> Boards" -ForegroundColor White
Write-Host "  3. + Create new board" -ForegroundColor White
Write-Host "  4. Kanban tipi secin" -ForegroundColor White
Write-Host "  5. Statuslere gore kolonlar olusturun" -ForegroundColor White
Write-Host ""
Write-Host "Proje URL: $($config.OpenProjectUrl)/projects/$($config.ProjectIdentifier)" -ForegroundColor Cyan
Write-Host ""

Write-Host "Script tamamlandi!" -ForegroundColor Green
