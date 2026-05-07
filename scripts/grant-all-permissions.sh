#!/data/data/com.termux/files/usr/bin/bash
# Grant all Android permissions to Termux and initialize Termux:API
# Run from NATIVE Termux (not Ubuntu proot)
# Approve each Android dialog that appears

echo "=== Granting All Termux Permissions ==="

echo "[1] Wake lock..."
termux-wake-lock && echo "  OK Wake lock"

echo "[2] Storage (approve Android dialog)..."
termux-setup-storage

echo "[3] pkg update..."
pkg update -y && pkg upgrade -y && echo "  OK Packages updated"

echo "[4] Battery (Termux:API dialog)..."
termux-battery-status && echo "  OK Battery"

echo "[5] Camera..."
termux-camera-info && echo "  OK Camera"

echo "[6] Location..."
termux-location --provider network --request once && echo "  OK Location"

echo "[7] Microphone..."
termux-microphone-record -d 2>/dev/null; echo "  OK Microphone"

echo "[8] Contacts..."
termux-contacts-list -l 1 2>/dev/null; echo "  OK Contacts"

echo "[9] SMS..."
termux-sms-list -l 1 2>/dev/null; echo "  OK SMS"

echo "[10] Call log..."
termux-call-log -l 1 2>/dev/null; echo "  OK Call log"

echo "[11] Notifications..."
termux-notification --title "Termux Setup" --content "All permissions granted!" \
  && echo "  OK Notifications"

echo ""
echo "=== Done! Approve any remaining Android dialogs ==="
echo ""
echo "Next: disable battery optimization in Android Settings"
echo "  Settings -> Apps -> Termux -> Battery -> Unrestricted"
echo "  Settings -> Apps -> Termux:API -> Battery -> Unrestricted"
