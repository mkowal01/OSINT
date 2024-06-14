#!/bin/bash

# Sprawdzenie uprawnień administratora
if [ "$EUID" -ne 0 ]; then 
  echo "Proszę uruchomić skrypt z uprawnieniami administratora."
  echo "Np. używając: sudo $0"
  exit 1
fi

# Ścieżka do pliku raportu
REPORT_FILE="maltego_report.txt"

# Czyszczenie starego raportu
> "$REPORT_FILE"

# Funkcja do zapisywania informacji do raportu
function write_report {
    echo "$1" >> "$REPORT_FILE"
}

# Instalacja Maltego, jeśli nie jest zainstalowany
if ! command -v maltego &> /dev/null; then
    write_report "Maltego nie jest zainstalowany. Instalacja Maltego..."
    echo "Maltego nie jest zainstalowany. Instalacja Maltego..."

    # Aktualizacja listy pakietów
    sudo apt update

    # Instalacja Maltego
    sudo apt install maltego -y

    if [ $? -eq 0 ]; then
        write_report "Maltego został pomyślnie zainstalowany."
        echo "Maltego został pomyślnie zainstalowany."
    else
        write_report "Błąd podczas instalacji Maltego. Sprawdź logi."
        echo "Błąd podczas instalacji Maltego. Sprawdź logi."
        exit 1
    fi
else
    write_report "Maltego jest już zainstalowany."
    echo "Maltego jest już zainstalowany."
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

# Pobranie informacji o domenie za pomocą whois
write_report "Informacje o domenie $organization:"
whois "$organization" >> "$REPORT_FILE"

# Generowanie raportu końcowego
write_report "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."
write_report "Data uruchomienia skryptu: $(date)"
echo "Skrypt zakończony. Zakończono analizę OSINT na organizacji: $organization."

echo "Raport został zapisany w pliku: $REPORT_FILE"
