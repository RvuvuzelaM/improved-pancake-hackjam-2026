Godot Project Overview

Cel dokumentu

Ten dokument opisuje ogólne działanie projektu w Godot: strukturę runtime, minimalne zasady architektury oraz bazowy przepływ gry. Jest przeznaczony dla agenta AI, który ma rozwijać projekt iteracyjnie.

Założenia techniczne
	•	Silnik: Godot 4.5 (GDScript).
	•	Render: 2D (Forward Plus).
	•	Rozdzielczość: 1920x1080 (Full HD).
	•	Filtrowanie tekstur: Nearest (pixel art).
	•	Grawitacja: 1500.0 (custom).
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
│   ├── ui/                 # UI (main_menu, level_select, pause_modal, restart_overlay)
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
| `scenes/ui/pause_modal.tscn` | CanvasLayer | Modal pauzy (Escape) |
| `scenes/ui/restart_overlay.tscn` | CanvasLayer | Hold-to-restart z wizualnym kołem |
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
├── floor              # Instancja floor.tscn
├── PauseModal         # Instancja pause_modal.tscn
└── RestartOverlay     # Instancja restart_overlay.tscn
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

### Struktura pause_modal.tscn
```
PauseModal (CanvasLayer) [layer = 10]
└── Control [process_mode = ALWAYS]
    ├── Background     # ColorRect (półprzezroczyste)
    └── Panel
        └── VBoxContainer
            ├── Title          # "PAUSED"
            ├── ResumeButton   # "RESUME"
            ├── RestartButton  # "RESTART"
            └── MenuButton     # "MENU"
```

### Struktura restart_overlay.tscn
```
RestartOverlay (CanvasLayer) [layer = 5]
└── CircleContainer (Control) [centered]
    └── [_draw() rysuje koło postępu]
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

W grze (Level):
    ├── [Escape] → Pause Modal
    │       ├── [RESUME] → Zamknij modal, wznów grę
    │       ├── [RESTART] → Przeładuj poziom
    │       └── [MENU] → Wróć do Main Menu
    └── [Hold R] → Szybki restart (koło postępu na środku)
```

⸻

Input

### Input Map (custom actions)
| Akcja | Klawisze | Użycie |
|-------|----------|--------|
| `character_left` | ← | Ruch w lewo |
| `character_right` | → | Ruch w prawo |
| `character_jump` | Space | Skok |
| `switch_mask_1` | 1 | Przełącz maskę (do implementacji) |
| `restart_level` | R (hold) | Szybki restart poziomu |
| `ui_cancel` | Escape | Pauza |

### Domyślne akcje Godot
| Akcja | Klawisze | Użycie |
|-------|----------|--------|
| `ui_left` | ← / A | Ruch w lewo (fallback) |
| `ui_right` | → / D | Ruch w prawo (fallback) |
| `ui_accept` | Space / Enter | Skok (fallback) |

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

Fizyka

| Parametr | Wartość |
|----------|---------|
| Grawitacja 2D | 1500.0 |

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

System pauzy

- **Trigger:** `ui_cancel` (Escape)
- **Logika:** `scenes/ui/pause_modal.gd`
- **Process mode:** `PROCESS_MODE_ALWAYS` - modal reaguje na input gdy gra jest zapauzowana
- **Akcje:**
  - Resume: `get_tree().paused = false`
  - Restart: `SceneManager.change_scene(GameData.get_current_level_path())`
  - Menu: `SceneManager.change_scene("res://scenes/ui/main_menu.tscn")`

⸻

System restartu poziomu (Hold-to-Restart)

- **Trigger:** Trzymanie `restart_level` (R) przez 0.8s
- **Logika:** `scenes/ui/restart_overlay.gd` + `scenes/ui/restart_circle.gd`
- **Wizualizacja:** Koło na środku ekranu wypełniające się podczas trzymania R
- **Parametry:**
  - `HOLD_TIME`: 0.8s
  - `CIRCLE_RADIUS`: 40px
  - `CIRCLE_WIDTH`: 14px
  - Kolor tła: szary (0.2, 0.2, 0.2, 0.8)
  - Kolor wypełnienia: czerwony (1.0, 0.3, 0.3, 1.0)
- **Działanie:**
  - Trzymaj R → koło się wypełnia
  - Puść wcześniej → resetuje się
  - Wypełni się → restart poziomu

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
6. Upewnij się że `PauseModal` i `RestartOverlay` są w scenie

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
- [x] Modal pauzy (Escape).
- [x] Szybki restart (Hold R).
- [ ] Dotknięcie przeszkody powoduje śmierć i restart poziomu.
- [ ] Zapis/odczyt postępu gracza do pliku.

⸻

Historia zmian

| Commit | Opis |
|--------|------|
| `23cda59` | Add restart overlay functionality |
| `78a139e` | Update documentation with detailed project overview |
| `bbf0b9a` | Smooth movement and double jump |
| `9f948a0` | Update project configuration to use compatibility profile 4.5 |
| `ebbf1ca` | Add pause menu functionality |
| `e3915fb` | Add initial game flow logic and UI (menu, level select, scene manager) |
| `621f4c9` | Add jump input to the project |
| `8b2b715` | Tiles + Full HD (1920x1080) |
| `906a3bb` | Assets (sprite'y, tilemapy) |
| `ba5c9a7` | Camera following player |
| `0108a01` | Initial scene and player setup |
| `86f5ec2` | Init docs |
| `3a23144` | Init commit |
