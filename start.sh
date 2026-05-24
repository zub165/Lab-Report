#!/bin/bash

# Medical Laboratory Management System Startup Script
echo "=========================================="
echo "Medical Laboratory Management System"
echo "=========================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    echo "❌ MySQL is not installed. Please install MySQL first."
    echo "Visit: https://dev.mysql.com/downloads/"
    exit 1
fi

echo "✅ Node.js and MySQL are installed"

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
    echo "✅ Dependencies installed successfully"
else
    echo "✅ Dependencies already installed"
fi

# Check if .env file exists, if not create one
if [ ! -f ".env" ]; then
    echo "🔧 Creating environment configuration..."
    cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_USER=labadmin
DB_PASSWORD=your_password_here
DB_NAME=Medi_Lab
DB_SSL=false

# Server Configuration
PORT=3003
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:3003,http://127.0.0.1:3003

# Security
JWT_SECRET=your_jwt_secret_here
SESSION_SECRET=your_session_secret_here
EOF
    echo "✅ Environment file created (.env)"
    echo "⚠️  Please update the .env file with your database credentials"
fi

# Check if database exists and has data
echo "🔍 Checking database status..."
mysql -u root -p -e "USE Medi_Lab;" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "📊 Setting up database..."
    echo "Please enter your MySQL root password:"
    mysql -u root -p < setup_database.sql
    if [ $? -ne 0 ]; then
        echo "❌ Failed to setup database"
        echo "Please run the setup_database.sql script manually"
        exit 1
    fi
    echo "✅ Database setup completed"
else
    echo "✅ Database already exists"
fi

# Start the server
echo "🚀 Starting the server..."
echo "The application will be available at: http://localhost:3003"
echo "Press Ctrl+C to stop the server"
echo ""

npm start
