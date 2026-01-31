# Fizyka i Mechanika Gry

Ten dokument opisuje wszystkie parametry fizyczne i mechaniki ruchu gracza. Stanowi podstawę do obliczeń przy generowaniu proceduralnych poziomów.

---

## Parametry Ruchu Gracza

| Parametr | Wartość | Jednostka | Opis |
|----------|---------|-----------|------|
| `SPEED` | 120.0 | px/s | Bazowa prędkość ruchu poziomego |
| `BASE_JUMP_VELOCITY` | -370.0 | jednostki | Siła skoku (ujemna = w górę) |
| `DASH_SPEED` | 400.0 | px/s | Prędkość podczas dashu |
| `DASH_DURATION` | 0.15 | sekundy | Czas trwania dashu |
| `DASH_COOLDOWN` | 0.5 | sekundy | Czas odnowienia dashu |
| `max_jump_count` | 2 | ilość | Maksymalna liczba skoków w powietrzu |

**Plik źródłowy:** `scenes/player.gd`

---

## System Masek (Abilities)

Gracz może wyposażyć różne maski, które modyfikują jego zdolności:

| Maska | Enum | Efekt | Aktywacja |
|-------|------|-------|-----------|
| Brak | `Mask.NONE` | Tylko pojedynczy skok | Domyślne |
| Podwójny Skok | `Mask.DOUBLE_JUMP` | Pozwala na 2 skoki w powietrzu | Klawisz `W` |
| Dash | `Mask.DASH` | Szybki ruch poziomy (400 px/s) | Klawisze `Q + D` |

---

## Obliczenia Fizyczne

### Zasięg Skoku

```
Siła skoku: 370 jednostek w górę
Grawitacja: standardowa Godot (980 px/s²)

Przybliżona wysokość skoku: ~70 px
Przybliżony zasięg poziomy (z pełnym biegiem): ~140 px
```

### Zasięg Dashu

```
Prędkość dashu: 400 px/s
Czas trwania: 0.15 s
Grawitacja podczas dashu: 10% normalnej

Zasięg poziomy dashu: 400 * 0.15 = 60 px
```

### Maksymalny Zasięg z Podwójnym Skokiem i Dashem

```
Pojedynczy skok + bieg: ~140 px poziomo
Podwójny skok + bieg: ~280 px poziomo
Podwójny skok + dash: ~340 px poziomo (maksymalny zasięg)
```

---

## Parametry Kolizji Gracza

| Parametr | Wartość |
|----------|---------|
| Typ węzła | `CharacterBody2D` |
| Warstwa kolizji | 2 |
| Kształt | `CapsuleShape2D` |
| Promień kapsuły | 9.0 px |
| Wysokość kapsuły | 20.0 px |
| Rozmiar sprite'a | 24x24 px |

---

## Mechanika Wejścia na Poziom (Entry Mode)

Gdy gracz wchodzi na poziom:

1. Przeźroczystość ustawiona na 0.6
2. Gracz spada z góry (nie może sterować)
3. Po wylądowaniu emitowany jest sygnał `landed`
4. Przeźroczystość wraca do 1.0
5. Gracz odzyskuje kontrolę

---

## Mechanika Śmierci

**Jedyny sposób śmierci:** Spadnięcie poza dolną granicę świata (`WorldBoundaryShape2D`)

**Proces restartu:**
1. Pojawia się `RestartOverlay`
2. Gracz musi przytrzymać `R` przez 0.8 sekundy
3. Wyświetlany jest okrągły wskaźnik postępu
4. Po 0.8s poziom się restartuje

---

## Ważne Wartości dla Generatora Poziomów

```gdscript
# Minimalna odległość między platformami (gracz może przeskoczyć)
const MIN_PLATFORM_GAP = 50  # px

# Maksymalna odległość bez masek
const MAX_GAP_NO_MASK = 140  # px

# Maksymalna odległość z podwójnym skokiem
const MAX_GAP_DOUBLE_JUMP = 280  # px

# Maksymalna odległość z dashem
const MAX_GAP_WITH_DASH = 340  # px

# Maksymalna wysokość skoku
const MAX_JUMP_HEIGHT = 70  # px

# Maksymalna wysokość z podwójnym skokiem
const MAX_DOUBLE_JUMP_HEIGHT = 140  # px
```

---

## Notatki Techniczne

- Gracz używa `move_and_slide()` do ruchu
- Grawitacja pobierana przez `get_gravity()` (domyślna Godot)
- Podczas dashu grawitacja zredukowana do 10%
- Platformy mają `one_way_collision = true` (można przeskakiwać od dołu)
- Kamera podąża za graczem (zoom 3x)
