#!/bin/bash

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Nginx if not already installed
sudo apt install nginx -y

# Backup existing nginx configuration
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Create new nginx configuration
sudo cat > /etc/nginx/nginx.conf << 'EOL'
http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    # Lab Management System
    server {
        listen 80;
        server_name 208.109.215.53;

        location / {
            proxy_pass http://localhost:3001;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_cache_bypass $http_upgrade;
        }
    }

    # Second Application
    server {
        listen 8080;
        server_name 208.109.215.53;

        location / {
            proxy_pass http://localhost:3002;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_cache_bypass $http_upgrade;
        }
    }
}

events {
    worker_connections 1024;
}
EOL

# Set proper permissions
sudo chmod 644 /etc/nginx/nginx.conf

# Test Nginx configuration
sudo nginx -t

# If test is successful, reload Nginx
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    echo "Nginx configuration has been updated successfully!"
else
    echo "Error in Nginx configuration. Please check the configuration file."
    exit 1
fi

# Configure firewall
sudo apt install ufw -y
sudo ufw allow 80
sudo ufw allow 8080
sudo ufw allow 22
sudo ufw --force enable

echo "Setup completed successfully!" 