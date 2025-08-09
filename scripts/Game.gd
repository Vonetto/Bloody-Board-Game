extends Node

## Game (autoload): estado y orquestación de movimientos

const BoardModel = preload("res://scripts/BoardModel.gd")
const MoveValidator = preload("res://scripts/MoveValidator.gd")
const Types = preload("res://scripts/Types.gd")

signal move_applied(piece, from_idx: int, to_idx: int)
signal invalid_move(reason: String)
signal turn_changed(is_white_turn: bool)
signal capture_made(attacker_team: String, attacker_id: String, victim_team: String, victim_id: String)

var model: BoardModel
var white_pieces: Array = []
var black_pieces: Array = []

func _ready() -> void:
	# Autoload singleton; el nodo ya vive bajo /root/Game
	model = BoardModel.new()
	add_child(model)

func initialize(white_pieces_in: Array, black_pieces_in: Array) -> void:
	white_pieces = white_pieces_in
	black_pieces = black_pieces_in
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
	var is_knight: bool = piece.ficha.id == Types.PieceType.N
	var is_king: bool = piece.ficha.id == Types.PieceType.K
	var is_pawn_capture: bool = piece.ficha.id == Types.PieceType.P and is_capture
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
		if dest_piece.ficha and typeof(dest_piece.ficha.index) == TYPE_INT:
			model.remove_piece_index(dest_piece.ficha.index)
		# Emitir evento de captura antes de liberar el nodo
		var attacker_team: String = ("White" if piece.ficha.team == Types.Team.White else "Black")
		var attacker_id: String = _piece_type_to_string(piece.ficha.id)
		var victim_team: String = ("White" if dest_piece.ficha.team == Types.Team.White else "Black")
		var victim_id: String = _piece_type_to_string(dest_piece.ficha.id)
		emit_signal("capture_made", attacker_team, attacker_id, victim_team, victim_id)
		# Eliminar de nuestras colecciones locales
		if dest_piece in white_pieces:
			white_pieces.erase(dest_piece)
		if dest_piece in black_pieces:
			black_pieces.erase(dest_piece)
		dest_piece.queue_free()
	# Aplica en pieza (pos y index) y modelo
	var old_index := _index_of(index_map, from_pos)
	piece.move_piece(from_pos, to_pos, index_map, null, model.full_map, is_capture)
	model.update_piece_index(old_index, new_index)
	emit_signal("move_applied", piece, old_index, new_index)
	# Cambiar turno
	model.turn = not model.turn
	emit_signal("turn_changed", model.turn)

func _piece_type_to_string(t: int) -> String:
	match t:
		Types.PieceType.P:
			return "P"
		Types.PieceType.N:
			return "N"
		Types.PieceType.B:
			return "B"
		Types.PieceType.R:
			return "R"
		Types.PieceType.Q:
			return "Q"
		Types.PieceType.K:
			return "K"
	return str(t)

static func _index_of(mapa: Dictionary, pos: Vector2) -> int:
	for k in mapa.keys():
		if mapa[k] == pos:
			return k
	return 0

func _piece_at_index(idx: int):
	# Busca pieza viva en índice en nuestras colecciones locales
	for p in white_pieces:
		if p.ficha.index == idx:
			return p
	for p in black_pieces:
		if p.ficha.index == idx:
			return p
	return null

func piece_at_selector_index(selector) -> Node:
	var idx = selector.indice
	return _piece_at_index(idx)
