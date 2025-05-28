// Database operations using fetch API to communicate with the server
const db = {
    // Base URL for API endpoints
    baseUrl: 'http://208.109.215.53:3003/api',

    // Initialize
    async init() {
        try {
            // Test connection
            const response = await fetch(`${this.baseUrl}/health`);
            if (!response.ok) throw new Error('API connection failed');
            console.log('API connection initialized');
            return true;
        } catch (error) {
            console.error('API initialization error:', error);
            return false;
        }
    },

    // Patient operations
    patients: {
        async getAll() {
            const response = await fetch(`${db.baseUrl}/patients`);
            if (!response.ok) throw new Error('Failed to fetch patients');
            return response.json();
        },

        async getById(id) {
            const response = await fetch(`${db.baseUrl}/patients/${id}`);
            if (!response.ok) throw new Error('Failed to fetch patient');
            return response.json();
        },

        async create(patientData) {
            const response = await fetch(`${db.baseUrl}/patients`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(patientData)
            });
            if (!response.ok) throw new Error('Failed to create patient');
            return response.json();
        },

        async update(id, patientData) {
            const response = await fetch(`${db.baseUrl}/patients/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(patientData)
            });
            if (!response.ok) throw new Error('Failed to update patient');
            return response.json();
        },

        async delete(id) {
            const response = await fetch(`${db.baseUrl}/patients/${id}`, {
                method: 'DELETE'
            });
            if (!response.ok) throw new Error('Failed to delete patient');
            return true;
        }
    },

    // Test operations
    tests: {
        async getAll() {
            const response = await fetch(`${db.baseUrl}/tests`);
            if (!response.ok) throw new Error('Failed to fetch tests');
            return response.json();
        },

        async getById(id) {
            const response = await fetch(`${db.baseUrl}/tests/${id}`);
            if (!response.ok) throw new Error('Failed to fetch test');
            return response.json();
        },

        async create(testData) {
            const response = await fetch(`${db.baseUrl}/tests`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(testData)
            });
            if (!response.ok) throw new Error('Failed to create test');
            return response.json();
        },

        async update(id, testData) {
            const response = await fetch(`${db.baseUrl}/tests/${id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(testData)
            });
            if (!response.ok) throw new Error('Failed to update test');
            return response.json();
        },

        async delete(id) {
            const response = await fetch(`${db.baseUrl}/tests/${id}`, {
                method: 'DELETE'
            });
            if (!response.ok) throw new Error('Failed to delete test');
            return true;
        }
    },

    // Test Types operations
    testTypes: {
        async getAll() {
            return storage.get('mockTestTypes') || [];
        },

        async getById(id) {
            const types = await this.getAll();
            return types.find(t => t.id === id);
        }
    },

    // Appointment operations
    appointments: {
        async getAll() {
            return storage.get('mockAppointments') || [];
        },

        async getById(id) {
            const appointments = await this.getAll();
            return appointments.find(a => a.id === id);
        },

        async create(appointmentData) {
            const appointments = await this.getAll();
            const newAppointment = {
                id: appointments.length + 1,
                ...appointmentData,
                status: 'Scheduled',
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };
            appointments.push(newAppointment);
            storage.save('mockAppointments', appointments);
            return newAppointment;
        },

        async update(id, appointmentData) {
            const appointments = await this.getAll();
            const index = appointments.findIndex(a => a.id === id);
            if (index === -1) return null;
            
            appointments[index] = {
                ...appointments[index],
                ...appointmentData,
                updatedAt: new Date().toISOString()
            };
            storage.save('mockAppointments', appointments);
            return appointments[index];
        },

        async delete(id) {
            const appointments = await this.getAll();
            const filteredAppointments = appointments.filter(a => a.id !== id);
            storage.save('mockAppointments', filteredAppointments);
            return true;
        }
    },

    // Payment operations
    payments: {
        async getAll() {
            return storage.get('mockPayments') || [];
        },

        async getById(id) {
            const payments = await this.getAll();
            return payments.find(p => p.id === id);
        },

        async create(paymentData) {
            const payments = await this.getAll();
            const newPayment = {
                id: payments.length + 1,
                ...paymentData,
                status: 'Pending',
                paymentDate: new Date().toISOString(),
                transactionId: `TXN${Date.now()}`
            };
            payments.push(newPayment);
            storage.save('mockPayments', payments);
            return newPayment;
        },

        async update(id, paymentData) {
            const payments = await this.getAll();
            const index = payments.findIndex(p => p.id === id);
            if (index === -1) return null;
            
            payments[index] = {
                ...payments[index],
                ...paymentData,
                updatedAt: new Date().toISOString()
            };
            storage.save('mockPayments', payments);
            return payments[index];
        },

        async delete(id) {
            const payments = await this.getAll();
            const filteredPayments = payments.filter(p => p.id !== id);
            storage.save('mockPayments', filteredPayments);
            return true;
        }
    }
};

// Make db available globally
window.db = db; 