#!/bin/bash
# Actually restore to the correct database!
set -e

echo "🔧 Fixing database restore - copying to 'openproject' database..."

# Stop containers first
cd /home/webadm/openproject
sudo docker compose -f docker-compose.enterprise.yml stop

# Start only the database
sudo docker compose -f docker-compose.enterprise.yml up -d db
sleep 5

# Drop and recreate the openproject database
echo "🗑️ Dropping old openproject database..."
sudo docker exec openproject-db-enterprise psql -U postgres -c "DROP DATABASE IF EXISTS openproject;"
sudo docker exec openproject-db-enterprise psql -U postgres -c "CREATE DATABASE openproject OWNER postgres;"

# The backup was restored to postgres database, we need to dump from there and restore to openproject
echo "📋 Copying data from postgres DB to openproject DB..."
sudo docker exec openproject-db-enterprise pg_dump -U postgres postgres | sudo docker exec -i openproject-db-enterprise psql -U postgres openproject

# Start all services
echo "🚀 Starting all services..."
sudo docker compose -f docker-compose.enterprise.yml up -d

sleep 30

echo ""
echo "✅ Database fixed and restored!"
echo "🌍 http://10.2.3.15:8200"
sudo docker ps
