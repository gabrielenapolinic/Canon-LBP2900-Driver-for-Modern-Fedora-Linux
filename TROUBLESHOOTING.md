# Canon LBP2900 Troubleshooting Guide

This document covers common issues and solutions when using the Canon LBP2900 driver on Fedora Linux.

## 🔧 Common Issues

### 1. Printer Not Detected

**Symptoms:**
- `lsusb` doesn't show Canon LBP2900
- `lpinfo -v` doesn't list the printer

**Solutions:**
```bash
# Check USB connection
lsusb | grep Canon

# Try different USB port
# Power cycle the printer (off/on)

# Check if printer is recognized by kernel
dmesg | grep -i usb | tail -10
```

### 2. Permission Denied Errors

**Symptoms:**
- Print jobs fail with permission errors
- Cannot access printer through applications

**Solutions:**
```bash
# Add user to lp group
sudo usermod -a -G lp $USER

# Log out and back in, then check
groups | grep lp

# Fix printer device permissions
sudo chmod 666 /dev/bus/usb/001/*
```

### 3. Print Jobs Stuck in Queue

**Symptoms:**
- Jobs appear in queue but don't print
- Printer status shows "processing" indefinitely

**Solutions:**
```bash
# Check print queue
lpstat -o

# Cancel all jobs
sudo cancel -a

# Restart CUPS
sudo systemctl restart cups

# Check CUPS error log
journalctl -u cups -f
```

### 4. Driver Not Found

**Symptoms:**
- `lpadmin` complains about missing PPD
- Filter not found errors

**Solutions:**
```bash
# Verify driver files exist
ls -la /usr/lib/cups/filter/rastertocapt
ls -la /usr/share/cups/model/Canon-LBP-2900.ppd

# If missing, reinstall
sudo cp /usr/local/bin/rastertocapt /usr/lib/cups/filter/
sudo cp Canon-LBP-2900.ppd /usr/share/cups/model/
```

### 5. Compilation Errors

**Symptoms:**
- `make` fails with errors
- Missing dependencies

**Solutions:**
```bash
# Install all development tools
sudo dnf groupinstall "Development Tools"
sudo dnf install cups-devel

# Clean and rebuild
make distclean
./configure
make
```

### 6. Old Canon Drivers Conflict

**Symptoms:**
- Multiple drivers installed
- CAPT daemon conflicts

**Solutions:**
```bash
# Remove old Canon packages
sudo rpm -e cndrvcups-capt cndrvcups-common

# Stop CAPT daemon
sudo systemctl stop ccpd
sudo systemctl disable ccpd

# Remove old PPD files
sudo find /usr/share/cups/model/ -name "*Canon*" -delete
sudo find /usr/share/cups/model/ -name "*LBP*" -delete
```

## 🔍 Diagnostic Commands

### Check Printer Status
```bash
# List all printers
lpstat -p

# Check specific printer
lpstat -p LBP2900

# View print queue
lpstat -o
```

### Check USB Connection
```bash
# List USB devices
lsusb

# Monitor USB events
sudo dmesg -w
# Then connect/disconnect printer
```

### Check CUPS Configuration
```bash
# List available drivers
lpinfo -m | grep -i canon

# List available devices
lpinfo -v

# Check CUPS status
systemctl status cups
```

### View Logs
```bash
# CUPS error log
sudo journalctl -u cups -f

# System messages
sudo dmesg | grep -i usb
sudo dmesg | grep -i printer
```

## 🛠️ Manual Driver Reinstallation

If you need to completely reinstall the driver:

```bash
# 1. Remove printer
sudo lpadmin -x LBP2900

# 2. Remove driver files
sudo rm -f /usr/lib/cups/filter/rastertocapt
sudo rm -f /usr/share/cups/model/Canon-LBP-2900.ppd

# 3. Restart CUPS
sudo systemctl restart cups

# 4. Rebuild and reinstall
cd Canon-LBP2900B
make distclean
./configure
make
sudo make install
sudo cp /usr/local/bin/rastertocapt /usr/lib/cups/filter/
sudo cp Canon-LBP-2900.ppd /usr/share/cups/model/

# 5. Add printer again
sudo systemctl restart cups
PRINTER_URI=$(lpinfo -v | grep "Canon/LBP2900" | head -1 | awk '{print $2}')
sudo lpadmin -p LBP2900 -E -v "$PRINTER_URI" -P Canon-LBP-2900.ppd
```

## 📞 Getting Help

### Information to Collect
When seeking help, please provide:

```bash
# System information
uname -a
cat /etc/fedora-release

# USB information
lsusb | grep Canon

# CUPS information
lpstat -p
lpinfo -v | grep Canon

# Recent logs
journalctl -u cups --since "1 hour ago"
```

### Useful Resources
- Original driver repository: https://github.com/itapplication/Canon-LBP2900B
- CUPS documentation: https://www.cups.org/doc/
- Fedora printing guide: https://docs.fedoraproject.org/

## 🔄 Complete Uninstallation

To completely remove the Canon LBP2900 driver:

```bash
# Remove printer
sudo lpadmin -x LBP2900

# Remove driver files
sudo rm -f /usr/lib/cups/filter/rastertocapt
sudo rm -f /usr/share/cups/model/Canon-LBP-2900.ppd
sudo rm -f /usr/local/bin/rastertocapt

# Remove source code
rm -rf ~/Canon-LBP2900B

# Restart CUPS
sudo systemctl restart cups
```