@echo off
echo Creating work packages...
powershell -ExecutionPolicy Bypass -Command "$token='72d8c1a710205e40e34da1ea945de2d4aaf6ebeb1129bd634893df9e81e24679'; $enc=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes('apikey:'+$token)); $h=@{'Authorization'='Basic '+$enc;'Content-Type'='application/json'}; $base='http://localhost:8200/api/v3'; $pid=3; $tid=1; for ($i=1; $i -le 6; $i++) { $pb=@{subject=\"Faz $i\";_links=@{type=@{href=\"/api/v3/types/$tid\"};project=@{href=\"/api/v3/projects/$pid\"}}} | ConvertTo-Json; $r=Invoke-RestMethod -Uri \"$base/projects/$pid/work_packages\" -Method POST -Body $pb -Headers $h; Write-Host \"Created: Faz $i (ID: $($r.id))\" }"
pause
