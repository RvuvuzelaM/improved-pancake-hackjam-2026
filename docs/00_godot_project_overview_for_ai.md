Godot Project Overview

Cel dokumentu

Ten dokument opisuje ogólne działanie projektu w Godot: strukturę runtime, minimalne zasady architektury oraz bazowy przepływ gry. Jest przeznaczony dla agenta AI, który ma rozwijać projekt iteracyjnie.

Założenia techniczne
	•	Silnik: Godot 4.6 (GDScript).
	•	Render: 2D (Forward Plus).
	•	Rozdzielczość: 1920x1080 (Full HD).
	•	Filtrowanie tekstur: Nearest (pixel art).
	•	Priorytet: modularność (sceny), czytelność, szybki restart poziomu.

⸻

Struktura repo

```
improved-pancake-hackjam-2026/
├── assets/
│   ├── characters/         # Sprite'y postaci (Player.png)
│   ├── tilemap/forest/     # Tilemapy (tilemap.png, tilemap-characters.png)
│   └── tiles/forest/       # Pojedyncze kafelki
├── scenes/
│   ├── autoload/           # Singletony (SceneManager, GameData)
│   ├── levels/             # Sceny poziomów (1-1.tscn, ...)
│   ├── ui/                 # UI (main_menu.tscn, level_select.tscn)
│   ├── player.tscn         # Scena gracza
│   ├── player.gd           # Skrypt ruchu gracza
│   └── floor.tscn          # Podłoże (WorldBoundaryShape2D)
├── docs/                   # Dokumentacja projektu
├── claude/commands/        # Komendy Claude Code
├── project.godot           # Konfiguracja projektu
└── icon.svg                # Ikona projektu
```

⸻

Główne sceny i ich rola

| Scena | Typ | Opis |
|-------|-----|------|
| `scenes/ui/main_menu.tscn` | Control | Główne menu (PLAY, LEVELS, QUIT) |
| `scenes/ui/level_select.tscn` | Control | Wybór poziomu (grid z przyciskami) |
| `scenes/levels/1-1.tscn` | Node2D | Pierwszy poziom gry |
| `scenes/player.tscn` | CharacterBody2D | Scena gracza z AnimatedSprite2D i CollisionShape2D |
| `scenes/floor.tscn` | StaticBody2D | Nieskończone podłoże (WorldBoundaryShape2D) |

### Struktura player.tscn
```
player (CharacterBody2D)
├── AnimatedSprite2D    # Animacja postaci (6 klatek, 6 FPS)
└── CollisionShape2D    # Kapsuła (radius: 6, height: 18)
```

### Struktura poziomu 1-1.tscn
```
1-1 (Node2D)
├── player             # Instancja player.tscn (skala 4.28x)
│   └── Camera2D       # Kamera podążająca za graczem
├── background         # Tło (Sprite2D)
└── floor              # Instancja floor.tscn
```

### Struktura main_menu.tscn
```
MainMenu (Control)
├── Background         # ColorRect (ciemne tło)
└── VBoxContainer      # Wyśrodkowany kontener
    ├── Title          # Label "GAME TITLE"
    ├── PlayButton     # "PLAY (1-1)" - aktualny poziom
    ├── LevelSelectButton  # "LEVELS"
    └── QuitButton     # "QUIT"
```

⸻

Autoload (Singletons)

| Singleton | Plik | Opis |
|-----------|------|------|
| `SceneManager` | `scenes/autoload/scene_manager.gd` | Przejścia między scenami z fade in/out |
| `GameData` | `scenes/autoload/game_data.gd` | Postęp gracza, odblokowane poziomy |

### SceneManager
```gdscript
SceneManager.change_scene("res://scenes/levels/1-1.tscn")  # Fade out → zmiana → fade in
```

### GameData
```gdscript
GameData.current_level          # "1-1" - aktualny poziom
GameData.unlocked_levels        # ["1-1"] - odblokowane poziomy
GameData.is_level_unlocked("1-2")  # false
GameData.unlock_next_level()    # Odblokowuje następny poziom
GameData.get_current_level_path()  # "res://scenes/levels/1-1.tscn"
```

⸻

Przepływ gry

```
Main Menu
    ├── [PLAY (1-1)] → Level 1-1 (z fade)
    ├── [LEVELS] → Level Select (z fade)
    │       ├── [1-1] → Level 1-1
    │       ├── [1-2] → Level 1-2 (zablokowany)
    │       └── [BACK] → Main Menu
    └── [QUIT] → Zamknij grę
```

⸻

Input

### Input Map
| Akcja | Klawisze | Użycie |
|-------|----------|--------|
| `ui_left` | ← / A | Ruch w lewo |
| `ui_right` | → / D | Ruch w prawo |
| `ui_accept` | Space / Enter | Skok |
| `character_jump` | Space | Skok (custom) |

### Obsługa w kodzie (`player.gd`)
```gdscript
var direction := Input.get_axis("ui_left", "ui_right")
if Input.is_action_just_pressed("ui_accept") and is_on_floor():
    # skok
```

⸻

Parametry ruchu gracza

| Parametr | Wartość | Opis |
|----------|---------|------|
| `SPEED` | 400.0 | Prędkość pozioma |
| `BASE_JUMP_VELOCITY` | -550.0 | Początkowa prędkość skoku |
| `EXTRA_JUMP_FORCE` | -700.0 | Dodatkowa siła przy przytrzymaniu |
| `MAX_JUMP_HOLD_TIME` | 0.6s | Max czas przytrzymania skoku |

System skoku: Variable jump height - im dłużej trzymasz przycisk, tym wyżej skaczesz (do limitu 0.6s).

⸻

Warstwy kolizji

Obecnie używane domyślne warstwy. Do zdefiniowania:

| Warstwa | Przeznaczenie |
|---------|---------------|
| 1 | World (podłoże, platformy) |
| 2 | Player |
| 3 | Hazards (przeszkody) |
| 4 | Enemies |
| 5 | Triggers |

⸻

Zasady architektury kodu

Minimalne zasady, których trzymamy się od początku:
1. Restart poziomu i stan gry są zarządzane centralnie (GameData + SceneManager).
2. Obiekty typu hazard / przeszkoda nie sterują restartem bezpośrednio — zgłaszają zdarzenie, a manager podejmuje akcję.
3. Każdy moduł ma jedną odpowiedzialność (player movement ≠ level loading ≠ UI).

⸻

System restartu poziomu

Do implementacji:
- Przy śmierci gracza → `SceneManager.change_scene(GameData.get_current_level_path())`
- Alternatywnie: reset pozycji gracza i stanu obiektów bez przeładowania sceny

⸻

Kamera

**Model: Follow (podążająca)**

Kamera jest child node gracza (`player/Camera2D`), automatycznie podąża za nim.

Lokalizacja logiki: `scenes/levels/1-1.tscn` → `player/Camera2D`

⸻

Dodawanie nowych poziomów

1. Skopiuj `scenes/levels/1-1.tscn` jako szablon
2. Zmień nazwę na `X-Y.tscn` (np. `1-2.tscn`, `2-1.tscn`)
3. Dostosuj:
   - Pozycję spawn gracza
   - Tło i podłoże/platformy
   - Przeszkody i wrogów
4. Dodaj poziom do `GameData.levels` array
5. Dodaj przycisk w `level_select.tscn`

⸻

Dodawanie nowych obiektów (przeszkody, platformy, itp.)

### Szablon sceny obiektu
```
object_name (StaticBody2D / Area2D)
├── Sprite2D / AnimatedSprite2D
└── CollisionShape2D
```

### Konwencje
- Przeszkody (hazards): `Area2D` + sygnał `body_entered`
- Platformy: `StaticBody2D` + `CollisionShape2D`
- Pliki w `scenes/objects/` lub `scenes/hazards/`

⸻

Debug i workflow

### Włączanie widocznych kolizji
W edytorze: Debug → Visible Collision Shapes

### Przydatne do debugowania
- `print()` w `_physics_process()` do śledzenia velocity
- `is_on_floor()` zwraca true gdy gracz stoi na podłożu

⸻

Definition of Done (dla core runtime)

Uznajemy, że "core Godot project runtime" jest gotowy, gdy:
- [x] Gra startuje i ładuje poziom.
- [x] Gracz się pojawia na starcie.
- [x] Da się poruszać (minimalnie).
- [x] Główne menu z przyciskami PLAY/LEVELS/QUIT.
- [x] System przejść między scenami (fade).
- [x] Wybór poziomu (level select).
- [ ] Dotknięcie przeszkody powoduje śmierć i restart poziomu.
- [ ] Zapis/odczyt postępu gracza do pliku.

⸻

Historia zmian

| Commit | Opis |
|--------|------|
| `e3915fb` | Add initial game flow logic and UI (menu, level select, scene manager) |
| `621f4c9` | Add jump input to the project |
| `8b2b715` | Tiles + Full HD (1920x1080) |
| `906a3bb` | Assets (sprite'y, tilemapy) |
| `ba5c9a7` | Camera following player |
| `0108a01` | Initial scene and player setup |
| `86f5ec2` | Init docs |
| `3a23144` | Init commit |
