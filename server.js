const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const path = require('path');
const app = express();
const port = process.env.PORT || 3003;

// Middleware
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    credentials: true
}));
app.use(express.json());
app.use(express.static('.'));

// Database configuration
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'labadmin',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'lab_management',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    ssl: process.env.DB_SSL === 'true' ? {
        rejectUnauthorized: false
    } : false
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Health check endpoint
app.get('/api/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({ status: 'healthy', environment: process.env.NODE_ENV });
    } catch (error) {
        console.error('Health check failed:', error);
        res.status(500).json({ error: 'Database connection failed' });
    }
});

// Patient endpoints
app.get('/api/patients', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM patients ORDER BY name');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/patients/:id', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM patients WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Patient not found' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/patients', async (req, res) => {
    try {
        const { name, dob, gender, contact_number, email, address } = req.body;
        const [result] = await pool.query(
            'INSERT INTO patients (name, dob, gender, contact_number, email, address) VALUES (?, ?, ?, ?, ?, ?)',
            [name, dob, gender, contact_number, email, address]
        );
        res.status(201).json({ id: result.insertId, ...req.body });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/patients/:id', async (req, res) => {
    try {
        const { name, dob, gender, contact_number, email, address } = req.body;
        await pool.query(
            'UPDATE patients SET name = ?, dob = ?, gender = ?, contact_number = ?, email = ?, address = ? WHERE id = ?',
            [name, dob, gender, contact_number, email, address, req.params.id]
        );
        const [rows] = await pool.query('SELECT * FROM patients WHERE id = ?', [req.params.id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/patients/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM patients WHERE id = ?', [req.params.id]);
        res.json({ message: 'Patient deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Test endpoints
app.get('/api/tests', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT t.*, p.name as patient_name 
            FROM tests t 
            JOIN patients p ON t.patient_id = p.id 
            ORDER BY t.date DESC
        `);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/tests/:id', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT t.*, p.name as patient_name 
            FROM tests t 
            JOIN patients p ON t.patient_id = p.id 
            WHERE t.id = ?
        `, [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Test not found' });
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/tests', async (req, res) => {
    try {
        const { patient_id, test_type, date, priority, notes } = req.body;
        const [result] = await pool.query(
            'INSERT INTO tests (patient_id, test_type, date, priority, notes) VALUES (?, ?, ?, ?, ?)',
            [patient_id, test_type, date, priority, notes]
        );
        const [rows] = await pool.query(`
            SELECT t.*, p.name as patient_name 
            FROM tests t 
            JOIN patients p ON t.patient_id = p.id 
            WHERE t.id = ?
        `, [result.insertId]);
        res.status(201).json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/tests/:id', async (req, res) => {
    try {
        const { patient_id, test_type, date, priority, status, notes } = req.body;
        await pool.query(
            'UPDATE tests SET patient_id = ?, test_type = ?, date = ?, priority = ?, status = ?, notes = ? WHERE id = ?',
            [patient_id, test_type, date, priority, status, notes, req.params.id]
        );
        const [rows] = await pool.query(`
            SELECT t.*, p.name as patient_name 
            FROM tests t 
            JOIN patients p ON t.patient_id = p.id 
            WHERE t.id = ?
        `, [req.params.id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/tests/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM tests WHERE id = ?', [req.params.id]);
        res.json({ message: 'Test deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Test Types endpoints
app.get('/api/test-types', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM TestTypes ORDER BY TestName');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/test-types', async (req, res) => {
    try {
        const { TestName, Description, Price } = req.body;
        const [result] = await pool.query(
            'INSERT INTO TestTypes (TestName, Description, Price) VALUES (?, ?, ?)',
            [TestName, Description, Price]
        );
        res.status(201).json({ 
            TestTypeID: result.insertId,
            TestName,
            Description,
            Price
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/test-types/:id', async (req, res) => {
    try {
        const { TestName, Description, Price } = req.body;
        await pool.query(
            'UPDATE TestTypes SET TestName = ?, Description = ?, Price = ? WHERE TestTypeID = ?',
            [TestName, Description, Price, req.params.id]
        );
        const [rows] = await pool.query('SELECT * FROM TestTypes WHERE TestTypeID = ?', [req.params.id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/test-types/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM TestParameters WHERE TestTypeID = ?', [req.params.id]);
        await pool.query('DELETE FROM TestTypes WHERE TestTypeID = ?', [req.params.id]);
        res.json({ message: 'Test type and associated parameters deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Test Parameters endpoints
app.get('/api/test-parameters/:testTypeId', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM TestParameters WHERE TestTypeID = ? ORDER BY ParameterName',
            [req.params.testTypeId]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/test-parameters', async (req, res) => {
    try {
        const { TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange } = req.body;
        const [result] = await pool.query(
            'INSERT INTO TestParameters (TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange) VALUES (?, ?, ?, ?, ?, ?)',
            [TestTypeID, ParameterName, Unit, MinValue, MaxValue, ReferenceRange]
        );
        res.status(201).json({ 
            ParameterID: result.insertId,
            TestTypeID,
            ParameterName,
            Unit,
            MinValue,
            MaxValue,
            ReferenceRange
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/test-parameters/:id', async (req, res) => {
    try {
        const { ParameterName, Unit, MinValue, MaxValue, ReferenceRange } = req.body;
        await pool.query(
            'UPDATE TestParameters SET ParameterName = ?, Unit = ?, MinValue = ?, MaxValue = ?, ReferenceRange = ? WHERE ParameterID = ?',
            [ParameterName, Unit, MinValue, MaxValue, ReferenceRange, req.params.id]
        );
        const [rows] = await pool.query('SELECT * FROM TestParameters WHERE ParameterID = ?', [req.params.id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/test-parameters/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM TestParameters WHERE ParameterID = ?', [req.params.id]);
        res.json({ message: 'Test parameter deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Dashboard Statistics endpoint
app.get('/api/stats', async (req, res) => {
    try {
        const today = new Date().toISOString().split('T')[0];
        
        // Get total tests
        const [totalTests] = await pool.query('SELECT COUNT(*) as count FROM tests');
        
        // Get pending tests
        const [pendingTests] = await pool.query("SELECT COUNT(*) as count FROM tests WHERE status = 'pending'");
        
        // Get today's patients
        const [todayPatients] = await pool.query('SELECT COUNT(DISTINCT patient_id) as count FROM tests WHERE DATE(date) = ?', [today]);
        
        // Get completed tests
        const [completedTests] = await pool.query("SELECT COUNT(*) as count FROM tests WHERE status = 'completed'");

        res.json({
            totalTests: totalTests[0].count,
            pendingTests: pendingTests[0].count,
            todayPatients: todayPatients[0].count,
            completedTests: completedTests[0].count
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Recent Tests endpoint
app.get('/api/tests/recent', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT t.*, p.name as patient_name 
            FROM tests t 
            JOIN patients p ON t.patient_id = p.id 
            ORDER BY t.date DESC 
            LIMIT 10
        `);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 