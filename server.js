const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const path = require('path');
const app = express();
const port = 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// Database connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Bismilah786$',
    database: 'lab_management'
});

// Connect to database with retry
function connectWithRetry() {
    db.connect((err) => {
        if (err) {
            console.error('Error connecting to database:', err);
            console.log('Retrying connection in 5 seconds...');
            setTimeout(connectWithRetry, 5000);
            return;
        }
        console.log('Connected to MySQL database');
        
        // Create database and tables if they don't exist
        const setupQueries = [
            'CREATE DATABASE IF NOT EXISTS lab_management',
            'USE lab_management',
            `CREATE TABLE IF NOT EXISTS patients (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                dob DATE NOT NULL,
                gender ENUM('male', 'female', 'other') NOT NULL,
                contact_number VARCHAR(20) NOT NULL,
                email VARCHAR(100),
                address TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )`,
            `CREATE TABLE IF NOT EXISTS tests (
                id INT AUTO_INCREMENT PRIMARY KEY,
                patient_id INT NOT NULL,
                test_type VARCHAR(50) NOT NULL,
                date DATE NOT NULL,
                priority ENUM('normal', 'urgent', 'emergency') NOT NULL,
                status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (patient_id) REFERENCES patients(id)
            )`
        ];

        setupQueries.forEach(query => {
            db.query(query, (err) => {
                if (err) {
                    console.error('Error setting up database:', err);
                }
            });
        });
    });
}

// Start connection
connectWithRetry();

// API Routes

// Get all patients
app.get('/api/patients', (req, res) => {
    const query = 'SELECT * FROM patients ORDER BY name';
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(results);
    });
});

// Add new patient
app.post('/api/patients', (req, res) => {
    const { name, dob, gender, contact_number, email, address } = req.body;
    const query = 'INSERT INTO patients (name, dob, gender, contact_number, email, address) VALUES (?, ?, ?, ?, ?, ?)';
    db.query(query, [name, dob, gender, contact_number, email, address], (err, result) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ id: result.insertId, message: 'Patient added successfully' });
    });
});

// Get all tests
app.get('/api/tests', (req, res) => {
    const query = `
        SELECT t.*, p.name as patient_name 
        FROM tests t 
        JOIN patients p ON t.patient_id = p.id 
        ORDER BY t.date DESC 
        LIMIT 10
    `;
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(results);
    });
});

// Add new test
app.post('/api/tests', (req, res) => {
    const { patient_id, test_type, date, priority, notes } = req.body;
    const query = 'INSERT INTO tests (patient_id, test_type, date, priority, notes) VALUES (?, ?, ?, ?, ?)';
    db.query(query, [patient_id, test_type, date, priority, notes], (err, result) => {
        if (err) {
            res.status(500).json({ error: err.message });
            return;
        }
        res.json({ id: result.insertId, message: 'Test added successfully' });
    });
});

// Update test status
app.patch('/api/tests/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;
        await pool.query('UPDATE Tests SET Status = ? WHERE TestID = ?', [status, id]);
        res.json({ message: 'Test status updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Generate report
app.get('/api/reports/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [tests] = await pool.query(`
            SELECT t.*, p.*, tr.* 
            FROM Tests t 
            JOIN Patients p ON t.PatientID = p.PatientID 
            LEFT JOIN TestResults tr ON t.TestID = tr.TestID 
            WHERE t.TestID = ?
        `, [id]);
        
        if (tests.length === 0) {
            return res.status(404).json({ error: 'Test not found' });
        }

        // Generate PDF report
        const report = generatePDFReport(tests[0]);
        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', `attachment; filename=test-report-${id}.pdf`);
        res.send(report);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Print report
app.get('/api/print/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const [tests] = await pool.query(`
            SELECT t.*, p.* 
            FROM Tests t 
            JOIN Patients p ON t.PatientID = p.PatientID 
            WHERE t.TestID = ?
        `, [id]);
        
        if (tests.length === 0) {
            return res.status(404).json({ error: 'Test not found' });
        }

        // Send to printer
        await printReport(tests[0]);
        res.json({ message: 'Report sent to printer successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Search tests
app.get('/api/search', async (req, res) => {
    try {
        const { q } = req.query;
        const [results] = await pool.query(`
            SELECT t.*, p.FullName as PatientName 
            FROM Tests t 
            JOIN Patients p ON t.PatientID = p.PatientID 
            WHERE p.FullName LIKE ? 
            OR t.TestType LIKE ? 
            OR t.TestID LIKE ?
        `, [`%${q}%`, `%${q}%`, `%${q}%`]);
        res.json(results);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get dashboard statistics
app.get('/api/stats', (req, res) => {
    const queries = {
        totalTests: 'SELECT COUNT(*) as count FROM tests',
        pendingTests: 'SELECT COUNT(*) as count FROM tests WHERE status = "pending"',
        todayPatients: 'SELECT COUNT(DISTINCT patient_id) as count FROM tests WHERE DATE(date) = CURDATE()',
        completedTests: 'SELECT COUNT(*) as count FROM tests WHERE status = "completed" AND date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)'
    };

    Promise.all(Object.values(queries).map(query => 
        new Promise((resolve, reject) => {
            db.query(query, (err, results) => {
                if (err) reject(err);
                else resolve(results[0].count);
            });
        })
    ))
    .then(results => {
        res.json({
            totalTests: results[0],
            pendingTests: results[1],
            todayPatients: results[2],
            completedTests: results[3]
        });
    })
    .catch(err => {
        res.status(500).json({ error: err.message });
    });
});

// Check system status
app.get('/api/system/status', async (req, res) => {
    try {
        // Check database connection
        await pool.query('SELECT 1');
        
        // Check printer status (mock implementation)
        const printerStatus = true;
        
        // Check for updates (mock implementation)
        const updatesAvailable = false;
        
        res.json({
            database: true,
            printer: printerStatus,
            updates: updatesAvailable
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Helper functions
function generatePDFReport(test) {
    // Implementation for PDF generation
    // This would typically use a PDF library like PDFKit
    return Buffer.from('PDF content');
}

async function printReport(test) {
    // Implementation for sending to printer
    // This would typically use a printer library or system command
    return true;
}

// Start server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 