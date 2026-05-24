#!/bin/bash

echo "🔑 Setting up MySQL Password for SAEED Laboratory"
echo "================================================"
echo ""

echo "Please enter your MySQL root password:"
read -s mysql_password

if [ -z "$mysql_password" ]; then
    echo "❌ Password cannot be empty"
    exit 1
fi

# Test the password
echo "Testing password..."
if mysql -u root -p"$mysql_password" -e "SELECT 1;" 2>/dev/null; then
    echo "✅ Password is correct!"
    
    # Update .env file
    if [ -f ".env" ]; then
        sed -i '' "s/your_mysql_root_password_here/$mysql_password/" .env
        echo "✅ .env file updated with your password"
    else
        echo "❌ .env file not found. Please run: cp env.example .env"
        exit 1
    fi
    
    echo ""
    echo "🎉 Setup complete! You can now start the server:"
    echo "   npm start"
    echo ""
    echo "📱 And run the mobile app:"
    echo "   cd lab_mobile_app && flutter run"
    
else
    echo "❌ Password is incorrect. Please try again."
    exit 1
fi
