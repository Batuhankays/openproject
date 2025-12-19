#!/bin/bash
set -e

echo "🔧 Configuring Docker DNS..."
sudo mkdir -p /etc/docker

# Create daemon.json with Google DNS
cat << 'EOF' | sudo tee /etc/docker/daemon.json > /dev/null
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

echo "🔄 Restarting Docker daemon..."
sudo systemctl restart docker
sleep 5

echo "🧹 Cleaning up old containers..."
sudo docker stop $(sudo docker ps -aq) 2>/dev/null || true
sudo docker rm $(sudo docker ps -aq) 2>/dev/null || true

echo "📂 Navigating to project..."
cd /home/webadm/openproject || exit 1

echo "📥 Pulling Docker images..."
sudo docker compose -f docker-compose.enterprise.yml pull || echo "⚠️ Pull had some issues, continuing..."

echo "🏗️ Building and starting containers..."
sudo docker compose -f docker-compose.enterprise.yml up -d --build

echo "⏳ Waiting 30 seconds for services to start..."
sleep 30

echo ""
echo "📊 Container Status:"
sudo docker ps

echo ""
echo "✅ DEPLOYMENT COMPLETE!"
echo "🌍 Access: http://10.2.3.15:8200"
echo "👤 Login: admin / admin"
echo ""
