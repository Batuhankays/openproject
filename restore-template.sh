#!/bin/bash
# Restore İSBİR Template Database on Remote Server
set -e

echo "🗄️ Restoring İSBİR Template Database..."

# Stop containers
echo "🛑 Stopping containers..."
cd /home/webadm/openproject
sudo docker compose -f docker-compose.enterprise.yml down

# Clear old data
echo "🧹 Clearing old database..."
sudo docker volume rm deployment_openproject-pgdata 2>/dev/null || true
sudo docker volume rm openproject_openproject-pgdata 2>/dev/null || true

# Create new volume
sudo docker volume create openproject_openproject-pgdata

# Restore backup
echo "♻️  Restoring database from backup..."
sudo docker run --rm \
  -v openproject_openproject-pgdata:/volume \
  -v /home/webadm:/backup \
  alpine tar xzf /backup/isbir-pgdata.tar.gz -C /volume

# Start containers
echo "🚀 Starting OpenProject..."
cd /home/webadm/openproject
sudo docker compose -f docker-compose.enterprise.yml up -d

echo "⏳ Waiting 30s for startup..."
sleep 30

echo ""
echo "✅ İSBİR Template Restored!"
echo "🌍 Access: http://10.2.3.15:8200"
echo "👤 Login: admin / Admin12345!"
echo ""
sudo docker ps
