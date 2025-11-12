# Canon LBP2900 Driver Installation on Fedora Linux

**Successfully tested on Fedora 43 (2024-2025)**

This guide provides step-by-step instructions to install and configure a Canon LBP2900 printer (from 2005) on modern Fedora Linux systems using a reverse-engineered open-source driver.

## ✅ What This Guide Achieves

- Install a modern, open-source driver for Canon LBP2900
- No proprietary Canon CAPT daemon required
- Direct integration with CUPS
- Compatible with modern Linux kernels
- Clean installation without obsolete dependencies

## 🖨️ Supported Printers

- Canon LBP2900
- Canon LBP2900B
- Other Canon CAPT-based printers (may work with modifications)

## 📋 Prerequisites

- Fedora Linux (tested on 43, should work on recent versions)
- Canon LBP2900 printer connected via USB
- Internet connection for downloading source code
- Administrator (sudo) privileges

## 🔧 Installation Steps

### 1. Install Build Dependencies

```bash
sudo dnf install -y autoconf automake libtool gcc make cups-devel git
```

### 2. Stop System CUPS Service (Temporarily)

```bash
sudo systemctl stop cups
```

### 3. Download and Build the Driver

```bash
# Clone the reverse-engineered driver
git clone https://github.com/itapplication/Canon-LBP2900B.git
cd Canon-LBP2900B

# Generate build configuration
aclocal
autoconf
automake --add-missing

# Configure, compile and install
./configure
make
sudo make install
```

### 4. Install Driver in CUPS

```bash
# Copy the filter to CUPS directory
sudo cp /usr/local/bin/rastertocapt /usr/lib/cups/filter/

# Copy the PPD file
sudo cp Canon-LBP-2900.ppd /usr/share/cups/model/
```

### 5. Restart CUPS and Configure Printer

```bash
# Restart CUPS service
sudo systemctl start cups

# Detect the printer
lpinfo -v | grep Canon

# Add the printer (replace with your actual USB device string)
sudo lpadmin -p LBP2900 -E -v "usb://Canon/LBP2900?serial=YOUR_SERIAL" -P Canon-LBP-2900.ppd
```

### 6. Test the Printer

```bash
# Check printer status
lpstat -p LBP2900

# Send a test print
echo "Hello from Canon LBP2900!" | lp -d LBP2900
```

## 🧹 Cleanup Old Drivers (If Previously Installed)

If you had old Canon CAPT drivers installed:

```bash
# Remove old RPM packages
sudo rpm -e cndrvcups-capt cndrvcups-common 2>/dev/null || true

# Stop CAPT daemon
sudo /etc/init.d/ccpd stop 2>/dev/null || true
```

## 🔍 Troubleshooting

### Printer Not Detected
- Ensure the printer is powered on and connected via USB
- Check USB connection: `lsusb | grep Canon`
- Verify CUPS is running: `systemctl status cups`

### Permission Issues
- Add your user to the `lp` group: `sudo usermod -a -G lp $USER`
- Log out and back in for group changes to take effect

### Print Jobs Stuck
- Check CUPS error log: `journalctl -u cups -f`
- Restart CUPS: `sudo systemctl restart cups`

## 📁 Project Structure

After installation, you'll have:
- `/usr/lib/cups/filter/rastertocapt` - The printer filter
- `/usr/share/cups/model/Canon-LBP-2900.ppd` - Printer description
- `~/Canon-LBP2900B/` - Source code (can be removed after installation)

## 🙏 Credits

- Original reverse-engineered driver: [itapplication/Canon-LBP2900B](https://github.com/itapplication/Canon-LBP2900B)
- Tested and documented installation process for Fedora Linux

## 📄 License

This guide is provided under MIT License. The Canon LBP2900B driver maintains its original license from the upstream repository.

## 🤝 Contributing

If you test this on other Fedora versions or Canon printer models, please share your results by opening an issue or pull request.

---

**Note**: This is an unofficial driver created through reverse engineering. Use at your own risk. The original Canon proprietary drivers may still be required for some advanced features.