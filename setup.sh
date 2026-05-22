#!/bin/bash

# ==========================================
# 1. INITIALIZATION & ROOT CHECK
# ==========================================

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo."
  exit 1
fi

# ==========================================
# 2. CALAMARES & LIVE SESSION CONFIGURATION
# ==========================================

echo "Creating Polkit rule for Calamares..."
# Create the polkit rules directory if it doesn't exist
mkdir -p /etc/polkit-1/rules.d

# Write the JavaScript rule for passwordless execution
cat <<EOF >/etc/polkit-1/rules.d/99-calamares.rules
polkit.addRule(function(action, subject) {
    if (action.id == "com.github.calamares.calamares.pkexec.run") {
        return polkit.Result.YES;
    }
});
EOF

echo "Creating live user installer check script..."
# Write the helper script to ensure it only runs for the 'live' user
cat <<EOF >/usr/local/bin/live-installer-check.sh
#!/bin/bash
if [ "\$(whoami)" = "live" ]; then
    sudo calamares
fi
EOF

# Make the check script executable
chmod +x /usr/local/bin/live-installer-check.sh

echo "Modifying the Desktop Entry for the installer..."
DESKTOP_FILE="/usr/share/applications/install-system.desktop"

if [ -f "$DESKTOP_FILE" ]; then
  # Update Exec path and set Terminal to true
  sed -i 's|^Exec=.*|Exec=/usr/local/bin/live-installer-check.sh|' "$DESKTOP_FILE"
  sed -i 's|^Terminal=.*|Terminal=true|' "$DESKTOP_FILE"

  echo "Setting up Autostart for the live session..."
  # Copy the updated desktop file to the XDG autostart directory
  mkdir -p /etc/xdg/autostart
  cp "$DESKTOP_FILE" /etc/xdg/autostart/
else
  echo "Warning: $DESKTOP_FILE not found! Make sure Calamares is installed."
fi

# ==========================================
# 3. SNAP REMOVAL & FIREFOX INSTALLATION
# ==========================================

# Stop all running Snap services
echo "Stopping Snap services..."
systemctl disable snapd.service snapd.socket snapd.seeded.service || true
systemctl stop snapd.service snapd.socket snapd.seeded.service || true

# Remove all installed Snap packages dynamically
echo "Removing all installed Snap packages..."
if command -v snap &>/dev/null; then
  for snap in $(snap list | awk '{print $1}' | tail -n +2); do
    snap remove --purge "$snap" || true
  done
fi

# Purge snapd from the system and clean leftover directories
echo "Purging snapd and cleaning directories..."
apt purge snapd -y
apt autoremove --purge -y
rm -rf /var/cache/snapd/ ~/snap /snap /var/snap /var/lib/snapd

# Block Ubuntu from reinstalling Snap in the future
echo "Blocking future Snap installations..."
cat <<EOF >/etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -100
EOF

# Add official Mozilla PPA for the APT version of Firefox
echo "Adding official Mozilla PPA for Vanilla Firefox..."
add-apt-repository ppa:mozillateam/ppa -y

# Prioritize the Mozilla PPA over standard Ubuntu repositories
cat <<EOF >/etc/apt/preferences.d/mozilla-firefox
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF

# Update package list with new PPA and install Firefox
echo "Installing Vanilla Firefox via APT..."
apt update
apt install firefox -y

# ==========================================
# 4. MINIMAL VANILLA GNOME INSTALLATION
# ==========================================

echo "Removing Ubuntu bloatware and unnecessary apps..."
# Purge LibreOffice, default mail client, media players, and other unneeded apps
apt purge libreoffice* thunderbird rhythmbox totem shotwell remmina* transmission* gnome-initial-setup -y

echo "Removing Ubuntu specific themes and desktop packages..."
# Purge Ubuntu's custom themes, sessions, and wallpapers
apt purge ubuntu-session yaru-theme-* ubuntu-wallpapers* ubuntu-desktop ubuntu-desktop-minimal -y

echo "Installing core Vanilla GNOME packages..."
# Install only the essential GNOME components for a minimal setup
apt install gnome-core gnome-session gnome-tweaks -y

echo "Ensuring display manager and network tools are intact..."
# Reinstall and ensure network manager and essential display tools are present
apt install gdm3 network-manager network-manager-gnome --reinstall -y

echo "Ensuring live boot components are safe..."
# Ensure casper and live-boot files required for the ISO environment are present
apt install casper live-boot -y

echo "Cleaning up unneeded packages and dependencies..."
# Remove all unused dependencies and leftover configuration files
apt autoremove --purge -y

# ==========================================
# 5. ADDITIONAL PACKAGES & SYSTEM UPDATE
# ==========================================
echo "Updating package list..."
apt update -y

echo "Installing essential CLI tools..."
# Install Vim text editor safely here
apt install vim -y

# Clean up unneeded packages and dependencies after all installations
echo "Cleaning up unneeded packages and dependencies..."
apt autoremove --purge -y

# ===================
# 6. SYSTEM BRANDING
# ===================

# Configure os-release branding for Cashevide OS
echo "Configuring os-release branding for Cashevide OS..."
if [ -f /etc/os-release ]; then
  sed -i 's/^NAME=.*/NAME="Cashevide OS"/' /etc/os-release
  sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Cashevide OS 1.0"/' /etc/os-release
  sed -i 's|^HOME_URL=.*|HOME_URL="https://cashevide.com/"|' /etc/os-release
  sed -i 's/^VERSION=.*/VERSION="1.0.0 (Cash-e-wide Edition)"/' /etc/os-release
  echo "os-release successfully updated!"
else
  echo "Error: /etc/os-release file not found!"
fi

# ============================================
# 7. PURGE OLD WALLPAPERS & PROPERTIES CLEANUP
# ============================================
echo "Purging default Ubuntu and GNOME wallpapers cleanly..."

# Ensure our custom cashevide backgrounds directory exists
mkdir -p /usr/share/backgrounds/cashevide

# Delete everything inside backgrounds EXCEPT the 'cashevide' folder itself
# This keeps your pre-copied wallpapers inside cashevide/ perfectly safe!
find /usr/share/backgrounds/ -maxdepth 1 ! -path /usr/share/backgrounds/ ! -name "cashevide" -exec rm -rf {} +

# Remove old wallpaper XML properties to clean up the Settings menu
rm -rf /usr/share/gnome-background-properties/*

echo "Creating Cashevide OS wallpaper properties for Settings menu..."
mkdir -p /usr/share/gnome-background-properties

# Start writing the base XML structure
cat <<EOF >/usr/share/gnome-background-properties/cashevide-wallpapers.xml
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
EOF

# Bulletproof loop that handles both lower and uppercase extensions (.jpg, .JPG, .png, .PNG etc.)
for img in /usr/share/backgrounds/cashevide/*; do
  # Ensure it is a file
  [ -f "$img" ] || continue

  filename=$(basename "$img")
  clean_name="${filename%.*}"

  # Convert extension to lowercase safely for verification
  ext=$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')

  case "$ext" in
  jpg | jpeg | png | webp | svg)
    # Format names nicely for the Settings UI (e.g., cool-dark.png -> Cool Dark)
    display_name=$(echo "$clean_name" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

    # Append entries cleanly to XML
    cat <<EOF >>/usr/share/gnome-background-properties/cashevide-wallpapers.xml
  <wallpaper deleted="false">
    <name>Cashevide $display_name</name>
    <filename>$img</filename>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>#000000</pcolor>
    <scolor>#000000</scolor>
  </wallpaper>
EOF
    ;;
  esac
done

# Close the XML structure properly
echo "</wallpapers>" >>/usr/share/gnome-background-properties/cashevide-wallpapers.xml

echo "Forcing cashevide/background.jpg as the hardcoded system default..."
# Force your main image as the default wallpaper for both Light and Dark modes
cat <<EOF >/usr/share/glib-2.0/schemas/99_cashevide_wallpaper.gschema.override
[org.gnome.desktop.background]
picture-uri='file:///usr/share/backgrounds/cashevide/background.jpg'
picture-uri-dark='file:///usr/share/backgrounds/cashevide/background.jpg'
EOF

# Ensure proper system permissions so GNOME can read everything without fail
chmod 755 /usr/share/backgrounds/cashevide
chmod 644 /usr/share/backgrounds/cashevide/* 2>/dev/null || true
chmod 644 /usr/share/gnome-background-properties/cashevide-wallpapers.xml

# Compile the new schema override into the system
glib-compile-schemas /usr/share/glib-2.0/schemas/

echo "Wallpaper generation and system-wide default lock completed successfully!"

# ================================================
# 8. SYSTEM-WIDE DCONF CUSTOMIZATIONS (PRO METHOD)
# ================================================

echo "Compiling GNOME desktop customizations professionally via dconf update..."

# 1. Ensure the script is running with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script with sudo (e.g., sudo ./setup.sh)"
  exit 1
fi

# 2. Create dconf profile
mkdir -p /etc/dconf/profile
cat <<EOF >/etc/dconf/profile/user
user-db:user
system-db:local
EOF

# 3. Create keyfile directory
mkdir -p /etc/dconf/db/local.d

# 4. Dump settings SAFELY from the actual logged-in user (not root)
REAL_USER="${SUDO_USER:-noufal}"
echo "Extracting desktop environment from user: $REAL_USER"

if command -v dconf &>/dev/null; then
  # Run dconf as the real user, but save the output to root directory
  sudo -u "$REAL_USER" dconf dump / >/etc/dconf/db/local.d/00-cashevide
fi

# 5. Compile the text settings into system database cleanly
dconf update

echo "Dconf settings compiled successfully without binary files!"

echo "All tasks completed! Cashevide OS is now running a pure minimalist setup. 🚀"
