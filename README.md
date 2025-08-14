# Bloody Board

Bloody Board es un juego creado por Francisco Faundez (FranciscoFaundez) , Sebastian Jana (SebaJana) y Vicente Onetto (Vonetto).  
Este proyecto nace de mezclar dos géneros usualmente inconexos como lo son los juegos de mesa y los "fighting games".  
Keep an eye in order to witness the magic

---

### Características Principales

*   **Ajedrez con una Vuelta de Tuerca:** En lugar de capturas instantáneas, las piezas se enfrentan en un combate de lucha en 2D en tiempo real donde tu habilidad determina el resultado.
*   **Combate Táctico con Estamina:** Gestiona tu estamina para atacar, esquivar y usar habilidades. No se trata solo de atacar sin pensar, sino de administrar tus recursos para superar a tu oponente.
*   **Salud Persistente:** Las piezas conservan el daño entre peleas. Una victoria costosa puede dejar a tu pieza más fuerte vulnerable en el siguiente encuentro, añadiendo una profunda capa estratégica.
*   **Habilidades Únicas por Pieza:** Cada tipo de pieza (Peón, Torre, Rey, etc.) tiene un estilo de lucha, estadísticas y habilidades únicas que reflejan su rol en el ajedrez.
*   **Diseño Detallado:** Todas las mecánicas de las piezas están documentadas en el archivo `GAME_DESIGN.md`.

### Estado del Proyecto

El proyecto se encuentra en una fase de desarrollo activa.

**Implementado:**
*   ✅ Lógica de ajedrez base (movimiento, turnos, validación).
*   ✅ Pieza Peón con sus funciones base.
*   ✅ Módulo de combate 1v1.
*   ✅ Sistema universal de **Estamina** (lógica y UI).
*   ✅ **Persistencia de salud** entre combates.
*   ✅ Documento de diseño de piezas detallado.

**Siguientes Pasos:**
*   ➡️ Implementación del sistema de **Block y Parry**.
*   ➡️ Implementación de las piezas restantes (Torre, Caballo, Alfil, Reina, Rey) con sus habilidades únicas.
*   ➡️ Creación de un menú principal.
*   ➡️ Desarrollo de una IA para el modo de un jugador.

---

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

### Arquitectura (Módulo de Combate)

- **Fighting (autoload):** Orquestador principal del modo de combate. Escucha la señal `fight_requested` de `Game`, instancia la arena, los luchadores, el HUD y el resolver. Gestiona el ciclo de vida completo del combate, desde el inicio hasta la resolución.
- **FightingModel:** La fuente de verdad para el estado del combate *actual*. Mantiene las estadísticas (HP, ataque, etc.) de los dos luchadores y es responsable de aplicar el daño cuando se lo indica el orquestador.
- **FightResolver:** Actúa como un "árbitro" imparcial. Se conecta a las señales de los luchadores para detectar colisiones válidas (un `hitbox` golpeando un `hurtbox`) y emite una señal `hit_resolved` para que el orquestador aplique la lógica del juego.
- **BaseFighter:** La clase base para todas las piezas de combate. Implementa toda la lógica común: movimiento, físicas, animaciones, el sistema de estamina y la emisión de señales (`hit_landed`, `stamina_changed`).
- **FightHud:** La interfaz de usuario del combate. Muestra las barras de vida y estamina, el temporizador y los mensajes de estado. Se actualiza escuchando las señales del `FightingModel` y de los `BaseFighter`.

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
