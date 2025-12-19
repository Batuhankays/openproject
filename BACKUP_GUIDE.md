# İSBİR Template Backup & Restore Guide

## 📦 Backup Locations

### Remote Server (10.2.3.15)
- **Path:** `/home/webadm/backups/`
- **Files:** `isbir-template-YYYYMMDD_HHMMSS.sql.gz`
- **Retention:** Last 5 backups kept automatically

### Local (This Machine)
- **Path:** `./backups/`
- **Latest:** `isbir-template-20251219_064152.sql.gz` (405 bytes)

---

## 🔄 Creating a Backup

### On Remote Server:
```bash
ssh -t webadm@10.2.3.15 "sudo ~/backup-remote.sh"
```
Password: `123qwe`

### Download to Local:
```powershell
scp webadm@10.2.3.15:/home/webadm/backups/isbir-template-*.sql.gz ./backups/
```

---

## ♻️ Restoring from Backup

### On Remote Server:
```bash
# Upload backup if needed
scp ./backups/isbir-template-YYYYMMDD.sql.gz webadm@10.2.3.15:/home/webadm/backups/

# Restore
ssh -t webadm@10.2.3.15
cd /home/webadm
sudo ./restore-from-backup.sh /home/webadm/backups/isbir-template-YYYYMMDD.sql.gz
```

**⚠️ Warning:** This will **REPLACE** the current database!

---

## 📋 What's Backed Up

The backup includes the complete İSBİR template:
- ✅ **Project:** SABLON: Proje Yonetimi
- ✅ **34 Work Packages** organized in 6 phases:
  - Faz 1: Musteri Talebi ve Degerlendirme (4 tasks)
  - Faz 2: Proje Degerlendirme (3 tasks)
  - Faz 3: Proje Planlama (7 tasks)
  - Faz 4: Proje Yurutme (4 tasks)
  - Faz 5: Izleme ve Kontrol (5 tasks)
  - Faz 6: Proje Kapanis (5 tasks)

---

## 🔧 Automated Backups

### Set up cron job on remote server:
```bash
ssh webadm@10.2.3.15
sudo crontab -e

# Add this line for daily backups at 2 AM:
0 2 * * * /home/webadm/backup-remote.sh
```

---

## 📝 Backup File Information

**Compressed:** ~400 bytes
**Uncompressed:** ~2-3 KB
**Format:** PostgreSQL SQL dump (gzipped)
**Database:** openproject
**Contains:** Full schema + all data

---

## 🚀 Quick Recovery Steps

If you lose data again:

1. **Stop OpenProject:**
   ```bash
   ssh -t webadm@10.2.3.15
   cd /home/webadm/openproject
   sudo docker compose -f docker-compose.enterprise.yml stop
   ```

2. **Restore backup:**
   ```bash
   sudo ~/restore-from-backup.sh /home/webadm/backups/isbir-template-LATEST.sql.gz
   ```

3. **Verify:**
   Open http://10.2.3.15:8200/projects/sablon-proje-yonetimi

---

## 📞 Support

**Remote Server:** http://10.2.3.15:8200
**Login:** admin / Admin12345*
**Project URL:** http://10.2.3.15:8200/projects/sablon-proje-yonetimi
