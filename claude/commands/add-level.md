# Dodaj nowy poziom

Stwórz nowy poziom gry na podstawie istniejącej struktury.

## Wymagania
- Numer poziomu: $ARGUMENTS (np. "1-2" lub "2-1")
- Lokalizacja: `scenes/levels/`

## Struktura poziomu (wzór z 1-1.tscn)
1. Root node: `Node2D` z nazwą poziomu
2. Instancja gracza (`player.tscn`) z:
   - z_index: 5
   - Pozycja startowa (spawn point)
   - Skala: Vector2(4.28, 4.28)
   - Camera2D jako child
3. Background (Sprite2D z teksturą tła)
4. Floor (instancja `floor.tscn`) lub TileMap

## Po utworzeniu
- Sprawdź czy poziom się uruchamia
- Zweryfikuj pozycję spawn gracza
- Przetestuj kolizje z podłożem
