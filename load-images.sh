#!/bin/bash
# REMOTE: Load Docker images from transferred files
set -e

echo "📥 Loading Docker images on remote server..."

cd /home/webadm/docker-images || exit 1

for tarfile in *.tar; do
    if [ -f "$tarfile" ]; then
        echo "  Loading $tarfile..."
        sudo docker load -i "$tarfile"
    fi
done

echo ""
echo "✅ All images loaded!"
echo "📊 Loaded images:"
sudo docker images

echo ""
echo "🏗️ Now starting containers..."
cd /home/webadm/openproject
sudo docker compose -f docker-compose.enterprise.yml up -d

echo ""
echo "⏳ Waiting 30s for services..."
sleep 30

echo ""
echo "📊 Container Status:"
sudo docker ps

echo ""
echo "✅ DEPLOYMENT COMPLETE!"
echo "🌍 Access: http://10.2.3.15:8200"
echo "👤 Login: admin / admin"
