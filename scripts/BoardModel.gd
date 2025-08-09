extends Node

## BoardModel: estado central del tablero (mapa de índices y ocupación)

class_name BoardModel

const BoardUtils = preload("res://utils/BoardUtils.gd")

var index_map: Dictionary = {}
var full_map: Array = []  # lista de índices ocupados (1..64)
var turn: bool = true

func initialize(white_pieces: Array, black_pieces: Array) -> void:
    index_map = BoardUtils.generate_index_map()
    refresh_full_map(white_pieces, black_pieces)

func refresh_full_map(white_pieces: Array, black_pieces: Array) -> void:
    full_map.clear()
    for p in white_pieces:
        full_map.append(p.ficha.index)
    for p in black_pieces:
        full_map.append(p.ficha.index)
    full_map.sort()

func remove_piece_index(piece_index: int) -> void:
    var idx := full_map.find(piece_index)
    if idx != -1:
        full_map.remove_at(idx)

func update_piece_index(old_index: int, new_index: int) -> void:
    var idx := full_map.find(old_index)
    if idx != -1:
        full_map[idx] = new_index
    full_map.sort()

func is_occupied(index: int) -> bool:
    return index in full_map

func get_position(index: int) -> Vector2:
    return index_map.get(index, Vector2.ZERO)


