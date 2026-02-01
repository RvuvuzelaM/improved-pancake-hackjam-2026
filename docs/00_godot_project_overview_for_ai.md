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
│   ├── audio/              # Efekty dźwiękowe (jump, dash, landing, death, wall_slide, wall_jump, double_jump)
│   ├── music/              # Muzyka tła (forest_calm.mp3, adventure.mp3, boss.mp3)
│   ├── characters/         # Sprite'y postaci (creature-sheet.png)
│   ├── fonts/              # Fonty (Kenney Pixel.ttf)
│   ├── themes/             # Motywy UI (default_theme.tres)
│   ├── tilemap/forest/     # Tilemapy (tilemap.png, tilemap-characters.png)
│   └── tiles/forest/       # Pojedyncze kafelki
├── scenes/
│   ├── autoload/           # Singletony (SceneManager, GameData)
│   ├── forest/             # Prefaby środowiska leśnego
│   │   ├── trees/          # Drzewa (small_tree, medium_tree_1, medium_tree_2)
│   │   ├── forest_background.tscn
│   │   ├── large_platform.tscn
│   │   ├── medium_platform.tscn
│   │   └── small_platform.tscn
│   ├── levels/             # Sceny poziomów (base_level.tscn, 1-1.tscn, 1-2.tscn, 1-3.tscn, zoo.tscn, final_boss.tscn, platform.tscn)
│   ├── enemies/            # Wrogowie (enemy_batman, enemy_fish, enemy_beetle, enemy_trap, bullet)
│   ├── chunks/             # Chunki do generatora poziomów (w trakcie rozwoju)
│   ├── objects/            # Obiekty gry (level_trigger.tscn, death_zone.tscn, ability_pickup.tscn)
│   ├── ui/                 # UI (main_menu, level_select, pause_modal, restart_overlay, level_intro, ability_widget, controls_legend)
│   ├── player.tscn         # Scena gracza
│   ├── player.gd           # Skrypt ruchu gracza
│   └── floor.tscn          # Podłoże (WorldBoundaryShape2D)
├── docs/                   # Dokumentacja projektu
├── .claude/commands/       # Komendy Claude Code
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
| `scenes/ui/level_intro.tscn` | CanvasLayer | Intro poziomu (nazwa + ID + kolor) |
| `scenes/levels/base_level.tscn` | Node2D | Bazowa scena poziomu (dziedziczenie) |
| `scenes/levels/1-1.tscn` | Node2D | Poziom 1-1 "First Steps" (extends base_level) |
| `scenes/levels/1-2.tscn` | Node2D | Poziom 1-2 "Rising Tide" (extends base_level) |
| `scenes/levels/1-3.tscn` | Node2D | Poziom 1-3 "Shadow Dance" (extends base_level) |
| `scenes/levels/zoo.tscn` | Node2D | Poziom testowy |
| `scenes/enemies/enemy_batman.tscn` | Node2D | Wróg-nietoperz z animacją (3 klatki, 9 FPS) |
| `scenes/enemies/enemy_fish.tscn` | Node2D | Wróg-ryba z animacją (2 klatki, 7 FPS) |
| `scenes/enemies/enemy_beetle.tscn` | Node2D | Wróg-żuk z animacją (3 klatki, 7 FPS) |
| `scenes/enemies/enemy_trap.tscn` | Node2D | Pułapka statyczna (kolce) |
| `scenes/enemies/bullet.tscn` | Node2D | Pocisk wroga z animacją (3 klatki, 7 FPS) |
| `scenes/levels/final_boss.tscn` | Node2D | Poziom finałowego bossa |
| `scenes/levels/platform.tscn` | AnimatableBody2D | Ruchoma platforma (57x20 px) |
| `scenes/objects/level_trigger.tscn` | Area2D | Trigger przejścia do następnego poziomu |
| `scenes/objects/ability_pickup.tscn` | Area2D | Pickup zbieralnej zdolności |
| `scenes/ui/ability_widget.tscn` | CanvasLayer | Widget pokazujący aktywną zdolność |
| `scenes/ui/controls_legend.tscn` | CanvasLayer | Legenda sterowania (toggle: H) |
| `scenes/forest/*.tscn` | Node2D/StaticBody2D | Prefaby środowiska (platformy, drzewa, tło) |
| `scenes/player.tscn` | CharacterBody2D | Scena gracza z AnimatedSprite2D i CollisionShape2D |
| `scenes/floor.tscn` | StaticBody2D | Nieskończone podłoże (WorldBoundaryShape2D) |

### Struktura player.tscn
```
player (CharacterBody2D) [collision_layer=2]
├── AnimatedSprite2D2   # Animacja postaci (4 klatki z creature-sheet.png, 7 FPS)
└── CollisionShape2D    # Kapsuła (radius: 9, height: 20)
```

### Struktura base_level.tscn (bazowa scena)
```
BaseLevel (Node2D) [script: base_level.gd]
├── player             # Instancja player.tscn (skala 1.2x)
│   └── Camera2D       # Kamera (zoom 3x)
├── LevelTrigger       # Instancja level_trigger.tscn (pozycja ustawiana w edytorze)
├── PauseModal         # Instancja pause_modal.tscn
├── RestartOverlay     # Instancja restart_overlay.tscn
├── ControlsLegend     # Instancja controls_legend.tscn
└── AbilityWidget      # Instancja ability_widget.tscn

@export var spawn_position: Vector2    # Pozycja spawn gracza
@export var next_level: String         # ID następnego poziomu
# LevelTrigger pozycjonowany ręcznie przez designera w edytorze Godot
```

### Struktura poziomu 1-2.tscn (dziedziczenie)
```
1-2 (Node2D) [extends base_level.tscn]
│   spawn_position = (39, 835)
│   next_level = "1-3"
├── [inherited: player, LevelTrigger (position=1085,832), PauseModal, RestartOverlay]
├── Background (TileMapLayer)   # Tło poziomu
├── TileMapLayer               # Platformy
├── StaticBody2D*              # Kolizje platform
└── medium_tree_1              # Dekoracje
```

### Struktura main_menu.tscn
```
MainMenu (Control)
├── Background         # ColorRect (ciemne tło)
└── VBoxContainer      # Wyśrodkowany kontener
    ├── Title          # Label "GAME TITLE"
    ├── PlayButton     # "[P] PLAY (1-1)" - aktualny poziom
    ├── LevelSelectButton  # "[L] LEVELS"
    └── QuitButton     # "[Q] QUIT"

Skróty klawiszowe: P (Play), L (Levels), Q (Quit)
```

### Struktura pause_modal.tscn
```
PauseModal (CanvasLayer) [layer = 10]
└── Control [process_mode = ALWAYS]
    ├── Background     # ColorRect (półprzezroczyste)
    └── Panel
        └── VBoxContainer
            ├── Title          # "PAUSED"
            ├── ResumeButton   # "[C] RESUME"
            ├── RestartButton  # "[R] RESTART"
            └── MenuButton     # "[M] MENU"

Skróty klawiszowe: C (Resume/Continue), R (Restart), M (Menu), ESC (Resume)
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
| `GameData` | `scenes/autoload/game_data.gd` | Postęp gracza, odblokowane poziomy, metadane poziomów |
| `LevelIntro` | `scenes/ui/level_intro.tscn` | UI intro poziomów (nazwa + ID + kolor) |

### SceneManager
```gdscript
SceneManager.change_scene("res://scenes/levels/1-1.tscn")  # Fade out → zmiana → fade in
# Domyślny czas tranzycji: 0.25s (fade in + fade out = 0.5s)

# Sygnały
signal transition_finished    # Emitowany po zakończeniu przejścia
signal scene_loaded(level_id) # Emitowany po załadowaniu sceny z ID poziomu (lub "" dla non-level)
```

### GameData
```gdscript
# Właściwości
GameData.current_level          # "1-1" - aktualny poziom
GameData.levels                 # Dictionary {"1-1": "res://scenes/levels/1-1.tscn", ...}
GameData.level_order            # ["1-1", "1-2", "1-3", "final_boss"]
GameData.unlocked_levels        # ["1-1"] - odblokowane poziomy
GameData.level_metadata         # Dictionary {"1-1": {"name": "First Steps", "color": "#4CAF50"}, ...}

# Metody - poziomy
GameData.get_current_level_path()  # "res://scenes/levels/1-1.tscn"
GameData.get_level_path("1-2")     # "res://scenes/levels/1-2.tscn"
GameData.level_exists("1-2")       # true
GameData.is_level_unlocked("1-2")  # false
GameData.unlock_level("1-2")       # Odblokowuje konkretny poziom
GameData.unlock_next_level()       # Odblokowuje następny w kolejności
GameData.set_current_level("1-2")  # Ustawia aktualny poziom

# Metody - metadane poziomów
GameData.get_level_metadata("1-1") # {"name": "First Steps", "color": "#4CAF50"}
GameData.get_level_name("1-1")     # "First Steps"
GameData.get_level_color("1-1")    # Color(0.298, 0.686, 0.314, 1) - z hex #4CAF50
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
| Akcja | Klawiatura | Gamepad | Użycie |
|-------|------------|---------|--------|
| `character_left` | ← | Left Stick ← | Ruch w lewo |
| `character_right` | → | Left Stick → | Ruch w prawo |
| `character_jump` | Space | A (Xbox) / X (PS) | Skok |
| `switch_mask_none` | 0 | RT (axis 5) | Przełącz na maskę NONE |
| `switch_mask_double_jump` | W | LB (button 9) | Przełącz na maskę DOUBLE_JUMP |
| `switch_mask_dash` | Q | RB (button 10) | Przełącz na maskę DASH |
| `switch_mask_ledge_grab` | E | LT (axis 4) | Przełącz na maskę LEDGE_GRAB |
| `dash` | D | X (Xbox) / Square (PS) | Wykonaj dash |
| `restart_level` | R (hold) | Start (button 6) | Szybki restart poziomu |
| `ui_cancel` | Escape | Menu (button 7) | Pauza |

### Obsługa Gamepada
- Wszystkie akcje mają bindingi dla kontrolera (device=-1 = wszystkie kontrolery)
- Deadzone: 0.2 dla przycisków, 0.5 dla triggerów (LT/RT)
- Kod `player.gd` nie wymaga zmian - Godot `Input.is_action_*` obsługuje oba typy inputów automatycznie

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
| `SPEED` | 120.0 | Prędkość pozioma |
| `BASE_JUMP_VELOCITY` | -370.0 | Początkowa prędkość skoku |
| `DASH_SPEED` | 400.0 | Prędkość dasza |
| `DASH_DURATION` | 0.15s | Czas trwania dasza |
| `DASH_COOLDOWN` | 0.5s | Cooldown między dashami |
| `COYOTE_TIME_DURATION` | 0.15s | Czas na skok po opuszczeniu platformy |
| `COYOTE_X_TOLERANCE` | 32.0px | Tolerancja pozioma dla coyote time |
| `wall_slide_speed` | 20.0 | Prędkość ślizgania po ścianie |
| `wall_x_force` | 320.0 | Siła pozioma wall jump |
| `wall_y_force` | -400.0 | Siła pionowa wall jump |
| `WALL_HOLD_DURATION` | 1.5s | Czas trzymania się ściany przed spadnięciem |

### System masek (umiejętności)
Gracz może przełączać maski, które dają różne zdolności:

| Maska | Klawisz | Zdolność |
|-------|---------|----------|
| `NONE` | 0 | Brak specjalnej zdolności |
| `DOUBLE_JUMP` | W | Podwójny skok (max 2 skoki) |
| `DASH` | Q | Dash w kierunku ruchu (D) |
| `LEDGE_GRAB` | E | Chwytanie ścian + wall jump |

### System dasza
- Aktywny tylko z maską `DASH`
- Dash w kierunku aktualnego ruchu (lub ostatniego kierunku velocity)
- Podczas dasza grawitacja zredukowana do 10%
- Cooldown zapobiega spamowaniu

⸻

Fizyka

| Parametr | Wartość |
|----------|---------|
| Grawitacja 2D | 1500.0 |

### Rendering (pixel art)
| Ustawienie | Wartość |
|------------|---------|
| `textures/canvas_textures/default_texture_filter` | 0 (Nearest) |
| `2d/snap/snap_2d_transforms_to_pixel` | true |
| `2d/snap/snap_2d_vertices_to_pixel` | true |

### Globalny motyw UI
| Ustawienie | Wartość |
|------------|---------|
| Font | Kenney Pixel.ttf |
| Domyślny rozmiar | 24px |
| Konfiguracja | `assets/themes/default_theme.tres` |
| project.godot | `gui/theme/custom` |

⸻

Warstwy kolizji

Zaimplementowane warstwy kolizji:

| Warstwa | Przeznaczenie | Użycie |
|---------|---------------|--------|
| 1 | World | Podłoże, platformy, StaticBody2D |
| 2 | Player | CharacterBody2D gracza |
| 3 | Hazards | Przeszkody (do implementacji) |
| 4 | Enemies | Wrogowie (do implementacji) |
| 5 | Triggers | LevelTrigger i inne Area2D |

### Konfiguracja obiektów
- **Player:** `collision_layer = 2`, `collision_mask = 1`
- **LevelTrigger:** `collision_layer = 0`, `collision_mask = 2` (wykrywa gracza)

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

Level Intro System

System prezentacji intro przy wejściu na poziom.

### Komponenty
1. **LevelIntro** (autoload) - UI overlay z nazwą i ID poziomu
2. **Player entry mode** - gracz spada z góry, nie może się ruszać horyzontalnie

### Przepływ
```
SceneManager.change_scene() → scene_loaded signal
        ↓                           ↓
   Player: entry_mode          LevelIntro: show
   (opacity 0.6, brak ruchu)   (nazwa + ID + kolor)
        ↓                           ↓
   Player ląduje (is_on_floor)      │
        ↓                           │
   player_landed signal ────────────┘
        ↓                           ↓
   Restore opacity             LevelIntro: fade out (natychmiast po fade-in)
```

### Struktura level_intro.tscn
```
LevelIntro (CanvasLayer) [layer = 15]
└── Container (Control) [full rect]
    ├── Background (ColorRect) [alpha 0.3]
    └── ContentBox (VBoxContainer) [bottom-center]
        ├── AccentBar (ColorRect) [6px, level color]
        ├── LevelName (Label) [font_size=144, level color]
        └── LevelID (Label) [font_size=72, black (LabelSettings)]
```

### Timing animacji Level Intro
| Parametr | Wartość | Opis |
|----------|---------|------|
| `FADE_IN_DURATION` | 0.4s | Czas pojawiania się |
| `FADE_OUT_DURATION` | 1.5s | Czas zanikania (gradualnie) |
| `AUTO_HIDE_DELAY` | 0.0s | Fade-out zaczyna się od razu po fade-in |
| `BACKGROUND_ALPHA` | 0.3 | Przezroczystość tła |

### Parametry entry mode (player.gd)
- `ENTRY_OPACITY`: 0.6 - przezroczystość gracza podczas spadania
- `ENTRY_DROP_HEIGHT`: 200.0 - wysokość z jakiej gracz spada

### Metadane poziomów (w GameData)
```gdscript
level_metadata = {
    "1-1": {"name": "First Steps", "color": "#4CAF50"},
    "1-2": {"name": "Rising Tide", "color": "#2196F3"},
    "1-3": {"name": "Shadow Dance", "color": "#9C27B0"},
    "final_boss": {"name": "Final Leap", "color": "#FF5722"},
}
```

⸻

System Audio

### Efekty dźwiękowe (SFX)
Pliki w `assets/audio/`, odtwarzane przez `AudioStreamPlayer` w `player.gd`:

| Dźwięk | Plik | Wyzwalany przez |
|--------|------|-----------------|
| Skok | `jump.mp3` | `perform_jump()` (pierwszy skok) |
| Podwójny skok | `double_jump.mp3` | `perform_jump()` (drugi skok, maska DOUBLE_JUMP) |
| Dash | `dash.mp3` | `start_dash()` |
| Lądowanie | `landing.mp3` | `apply_gravity()` (was_on_floor → is_on_floor) |
| Wall jump | `wall_jump.mp3` | `wall_jumping()` |
| Wall slide | `wall_slide.mp3` | `wall_logic()` (looped podczas ślizgania) |
| Śmierć | `death.mp3` | `die()` |

### Muzyka w tle
Pliki w `assets/music/`, odtwarzane przez `SceneManager`:

| Poziom | Plik | Styl |
|--------|------|------|
| 1-1 | `forest_calm.mp3` | Spokojny, ambient chiptune |
| 1-2 | `adventure.mp3` | Energiczny, retro |
| final_boss | `boss.mp3` | Epicka, dramatyczna |

**Konfiguracja muzyki** w `scene_manager.gd`:
```gdscript
var _level_music: Dictionary = {
    "1-1": "res://assets/music/forest_calm.mp3",
    "1-2": "res://assets/music/adventure.mp3",
    "final_boss": "res://assets/music/boss.mp3",
}
```

**Parametry:**
- `MUSIC_VOLUME_DB`: -10.0 (nie zagłusza SFX)
- `MUSIC_FADE_DURATION`: 0.5s (fade-out przy zmianie)
- Muzyka zapętlona (`stream.loop = true`)
- Ta sama muzyka nie restartuje się przy restarcie poziomu

⸻

Level Trigger (przejście między poziomami)

- **Scena:** `scenes/objects/level_trigger.tscn`
- **Typ:** Area2D z CollisionShape2D
- **Parametr:** `@export var target_level: String` - ID docelowego poziomu (np. "1-2")
- **Działanie:** Gracz wchodzi w trigger → automatyczne przejście do `target_level` z fade
- **Gracz:** Musi być w grupie "player" (dodawane automatycznie w `player.gd`)

### Struktura level_trigger.tscn
```
LevelTrigger (Area2D) [collision_layer=0, collision_mask=2]
└── CollisionShape2D    # RectangleShape2D (64x128)
```

### Użycie
1. Dodaj instancję `level_trigger.tscn` na końcu poziomu
2. W Inspektorze ustaw `target_level` np. `"1-2"`
3. Gracz wchodzi → zmiana sceny z fade

⸻

Death Zone (strefa śmierci)

- **Scena:** `scenes/objects/death_zone.tscn`
- **Typ:** Area2D z CollisionShape2D (64x16)
- **Działanie:** Gracz wchodzi w strefę → `die()` → obrót 90° + czerwony overlay
- **Restart:** Gracz musi przytrzymać R (0.8s) żeby zrestartować

### Struktura death_zone.tscn
```
DeathZone (Area2D) [collision_layer=0, collision_mask=2]
└── CollisionShape2D    # RectangleShape2D (64x16), debug_color czerwony
```

### Mechanizm śmierci gracza (player.gd)
```gdscript
func die() -> void:
    _is_dead = true
    velocity = Vector2.ZERO
    rotation_degrees = 90
    _show_death_overlay()  # Czerwony ekran + "PORAZKA" + instrukcje
```

### Ekran śmierci
- Czerwone przezroczyste tło (30% opacity)
- Napis "PORAZKA" (128px, czerwony)
- Czas ukończenia (64px, biały) - format MM:SS.ms
- Instrukcje "[R] Restart    [ESC] Menu" (32px, biały)

⸻

Level Timer System

System licznika czasu dla każdego poziomu.

### Mechanizm
- Timer startuje gdy gracz ląduje (koniec entry mode)
- Timer zatrzymuje się przy śmierci lub ukończeniu poziomu
- Czas wyświetlany w formacie `MM:SS.ms` (np. `00:12.45`)

### Lokalizacja kodu
Timer zaimplementowany w `player.gd` dla niezawodności:
```gdscript
var elapsed_time: float = 0.0
var _timer_running: bool = false
var _timer_ui: CanvasLayer = null
var _timer_label: Label = null

func _start_timer() -> void:
    _timer_running = true
    _create_timer_ui()

func stop_timer() -> void:
    _timer_running = false
    _hide_timer_ui()

func get_elapsed_time() -> float:
    return elapsed_time
```

### Wyświetlanie czasu
1. **Real-time UI** - timer w lewym górnym rogu (32px, czarny), aktualizowany co klatkę
2. **Ekran śmierci** - czas wyświetlany pod napisem "PORAZKA" (wycentrowany)
3. **Ekran ukończenia** - czas wyświetlany z nazwą poziomu przez 1 sekundę (wycentrowany)

### Ekran ukończenia poziomu
- Zielone przezroczyste tło (30% opacity)
- Napis "UKONCZONO" (96px, zielony)
- Nazwa poziomu "1-1 - First Steps" (48px, czarny)
- Czas ukończenia (64px, biały)
- Automatyczne przejście do następnego poziomu po 1s

⸻

Ability Pickup (zbieralne zdolności)

- **Scena:** `scenes/objects/ability_pickup.tscn`
- **Typ:** Area2D z CollisionShape2D
- **Działanie:** Gracz dotyka pickup → odblokowanie zdolności w GameData

### Struktura ability_pickup.tscn
```
AbilityPickup (Area2D) [collision_layer=0, collision_mask=2]
├── Sprite2D          # Ikona zdolności
└── CollisionShape2D
```

### Parametry eksportowane
```gdscript
@export var ability_id: String = "d-jump"  # "d-jump", "dash", "ledge-grab"
```

### Mechanizm
1. Przy wejściu sprawdza czy gracz ma już zdolność (`GameData.has_ability()`)
2. Jeśli nie → pokazuje pickup
3. Po dotknięciu → `GameData.unlock_ability(ability_id)`
4. Pickup znika (ukryty, collision disabled)

⸻

Ability Widget (tracker aktywnej zdolności)

- **Scena:** `scenes/ui/ability_widget.tscn`
- **Typ:** CanvasLayer z ikonami zdolności
- **Działanie:** Pokazuje którą zdolność gracz ma aktywną (podświetlenie)

### Mechanizm
- Nasłuchuje sygnału `player.mask_changed`
- Aktywna zdolność: opacity 1.0, brightness 1.0
- Nieaktywne: opacity 0.3, brightness 0.5

⸻

Controls Legend (legenda sterowania)

- **Scena:** `scenes/ui/controls_legend.tscn`
- **Typ:** CanvasLayer (warstwa 5)
- **Pozycja:** Lewy dolny róg
- **Toggle:** Klawisz `H`

### Aktualne klawisze
| Klawisz | Akcja |
|---------|-------|
| `< >` | Ruch |
| `SPACE` | Skok |
| `W` | Podwójny skok (maska) |
| `Q + D` | Dash (maska + akcja) |
| `E` | Ledge grab (maska) |
| `R` | Restart (hold) |
| `ESC` | Pauza |

⸻

Kamera

**Model: Follow (podążająca)**

Kamera jest child node gracza (`player/Camera2D`), automatycznie podąża za nim.

Lokalizacja logiki: `scenes/levels/1-1.tscn` → `player/Camera2D`

⸻

Dodawanie nowych poziomów

1. **Utwórz scenę dziedziczącą z `base_level.tscn`**
   - Scene → New Inherited Scene → base_level.tscn
   - Zapisz jako `X-Y.tscn` (np. `1-3.tscn`)

2. **Ustaw @export wartości w inspektorze root node:**
   - `spawn_position` - pozycja spawn gracza (np. Vector2(100, 500))
   - `trigger_position` - pozycja triggera końca poziomu
   - `next_level` - ID następnego poziomu (np. "1-4")

3. **Dodaj level-specific content:**
   - Background (TileMapLayer) - tło poziomu
   - TileMapLayer - platformy
   - StaticBody2D - kolizje platform
   - Dekoracje (drzewa, etc.)

4. **Zarejestruj poziom w `GameData`:**
   - Dodaj do `levels`: `"1-3": "res://scenes/levels/1-3.tscn"`
   - Dodaj do `level_order`: `["1-1", "1-2", "1-3", ...]`
   - Dodaj do `level_metadata`: `"1-3": {"name": "Level Name", "color": "#HEX"}`

5. **Dodaj przycisk w `level_select.tscn`**

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
- [x] Legenda klawiszy (tymczasowy overlay podczas gry pokazujący sterowanie).
- [x] Dotknięcie przeszkody powoduje śmierć i restart poziomu (DeathZone + die()).
- [ ] Zapis/odczyt postępu gracza do pliku.

⸻

Historia zmian

| Commit | Opis |
|--------|------|
| `8d1bc3a` | Adds masks |
| `1e66bb3` | Fix max jump |
| `8ea526a` | Fix music |
| `0c60579` | Adds water animation |
| `3a3e30c` | Fixed level order |
| `e5b039d` | Fixed dash color |
| `ecd4c54` | Adds flag to 1-2 |
| `674b369` | Add animation script |
| `8770e3b` | Revert level 1-1 music to forest_calm.mp3 |
| `5dfbcc2` | Added masks colors |
| `3cfbc43` | Boss level design |
| `c013592` | Add boss.mp3 import file |
| `93b5aff` | Add boss music and set it as level 1-1 soundtrack temporarily |
| `bc04ae5` | Replace jump and landing sounds with softer, quirky versions |
| `c33a7ef` | Update documentation with gamepad support and platform component |
| `40d5280` | Final boss update, and adding platform as comp |
| `117a4d6` | Add gamepad/controller support for all input actions |
| `97d9146` | Update documentation with audio system details |
| `61f5e88` | Remove procedural_level.tscn references from docs |
| `863b29e` | Add music import files for Godot |
| `a78f3a2` | Add background music system for levels |
| `2a94bb3` | Add audio system with sound effects for player actions |
| `8ff8117` | Update documentation with new objects and mechanics |
| `498bea2` | Clean up unnecessary TileSet data in 1-1.tscn |
| `52765ed` | Fix missing Animation_10r0f in 1-1.tscn |
| `cd2450d` | Fix level intro: black ID text, smooth fade timing |
| `2b5205f` | Update documentation and reduce scene transition time |
| `743affa` | Fix TileSet errors: remove out-of-bounds tile definitions |
| `65013e9` | Improve UI readability: black text for timer and level name |
| `1a7da80` | Fix dash bug, and wall holding |
| `b1d3b48` | Levels |
| `a9cc1a1` | Add base final boss scene |
| `354c49e` | Active ability tracker |
| `167522c` | Fix TileSet errors: remove out-of-bounds tile definitions |
| `96f663e` | Improve UI readability: black text for timer and level name |
| `3a9b861` | Fix LevelTrigger positioning - let designer set position in editor |
| `7bfd46a` | Update documentation with real-time timer UI details |
| `46ee746` | Add real-time timer UI and center overlay messages |
| `1f59181` | Add coyote time documentation |
| `6f5271c` | Update documentation with shortcuts, timer and wall jump |
| `c6894b0` | Add coyote jumping |
| `c2cf4e4` | Add keyboard shortcuts to all menu buttons |
| `bccccf1` | Fix timer tracking by moving it to player |
| `ef154fc` | Add level timer with completion and death overlays |
| `0147ab0` | 1-2 |
| `a31a886` | Add dashing animations |
| `81ef8d5` | Add wall jump |
| `f05e903` | Added dash animation |
| `31b5ff7` | Added sprite animation |
| `1307d44` | Add ledge grab to controls legend |
| `0941bb9` | Update documentation with death screen details |
| `5288aed` | Add death screen with PORAZKA title and restart hints |
| `14e68b5` | Merge remote-tracking branch 'origin/main' |
| `04eb902` | Active ability tracker |
| `7716aa9` | Merge branch 'main' |
| `6398f33` | 1-2 level |
| `f5cb3c5` | Update documentation with death system details |
| `d86e8a2` | Add death system with DeathZone and player death mechanics |
| `8d6dbde` | Adds collectible items |
| `a40d085` | Add controls_legend script UID file |
| `12c0697` | Double controls legend size |
| `21862fb` | Add controls legend overlay in bottom-left corner |
| `e313197` | Update documentation with new input bindings |
| `32efd1a` | Merge remote-tracking branch 'origin/main' |
| `16e89b9` | Improved collisions for trees |
| `8a0528e` | Add dash in flight handling |
| `2a26235` | Update documentation with 1-1 level and recent commits |
| `4b4b650` | Update documentation with folder structure and timing changes |
| `8c77661` | Move commands to .claude/ and restore 1-2 BaseLevel inheritance |
| `69f5373` | fix |
| `e42fdfe` | Merge remote-tracking branch 'origin/detached' |
| `7431b09` | Revert "1-2 lvl" |
| `cdbfb33` | Merge branch 'main' |
| `a958d3b` | 1-2 lvl |
| `ed3281e` | Update documentation with BaseLevel inheritance and font system |
| `73ac923` | Add Kenney Pixel font and increase UI text sizes |
| `0bd4613` | Refactor levels to use BaseLevel inheritance |
| `3111703` | Merge branch 'main' |
| `794aaf1` | Update documentation with forest prefabs and latest changes |
| `9d55d98` | 1-2 lvl |
| `4557323` | 1-2 lvl |
| `12cd4a1` | Reusable trees and platforms |
| `8ddc81d` | Update documentation with level intro and dash systems |
| `d46d7b7` | Merge remote changes (dash system) with level intro |
| `ac6e992` | Add level intro system with entry animation |
| `123f142` | Add dash mask handling |
| `5f6718c` | Add level_trigger script UID file |
| `d3c60cf` | 1-2 lvl |
| `3b0fff6` | Update documentation with collision layers and level triggers |
| `220a385` | Add level triggers to levels and fix player collision layers |
| `c8dd39f` | Add level trigger system and level references |
| `7d9b09d` | Update documentation with 1-2 level details |
| `a96e6f4` | 1-2 lvl |
| `559535a` | Update documentation with restart overlay details |
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
