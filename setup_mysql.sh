#!/bin/bash

echo "🔧 Setting up MySQL for SAEED Laboratory Management System"
echo ""

# Check if MySQL is running
if ! brew services list | grep mysql | grep started > /dev/null; then
    echo "❌ MySQL is not running. Starting MySQL..."
    brew services start mysql
    sleep 5
fi

echo "📊 Creating database and user..."
echo "Please enter your MySQL root password when prompted:"

# Create database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS Medi_Lab;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Database 'Medi_Lab' created successfully"
else
    echo "❌ Failed to create database"
    exit 1
fi

# Create user and grant privileges
mysql -u root -p -e "CREATE USER IF NOT EXISTS 'labadmin'@'localhost' IDENTIFIED BY 'labadmin123';" 2>/dev/null
mysql -u root -p -e "GRANT ALL PRIVILEGES ON Medi_Lab.* TO 'labadmin'@'localhost';" 2>/dev/null
mysql -u root -p -e "FLUSH PRIVILEGES;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ User 'labadmin' created with privileges"
else
    echo "❌ Failed to create user"
    exit 1
fi

# Set up the database schema
echo "📋 Setting up database schema..."
mysql -u root -p Medi_Lab < setup_database.sql

if [ $? -eq 0 ]; then
    echo "✅ Database schema set up successfully"
else
    echo "❌ Failed to set up database schema"
    exit 1
fi

echo ""
echo "🎉 MySQL setup completed successfully!"
echo ""
echo "📝 Database Details:"
echo "   Database: Medi_Lab"
echo "   User: labadmin"
echo "   Password: labadmin123"
echo "   Host: localhost"
echo ""
echo "🚀 You can now start the server with: npm start"
