# 🗄️ Database Recall Guide - How to Get Data from Backend

## 🎯 **Overview**

This guide shows you how to recall (sync) data from your backend database to your Flutter app. Your backend is accessible via:
- **External URL**: `http://47.205.170.164:3003/api`
- **Local URL**: `http://192.168.4.152:3003/api`

## 🔧 **Current Issue & Solution**

### **Problem**: Authentication Token Expired
The app is getting "Unauthorized access" errors because the JWT token has expired.

### **Solution**: Auto-Reauthentication
I've implemented automatic token validation and re-authentication to fix this issue.

## 📱 **How to Recall Data from Backend**

### **Method 1: Using the Database Management Screen**

1. **Open the Database Management Screen**
   - Navigate to the new Database Management screen in your app
   - This screen shows backend status and database statistics

2. **Check Backend Connection**
   - The screen automatically checks if the backend is accessible
   - Shows green checkmark if connected, red X if disconnected

3. **Sync All Data**
   - Tap "Sync All Data" button
   - This will fetch all data from the backend database
   - Shows progress and results

4. **Export Data**
   - Tap "Export Data to JSON" to download all data
   - Useful for backup or analysis

### **Method 2: Using API Commands**

#### **Test Backend Connection**
```bash
# Health check
curl http://47.205.170.164:3003/api/health

# Expected response:
{"status":"OK","message":"SAEED Laboratory API is running"}
```

#### **Login to Get Fresh Token**
```bash
# Login with admin credentials
curl -X POST http://47.205.170.164:3003/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Response includes access_token
```

#### **Fetch Data with Authentication**
```bash
# Get all patients (replace <token> with actual token)
curl -X GET http://47.205.170.164:3003/api/patients/ \
  -H "Authorization: Bearer <token>"

# Get all tests
curl -X GET http://47.205.170.164:3003/api/tests/ \
  -H "Authorization: Bearer <token>"

# Get all appointments
curl -X GET http://47.205.170.164:3003/api/appointments/ \
  -H "Authorization: Bearer <token>"

# Get all payments
curl -X GET http://47.205.170.164:3003/api/payments/ \
  -H "Authorization: Bearer <token>"
```

### **Method 3: Using the Flutter App**

#### **Automatic Data Loading**
The app automatically tries to load data when you:
1. **Open the app** - Loads patients and tests
2. **Navigate to screens** - Loads relevant data
3. **Pull to refresh** - Reloads data from backend

#### **Manual Refresh**
- **Pull down** on any list screen to refresh
- **Tap refresh button** in app bars
- **Restart the app** to force reload

## 🔄 **Data Sync Process**

### **What Gets Synced**
1. **Patients** - All patient records
2. **Tests** - All laboratory tests
3. **Appointments** - All scheduled appointments
4. **Payments** - All payment records
5. **Users** - All user accounts

### **Sync Flow**
```
App → Check Token → If Expired → Re-authenticate → Fetch Data → Update UI
```

### **Fallback Strategy**
```
Backend API → If Failed → Local Storage → If Failed → Show Error
```

## 📊 **Database Statistics**

### **Current Data Counts**
- **Patients**: 10+ records
- **Tests**: 100+ records
- **Appointments**: Available
- **Payments**: Available
- **Users**: Multiple accounts

### **How to Check Stats**
1. **In the App**: Database Management screen shows live stats
2. **Via API**: Use the stats endpoint
3. **Via Command Line**: Use curl commands above

## 🛠️ **Troubleshooting**

### **If Data Won't Load**

#### **1. Check Authentication**
```bash
# Test login
curl -X POST http://47.205.170.164:3003/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

#### **2. Check Backend Health**
```bash
# Health check
curl http://47.205.170.164:3003/api/health
```

#### **3. Check Network**
```bash
# Test connectivity
ping 47.205.170.164
```

### **Common Issues**

#### **"Unauthorized Access"**
- **Cause**: Token expired
- **Solution**: App will auto-reauthenticate, or manually login again

#### **"Connection Failed"**
- **Cause**: Network issue or backend down
- **Solution**: Check internet connection and backend status

#### **"No Data Found"**
- **Cause**: Database empty or API error
- **Solution**: Check backend logs and database content

## 📋 **Step-by-Step Instructions**

### **For Users**
1. **Open the app**
2. **Login** with `admin` / `admin123`
3. **Navigate** to any screen (data loads automatically)
4. **Pull to refresh** if needed
5. **Use Database Management** screen for advanced operations

### **For Developers**
1. **Check backend status**: `curl http://47.205.170.164:3003/api/health`
2. **Get fresh token**: Login API call
3. **Fetch data**: Use authenticated API calls
4. **Monitor logs**: Check app and backend logs

### **For Administrators**
1. **Monitor backend**: Check server status
2. **Check database**: Verify data exists
3. **Review logs**: Look for errors
4. **Restart if needed**: Restart backend server

## 🎯 **Quick Commands**

### **Test Everything**
```bash
# 1. Health check
curl http://47.205.170.164:3003/api/health

# 2. Login
curl -X POST http://47.205.170.164:3003/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 3. Get data (replace <token>)
curl -X GET http://47.205.170.164:3003/api/patients/ \
  -H "Authorization: Bearer <token>"
```

### **Export All Data**
```bash
# Get all data types
curl -X GET http://47.205.170.164:3003/api/patients/ -H "Authorization: Bearer <token>"
curl -X GET http://47.205.170.164:3003/api/tests/ -H "Authorization: Bearer <token>"
curl -X GET http://47.205.170.164:3003/api/appointments/ -H "Authorization: Bearer <token>"
curl -X GET http://47.205.170.164:3003/api/payments/ -H "Authorization: Bearer <token>"
```

## 🎉 **Success Indicators**

### **✅ Working Correctly**
- App loads data automatically
- No "Unauthorized" errors
- Data appears in lists
- Sync operations complete successfully

### **❌ Needs Attention**
- "Unauthorized access" messages
- Empty data lists
- Connection timeouts
- Sync failures

## 📞 **Support**

### **If You Need Help**
1. **Check this guide** for troubleshooting steps
2. **Test backend connectivity** using curl commands
3. **Check app logs** for specific error messages
4. **Verify credentials** are correct (`admin` / `admin123`)

### **Backend Information**
- **External URL**: `http://47.205.170.164:3003/api`
- **Local URL**: `http://192.168.4.152:3003/api`
- **Health Check**: `/api/health`
- **Login**: `/api/auth/login`

**🎯 Your backend database is fully accessible and ready to sync data to your Flutter app!**
