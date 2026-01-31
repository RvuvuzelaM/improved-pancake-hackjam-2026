# Aktualizuj dokumentację projektu

Zaktualizuj dokumentację na podstawie aktualnego stanu projektu i ostatnich commitów.

## Pliki dokumentacji

- `docs/00_godot_project_overview_for_ai.md` - Ogólny przegląd projektu
- `docs/01_physics_and_mechanics.md` - Fizyka i mechanika ruchu gracza
- `docs/02_game_objects_catalog.md` - Katalog obiektów gry

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

#### 3a. Plik `docs/00_godot_project_overview_for_ai.md`:
- **Struktura repo** - aktualna struktura katalogów
- **Główne sceny** - tabela z nazwą, typem, opisem + drzewa node'ów
- **Autoload** - czy są zdefiniowane w project.godot
- **Input** - akcje z Input Map i ich obsługa w kodzie
- **Kamera** - model (follow/scroll) i lokalizacja
- **Definition of Done** - zaktualizuj checkboxy
- **Historia zmian** - tabela z ostatnimi commitami

#### 3b. Plik `docs/01_physics_and_mechanics.md`:
- **Parametry ruchu** - stałe z player.gd (SPEED, JUMP_VELOCITY, DASH_*, itp.)
- **System masek** - enum Mask i ich efekty
- **Obliczenia fizyczne** - zasięgi skoków, wysokości, dash
- **Wartości dla generatora** - MIN/MAX_GAP, MAX_JUMP_HEIGHT

#### 3c. Plik `docs/02_game_objects_catalog.md`:
- **Platformy** - wszystkie typy platform z rozmiarami i plikami
- **Dekoracje** - drzewa, tła, elementy wizualne
- **Obiekty interaktywne** - triggery, przeszkody
- **Zagrożenia** - co zabija gracza
- **Warstwy kolizji** - mapa collision_layer/mask
- **Szybka referencja** - kod preload dla generatora

### 4. Zachowaj sekcje "Do implementacji"
Nie usuwaj sekcji oznaczonych jako "Do implementacji" - zaktualizuj je jeśli zostały zaimplementowane.

## Format wyjściowy
Po aktualizacji pokaż użytkownikowi:
- Co zostało zmienione w każdym pliku
- Które sekcje zostały uzupełnione
- Co pozostaje do zrobienia (Definition of Done)
