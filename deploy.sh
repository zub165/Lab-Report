#!/bin/bash

# Stop the existing process
pm2 stop lab-management || true

# Pull the latest changes
git pull origin main

# Install dependencies
npm install --production

# Apply database migrations
mysql -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" lab_management < setup_vps_user.sql
mysql -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" lab_management < additional_tests.sql

# Create log directory if it doesn't exist
sudo mkdir -p /var/log/lab-management
sudo chown -R $USER:$USER /var/log/lab-management

# Start the application with PM2
pm2 start ecosystem.config.js --env production

# Save PM2 process list
pm2 save

echo "Deployment completed successfully!" 