extends Node

## Game (autoload): estado y orquestación de movimientos

const BoardModel = preload("res://scripts/BoardModel.gd")
const MoveValidator = preload("res://scripts/MoveValidator.gd")

signal move_applied(piece, from_idx: int, to_idx: int)
signal invalid_move(reason: String)
signal turn_changed(is_white_turn: bool)
signal capture_made(attacker_team: String, attacker_id: String, victim_team: String, victim_id: String)

var model: BoardModel

func _ready() -> void:
	# Autoload singleton; el nodo ya vive bajo /root/Game
	model = BoardModel.new()
	add_child(model)

func initialize(white_pieces: Array, black_pieces: Array) -> void:
	model.initialize(white_pieces, black_pieces)
	emit_signal("turn_changed", model.turn)

func request_move(piece, from_pos: Vector2, to_pos: Vector2, index_map: Dictionary, _is_capture_hint: bool) -> void:
	# Valida y aplica movimiento; este método no conoce selectores ni input
	if piece == null:
		emit_signal("invalid_move", "No piece selected")
		return
	var dest_index := _index_of(index_map, to_pos)
	if dest_index == 0:
		emit_signal("invalid_move", "Destination out of board")
		return
	var dest_piece = _piece_at_index(dest_index)
	var is_capture := dest_piece != null
	var new_index: int = MoveValidator.move_index(piece.ficha, from_pos, to_pos, index_map, is_capture)
	if new_index == 0:
		emit_signal("invalid_move", "Invalid move by rules")
		return
	# Validar obstrucciones con el roadmap
	var road_map := MoveValidator.obstructions_indices(piece.ficha, from_pos, to_pos, index_map, is_capture)
	# Si no es caballo/rey ni un peón capturando, filtrar ocupación intermedia
	var is_knight: bool = piece.ficha.id == "N"
	var is_king: bool = piece.ficha.id == "K"
	var is_pawn_capture: bool = piece.ficha.id == "P" and is_capture
	if not is_knight and not is_king and not is_pawn_capture:
		for idx in road_map:
			if idx == new_index:
				continue
			if idx in model.full_map:
				emit_signal("invalid_move", "Path obstructed")
				return
	# Capturas: si destino ocupado por rival, permitir; si ocupado por aliado, invalidar
	if dest_piece != null:
		if dest_piece.ficha.team == piece.ficha.team:
			emit_signal("invalid_move", "Blocked by ally")
			return
		# eliminar pieza capturada del modelo
		model.remove_piece_index(dest_piece.ficha.index)
		# Emitir evento de captura antes de liberar el nodo
		var attacker_team: String = piece.ficha.team
		var attacker_id: String = piece.ficha.id
		var victim_team: String = dest_piece.ficha.team
		var victim_id: String = dest_piece.ficha.id
		emit_signal("capture_made", attacker_team, attacker_id, victim_team, victim_id)
		# Retirar de colecciones del main para evitar accesos posteriores
		var mains := get_tree().get_nodes_in_group("main")
		if mains.size() > 0:
			var main = mains[0]
			if dest_piece in main.white_pieces:
				main.white_pieces.erase(dest_piece)
			if dest_piece in main.black_pieces:
				main.black_pieces.erase(dest_piece)
		dest_piece.queue_free()
	# Aplica en pieza (pos y index) y modelo
	var old_index := _index_of(index_map, from_pos)
	piece.move_piece(from_pos, to_pos, index_map, null, model.full_map, is_capture)
	model.update_piece_index(old_index, new_index)
	emit_signal("move_applied", piece, old_index, new_index)
	# Cambiar turno
	model.turn = not model.turn
	emit_signal("turn_changed", model.turn)

static func _index_of(mapa: Dictionary, pos: Vector2) -> int:
	for k in mapa.keys():
		if mapa[k] == pos:
			return k
	return 0

func _piece_at_index(idx: int):
	# Busca pieza viva en índice, con acceso seguro al nodo main
	var mains := get_tree().get_nodes_in_group("main")
	if mains.size() == 0:
		return null
	var main = mains[0]
	for p in main.white_pieces:
		if p.ficha.index == idx:
			return p
	for p in main.black_pieces:
		if p.ficha.index == idx:
			return p
	return null

func piece_at_selector_index(selector) -> Node:
	var idx = selector.indice
	return _piece_at_index(idx)
