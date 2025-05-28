// Database connection configuration
const dbConfig = {
    database: 'Medi_Lab.mdb',
    connectionString: 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Medi_Lab.mdb'
};

// API Configuration
const API_BASE_URL = 'http://localhost:3000';

// Utility Functions
const formatDate = (date) => {
    return new Date(date).toLocaleDateString('en-US', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
};

const showNotification = (message, type = 'success') => {
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0 position-fixed top-0 end-0 m-3`;
    toast.setAttribute('role', 'alert');
    toast.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">${message}</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    `;
    document.body.appendChild(toast);
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    setTimeout(() => toast.remove(), 3000);
};

// Patient Management Functions
const addPatient = async (patientData) => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/patients`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(patientData)
        });
        if (!response.ok) throw new Error('Failed to add patient');
        showNotification('Patient added successfully');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

const getPatients = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/patients`);
        if (!response.ok) throw new Error('Failed to fetch patients');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

// Test Management Functions
const addTest = async (testData) => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/tests`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(testData)
        });
        if (!response.ok) throw new Error('Failed to add test');
        showNotification('Test added successfully');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

const getTests = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/tests`);
        if (!response.ok) throw new Error('Failed to fetch tests');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

const updateTestStatus = async (testId, status) => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/tests/${testId}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status })
        });
        if (!response.ok) throw new Error('Failed to update test status');
        showNotification('Test status updated successfully');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

// Report Generation Functions
const generateReport = async (testId) => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/reports/${testId}`);
        if (!response.ok) throw new Error('Failed to generate report');
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `test-report-${testId}.pdf`;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        a.remove();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

// Print Functions
const printReport = async (testId) => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/print/${testId}`);
        if (!response.ok) throw new Error('Failed to print report');
        showNotification('Report sent to printer successfully');
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

// Search Functions
const searchTests = async (query) => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/search?q=${encodeURIComponent(query)}`);
        if (!response.ok) throw new Error('Failed to search tests');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

// Dashboard Statistics Functions
const getDashboardStats = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/dashboard/stats`);
        if (!response.ok) throw new Error('Failed to fetch dashboard statistics');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

// System Status Functions
const checkSystemStatus = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/system/status`);
        if (!response.ok) throw new Error('Failed to check system status');
        return await response.json();
    } catch (error) {
        showNotification(error.message, 'danger');
        throw error;
    }
};

// Event Listeners
document.addEventListener('DOMContentLoaded', async () => {
    // Initialize dashboard
    try {
        const stats = await getDashboardStats();
        updateDashboardStats(stats);
    } catch (error) {
        console.error('Failed to initialize dashboard:', error);
    }

    // Search functionality
    const searchInput = document.querySelector('input[placeholder="Search..."]');
    const searchButton = searchInput.nextElementSibling;
    
    searchButton.addEventListener('click', async () => {
        const query = searchInput.value.trim();
        if (query) {
            try {
                const results = await searchTests(query);
                updateSearchResults(results);
            } catch (error) {
                console.error('Search failed:', error);
            }
        }
    });

    // Quick action buttons
    document.querySelector('.btn-primary').addEventListener('click', () => {
        const newTestModal = new bootstrap.Modal(document.getElementById('newTestModal'));
        newTestModal.show();
    });

    document.querySelector('.btn-outline-primary').addEventListener('click', () => {
        const addPatientModal = new bootstrap.Modal(document.getElementById('addPatientModal'));
        addPatientModal.show();
    });

    // System status check
    setInterval(async () => {
        try {
            const status = await checkSystemStatus();
            updateSystemStatus(status);
        } catch (error) {
            console.error('System status check failed:', error);
        }
    }, 30000); // Check every 30 seconds
});

// UI Update Functions
const updateDashboardStats = (stats) => {
    document.querySelector('.stat-card:nth-child(1) h2').textContent = stats.totalTests;
    document.querySelector('.stat-card:nth-child(2) h2').textContent = stats.pendingTests;
    document.querySelector('.stat-card:nth-child(3) h2').textContent = stats.todayPatients;
    document.querySelector('.stat-card:nth-child(4) h2').textContent = stats.completedTests;
};

const updateSearchResults = (results) => {
    const tbody = document.querySelector('.table tbody');
    tbody.innerHTML = results.map(test => `
        <tr>
            <td>#${test.id}</td>
            <td>${test.patientName}</td>
            <td>${test.testType}</td>
            <td><span class="badge bg-${test.status === 'Completed' ? 'success' : 'warning'}">${test.status}</span></td>
            <td>${formatDate(test.date)}</td>
            <td>
                <button class="btn btn-sm btn-outline-primary" onclick="viewTest(${test.id})">View</button>
                <button class="btn btn-sm btn-outline-secondary" onclick="printReport(${test.id})">Print</button>
            </td>
        </tr>
    `).join('');
};

const updateSystemStatus = (status) => {
    const statusElements = document.querySelectorAll('.card-body .d-flex');
    statusElements[0].querySelector('span:last-child').innerHTML = 
        `<i class="fas fa-${status.database ? 'check' : 'times'}-circle"></i> ${status.database ? 'Connected' : 'Disconnected'}`;
    statusElements[1].querySelector('span:last-child').innerHTML = 
        `<i class="fas fa-${status.printer ? 'check' : 'times'}-circle"></i> ${status.printer ? 'Ready' : 'Not Ready'}`;
    statusElements[2].querySelector('span:last-child').innerHTML = 
        `<i class="fas fa-${status.updates ? 'exclamation' : 'check'}-circle"></i> ${status.updates ? 'Available' : 'Up to date'}`;
};

// Modal Functions
const showNewTestModal = () => {
    // Implementation for new test modal
};

const showAddPatientModal = () => {
    // Implementation for add patient modal
};

// Export functions for use in HTML
window.addPatient = addPatient;
window.getPatients = getPatients;
window.addTest = addTest;
window.getTests = getTests;
window.updateTestStatus = updateTestStatus;
window.generateReport = generateReport;
window.printReport = printReport;
window.searchTests = searchTests;
window.getDashboardStats = getDashboardStats;
window.checkSystemStatus = checkSystemStatus;

// Initialize Bootstrap tooltips and popovers
document.addEventListener('DOMContentLoaded', function() {
    // Load initial data
    loadDashboardStats();
    loadRecentTests();
    loadPatients();

    // Add event listeners
    document.querySelector('.btn-primary').addEventListener('click', () => {
        const newTestModal = new bootstrap.Modal(document.getElementById('newTestModal'));
        newTestModal.show();
    });

    document.querySelector('.btn-outline-primary').addEventListener('click', () => {
        const addPatientModal = new bootstrap.Modal(document.getElementById('addPatientModal'));
        addPatientModal.show();
    });
});

// Load dashboard statistics
async function loadDashboardStats() {
    try {
        const response = await fetch('/api/stats');
        const stats = await response.json();
        
        document.querySelector('.stat-card:nth-child(1) h2').textContent = stats.totalTests;
        document.querySelector('.stat-card:nth-child(2) h2').textContent = stats.pendingTests;
        document.querySelector('.stat-card:nth-child(3) h2').textContent = stats.todayPatients;
        document.querySelector('.stat-card:nth-child(4) h2').textContent = stats.completedTests;
    } catch (error) {
        console.error('Error loading dashboard stats:', error);
    }
}

// Load recent tests
async function loadRecentTests() {
    try {
        const response = await fetch('/api/tests');
        const tests = await response.json();
        
        const tbody = document.querySelector('table tbody');
        tbody.innerHTML = '';
        
        tests.forEach(test => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>#${test.id}</td>
                <td>${test.patient_name}</td>
                <td>${test.test_type}</td>
                <td><span class="badge bg-${test.status === 'completed' ? 'success' : 'warning'}">${test.status}</span></td>
                <td>${new Date(test.date).toLocaleDateString()}</td>
                <td>
                    <button class="btn btn-sm btn-outline-primary" onclick="viewTest(${test.id})">View</button>
                    <button class="btn btn-sm btn-outline-secondary" onclick="printTest(${test.id})">Print</button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    } catch (error) {
        console.error('Error loading recent tests:', error);
    }
}

// Load patients for dropdown
async function loadPatients() {
    try {
        const response = await fetch('/api/patients');
        const patients = await response.json();
        
        const select = document.querySelector('select[name="patientId"]');
        select.innerHTML = '<option value="">Select Patient</option>';
        
        patients.forEach(patient => {
            const option = document.createElement('option');
            option.value = patient.id;
            option.textContent = patient.name;
            select.appendChild(option);
        });
    } catch (error) {
        console.error('Error loading patients:', error);
    }
}

// Submit new test
async function submitNewTest() {
    const form = document.getElementById('newTestForm');
    const formData = new FormData(form);
    
    try {
        const response = await fetch('/api/tests', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                patient_id: formData.get('patientId'),
                test_type: formData.get('testType'),
                date: formData.get('testDate'),
                priority: formData.get('priority'),
                notes: formData.get('notes')
            })
        });
        
        if (response.ok) {
            const newTestModal = bootstrap.Modal.getInstance(document.getElementById('newTestModal'));
            newTestModal.hide();
            form.reset();
            loadRecentTests();
            loadDashboardStats();
        }
    } catch (error) {
        console.error('Error submitting new test:', error);
    }
}

// Submit new patient
async function submitNewPatient() {
    const form = document.getElementById('addPatientForm');
    const formData = new FormData(form);
    
    try {
        const response = await fetch('/api/patients', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                name: formData.get('fullName'),
                dob: formData.get('dob'),
                gender: formData.get('gender'),
                contact_number: formData.get('contactNumber'),
                email: formData.get('email'),
                address: formData.get('address')
            })
        });
        
        if (response.ok) {
            const addPatientModal = bootstrap.Modal.getInstance(document.getElementById('addPatientModal'));
            addPatientModal.hide();
            form.reset();
            loadPatients();
        }
    } catch (error) {
        console.error('Error submitting new patient:', error);
    }
}

// View test details
async function viewTest(testId) {
    try {
        const response = await fetch(`/api/tests/${testId}`);
        const test = await response.json();
        
        document.getElementById('patientInfo').innerHTML = `
            <strong>Name:</strong> ${test.patient_name}<br>
            <strong>Test Type:</strong> ${test.test_type}<br>
            <strong>Date:</strong> ${new Date(test.date).toLocaleDateString()}
        `;
        
        document.getElementById('testInfo').innerHTML = `
            <strong>Status:</strong> ${test.status}<br>
            <strong>Priority:</strong> ${test.priority}<br>
            <strong>Notes:</strong> ${test.notes || 'None'}
        `;
        
        const viewTestModal = new bootstrap.Modal(document.getElementById('viewTestModal'));
        viewTestModal.show();
    } catch (error) {
        console.error('Error loading test details:', error);
    }
}

// Print test
function printTest(testId) {
    window.print();
} 