# Praktikum DevOps Minggu 1
## Introduction to DevOps: Filosofi, Budaya, & SDLC

Repository ini berisi implementasi praktikum DevOps Minggu 1 mengenai perbandingan proses deployment manual dan deployment berbasis automation.

Project ini mensimulasikan permasalahan **Wall of Confusion** antara Developer (Dev) dan Operations (Ops), kemudian memperbaikinya menggunakan pendekatan DevOps melalui automation script, version control, dan dokumentasi proses.

---

## 👥 Team

| Role | Member |
|---|---|
| Developer | Laila Rezky |
| Operations | Muhammad Danish |

---

# 📌 Project Overview

Aplikasi yang digunakan pada praktikum ini adalah:

**Sentra Digital Batam**

Aplikasi sederhana berbasis Flask yang digunakan sebagai simulasi deployment dalam proses Software Development Life Cycle (SDLC).

Pada tahap awal, deployment dilakukan secara manual dengan proses handover antara Developer dan Operations. Proses tersebut menyebabkan beberapa permasalahan seperti:

- Dependency aplikasi tidak terdokumentasi dengan baik
- Perbedaan environment antara Developer dan Operations
- Proses troubleshooting membutuhkan komunikasi tambahan

Permasalahan tersebut kemudian diperbaiki menggunakan automation script `setup.sh`.

---

# 🏗️ Workflow Praktikum

## 1. Manual Deployment (JOB 2)

Pada proses awal:

```
Developer
    |
    |  Serah-terima artefak manual
    |
    v
Operations
    |
    |  Install dependency & menjalankan aplikasi
    |
    v
Deployment Failure
```

Masalah yang ditemukan:

- Dependency belum tersedia
- Environment berbeda
- Instruksi deployment masih manual

---

## 2. Automated Deployment (JOB 4)

Perbaikan dilakukan dengan membuat automation script:

```
Developer
    |
    v
Git Repository
    |
    v
Operations

Menjalankan:

./setup.sh
```

Script akan:

- Mengecek kebutuhan environment
- Membuat virtual environment
- Menginstall dependency
- Menjalankan aplikasi
- Melakukan health check

---

# 📂 Project Structure

```
app-sentra/
│
├── src/
│   └── app.py
│
├── requirements.txt
│
├── setup.sh
│
├── .gitignore
│
├── HANDOVER.md
│
└── POSTMORTEM.md
```

---

# ⚙️ Requirements

Environment yang dibutuhkan:

- Linux / WSL Ubuntu
- Python 3.10+
- Git
- pip

---

# 🚀 Installation & Running

Clone repository:

```bash
git clone https://github.com/dan15here/praktikum-devops-m01.git
```

Masuk ke directory:

```bash
cd praktikum-devops-m01
```

Jalankan automation deployment:

```bash
./setup.sh
```

Jika berhasil akan muncul:

```
SUKSES: aplikasi berjalan dan lulus health check.
```

---

# 🧪 Testing

Health check aplikasi:

```bash
curl http://127.0.0.1:5000/health
```

Expected response:

```json
{
  "status": "ok"
}
```

---

# 🔄 SDLC Comparison

## Waterfall Flow

```
Requirement
      |
      v
Design
      |
      v
Implementation
      |
      v
Testing
      |
      v
Deployment
```

## DevOps Continuous Flow

```
Backlog
   |
   v
In Progress
   |
   v
Review
   |
   v
Deployed
   |
   v
Monitored
```

---

# 📊 DevOps Implementation

Implementasi DevOps pada project ini:

✅ Version Control menggunakan Git  
✅ Repository menggunakan GitHub  
✅ Automation deployment menggunakan `setup.sh`  
✅ Dependency management menggunakan `requirements.txt`  
✅ Environment isolation menggunakan virtual environment  
✅ Dokumentasi insiden menggunakan Blameless Postmortem  

---

# 📝 Postmortem

Dokumentasi analisis kegagalan deployment manual tersedia pada:

```
POSTMORTEM.md
```

Dokumen tersebut berisi:

- Ringkasan insiden
- Timeline kejadian
- Dampak
- Root cause analysis
- Action items
- Lesson learned

---

# 📚 Praktikum

Mata Kuliah:

**DevOps**

Topik:

**Introduction to DevOps: Filosofi, Budaya, & SDLC**

Politeknik Negeri Batam

---
