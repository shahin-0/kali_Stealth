#!/bin/bash

# Kali Stealth Setup Script
# By ChatGPT and Shahin 🔥

echo "[*] Updating system..."
sudo apt update && sudo apt upgrade -y

echo "[*] Installing essential privacy tools..."
sudo apt install -y ufw tor torsocks proxychains4 macchanger torbrowser-launcher openvpn

# ================================
# Firewall Setup
# ================================
echo "[*] Configuring UFW Firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# ================================
# Proxychains Setup
# ================================
echo "[*] Configuring Proxychains to use Tor..."
sudo sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
sudo sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains4.conf
sudo sed -i 's/socks4 127.0.0.1 9050/#socks4 127.0.0.1 9050/' /etc/proxychains4.conf
echo "socks5 127.0.0.1 9050" | sudo tee -a /etc/proxychains4.conf

# ================================
# MAC Address Randomization
# ================================
echo "[*] Setting up MAC address randomization..."
interface=$(ip route | grep default | awk '{print $5}')
sudo macchanger -r $interface

# Create a systemd service to randomize MAC on every boot
echo "[*] Creating MAC randomization service..."
sudo bash -c "cat > /etc/systemd/system/macspoof.service" <<EOL
[Unit]
Description=Randomize MAC address at boot
After=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/bin/macchanger -r $interface

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable macspoof

# ================================
# Bash Aliases for Privacy
# ================================
echo "[*] Adding privacy aliases to .bashrc..."
cat <<EOL >> ~/.bashrc

# Stealth Aliases
alias rm='shred -u'
alias cp='cp -p'
alias mv='mv -p'
alias cls='clear && echo "Cleared"'
alias ipcheck='proxychains curl ifconfig.me'
alias torstart='sudo systemctl start tor'
alias torstop='sudo systemctl stop tor'
EOL

# ================================
# Log Cleaner Script
# ================================
echo "[*] Creating quick log cleaner script..."
cat <<EOL > ~/clean_logs.sh
#!/bin/bash
echo "Clearing system logs..."
sudo truncate -s 0 /var/log/syslog
sudo truncate -s 0 /var/log/auth.log
sudo truncate -s 0 /var/log/kern.log
sudo truncate -s 0 /var/log/dmesg
sudo dmesg --clear
echo "Logs cleaned."
EOL

chmod +x ~/clean_logs.sh

# ================================
# Tor Browser Setup
# ================================
echo "[*] Setting up Tor Browser..."
torbrowser-launcher

echo "[*] All Done! Please reboot your system for full effects."

echo "
🔥 Now:
- Use 'ipcheck' to check IP under Proxychains
- Run '~/clean_logs.sh' often to wipe logs
- Start Tor with 'torstart', stop with 'torstop'
- Your MAC address will change every reboot
"
