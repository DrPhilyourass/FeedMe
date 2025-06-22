FeedMe - USB Wiper for Linux

FeedMe is a lightweight, beginner-friendly USB wipe and format utility for Linux. It detects inserted USB drives, prompts for confirmation, securely wipes the drive using your selected method, then reformats it to FAT32.

Features

🧠 Automatic Detection of newly mounted USB drives

🔐 Secure Wipe Options:

Quick format

Zero-fill

Random-fill

DoD 3-pass (shred)

💬 Zenity GUI Prompts for ease of use

🔁 Runs at Login in the background

🖥️ No terminal required (but terminal output is shown for wipe progress)

🧼 Removes all data from selected USBs

How to Install

Method 1: One-Line Script Install

(Recommended for easy installation on most systems)

wget https://raw.githubusercontent.com/DrPhilyourass/FeedMe/main/install_feedme_1_3.sh
chmod +x install_feedme_1_3.sh
./install_feedme_1_3.sh

Method 2: Manual Installation from Source

Clone the repo and run the script:

git clone https://github.com/DrPhilyourass/FeedMe.git
cd FeedMe
chmod +x install_feedme_1_3.sh
./install_feedme_1_3.sh

How to Use

Plug in a USB drive

FeedMe will detect the drive and pop up a prompt

Choose your wipe method

Watch the terminal for real-time progress

Drive is wiped and reformatted automatically

Uninstall

sudo rm /usr/local/bin/feedme
rm ~/.config/systemd/user/feedme.service
rm ~/.config/autostart/feedme.desktop
systemctl --user daemon-reexec

Tested On

Ubuntu 22.04 / 24.04

GNOME desktop (Wayland and X11)

Disclaimer

This tool is destructive. Make absolutely sure you are wiping the correct device. The author is not responsible for any data loss or damage.

License

MIT

Author

Made by DrPhilyourass as a learning project. Contributions welcome!

