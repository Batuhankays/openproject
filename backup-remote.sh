#!/bin/bash
# Backup İSBİR Template Database
# Run this on remote server to create a backup

BACKUP_DIR="/home/webadm/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/isbir-template-$TIMESTAMP.sql"

echo "📦 Creating database backup..."
mkdir -p $BACKUP_DIR

# Dump the database
sudo docker exec openproject-db-enterprise \
  pg_dump -U postgres openproject > "$BACKUP_FILE"

# Compress it
gzip "$BACKUP_FILE"

echo "✅ Backup created: ${BACKUP_FILE}.gz"
ls -lh "${BACKUP_FILE}.gz"

# Keep only last 5 backups
echo "🧹 Cleaning old backups (keeping last 5)..."
cd $BACKUP_DIR
ls -t isbir-template-*.sql.gz | tail -n +6 | xargs -r rm

echo "📋 Available backups:"
ls -lht isbir-template-*.sql.gz
