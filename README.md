# 🧰 Automated Backup System

### 📘 Project Overview

This project is a **Bash scripting automation tool** that creates backups of important files and folders.  
It compresses the data, generates a checksum for file integrity, skips unnecessary files, and automatically removes old backups.

It acts like a **smart "copy and paste" system** — one that:
- Remembers what it copied,
- Verifies the copy is valid,
- Saves space by cleaning old backups.

---

## 🧱 Project Structure

backup-system/
├── backup.sh ← Main backup script
├── backup.config ← Configuration file
└── README.md ← Documentation file

yaml
Copy code

---

## ⚙️ Features

✅ **Takes a folder as input**  
The user specifies which folder to back up:
```bash
./backup.sh /home/user/my_documents
✅ Creates a compressed backup file
All files are compressed into a single .tar.gz file with a timestamp:

Copy code
backup-2025-11-04-1430.tar.gz
✅ Generates a checksum
An MD5 checksum file is created to verify the integrity of the backup:

Copy code
backup-2025-11-04-1430.tar.gz.md5
✅ Skips unnecessary files
Automatically excludes unwanted directories like:

.git

node_modules

.cache

✅ Automatically deletes old backups
Backups older than a certain number of days (default: 7) are automatically removed.

✅ Customizable configuration
All settings can be modified in the backup.config file.

⚙️ Configuration File: backup.config
The configuration file lets you customize how the script behaves.

bash
Copy code
# ====================================
# Backup System Configuration
# ====================================

# Where backups are stored
BACKUP_DIR="$HOME/backups"

# Files/folders to exclude from backup
EXCLUDES=(
  ".git"
  "node_modules"
  ".cache"
)

# How many days to keep old backups
RETENTION_DAYS=7
You can change these values as needed.
For example, increase RETENTION_DAYS to 30 to keep backups for a month.

🧩 How to Run
1️⃣ Open the terminal in VS Code
Press:

nginx
Copy code
Ctrl + `
or go to:

sql
Copy code
View → Terminal
2️⃣ Make the script executable
bash
Copy code
chmod +x backup.sh
3️⃣ Run the script with a folder path
bash
Copy code
./backup.sh /c/Users/Anil/Desktop/test_backup_folder
4️⃣ Example Output
bash
Copy code
🔄 Starting backup of: /c/Users/Anil/Desktop/test_backup_folder
📦 Backup file will be: /c/Users/Anil/backups/backup-2025-11-04-1045.tar.gz
✅ Backup completed successfully.
🔐 Checksum file created: /c/Users/Anil/backups/backup-2025-11-04-1045.tar.gz.md5
🕒 Finished at Tue Nov 4 10:45:18 IST 2025
🧪 Example Workflow
User runs:

bash
Copy code
./backup.sh /c/Users/Anil/OneDrive/Documents
Script compresses files → backup-YYYY-MM-DD-HHMM.tar.gz

Creates checksum → backup-YYYY-MM-DD-HHMM.tar.gz.md5

Deletes old backups after 7 days

Logs all activity to the terminal

🧠 How It Works Internally
Loads configuration from backup.config

Validates input folder

Builds an exclusion list dynamically from the config

Creates a compressed .tar.gz archive

Generates an MD5 checksum

Cleans up backups older than the retention period

Displays progress and success messages

⚡ Example Use Cases
Regularly backing up project files

Keeping snapshots of configurations or scripts

Automating daily backups via cron (Linux) or Task Scheduler (Windows)

Example cron entry (for daily backup at midnight):

bash
Copy code
0 0 * * * /path/to/backup-system/backup.sh /home/user/Documents
🧹 Maintenance and Logs
Default backup location: ~/backups

Old backups automatically deleted after 7 days

If needed, you can add logging to a file like:

bash
Copy code
./backup.sh /path/to/folder >> backup.log 2>&1
🧾 Future Enhancements
Add email notifications for successful or failed backups

Support multiple backup targets (e.g., USB, cloud)

Add progress bar for large archives

Encrypt backup files for extra security

👨‍💻 Author
Anil Kumar
Bash Scripting Project — Automated Backup System
Created for learning and automation practice.