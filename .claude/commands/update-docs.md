# Aktualizuj dokumentację projektu

Zaktualizuj dokumentację na podstawie aktualnego stanu projektu i ostatnich commitów.

## Kroki

### 1. Zbierz informacje o projekcie
- Przeczytaj `project.godot` - konfiguracja (wersja Godot, rozdzielczość, main scene)
- Znajdź wszystkie sceny: `**/*.tscn`
- Znajdź wszystkie skrypty: `**/*.gd`
- Sprawdź strukturę folderów: `ls -la` w głównych katalogach
- Pobierz ostatnie commity: `git log --oneline -10`

### 2. Przeanalizuj kluczowe pliki
Dla każdej sceny i skryptu:
- Przeczytaj plik i zrozum jego strukturę
- Zidentyfikuj node tree, typy, zależności
- Wynotuj parametry (stałe, zmienne eksportowane)

### 3. Zaktualizuj dokumentację
Edytuj `docs/00_godot_project_overview_for_ai.md`:

- **Struktura repo** - aktualna struktura katalogów
- **Główne sceny** - tabela z nazwą, typem, opisem + drzewa node'ów
- **Autoload** - czy są zdefiniowane w project.godot
- **Input** - akcje z Input Map i ich obsługa w kodzie
- **Parametry ruchu** - stałe z player.gd
- **Kamera** - model (follow/scroll) i lokalizacja
- **Definition of Done** - zaktualizuj checkboxy
- **Historia zmian** - tabela z ostatnimi commitami

### 4. Zachowaj sekcje "Do implementacji"
Nie usuwaj sekcji oznaczonych jako "Do implementacji" - zaktualizuj je jeśli zostały zaimplementowane.

## Format wyjściowy
Po aktualizacji pokaż użytkownikowi:
- Co zostało zmienione
- Które sekcje zostały uzupełnione
- Co pozostaje do zrobienia (Definition of Done)
