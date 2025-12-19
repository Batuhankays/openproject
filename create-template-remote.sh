#!/bin/bash
# Create İSBİR Template on Remote OpenProject

# Configuration
API_URL="http://10.2.3.15:8200/api/v3"
ADMIN_USER="admin"
ADMIN_PASS="Admin12345!"

echo "🔑 Getting API Token..."
# In OpenProject, we need to use basic auth or get token from UI
# For now, we'll use admin credentials

echo "📋 Creating İSBİR Project Template..."

# Create project
PROJECT_JSON='{
  "identifier": "isbir-template",
  "name": "İSBİR Proje Şablonu",
  "description": {
    "format": "markdown",
    "raw": "İSBİR proje yönetimi şablonu - 6 fazlı süreç"
  },
  "public": false,
  "active": true
}'

curl -u "$ADMIN_USER:$ADMIN_PASS" \
  -X POST \
  -H "Content-Type: application/json" \
  -d "$PROJECT_JSON" \
  "$API_URL/projects"

echo ""
echo "✅ İSBİR Template project created!"
echo "🌍 Access it at: http://10.2.3.15:8200"
echo ""
echo "⚠️  For full setup with work packages, boards, and wiki:"
echo "    Please run the PowerShell scripts manually or access via UI"
