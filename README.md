# Bloody Board

Bloody Board es un juego creado por Francisco Faundez (FranciscoFaundez) , Sebastian Jana (SebaJana) y Vicente Onetto (Vonetto).  
Este proyecto nace de mezclar dos géneros usualmente inconexos como lo son los juegos de mesa y los "fighting games".  
Keep an eye in order to witness the magic

## Arquitectura (Tablero de Ajedrez)

- Game (autoload): Orquestador del tablero. Valida y aplica movimientos, maneja capturas, cambia el turno y emite señales.
  - Señales:
    - `move_applied(piece, from_idx, to_idx)`
    - `invalid_move(reason)`
    - `turn_changed(is_white_turn)`
    - `capture_made(attacker_team, attacker_id, victim_team, victim_id)`
- BoardModel: Fuente de verdad del tablero. Mantiene `index_map`, `full_map` y el turno.
- MoveValidator: Funciones puras para validar movimientos (P, N, B, R, Q, K) y obstrucciones.
- InputController: Centraliza el input de mouse y teclado, emite `select_origin`, `select_destination`, `hover_index_changed`, `cancel_selection`.
- SelectorView (`scripts/Selector.gd`): Vista del selector (color/posición). No maneja input.
- SelectorController: Helpers estáticos para mostrar/ocultar y resetear selectores según turno.
- StatusHud: HUD de mensajes con cola (turno, movimiento inválido, captura).
- ViewHelpers: Utilidades de vista (screen→world y nearest-index).
- PieceFactory: Instanciación de piezas iniciales fuera de la escena de tablero.

## Convenciones de físicas (2D Physics Layers)

- Capas reservadas para combate:
  - Capa 5: Hurtbox del Jugador 1
  - Capa 6: Hurtbox del Jugador 2
  - Capa 7: Hitbox del Jugador 1 (mask → capa 6)
  - Capa 8: Hitbox del Jugador 2 (mask → capa 5)
- Nota: Los `HitboxArea` deben tener `monitoring = true`, y los `HurtboxArea` `monitorable = true`.

## Estructura de carpetas (scripts)

- `scripts/game_logic`: reglas del tablero, modelos, tipos y piezas
- `scripts/systems`: orquestadores/autoloads (Fighting, input, logger)
- `scripts/ui`: HUDs, selector y utilidades visuales
- `scripts/fighters`: lógica de luchadores (BaseFighter)
- `scripts/tools`: herramientas (HitboxEditor)
- `scripts/debug`: utilidades de debug

## Nomenclatura

- Archivos en snake_case.
- Scripts principales con `class_name` cuando aplique.

## Flujo de datos

1) InputController detecta un click/tecla y emite `select_origin` o `select_destination` con el índice.
2) game_logic escucha estas señales, resuelve la pieza seleccionada mediante `Game.piece_at_selector_index` y llama `Game.request_move(...)`.
3) Game usa MoveValidator y BoardModel para validar el movimiento, comprobar obstrucciones, y aplicar el resultado.
4) Si hay captura, `capture_made` se emite primero; luego, si procede, `move_applied` y `turn_changed`.
5) game_logic reacciona a estas señales para actualizar la UI (selectores y HUD).

## Señales clave

- `Game.capture_made(attacker_team, attacker_id, victim_team, victim_id)`: El HUD muestra “X come Y”.
- `Game.invalid_move(reason)`: El selector parpadea rojo y el HUD muestra “Movimiento inválido”.
- `Game.turn_changed(is_white_turn)`: El HUD muestra “Turno Blancas/Negras”.

## Estándares de código

- Enums globales `Types.Team` y `Types.PieceType` (sin strings sueltas).
- `PieceData` (Resource) tipa el estado de cada pieza.
- Lógica en Game/BoardModel/MoveValidator, vista en scripts de UI.
- Señales y helpers para acoplamiento bajo.

## Desarrollo

- Logger (autoload) con métodos `Logger.d/i/w/e(...)`.
- `PieceFactory.setup(tablero, game_logic)` instancia el estado inicial.
- `BoardModel.index_map` es la única fuente de `index_map`.
