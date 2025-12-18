# OpenProject Community Optimizasyon Scripti
# Birden fazla board, saved query ve view olusturur

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
Write-Host "Community Edition Optimizasyon Baslatiyor" -ForegroundColor Cyan
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

# PROJE BILGILERINI AL
Write-Host "`n1. Proje bilgileri aliniyor..." -ForegroundColor Yellow
$project = Invoke-OpenProjectApi -Endpoint "/projects/$($config.ProjectIdentifier)"

if (-not $project) {
    Write-Host "HATA: Proje bulunamadi!" -ForegroundColor Red
    exit 1
}

$projectId = $project.id
Write-Host "OK: Proje: $($project.name) (ID: $projectId)" -ForegroundColor Green

# SAVED QUERIES OLUSTUR
Write-Host "`n2. Saved queries olusturuluyor..." -ForegroundColor Yellow

$queries = @(
    @{
        name    = "Bu Haftam"
        filters = '[{"dueDate":{"operator":"<>d","values":["1","7"]}},{"assignee":{"operator":"=","values":["me"]}}]'
        sortBy  = '[["dueDate","asc"]]'
        columns = '["id","subject","status","priority","assignee","dueDate"]'
    },
    @{
        name    = "Gec Kalan Gorevler"
        filters = '[{"dueDate":{"operator":"<t-","values":["1"]}},{"status":{"operator":"!","values":["7"]}}]'
        sortBy  = '[["dueDate","asc"]]'
        columns = '["id","subject","assignee","dueDate","priority"]'
    },
    @{
        name    = "Yuksek Oncelikli ve Acik"
        filters = '[{"priority":{"operator":"=","values":["3","4"]}},{"status":{"operator":"o","values":[]}}]'
        sortBy  = '[["priority","desc"],["dueDate","asc"]]'
        columns = '["id","subject","status","assignee","dueDate"]'
    },
    @{
        name    = "Bana Atananlar"
        filters = '[{"assignee":{"operator":"=","values":["me"]}},{"status":{"operator":"o","values":[]}}]'
        sortBy  = '[["priority","desc"]]'
        columns = '["id","subject","status","priority","dueDate","estimatedTime"]'
    }
)

foreach ($query in $queries) {
    $queryBody = @{
        name   = $query.name
        _links = @{
            project = @{
                href = "/api/v3/projects/$projectId"
            }
        }
    }
    
    # Queries API endpoint
    $created = Invoke-OpenProjectApi -Endpoint "/queries" -Method "POST" -Body $queryBody
    
    if ($created) {
        Write-Host "  OK: Query olusturuldu: $($query.name)" -ForegroundColor Green
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "TAMAMLANDI!" -ForegroundColor Green  
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Olusturulan Queries:" -ForegroundColor Yellow
Write-Host "  - Bu Haftam" -ForegroundColor White
Write-Host "  - Gec Kalan Gorevler" -ForegroundColor White
Write-Host "  - Yuksek Oncelikli ve Acik" -ForegroundColor White
Write-Host "  - Bana Atananlar" -ForegroundColor White
Write-Host ""
Write-Host "Diger optimizasyonlar (manuel):" -ForegroundColor Yellow
Write-Host "  - Ek board'lar tarayicidan olusturun" -ForegroundColor White
Write-Host "  - My Page widget'lari duzenleyin" -ForegroundColor White
Write-Host ""
Write-Host "Proje: http://localhost:8200/projects/$($config.ProjectIdentifier)" -ForegroundColor Cyan
Write-Host "Script tamamlandi!" -ForegroundColor Green
