#!/bin/bash

# Sprawdzenie uprawnień administratora
if [ "$EUID" -ne 0 ]; then 
  echo "Proszę uruchomić skrypt z uprawnieniami administratora."
  echo "Np. używając: sudo $0"
  exit 1
fi

# Ścieżka do pliku raportu
REPORT_FILE="censys_report.txt"

# Czyszczenie starego raportu
> $REPORT_FILE

# Funkcja do zapisywania informacji do raportu
function write_report {
    echo "$1" >> $REPORT_FILE
}

# Sprawdzenie, czy Censys jest zainstalowany
if ! command -v censys &> /dev/null; then
    write_report "Censys nie jest zainstalowany. Instalacja Censys..."
    echo "Censys nie jest zainstalowany. Instalacja Censys..."
    
    # Instalacja Censys
    sudo pip3 install censys
    
    if [ $? -ne 0 ]; then
        write_report "Błąd podczas instalacji Censys. Proszę sprawdzić logi."
        echo "Błąd podczas instalacji Censys. Proszę sprawdzić logi."
        exit 1
    fi

    write_report "Censys został zainstalowany."
    echo "Censys został zainstalowany."
else
    write_report "Censys jest już zainstalowany."
    echo "Censys jest już zainstalowany."
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

# Uruchomienie Censys
write_report "Wyniki Censys dla organizacji $organization:"
censys search --api-id 149cf914-4707-4fb1-adb0-0aabe3e7aabb --api-secret axAMWZAYWdFuSBgVzz1GTe0Yw0MIvZ1P --index-type hosts "$organization" >> $REPORT_FILE

if [ $? -ne 0 ]; then
    write_report "Błąd podczas wykonywania Censys."
    echo "Błąd podczas wykonywania Censys."
    exit 1
fi

# Generowanie raportu końcowego
write_report "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."
write_report "Data uruchomienia skryptu: $(date)"
echo "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."

echo "Raport został zapisany w pliku: $REPORT_FILE"
