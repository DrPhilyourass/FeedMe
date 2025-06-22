#!/bin/bash

echo "🚀 Installing FeedMe 1.3..."

# Remove old FeedMe install
echo "🔁 Removing old FeedMe..."
systemctl --user stop feedme.service 2>/dev/null
systemctl --user disable feedme.service 2>/dev/null
rm -f ~/.config/systemd/user/feedme.service
rm -f ~/.config/autostart/feedme.desktop
sudo rm -f /usr/local/bin/feedme

# Create wrapper script for pkexec
sudo tee /usr/local/bin/feedme-wrapper >/dev/null << 'EOF'
#!/bin/bash
DEVICE="$1"
WIPE_TYPE="$2"

case "$WIPE_TYPE" in
  "Zero-fill (overwrite with 0s)")
    dd if=/dev/zero of="$DEVICE" bs=4M status=progress
    ;;
  "Random-fill (overwrite with random data)")
    dd if=/dev/urandom of="$DEVICE" bs=4M status=progress
    ;;
  "DoD 3-pass wipe (shred)")
    shred -v -n 3 -z "$DEVICE"
    ;;
esac

# Partition and format
parted "$DEVICE" --script mklabel msdos
parted "$DEVICE" --script mkpart primary fat32 0% 100%
sleep 2
mkfs.vfat -F 32 "${DEVICE}1"
EOF

sudo chmod +x /usr/local/bin/feedme-wrapper

# Create the main FeedMe script
tee ~/.feedme >/dev/null << 'EOF'
#!/bin/bash

LAST_STATE=""

while true; do
  CURRENT_STATE=$(lsblk -dn -o NAME,TRAN | grep -E "sd[b-z]" | awk '{print $1}')

  if [[ "$CURRENT_STATE" != "$LAST_STATE" ]]; then
    if [[ -n "$CURRENT_STATE" ]]; then
      DEVICE="/dev/$(echo "$CURRENT_STATE" | head -n1)"

      CHOICE=$(zenity --list --title="FeedMe - USB Wipe Tool"         --column="Method"         "Quick Format (no secure wipe)"         "Zero-fill (overwrite with 0s)"         "Random-fill (overwrite with random data)"         "DoD 3-pass wipe (shred)"         --height=300 --width=400)

      [[ -z "$CHOICE" ]] && LAST_STATE="$CURRENT_STATE" && sleep 5 && continue

      if [[ "$CHOICE" == "Quick Format (no secure wipe)" ]]; then
        pkexec bash -c "parted $DEVICE --script mklabel msdos && parted $DEVICE --script mkpart primary fat32 0% 100% && sleep 2 && mkfs.vfat -F 32 ${DEVICE}1"
      else
        x-terminal-emulator -e pkexec /usr/local/bin/feedme-wrapper "$DEVICE" "$CHOICE"
      fi

      zenity --info --text="✅ $DEVICE wiped and formatted." --width=300
    fi
    LAST_STATE="$CURRENT_STATE"
  fi

  sleep 5
done
EOF

chmod +x ~/.feedme

# Set up systemd user service
mkdir -p ~/.config/systemd/user
tee ~/.config/systemd/user/feedme.service >/dev/null <<EOF
[Unit]
Description=FeedMe USB Wiper

[Service]
ExecStart=/bin/bash /home/$USER/.feedme
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable feedme.service
systemctl --user start feedme.service

echo "✅ FeedMe 1.3 installed and running."
echo "Please reboot and then insert a USB to begin testing."
