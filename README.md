# Medical Laboratory Management System

A comprehensive web-based laboratory management system for medical facilities to manage patients, tests, appointments, and generate reports.

## Features

- **Dashboard**: Real-time statistics and overview of laboratory operations
- **Patient Management**: Add, edit, and manage patient information
- **Test Management**: Schedule and track laboratory tests
- **Appointment Scheduling**: Manage patient appointments
- **Report Generation**: Generate and print test reports with multiple templates
- **Payment Tracking**: Track payments and billing
- **Search Functionality**: Search across patients, tests, and reports
- **Responsive Design**: Works on desktop, tablet, and mobile devices

## Prerequisites

Before running this application, make sure you have the following installed:

- **Node.js** (version 18 or higher) - [Download here](https://nodejs.org/)
- **MySQL** (version 8.0 or higher) - [Download here](https://dev.mysql.com/downloads/)
- **Git** (for cloning the repository)

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd Lab-Report
```

### 2. Run the Startup Script
```bash
./start.sh
```

This script will:
- Check if Node.js and MySQL are installed
- Install dependencies
- Create environment configuration
- Set up the database
- Start the server

### 3. Access the Application
Open your web browser and navigate to:
```
http://localhost:3003
```

## Manual Setup

If you prefer to set up manually or the startup script doesn't work:

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
Create a `.env` file in the root directory:
```env
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
```

### 3. Set Up Database
```bash
# Create database user (run as MySQL root)
mysql -u root -p
CREATE USER 'labadmin'@'localhost' IDENTIFIED BY 'your_password_here';
GRANT ALL PRIVILEGES ON Medi_Lab.* TO 'labadmin'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Set up database schema and sample data
mysql -u labadmin -p < setup_database.sql
```

### 4. Start the Server
```bash
npm start
```

## Database Schema

The system uses the following main tables:

- **Patients**: Patient information and demographics
- **Tests**: Laboratory test records
- **TestResults**: Individual test parameters and results
- **TestTypes**: Available test types and pricing
- **Appointments**: Patient appointment scheduling
- **Payments**: Payment tracking and billing
- **Users**: System user accounts and roles

## API Endpoints

The system provides RESTful API endpoints:

### Patients
- `GET /api/patients` - Get all patients
- `GET /api/patients/:id` - Get patient by ID
- `POST /api/patients` - Create new patient
- `PUT /api/patients/:id` - Update patient
- `DELETE /api/patients/:id` - Delete patient

### Tests
- `GET /api/tests` - Get all tests
- `GET /api/tests/:id` - Get test by ID
- `POST /api/tests` - Create new test
- `PUT /api/tests/:id` - Update test
- `PATCH /api/tests/:id` - Update test status
- `DELETE /api/tests/:id` - Delete test

### Reports
- `GET /api/reports` - Get all reports
- `GET /api/reports/:id` - Get report by ID

### Statistics
- `GET /api/stats` - Get dashboard statistics

## Report Templates

The system includes multiple report templates:

1. **Standard Report**: Traditional laboratory report format
2. **Modern Report**: Clean, modern design
3. **Quest Diagnostics Style**: Professional medical report format

## Usage Guide

### Adding a Patient
1. Navigate to the "Patients" tab
2. Click "Add Patient" button
3. Fill in patient information
4. Click "Add Patient" to save

### Creating a Test
1. Navigate to the "Lab Tests" tab
2. Click "New Test" button
3. Select patient and test type
4. Set priority and add notes
5. Click "Add Test" to save

### Generating Reports
1. Navigate to the "Reports" tab
2. Find the test you want to report on
3. Click "Preview" to see the report
4. Choose a template
5. Click "Print" or "Download PDF"

### Managing Appointments
1. Navigate to the "Appointments" tab
2. Click "New Appointment" button
3. Select patient and test type
4. Set date and time
5. Click "Schedule" to save

## Troubleshooting

### Common Issues

**Database Connection Error**
- Ensure MySQL is running
- Check database credentials in `.env` file
- Verify database user has proper permissions

**Port Already in Use**
- Change the PORT in `.env` file
- Or kill the process using the port: `lsof -ti:3003 | xargs kill -9`

**Dependencies Installation Failed**
- Clear npm cache: `npm cache clean --force`
- Delete node_modules and package-lock.json
- Run `npm install` again

**CORS Errors**
- Check ALLOWED_ORIGINS in `.env` file
- Ensure the frontend URL is included in the allowed origins

### Logs
Check the console output for detailed error messages. The server logs all API requests and errors.

## Development

### Project Structure
```
Lab-Report/
├── index.html          # Main application interface
├── script.js           # Frontend JavaScript logic
├── database.js         # Database operations
├── server.js           # Express.js server
├── setup_database.sql  # Database schema and sample data
├── package.json        # Node.js dependencies
├── start.sh           # Startup script
└── README.md          # This file
```

### Adding New Features
1. Add new API endpoints in `server.js`
2. Update database schema if needed
3. Add frontend functionality in `script.js`
4. Update UI in `index.html`

### Testing
```bash
# Run tests (if configured)
npm test

# Start in development mode
npm run dev
```

## Security Considerations

- Change default passwords in production
- Use HTTPS in production
- Implement proper authentication and authorization
- Regularly update dependencies
- Backup database regularly

## Production Deployment

For production deployment:

1. Set `NODE_ENV=production` in `.env`
2. Use a production database
3. Set up HTTPS
4. Configure proper CORS settings
5. Use a process manager like PM2
6. Set up monitoring and logging

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review the console logs
3. Ensure all prerequisites are met
4. Verify database connectivity

## License

This project is licensed under the MIT License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Note**: This is a demonstration system. For production use in medical facilities, ensure compliance with local healthcare regulations and data protection laws. 