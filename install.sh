#!/bin/bash

# Canon LBP2900 Driver Installation Script for Fedora Linux
# Version: 1.0
# Tested on: Fedora 43

set -e

echo "========================================="
echo "Canon LBP2900 Driver Installation Script"
echo "========================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "Please do not run this script as root. It will ask for sudo when needed."
   exit 1
fi

# Check if printer is connected
echo "Checking for Canon LBP2900 printer..."
if ! lsusb | grep -q "Canon.*LBP2900"; then
    echo "WARNING: Canon LBP2900 not detected via USB."
    echo "Please ensure the printer is powered on and connected."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Install dependencies
echo "Installing build dependencies..."
sudo dnf install -y autoconf automake libtool gcc make cups-devel git

# Stop CUPS temporarily
echo "Stopping CUPS service temporarily..."
sudo systemctl stop cups

# Clone and build driver
echo "Downloading Canon LBP2900B driver source..."
if [ -d "Canon-LBP2900B" ]; then
    echo "Directory Canon-LBP2900B already exists. Removing..."
    rm -rf Canon-LBP2900B
fi

git clone https://github.com/itapplication/Canon-LBP2900B.git
cd Canon-LBP2900B

echo "Building driver..."
aclocal
autoconf
automake --add-missing
./configure
make
sudo make install

# Install in CUPS
echo "Installing driver in CUPS..."
sudo cp /usr/local/bin/rastertocapt /usr/lib/cups/filter/
sudo cp Canon-LBP-2900.ppd /usr/share/cups/model/

# Restart CUPS
echo "Starting CUPS service..."
sudo systemctl start cups

# Detect printer
echo "Detecting printer..."
sleep 2
PRINTER_URI=$(lpinfo -v | grep "Canon/LBP2900" | head -1 | awk '{print $2}')

if [ -z "$PRINTER_URI" ]; then
    echo "ERROR: Canon LBP2900 not detected by CUPS."
    echo "Please ensure the printer is connected and powered on."
    exit 1
fi

echo "Found printer: $PRINTER_URI"

# Remove existing printer configuration
sudo lpadmin -x LBP2900 2>/dev/null || true

# Add printer
echo "Adding printer to CUPS..."
sudo lpadmin -p LBP2900 -E -v "$PRINTER_URI" -P Canon-LBP-2900.ppd

# Test printer
echo "Testing printer..."
lpstat -p LBP2900

echo "========================================="
echo "Installation completed successfully!"
echo "========================================="
echo
echo "To test the printer, run:"
echo "  echo 'Test print' | lp -d LBP2900"
echo
echo "To check printer status:"
echo "  lpstat -p LBP2900"
echo
echo "CUPS web interface: http://localhost:631"
echo

cd ..

# Cleanup option
read -p "Remove source code directory Canon-LBP2900B? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd Canon-LBP2900B
    make distclean 2>/dev/null || true
    cd ..
    echo "Build files cleaned. Source code preserved in Canon-LBP2900B/"
fi

echo "Installation script finished."