# Debug gracza

Pomóż zdiagnozować problemy z graczem.

## Sprawdź
1. Przeczytaj `scenes/player.gd` - logika ruchu
2. Przeczytaj `scenes/player.tscn` - struktura node'ów
3. Sprawdź parametry:
   - SPEED: 400.0
   - BASE_JUMP_VELOCITY: -550.0
   - EXTRA_JUMP_FORCE: -700.0
   - MAX_JUMP_HOLD_TIME: 0.6s

## Typowe problemy
- Gracz nie skacze → sprawdź `is_on_floor()` i Input Map
- Gracz przelatuje przez podłogę → sprawdź collision layers/masks
- Animacja nie działa → sprawdź AnimatedSprite2D i autoplay

## Input Map (domyślne)
- `ui_left` / `ui_right` - ruch poziomy
- `ui_accept` - skok
