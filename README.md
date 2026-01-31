# S3Hero 🦸‍♂️

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**The friendly command-line tool for managing your files in the cloud.**

S3Hero helps you easily upload, download, and manage files on **AWS S3**, **Cloudflare R2**, **MinIO**, and other similar services without needing to be a cloud expert.

---

## 📦 Installation

Choose the method that works best for your system.

### Mac & Linux (Recommended)
Copy and paste this into your terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/kamaravichow/s3hero/main/scripts/install.sh | bash
```

### Windows
Open PowerShell as Administrator and run:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/kamaravichow/s3hero/main/scripts/install.ps1 | iex
```

### Using Python (pip)
If you already have Python installed:
```bash
pip install s3hero
```

---

## 🚀 Getting Started

Follow these 3 simple steps to start using S3Hero.

### 1. Connect your Cloud Account
Before you can manage files, tell S3Hero about your cloud provider.
Run:
```bash
s3hero configure add
```
You will be asked a few questions:
- **Profile Name**: A nickname for this account (e.g., `my-website`, `personal-backup`).
- **Provider**: Choose AWS, Cloudflare, etc.
- **Keys**: Paste your Access Key and Secret Key when prompted.

### 2. Check Connection
List your buckets to make sure everything is working:
```bash
s3hero bucket list
```

### 3. Create a Bucket (Optional)
If you don't have a bucket yet, create one:
```bash
s3hero bucket create my-first-bucket
```

---

## 💡 Common Tasks

Here are the most common things you'll want to do.

### 📤 Uploading Files
**Upload a single file:**
```bash
s3hero cp my-photo.jpg s3://my-bucket/my-photo.jpg
```

**Upload an entire folder:**
```bash
# This uploads everything inside 'photos' to the bucket
s3hero cp -r ./photos/ s3://my-bucket/vacation-pics/
```

### 📥 Downloading Files
**Download a file:**
```bash
s3hero cp s3://my-bucket/report.pdf ./downloads/report.pdf
```

**Download a folder:**
```bash
s3hero cp -r s3://my-bucket/backup-data/ ./restore-folder/
```

### 🔎 Exploring Files
**List files in a bucket:**
```bash
s3hero ls s3://my-bucket
```

**See a tree view of your folders (Great for overviews!):**
```bash
s3hero ls s3://my-bucket --tree
```

### 🔄 Backing Up & Syncing
Use `sync` to make the destination look exactly like the source. This is great for backups.

**Backup local folder to cloud:**
```bash
s3hero sync ./important-docs/ s3://my-bucket/backup-docs/
```

**Restore cloud backup to local computer:**
```bash
s3hero sync s3://my-bucket/backup-docs/ ./restored-docs/
```

### 🔗 Sharing Files
Generate a temporary link to share a private file with someone (valid for 1 hour by default):
```bash
s3hero presign s3://my-bucket/secret-plan.pdf
```

### 🗑️ Cleaning Up
**Delete a file:**
```bash
s3hero rm s3://my-bucket/old-file.txt
```

**Delete a folder and everything inside it:**
```bash
s3hero rm -r s3://my-bucket/trash-folder/
```

**Empty a bucket completely:**
```bash
s3hero bucket empty my-bucket
```

---

## ☁️ Provider Setup Examples

Here is exactly what you need for common providers.

### AWS S3
You need an **Access Key ID** and **Secret Access Key**.
```bash
s3hero configure add
# Choose '1. AWS S3'
# Enter your keys
# Region: e.g., us-east-1
```

### Cloudflare R2
You need an **Access Key**, **Secret Key**, and **Account ID**.
```bash
s3hero configure add --provider cloudflare_r2
# It will ask for your keys and Account ID found in R2 dashboard
```

### MinIO / Custom
You need your keys and the **Endpoint URL**.
```bash
s3hero configure add
# Choose '3. Other S3-Compatible'
# Enter keys
# Endpoint: https://minio.example.com
```

---

## 🔧 Pro Tips

### Switching Profiles
If you have multiple accounts (e.g., `work` and `personal`), you can switch between them easily.

**Run a single command as a different user:**
```bash
s3hero -p work bucket list
```

**Set a default profile:**
```bash
s3hero configure default work
```

### Viewing Configuration
See where S3Hero is saving your settings:
```bash
s3hero configure list
```

---

## 📄 License

This project is licensed under the MIT License.

<p align="center">
  Made with ❤️ by the S3Hero Team
</p>
