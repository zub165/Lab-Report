# Medical Laboratory Management System

A modern, web-based application for managing patients, lab tests, appointments, payments, and generating/printing lab reports. Designed for use by laboratory staff and administrators.

---

## 🔐 Database Connection
- **Host:** localhost
- **Port:** 3306
- **Username:** labadmin
- **Password:** Lab12345
- **Database:** lab_management

To test the connection:
```bash
mysql -u labadmin -pLab12345 -h localhost
```

---

## 🚀 Features
- Dashboard with real-time statistics
- Patient management (add, edit, view, delete)
- Lab test management (add, edit, view, print, preview)
- Appointment scheduling and management
- Payment processing and receipts
- Batch actions for reports (print, export, delete)
- Multiple report templates (Standard, Modern, Saeed Laboratory style)
- System settings and status
- Responsive, modern UI (Bootstrap)
- Mock data for demo/testing (localStorage)

---

## 🌐 Demo / Deployment
- **Static Frontend:** Can be deployed on GitHub Pages or any static web host.
- **Live Demo:**
  - If deployed via GitHub Pages, access at: `https://zub165.github.io/Lab-Report/`

---

## 🛠️ Getting Started
1. **Clone the repository:**
   ```bash
   git clone https://github.com/zub165/Lab-Report.git
   cd Lab-Report
   ```
2. **Open `index.html` in your browser**
   - No build step required. All logic is in HTML/JS/CSS.
3. **(Optional) Deploy to GitHub Pages:**
   - Go to your repo > Settings > Pages > Source: `main` or `master` branch, `/ (root)` folder.

---

## 📁 File Structure
- `index.html` — Main UI and modals
- `script.js` — Frontend logic, event handling, report generation
- `database.js` — Database abstraction and mock data
- `context.md` — Project workflow and architecture
- `setup_database.sql` / `database.sql` — (For future backend integration)

---

## 🧰 Technologies Used
- HTML, CSS (Bootstrap), JavaScript (ES6+)
- localStorage (mock data)
- Bootstrap, FontAwesome

---

## 📄 License
This project is licensed under the MIT License. 