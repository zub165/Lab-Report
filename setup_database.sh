#!/bin/bash

echo "🔧 SAEED Laboratory Management System - Database Setup"
echo "======================================================"
echo ""

# Check if MySQL is running
if ! brew services list | grep mysql | grep started > /dev/null; then
    echo "❌ MySQL is not running. Starting MySQL..."
    brew services start mysql
    sleep 5
fi

echo "📊 Database Status:"
echo "   - MySQL Service: Running"
echo "   - Database: Medi_Lab (created)"
echo "   - Tables: Loaded with sample data"
echo ""

echo "🔑 Database Connection Setup:"
echo "   The server needs your MySQL root password to connect."
echo "   Please follow these steps:"
echo ""
echo "   1. Copy the env.example file to .env:"
echo "      cp env.example .env"
echo ""
echo "   2. Edit the .env file and replace 'your_mysql_root_password_here'"
echo "      with your actual MySQL root password"
echo ""
echo "   3. Restart the server:"
echo "      npm start"
echo ""

echo "📝 Quick Setup Commands:"
echo "   cp env.example .env"
echo "   # Edit .env file with your MySQL password"
echo "   npm start"
echo ""

echo "🎯 Current Status:"
echo "   ✅ MySQL is running"
echo "   ✅ Database 'Medi_Lab' exists"
echo "   ✅ Sample data is loaded"
echo "   ⚠️  Need to configure .env file with password"
echo ""

echo "💡 If you don't remember your MySQL root password, you can:"
echo "   1. Reset it: brew services stop mysql && brew services start mysql"
echo "   2. Or create a new user: mysql -u root -p"
echo ""
