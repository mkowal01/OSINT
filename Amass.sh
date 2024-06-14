#!/bin/bash

# Sprawdzenie uprawnień administratora
if [ "$EUID" -ne 0 ]; then 
  echo "Proszę uruchomić skrypt z uprawnieniami administratora."
  echo "Np. używając: sudo $0"
  exit 1
fi

# Ścieżka do pliku raportu
REPORT_FILE="amass_report.txt"

# Czyszczenie starego raportu
> $REPORT_FILE

# Funkcja do zapisywania informacji do raportu
function write_report {
    echo "$1" >> $REPORT_FILE
}

# Sprawdzenie, czy Amass jest zainstalowany
if ! command -v amass &> /dev/null; then
    write_report "Amass nie jest zainstalowany. Instalacja Amass..."
    echo "Amass nie jest zainstalowany. Instalacja Amass..."
    
    # Instalacja Amass
    sudo apt update
    sudo apt install -y amass

    if [ $? -ne 0 ]; then
        write_report "Błąd podczas instalacji Amass. Proszę sprawdzić logi."
        echo "Błąd podczas instalacji Amass. Proszę sprawdzić logi."
        exit 1
    fi

    write_report "Amass został zainstalowany."
    echo "Amass został zainstalowany."
else
    write_report "Amass jest już zainstalowany."
    echo "Amass jest już zainstalowany."
fi

# Odczytanie nazwy organizacji z argumentu wiersza poleceń
if [ -z "$1" ]; then
    write_report "Nie podano nazwy organizacji."
    echo "Nie podano nazwy organizacji."
    exit 1
fi

organization="$1"
write_report "Podana nazwa organizacji: $organization"
echo "Przeprowadzanie OSINT na organizacji: $organization"

# Wykonanie zapytania do Amass
write_report "Wyniki Amass dla organizacji $organization:"
amass enum -d "$organization" >> $REPORT_FILE

if [ $? -ne 0 ]; then
    write_report "Błąd podczas wykonywania zapytania do Amass."
    echo "Błąd podczas wykonywania zapytania do Amass."
    exit 1
fi

# Generowanie raportu końcowego
write_report "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."
write_report "Data uruchomienia skryptu: $(date)"
echo "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."

echo "Raport został zapisany w pliku: $REPORT_FILE"
