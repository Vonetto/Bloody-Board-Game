extends Node

## Utilidades de tablero: generación y conversiones de índices/posiciones

class_name BoardUtils

static func generate_index_map() -> Dictionary:
    # Mapa de índices 1..64 a posiciones Vector2 con el mismo origen y espaciado usado en el proyecto
    # Índice 1 = (48, -48), incremento de 96 px por casilla, 8 columnas, 8 filas
    var index_map: Dictionary = {}
    var tile_size := 96
    var origin := Vector2(48, -48)
    for i in range(1, 65):
        var col := int((i - 1) % 8) # 0..7
        var row := int((i - 1) / 8) # 0..7
        var x := origin.x + col * tile_size
        var y := origin.y - row * tile_size
        index_map[i] = Vector2(x, y)
    return index_map

static func index_to_position(index: int) -> Vector2:
    return generate_index_map().get(index, Vector2.ZERO)

static func position_to_index(pos: Vector2) -> int:
    # Convierte coordenadas de mundo a índice aproximado de casilla.
    # Se adapta a escenarios donde Y es negativa hacia arriba y hay cámara/zoom.
    var tile_size := 96.0
    var origin := Vector2(48, -48)
    var colf := (pos.x - origin.x) / tile_size
    var rowf := (origin.y - pos.y) / tile_size
    var col := int(floor(colf + 0.5))
    var row := int(floor(rowf + 0.5))
    if col < 0: col = 0
    if col > 7: col = 7
    if row < 0: row = 0
    if row > 7: row = 7
    return row * 8 + col + 1


