#!/bin/bash
set -e

echo "🔄 Final attempt - importing SQL dump to openproject database..."

cd /home/webadm/openproject

# Stop app to avoid conflicts
sudo docker compose -f docker-compose.enterprise.yml stop openproject

# Drop and recreate clean database
echo "🗑️ Recreating database..."
sudo docker exec openproject-db-enterprise psql -U postgres -c "DROP DATABASE IF EXISTS openproject;"
sudo docker exec openproject-db-enterprise psql -U postgres -c "CREATE DATABASE openproject OWNER postgres;"

# Import the SQL dump
echo "📥 Importing SQL dump..."
cat /home/webadm/isbir.sql | sudo docker exec -i openproject-db-enterprise psql -U postgres -d openproject

# Verify
echo "✅ Verifying import..."
sudo docker exec openproject-db-enterprise psql -U postgres -d openproject -c "SELECT COUNT(*) as project_count FROM projects;"

# Start everything
echo "🚀 Starting OpenProject..."
sudo docker compose -f docker-compose.enterprise.yml up -d

sleep 30

echo ""
echo "✅ DONE! Check http://10.2.3.15:8200"
sudo docker ps
