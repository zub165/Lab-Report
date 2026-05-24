# Medical Laboratory Management System — Context

## Overview
This application is a web-based Medical Laboratory Management System for managing patients, lab tests, appointments, payments, and generating/printing lab reports. It is designed for use by laboratory staff and administrators, providing a modern, tabbed interface and multiple report templates. Data is managed via localStorage (mock database) with a modular abstraction for future backend integration.

---

## Main Components

### 1. Frontend (index.html + script.js)
- **UI Structure:**
  - Sidebar navigation: Dashboard, Lab Tests, Patients, Appointments, Payments, Reports, Settings.
  - Main content: Tabbed interface for each module.
  - Modals: For adding/editing patients, tests, appointments, payments, and viewing details.

- **Tabs/Features:**
  - **Dashboard:**
    - Statistics cards (Total Tests, Pending, Today's Patients, Completed)
    - Recent tests table
    - Clicking a stat card shows a filtered patient/test list
  - **Lab Tests:**
    - Table of all tests
    - Add new test modal
    - View/print/preview test details
  - **Patients:**
    - Table of all patients
    - Add new patient modal
    - View patient details and test history
  - **Appointments:**
    - Table of appointments
    - Schedule new appointment modal
    - View/delete appointment
  - **Payments:**
    - Table of payments
    - Process new payment modal
    - View/print receipt
  - **Reports:**
    - Table of reports with batch actions (print/export/delete)
    - Filter by date/type
    - Statistics for total/completed/pending/today's reports
    - Multiple report templates (Standard, Modern, Saeed Laboratory/Quest style)
    - Report preview and print/download options
  - **Settings:**
    - System settings (lab name, address, contact)
    - System status (database, printer, updates)
    - Report settings (default template, QR code, printer type)

---

### 2. Data Layer (database.js + localStorage)
- **Database Abstraction (`db` object):**
  - Patients: CRUD operations
  - Tests: CRUD operations
  - Test Types: Read operations
  - Appointments: CRUD operations
  - Payments: CRUD operations
- **Mock Data:**
  - On first load, mock data for patients, tests, test types, appointments, and payments is generated and stored in localStorage.
- **All data operations in the UI interact with the `db` object, which reads/writes to localStorage.**

---

### 3. Business Logic (script.js)
- **Initialization:**
  - On DOMContentLoaded, initializes the database, loads mock data, and populates all tables and selectors.
- **Event Handling:**
  - Tab switching, modal opening, form submissions, and batch actions.
  - Dynamic updates to tables and statistics.
- **Report Generation:**
  - Multiple templates (Standard, Modern, Saeed Laboratory/Quest)
  - Dynamic rendering of patient/test data into printable HTML
  - Print and export (PDF/Excel/CSV) functionality
- **Notifications:**
  - Toast notifications for success/error/info
- **Offline Support:**
  - Uses cached data if offline, with notifications

---

## Workflow Summary
1. User logs in and sees the dashboard.
2. Navigation: User can switch between tabs to manage lab tests, patients, appointments, payments, and reports.
3. CRUD Operations: Add/edit/delete patients, tests, appointments, and payments via modals. All data is stored in localStorage via the `db` abstraction.
4. Reports: User can preview, print, and export lab reports in multiple formats. Batch actions are available for reports.
5. Settings: User can update lab info, system settings, and report preferences.
6. Notifications and Status: System provides real-time feedback and status updates.

---

## Extensibility
- **Backend Integration:** The current system uses localStorage for demo/mock data. The `db` abstraction and API endpoints are ready to be connected to a real backend (e.g., Node.js + MySQL).
- **Custom Report Templates:** Easily add new report templates by extending the `reportTemplates` object.
- **Role Management:** Can be extended to support user roles and authentication.

---

## Technologies Used
- **Frontend:** HTML, CSS (Bootstrap), JavaScript (ES6+)
- **Data Storage:** localStorage (mock), modular database abstraction
- **UI Libraries:** Bootstrap, FontAwesome
- **Printing/Export:** HTML to print, download as PDF/Excel/CSV

---

## File Structure
- `index.html` — Main UI and modals
- `script.js` — All frontend logic, event handling, and report generation
- `database.js` — Database abstraction and mock data management
- `setup_database.sql` / `database.sql` — (For future backend integration) 