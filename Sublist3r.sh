#!/bin/bash

# Sprawdzenie uprawnień administratora
if [ "$EUID" -ne 0 ]; then 
  echo "Proszę uruchomić skrypt z uprawnieniami administratora."
  echo "Np. używając: sudo $0"
  exit 1
fi

# Ścieżka do pliku raportu
REPORT_FILE="sublist3r_report.txt"

# Czyszczenie starego raportu
> $REPORT_FILE

# Funkcja do zapisywania informacji do raportu
function write_report {
    echo "$1" >> $REPORT_FILE
}

# Sprawdzenie, czy Sublist3r jest zainstalowany
if ! command -v sublist3r &> /dev/null; then
    write_report "Sublist3r nie jest zainstalowany. Instalacja Sublist3r..."
    echo "Sublist3r nie jest zainstalowany. Instalacja Sublist3r..."
    
    # Instalacja Sublist3r
    sudo apt update
    sudo apt install -y sublist3r

    if [ $? -ne 0 ]; then
        write_report "Błąd podczas instalacji Sublist3r. Proszę sprawdzić logi."
        echo "Błąd podczas instalacji Sublist3r. Proszę sprawdzić logi."
        exit 1
    fi

    write_report "Sublist3r został zainstalowany."
    echo "Sublist3r został zainstalowany."
else
    write_report "Sublist3r jest już zainstalowany."
    echo "Sublist3r jest już zainstalowany."
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

# Wykonanie zapytania do Sublist3r
write_report "Wyniki wyszukiwania subdomen dla organizacji $organization:"
sublist3r -d "$organization" >> $REPORT_FILE

if [ $? -ne 0 ]; then
    write_report "Błąd podczas wykonywania zapytania do Sublist3r."
    echo "Błąd podczas wykonywania zapytania do Sublist3r."
    exit 1
fi

# Generowanie raportu końcowego
write_report "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."
write_report "Data uruchomienia skryptu: $(date)"
echo "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."

echo "Raport został zapisany w pliku: $REPORT_FILE"
