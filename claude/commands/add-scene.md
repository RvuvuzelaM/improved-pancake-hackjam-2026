# Dodaj nową scenę

Stwórz nową scenę Godot według poniższego szablonu:

## Wymagania
- Nazwa sceny: $ARGUMENTS (lub zapytaj użytkownika)
- Lokalizacja: `scenes/` lub odpowiedni podfolder
- Format: `.tscn`

## Szablon sceny
1. Utwórz plik `.tscn` z odpowiednim root node
2. Dodaj wymagane child nodes
3. Jeśli potrzebny skrypt - utwórz plik `.gd` w tym samym folderze

## Konwencje projektu
- Nazwy scen: lowercase z myślnikami (np. `player-spawn.tscn`)
- Poziomy w `scenes/levels/` z numeracją (np. `1-1.tscn`, `1-2.tscn`)
- Komponenty wielokrotnego użytku w `scenes/`
