#!/bin/bash
# Restore İSBİR Template Database from Backup
# Usage: ./restore-from-backup.sh <backup-file.sql.gz>

if [ -z "$1" ]; then
  echo "❌ Error: Please provide backup file"
  echo "Usage: $0 <backup-file.sql.gz>"
  echo ""
  echo "Available backups:"
  ls -lht /home/webadm/backups/isbir-template-*.sql.gz 2>/dev/null
  exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Backup file not found: $BACKUP_FILE"
  exit 1
fi

echo "🔄 Restoring from: $BACKUP_FILE"
echo "⚠️  This will REPLACE the current database!"
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Cancelled"
  exit 0
fi

# Stop app
cd /home/webadm/openproject
sudo docker compose -f docker-compose.enterprise.yml stop openproject

# Drop and recreate database
echo "🗑️  Dropping old database..."
sudo docker exec openproject-db-enterprise psql -U postgres -c "DROP DATABASE IF EXISTS openproject;"
sudo docker exec openproject-db-enterprise psql -U postgres -c "CREATE DATABASE openproject OWNER postgres;"

# Restore
echo "📥 Restoring backup..."
if [[ $BACKUP_FILE == *.gz ]]; then
  gunzip -c "$BACKUP_FILE" | sudo docker exec -i openproject-db-enterprise psql -U postgres -d openproject
else
  cat "$BACKUP_FILE" | sudo docker exec -i openproject-db-enterprise psql -U postgres -d openproject
fi

# Start app
echo "🚀 Starting OpenProject..."
sudo docker compose -f docker-compose.enterprise.yml up -d

sleep 10
echo "✅ Restore complete!"
echo "🌍 Access: http://10.2.3.15:8200"
