#!/bin/bash

first_file="$1"
shift

# Wyświetlenie pomocy
if [ "$first_file" = "-h" ] || [ "$first_file" = "--help" ]; then
  echo "Use: <save_to_merge> <save1> <save2> ..."
  echo "save_to_merge is the save to which all other save files will add their data"
  exit 1
fi

# Sprawdzenie liczby argumentów
if [[ $# -lt 1 ]]; then
  echo "You have to specify at least two files"
  exit 1
fi

# Tymczasowy katalog
tmpdir=$(mktemp -d)

# Funkcja czyszcząca katalog tymczasowy
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

# Rozpakowanie pierwszego pliku (głównego)
unzip "$first_file" -d "$tmpdir/original"

# Iteracja po pozostałych plikach
for file in "$@"; do
  echo "Current file: $file"
  rm -rf "$tmpdir/new"
  unzip "$file" -d "$tmpdir/new"
  # Upewnienie się, że katalog schematics istnieje
  if [ -d "$tmpdir/new/schematics" ]; then
    mv -n "$tmpdir/new/schematics/"* "$tmpdir/original/schematics/"
  fi
done

# Utworzenie archiwum wynikowego
(cd "$tmpdir/original" && zip -r9 "$OLDPWD/output.zip" .)
