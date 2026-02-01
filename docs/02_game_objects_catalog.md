# Katalog Obiektów Gry

Ten dokument zawiera pełną listę wszystkich obiektów gry wraz z ich właściwościami. Służy jako referencja do generowania proceduralnych poziomów.

---

## Spis Treści

1. [Platformy](#platformy)
2. [Dekoracje](#dekoracje)
3. [Obiekty Interaktywne](#obiekty-interaktywne)
4. [Zagrożenia](#zagrożenia)
5. [Elementy UI](#elementy-ui)
6. [Warstwy Kolizji](#warstwy-kolizji)

---

## Platformy

### Small Platform (Mała Platforma)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/platforms/small_platform.tscn` |
| **Typ węzła** | `Node2D` + `StaticBody2D` |
| **Rozmiar kolizji** | 50 x 15 px |
| **One-way collision** | Tak |
| **Offset kolizji** | (27, -9.5) |
| **Tekstura** | TileMapLayer (18x18 kafelki) |

**Użycie:** Idealna do krótkich przeskoków, sekwencji platform.

---

### Medium Platform (Średnia Platforma)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/platforms/medium_platform.tscn` |
| **Typ węzła** | `Node2D` + `StaticBody2D` |
| **Rozmiar kolizji** | 104 x 15 px |
| **One-way collision** | Tak |
| **Offset kolizji** | (54, -9.5) |
| **Tekstura** | TileMapLayer (18x18 kafelki) |

**Użycie:** Standardowa platforma, miejsce odpoczynku.

---

### Large Platform (Duża Platforma)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/platforms/large_platform.tscn` |
| **Typ węzła** | `Node2D` + `StaticBody2D` |
| **Rozmiar kolizji** | 212 x 15 px |
| **One-way collision** | Tak |
| **Offset kolizji** | (108, -9.5) |
| **Tekstura** | TileMapLayer (18x18 kafelki) |

**Użycie:** Obszary startowe, główne platformy, punkty orientacyjne.

---

### Fading Platform (Zanikająca Platforma)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/platforms/fading_platform_small.tscn` |
| **Skrypt** | `scenes/forest/platforms/fading_platform.gd` |
| **Typ węzła** | `Node2D` (class_name: FadingPlatform) |
| **Dziedziczenie** | StaticBody2D + CollisionShape2D |

**Parametry eksportowane:**
```gdscript
@export var respawn_time: float = 3.0       # Czas do respawnu (0 = brak)
@export var fade_out_duration: float = 0.5  # Czas zanikania
@export var fade_in_duration: float = 0.3   # Czas pojawiania się
@export var fade_delay: float = 0.5         # Opóźnienie przed zanikaniem
```

**Zachowanie:**
1. Gracz wchodzi na platformę → `trigger_fade()`
2. Po `fade_delay` sekund zaczyna zanikać
3. Kolizja wyłączona podczas fade-out
4. Po `respawn_time` platforma się odradza (fade-in)
5. Kolizja włączona po zakończeniu fade-in

**Użycie:** Dynamiczne poziomy wymagające szybkiego poruszania się.

---

### Animated Platform (Ruchoma Platforma)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/levels/platform.tscn` |
| **Typ węzła** | `AnimatableBody2D` |
| **Rozmiar kolizji** | 57 x 20 px |
| **Tekstura** | Region z `tilemap.png` (152, 38, 56x18) |

**Struktura:**
```
Platform (AnimatableBody2D)
├── CollisionShape2D    # RectangleShape2D (57x20)
└── Sprite2D            # Region z tilemap.png
```

**Użycie:** Ruchome platformy z animacją - można animować pozycję przez AnimationPlayer w poziomie.

---

### Podsumowanie Platform

| Platforma | Szerokość | Wysokość | Plik |
|-----------|-----------|----------|------|
| Mała | 50 px | 15 px | `small_platform.tscn` |
| Średnia | 104 px | 15 px | `medium_platform.tscn` |
| Duża | 212 px | 15 px | `large_platform.tscn` |
| Ruchoma | 57 px | 20 px | `platform.tscn` |

---

## Dekoracje

### Small Tree (Małe Drzewo)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/trees/small_tree.tscn` |
| **Typ węzła** | `TileMapLayer` |
| **Kolizja** | `StaticBody2D` (48 x 7 px) |
| **Offset kolizji** | (36, -13) |
| **Funkcja** | Dekoracja + opcjonalna powierzchnia |

---

### Medium Tree 1 (Średnie Drzewo 1)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/trees/medium_tree_1.tscn` |
| **Typ węzła** | `TileMapLayer` |
| **Kolizja gałęzi** | `StaticBody2D` (30 x 7 px) |
| **Offset kolizji** | (-9, -31.5) |
| **One-way collision** | Tak (gałąź) |
| **Funkcja** | Dekoracja z możliwością wskoczenia na gałąź |

---

### Medium Tree 2 (Średnie Drzewo 2)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/trees/medium_tree_2.tscn` |
| **Typ węzła** | `TileMapLayer` |
| **Struktura** | Podobna do Medium Tree 1 |
| **Funkcja** | Wariant wizualny średniego drzewa |

---

### Forest Background (Tło Lasu)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/forest_background.tscn` |
| **Typ węzła** | `TileMapLayer` |
| **Tekstura** | `tilemap-backgrounds_packed.png` (24x24 kafelki) |
| **Kolizja** | Brak |
| **Funkcja** | Tło wizualne, efekt paralaksy |

---

### Podsumowanie Dekoracji

| Obiekt | Ma kolizję | One-way | Plik |
|--------|------------|---------|------|
| Małe drzewo | Tak | Nie | `small_tree.tscn` |
| Średnie drzewo 1 | Tak (gałąź) | Tak | `medium_tree_1.tscn` |
| Średnie drzewo 2 | Tak (gałąź) | Tak | `medium_tree_2.tscn` |
| Tło lasu | Nie | - | `forest_background.tscn` |

---

## Obiekty Interaktywne

### Level Trigger (Wyzwalacz Poziomu)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/objects/level_trigger.tscn` |
| **Skrypt** | `scenes/objects/level_trigger.gd` |
| **Typ węzła** | `Area2D` |
| **Rozmiar** | 64 x 128 px |
| **Warstwa kolizji** | 0 (tylko detekcja) |
| **Maska kolizji** | 2 (wykrywa gracza) |

**Parametry eksportowane:**
```gdscript
@export var target_level: String  # np. "1-2" - ustawiane przez base_level.gd
```

**Pozycjonowanie:** Designer ustawia pozycję LevelTrigger ręcznie w edytorze Godot (przeciągając node w scenie).

**Zachowanie:** Gdy gracz wejdzie w obszar, następuje przejście do `target_level`.

---

### Floor (Podłoga / Granica Świata)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/floor.tscn` |
| **Typ węzła** | `StaticBody2D` |
| **Kształt kolizji** | `WorldBoundaryShape2D` |
| **Funkcja** | Niewidzialna granica na dole świata |

**Zachowanie:** Gdy gracz spadnie poniżej tej granicy, aktywuje się mechanizm restartu.

---

### Ability Pickup (Zbieralna Zdolność)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/objects/ability_pickup.tscn` |
| **Skrypt** | `scenes/objects/ability_pickup.gd` |
| **Typ węzła** | `Area2D` |
| **Warstwa kolizji** | 0 (tylko detekcja) |
| **Maska kolizji** | 2 (wykrywa gracza) |

**Parametry eksportowane:**
```gdscript
@export var ability_id: String = "d-jump"  # "d-jump", "dash", "ledge-grab"
```

**Zachowanie:**
1. Sprawdza czy gracz ma już zdolność (`GameData.has_ability()`)
2. Jeśli nie → pickup jest widoczny
3. Gracz dotyka → `GameData.unlock_ability(ability_id)`
4. Pickup znika (ukryty + collision disabled)

**Użycie:** Umieść w poziomie jako nagrodę lub element progressji.

---

### Destructable Wall (Niszczalna Ściana)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/forest/destructable_wall.tscn` |
| **Skrypt** | `scenes/forest/destructable_wall.gd` |
| **Typ węzła** | `AnimatedSprite2D` (class_name: DestructableWall) |
| **Dziedziczenie** | StaticBody2D + CollisionShape2D |

**Parametry eksportowane:**
```gdscript
@export_flags("Dash", "Touch", "Jump Through") var break_abilities: int = 0
@export var respawn_time: float = 0.0           # Czas do respawnu (0 = brak)
@export var break_animation_duration: float = 0.3
@export var fade_duration: float = 0.2
@export var break_delay: float = 0.0            # Opóźnienie przed zniszczeniem
```

**Typy zdolności niszczących:**
| Flaga | Opis |
|-------|------|
| `DASH` | Niszczona podczas dashu |
| `TOUCH` | Niszczona przy dotknięciu |
| `JUMP_THROUGH` | Niszczona przy przeskoku od dołu |

**Zachowanie:**
1. Gracz dotyka ściany z odpowiednią zdolnością
2. Po `break_delay` sekund zaczyna się animacja zniszczenia
3. Kolizja wyłączona, animacja "default" + fade-out
4. Po `respawn_time` ściana się odradza (jeśli > 0)

**Użycie:** Ukryte sekrety, alternatywne drogi, wymaganie konkretnych zdolności.

---

## Zagrożenia

### Death Zone (Strefa Śmierci)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/objects/death_zone.tscn` |
| **Skrypt** | `scenes/objects/death_zone.gd` |
| **Typ węzła** | `Area2D` |
| **Rozmiar** | 64 x 16 px (domyślny, skalowalny) |
| **Warstwa kolizji** | 0 (tylko detekcja) |
| **Maska kolizji** | 2 (wykrywa gracza) |
| **Debug color** | Czerwony (1, 0, 0, 0.4) |

**Zachowanie:** Gdy gracz wejdzie w obszar:
1. Wywołuje `body.die()` na graczu
2. Gracz obraca się o 90° (położony na bok)
3. Pojawia się ekran śmierci:
   - Czerwone tło (30% opacity)
   - Napis "PORAZKA" (128px)
   - "[R] Restart    [ESC] Menu"
4. Gracz musi przytrzymać R (0.8s) żeby zrestartować

**Użycie:** Umieść pod kolcami, przepaściami, lub jako niewidzialną barierę śmierci.

---

### Spadnięcie poza mapę

| Właściwość | Wartość |
|------------|---------|
| **Typ** | Spadnięcie poza mapę |
| **Mechanizm** | `WorldBoundaryShape2D` |
| **Skutek** | Aktywacja `RestartOverlay` |
| **Restart** | Przytrzymaj `R` przez 0.8s |

---

### Potencjalne Zagrożenia do Implementacji

Dla przyszłego rozwoju generatora poziomów, można dodać:

| Typ Zagrożenia | Sugerowany Węzeł | Zachowanie |
|----------------|------------------|------------|
| Kolce (wizualne) | `Death Zone` + Sprite | Death Zone z grafiką kolców |
| Ruchome Kolce | `Death Zone` + `AnimationPlayer` | Cykliczny ruch |
| Spadające Obiekty | `RigidBody2D` + `Death Zone` | Fizyka + śmierć |

---

## Elementy UI

### Main Menu (Menu Główne)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/ui/main_menu.tscn` |
| **Skrypt** | `scenes/ui/main_menu.gd` |
| **Typ węzła** | `Control` |

**Przyciski (ze skrótami klawiszowymi):**
- `[P]` PLAY (1-1) - rozpocznij grę od aktualnego poziomu
- `[L]` LEVELS - przejdź do wyboru poziomu
- `[Q]` QUIT - zamknij grę

---

### Level Select (Wybór Poziomu)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/ui/level_select.tscn` |
| **Skrypt** | `scenes/ui/level_select.gd` |
| **Typ węzła** | `Control` |

**Przyciski (ze skrótami klawiszowymi):**
- `[1]` 1-1 - pierwszy poziom
- `[2]` 1-2 - drugi poziom (zablokowany domyślnie)
- `[3]` 1-3 - trzeci poziom (zablokowany)
- `[4]` 1-4 - czwarty poziom (zablokowany)
- `[B]` BACK - powrót do menu głównego

**Uwaga:** Skróty klawiszowe dla zablokowanych poziomów nie działają.

---

### Pause Modal (Menu Pauzy)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/ui/pause_modal.tscn` |
| **Skrypt** | `scenes/ui/pause_modal.gd` |
| **Typ węzła** | `CanvasLayer` (warstwa 10) |
| **Aktywacja** | Klawisz `ESC` |

**Przyciski (ze skrótami klawiszowymi):**
- `[C]` RESUME - kontynuuj grę (lub ESC)
- `[R]` RESTART - zrestartuj poziom
- `[M]` MENU - wróć do menu głównego

---

### Restart Overlay (Nakładka Restartu)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/ui/restart_overlay.tscn` |
| **Skrypt** | `scenes/ui/restart_overlay.gd` |
| **Typ węzła** | `CanvasLayer` (warstwa 5) |
| **Aktywacja** | Automatyczna przy śmierci / `R` |

**Parametry:**
```gdscript
const HOLD_TIME = 0.8        # Czas przytrzymania R
const CIRCLE_RADIUS = 40.0   # Promień wskaźnika
const CIRCLE_WIDTH = 6.0     # Grubość linii
```

---

### Controls Legend (Legenda Sterowania)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/ui/controls_legend.tscn` |
| **Skrypt** | `scenes/ui/controls_legend.gd` |
| **Typ węzła** | `CanvasLayer` (warstwa 5) |
| **Pozycja** | Lewy dolny róg |
| **Toggle** | Klawisz `H` |

**Wyświetlane klawisze:**
- `< >` - Ruch
- `SPACE` - Skok
- `W` - Podwójny skok
- `Q + D` - Dash
- `E` - Ledge grab
- `R` - Restart (hold)
- `ESC` - Pauza

---

### Ability Widget (Tracker Zdolności)

| Właściwość | Wartość |
|------------|---------|
| **Plik** | `scenes/ui/ability_widget.tscn` |
| **Skrypt** | `scenes/ui/ability_widget.gd` |
| **Typ węzła** | `CanvasLayer` |
| **Funkcja** | Pokazuje aktywną zdolność gracza |

**Mechanizm:**
- Nasłuchuje sygnału `player.mask_changed`
- Aktywna zdolność: opacity 1.0, brightness 1.0
- Nieaktywne: opacity 0.3, brightness 0.5

---

## System Audio

### Efekty Dźwiękowe (SFX)
Lokalizacja: `assets/audio/`

| Plik | Dźwięk | Wyzwalacz |
|------|--------|-----------|
| `jump.mp3` | Skok | Pierwszy skok |
| `double_jump.mp3` | Podwójny skok | Drugi skok (maska DOUBLE_JUMP) |
| `dash.mp3` | Dash | Rozpoczęcie dasha |
| `landing.mp3` | Lądowanie | Dotknięcie podłogi po skoku |
| `wall_jump.mp3` | Wall jump | Odbicie od ściany |
| `wall_slide.mp3` | Wall slide | Ślizganie się po ścianie |
| `death.mp3` | Śmierć | Gracz umiera |

### Muzyka Tła
Lokalizacja: `assets/music/`

| Plik | Poziom | Styl |
|------|--------|------|
| `forest_calm.mp3` | 1-1 | Spokojny ambient chiptune |
| `adventure.mp3` | 1-2 | Energiczny retro |

**Konfiguracja:** `scenes/autoload/scene_manager.gd` → `_level_music` dictionary

---

## Warstwy Kolizji

### Definicja Warstw

| Warstwa | Użycie |
|---------|--------|
| 1 | Platformy, ściany, obiekty statyczne |
| 2 | Gracz |

### Konfiguracja Obiektów

| Obiekt | collision_layer | collision_mask |
|--------|-----------------|----------------|
| Gracz | 2 | 1 (domyślna) |
| Platformy | 1 | 0 |
| Level Trigger | 0 | 2 |
| Death Zone | 0 | 2 |
| Ability Pickup | 0 | 2 |
| Podłoga | 1 | 0 |

---

## Szybka Referencja dla Generatora

### Obiekty do Instancjonowania

```gdscript
# Platformy
const SMALL_PLATFORM = preload("res://scenes/forest/platforms/small_platform.tscn")
const MEDIUM_PLATFORM = preload("res://scenes/forest/platforms/medium_platform.tscn")
const LARGE_PLATFORM = preload("res://scenes/forest/platforms/large_platform.tscn")
const FADING_PLATFORM = preload("res://scenes/forest/platforms/fading_platform_small.tscn")
const ANIMATED_PLATFORM = preload("res://scenes/levels/platform.tscn")

# Dekoracje
const SMALL_TREE = preload("res://scenes/forest/trees/small_tree.tscn")
const MEDIUM_TREE_1 = preload("res://scenes/forest/trees/medium_tree_1.tscn")
const MEDIUM_TREE_2 = preload("res://scenes/forest/trees/medium_tree_2.tscn")

# Interaktywne
const LEVEL_TRIGGER = preload("res://scenes/objects/level_trigger.tscn")
const ABILITY_PICKUP = preload("res://scenes/objects/ability_pickup.tscn")
const DESTRUCTABLE_WALL = preload("res://scenes/forest/destructable_wall.tscn")

# Zagrożenia
const DEATH_ZONE = preload("res://scenes/objects/death_zone.tscn")

# Wrogowie
const ENEMY_BATMAN = preload("res://scenes/enemies/enemy_batman.tscn")
const ENEMY_FISH = preload("res://scenes/enemies/enemy_fish.tscn")
const ENEMY_BEETLE = preload("res://scenes/enemies/enemy_beetle.tscn")
```

### Rozmiary Platform (szybki dostęp)

```gdscript
enum PlatformSize {
    SMALL = 50,
    MEDIUM = 104,
    LARGE = 212
}
```

---

## Notatki dla Rozwoju

1. **Brak systemu obrażeń** - gracz nie ma HP, jedynie restart
2. **Collectibles (Ability Pickup)** - zdolności można zbierać w poziomach, zapisywane w GameData
3. **Prosty model kolizji** - prostokąty, brak skomplikowanych kształtów
4. **One-way platforms** - gracz może przeskakiwać od dołu
5. **Modułowa architektura** - łatwe do instancjonowania prefaby
6. **System śmierci** - `_is_dead` blokuje physics, `die()` dodaje animację (obrót 90°) i czerwony overlay
7. **Ledge Grab** - maska zdefiniowana, wall slide + wall jump zaimplementowane
8. **Keyboard shortcuts** - wszystkie menu mają skróty klawiszowe w formacie `[X]`
9. **Level Timer** - czas mierzony od lądowania do śmierci/ukończenia, wyświetlany real-time w lewym górnym rogu (czarny tekst)
10. **Centered overlays** - komunikaty śmierci/sukcesu używają CenterContainer dla prawidłowego centrowania
11. **Szybkie przejścia** - tranzycja scen 0.25s, overlay ukończenia 1s
12. **Destructable Walls** - ściany niszczone przez dash/touch/jump-through, opcjonalny respawn
13. **Fading Platforms** - platformy zanikające po wejściu gracza, opcjonalny respawn
14. **Wall Hold Timer** - gracz może trzymać się ściany przez max 1.5s przed spadnięciem (maska LEDGE_GRAB)
15. **Level Intro** - fade-in 0.4s, natychmiast fade-out 1.5s, ID poziomu czarny tekst (LabelSettings)
16. **System SFX** - 7 efektów dźwiękowych w `assets/audio/` (jump, double_jump, dash, landing, wall_jump, wall_slide, death)
17. **Muzyka w tle** - 2 utwory w `assets/music/`, odtwarzane przez SceneManager, zapętlone, -10dB
18. **Obsługa gamepada** - wszystkie akcje mają bindingi dla kontrolera Xbox/PlayStation, device=-1
19. **Ruchome platformy** - `AnimatableBody2D` w `scenes/levels/platform.tscn` (57x20 px)
