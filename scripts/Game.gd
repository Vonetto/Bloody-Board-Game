extends Node

## Game (autoload): estado y orquestación de movimientos

const BoardModel = preload("res://scripts/BoardModel.gd")
const MoveValidator = preload("res://scripts/MoveValidator.gd")
const Types = preload("res://scripts/Types.gd")

signal move_applied(piece, from_idx: int, to_idx: int)
signal invalid_move(reason: String)
signal turn_changed(is_white_turn: bool)
signal capture_made(attacker_team: String, attacker_id: String, victim_team: String, victim_id: String)
signal fight_requested(attacker, defender, from_idx: int, to_idx: int)
signal fight_resolved(result: String, attacker, defender, from_idx: int, to_idx: int)

var model: BoardModel
var white_pieces: Array = []
var black_pieces: Array = []
var index_to_piece: Dictionary = {}
var is_fighting: bool = false
var fighting_enabled: bool = false # Activar cuando el módulo de pelea esté listo

# Movimiento pendiente mientras se resuelve la pelea
var _pending_attacker = null
var _pending_defender = null
var _pending_from_idx: int = 0
var _pending_to_idx: int = 0
var _pending_index_map: Dictionary = {}

func _ready() -> void:
	# Autoload singleton; el nodo ya vive bajo /root/Game
	model = BoardModel.new()
	add_child(model)

func initialize(white_pieces_in: Array, black_pieces_in: Array) -> void:
	white_pieces = white_pieces_in
	black_pieces = black_pieces_in
	model.initialize(white_pieces, black_pieces)
	# Construir mapa índice→pieza para O(1)
	index_to_piece.clear()
	for p in white_pieces:
		index_to_piece[p.ficha.index] = p
	for p in black_pieces:
		index_to_piece[p.ficha.index] = p
	emit_signal("turn_changed", model.turn)

func request_move(piece, from_pos: Vector2, to_pos: Vector2, index_map: Dictionary, _is_capture_hint: bool) -> void:
	# Valida y aplica movimiento; este método no conoce selectores ni input
	if piece == null:
		emit_signal("invalid_move", "No piece selected")
		return
	if is_fighting:
		# Ignorar input durante pelea para no spamear HUD del tablero
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
		# Si el modo pelea está activo, solicitar pelea en lugar de capturar directo
		if fighting_enabled:
			is_fighting = true
			_pending_attacker = piece
			_pending_defender = dest_piece
			_pending_from_idx = _index_of(index_map, from_pos)
			_pending_to_idx = dest_index
			_pending_index_map = index_map.duplicate()
			emit_signal("fight_requested", piece, dest_piece, _pending_from_idx, _pending_to_idx)
			return
		# eliminar pieza capturada del modelo
		if dest_piece.ficha and typeof(dest_piece.ficha.index) == TYPE_INT:
			model.remove_piece_index(dest_piece.ficha.index)
		# Emitir evento de captura antes de liberar el nodo
		var attacker_team: String = ("White" if piece.ficha.team == Types.Team.White else "Black")
		var attacker_id: String = _piece_type_to_string(piece.ficha.id)
		var victim_team: String = ("White" if dest_piece.ficha.team == Types.Team.White else "Black")
		var victim_id: String = _piece_type_to_string(dest_piece.ficha.id)
		Logger.d("[Game] Capture: %s %s eats %s %s at index %d" % [attacker_team, attacker_id, victim_team, victim_id, dest_index])
		emit_signal("capture_made", attacker_team, attacker_id, victim_team, victim_id)
		# Eliminar de nuestras colecciones locales
		if dest_piece in white_pieces:
			white_pieces.erase(dest_piece)
		if dest_piece in black_pieces:
			black_pieces.erase(dest_piece)
		# Quitar del índice → pieza
		index_to_piece.erase(dest_piece.ficha.index)
		dest_piece.queue_free()
	# Aplica en pieza (pos y index) y modelo
	var old_index := _index_of(index_map, from_pos)
	# Actualizar vista (posición) y estado del nodo
	var to_pos_grid: Vector2 = index_map[new_index]
	piece.global_position = Vector2(to_pos_grid.x - 48, to_pos_grid.y + 50)
	piece.ficha.index = new_index
	model.update_piece_index(old_index, new_index)
	# Actualizar índice → pieza
	index_to_piece.erase(old_index)
	index_to_piece[new_index] = piece
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
	return index_to_piece.get(idx, null)

# Resolver pelea desde el módulo de fighting. result puede ser:
#  "attacker_wins", "defender_wins", "defender_survives" (o "timeout_survive")
func resolve_fight(result: String) -> void:
	if not is_fighting:
		return
	var attacker = _pending_attacker
	var defender = _pending_defender
	var from_idx: int = _pending_from_idx
	var to_idx: int = _pending_to_idx
	var index_map := _pending_index_map

	# Limpia estado fighting al final
	var cleanup = func():
		is_fighting = false
		_pending_attacker = null
		_pending_defender = null
		_pending_from_idx = 0
		_pending_to_idx = 0
		_pending_index_map = {}

	# Notificar resultado a oyentes
	emit_signal("fight_resolved", result, attacker, defender, from_idx, to_idx)

	match result:
		"attacker_wins":
			# Captura normal del defensor y mover atacante a destino
			if defender and defender.ficha:
				model.remove_piece_index(defender.ficha.index)
				if defender in white_pieces:
					white_pieces.erase(defender)
				if defender in black_pieces:
					black_pieces.erase(defender)
				index_to_piece.erase(defender.ficha.index)
				defender.queue_free()
			# Mover atacante
			var to_pos_grid: Vector2 = index_map[to_idx]
			attacker.global_position = Vector2(to_pos_grid.x - 48, to_pos_grid.y + 50)
			attacker.ficha.index = to_idx
			model.update_piece_index(from_idx, to_idx)
			index_to_piece.erase(from_idx)
			index_to_piece[to_idx] = attacker
			emit_signal("move_applied", attacker, from_idx, to_idx)
			model.turn = not model.turn
			emit_signal("turn_changed", model.turn)
		"defender_wins":
			# El atacante muere; el defensor queda en su sitio
			if attacker and attacker.ficha:
				model.remove_piece_index(attacker.ficha.index)
				if attacker in white_pieces:
					white_pieces.erase(attacker)
				if attacker in black_pieces:
					black_pieces.erase(attacker)
				index_to_piece.erase(attacker.ficha.index)
				attacker.queue_free()
			# Turno cambia
			model.turn = not model.turn
			emit_signal("turn_changed", model.turn)
		"defender_survives", "timeout_survive":
			# No hay cambios de tablero; atacante "pierde turno"
			model.turn = not model.turn
			emit_signal("turn_changed", model.turn)
		_:
			# Resultado desconocido: no cambiar nada, reanudar
			Logger.w("[Game] Unknown fight result: %s" % result)
	cleanup.call()

func piece_at_selector_index(selector) -> Node:
	var idx = selector.indice
	return _piece_at_index(idx)
