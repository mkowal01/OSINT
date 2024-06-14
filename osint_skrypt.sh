#!/bin/bash

# Sprawdzanie czy argument został podany
if [ -z "$1" ]; then
  echo "Usage: $0 target_domain"
  exit 1
fi

TARGET=$1
OUTPUT_DIR="output_$TARGET"
mkdir -p $OUTPUT_DIR

# Ładowanie kluczy API z pliku .env
if [ -f "./api_keys.env" ]; then
  export $(cat ./api_keys.env | xargs)
else
  echo "API keys file not found!"
  exit 1
fi

# theHarvester - zbieranie adresów e-mail i subdomen
echo "[*] Running theHarvester..."
theHarvester -d $TARGET -l 500 -b all -f $OUTPUT_DIR/theHarvester_$TARGET

# Nmap - skanowanie portów
echo "[*] Running Nmap scan..."
nmap -sV -oN $OUTPUT_DIR/nmap_$TARGET.txt $TARGET

# Recon-ng - framework do zbierania różnych informacji
echo "[*] Running Recon-ng..."
echo "workspaces create $TARGET" > $OUTPUT_DIR/recon_script.rc
echo "set SOURCE $TARGET" >> $OUTPUT_DIR/recon_script.rc
echo "keys add bufferoverun $BUFFEROVERUN_API_KEY" >> $OUTPUT_DIR/recon_script.rc
echo "keys add censys_id $CENSYS_ID" >> $OUTPUT_DIR/recon_script.rc
echo "keys add censys_secret $CENSYS_SECRET" >> $OUTPUT_DIR/recon_script.rc
echo "keys add criminalip $CRIMINALIP_API_KEY" >> $OUTPUT_DIR/recon_script.rc
echo "keys add fullhunt $FULLHUNT_API_KEY" >> $OUTPUT_DIR/recon_script.rc
echo "keys add github $GITHUB_API_KEY" >> $OUTPUT_DIR/recon_script.rc
echo "keys add hunter $HUNTER_API_KEY" >> $OUTPUT_DIR/recon_script.rc
echo "keys add hunterhow $HUNTERHOW_API_KEY" >> $OUTPUT_DIR/recon_script.rc
echo "modules load recon/domains-hosts/brute_hosts" >> $OUTPUT_DIR/recon_script.rc
echo "run" >> $OUTPUT_DIR/recon_script.rc
echo "modules load recon/domains-contacts/whois_pocs" >> $OUTPUT_DIR/recon_script.rc
echo "run" >> $OUTPUT_DIR/recon_script.rc
echo "modules load recon/netblocks-companies/whois_netblocks" >> $OUTPUT_DIR/recon_script.rc
echo "run" >> $OUTPUT_DIR/recon_script.rc
echo "modules load reporting/csv" >> $OUTPUT_DIR/recon_script.rc
echo "set FILENAME $OUTPUT_DIR/recon-ng_$TARGET.csv" >> $OUTPUT_DIR/recon_script.rc
echo "run" >> $OUTPUT_DIR/recon_script.rc
echo "exit" >> $OUTPUT_DIR/recon_script.rc
recon-ng -r $OUTPUT_DIR/recon_script.rc

# whois - zbieranie danych WHOIS
echo "[*] Running whois..."
whois $TARGET > $OUTPUT_DIR/whois_$TARGET.txt

# DNSRecon - rekonesans DNS
echo "[*] Running DNSRecon..."
dnsrecon -d $TARGET -a > $OUTPUT_DIR/dnsrecon_$TARGET.txt

# Sublist3r - enumeracja subdomen
echo "[*] Running Sublist3r..."
sublist3r -d $TARGET -o $OUTPUT_DIR/sublist3r_$TARGET.txt

# Maltego - analiza danych (przykładowo dodajemy ręcznie, ponieważ Maltego jest narzędziem GUI)
echo "[*] Maltego analysis should be performed manually using the gathered data."

# Metasploit - przykładowe wykorzystanie
echo "[*] Running Metasploit auxiliary modules..."
echo "use auxiliary/scanner/http/title" > $OUTPUT_DIR/metasploit_script.rc
echo "set RHOSTS $TARGET" >> $OUTPUT_DIR/metasploit_script.rc
echo "run" >> $OUTPUT_DIR/metasploit_script.rc
echo "exit" >> $OUTPUT_DIR/metasploit_script.rc
msfconsole -r $OUTPUT_DIR/metasploit_script.rc -o $OUTPUT_DIR/metasploit_$TARGET.txt

echo "[*] OSINT scan completed. Results saved in $OUTPUT_DIR."
