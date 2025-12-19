#!/bin/bash
# Create İSBİR Template on Remote Server via API

API_URL="http://10.2.3.15:8200/api/v3"
USER="admin"
PASS="Admin12345!"

echo "📋 Creating İSBİR Project Template..."

# Create project
curl -u "$USER:$PASS" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "sablon-proje-yonetimi",
    "name": "SABLON: Proje Yonetimi",
    "description": {
      "format": "markdown",
      "raw": "İSBİR 6 fazlı proje yönetimi şablonu"
    },
    "active": true
  }' \
  "$API_URL/projects"

echo ""
echo "✅ Project created! Now use PowerShell scripts to add work packages, boards, wiki."
echo "🌍 Access: http://10.2.3.15:8200/projects/sablon-proje-yonetimi"
