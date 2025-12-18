#!/bin/bash
set -e

echo "🚀 Starting OpenProject Deployment on $(hostname)..."

# 1. Update and Install Docker
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
fi

if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo apt-get update && sudo apt-get install -y docker-compose-plugin dummy-package || true
    alias docker-compose='docker compose'
fi

# 2. Stop existing
echo "🛑 Stopping existing..."
docker compose down || true

# 3. Initialize Volumes
echo "📦 Initializing Volumes..."
# Create containers but don't start, to ensure volumes are created with correct names
docker compose up --no-start

# Identify volume names (assuming directory is 'deployment')
PGDATA_VOL="deployment_openproject-pgdata"
ASSETS_VOL="deployment_openproject-data"

# Verify loop if names differ
# We'll blindly try to restore to these names.

# 4. Restore Data
if [ -f "pgdata.tar.gz" ]; then
    echo "♻️  Restoring Database..."
    # Clear volume first?
    docker run --rm -v $PGDATA_VOL:/volume alpine sh -c 'rm -rf /volume/*'
    docker run --rm -v $PGDATA_VOL:/volume -v $(pwd):/backup alpine tar xzf /backup/pgdata.tar.gz -C /volume
    echo "✅ Database restored."
fi

if [ -f "assets.tar.gz" ]; then
    echo "♻️  Restoring Assets..."
    docker run --rm -v $ASSETS_VOL:/volume alpine sh -c 'rm -rf /volume/*'
    docker run --rm -v $ASSETS_VOL:/volume -v $(pwd):/backup alpine tar xzf /backup/assets.tar.gz -C /volume
    echo "✅ Assets restored."
fi

# 5. Build and Start
echo "🏗️  Starting Services..."
docker compose up -d --build

echo "✅ DONE! Access at http://$(hostname -I | awk '{print $1}'):8200"
