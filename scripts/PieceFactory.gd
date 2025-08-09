extends Node

class_name PieceFactory

const Types = preload("res://scripts/Types.gd")

static func setup(tablero: Node, game_logic: Node) -> void:
	var square_size: Vector2 = tablero.square_size if tablero.has_method("get") or tablero.has_variable("square_size") else Vector2(96, -96)

	# Preloads de escenas
	var W = {
		"P": preload("res://Chess_Pieces/peon.tscn"),
		"B": preload("res://Chess_Pieces/bishop.tscn"),
		"R": preload("res://Chess_Pieces/rook.tscn"),
		"N": preload("res://Chess_Pieces/knight.tscn"),
		"Q": preload("res://Chess_Pieces/queen.tscn"),
		"K": preload("res://Chess_Pieces/king.tscn")
	}
	var B = {
		"P": preload("res://Chess_Pieces/Bpeon.tscn"),
		"B": preload("res://Chess_Pieces/Bbishop.tscn"),
		"R": preload("res://Chess_Pieces/Brook.tscn"),
		"N": preload("res://Chess_Pieces/Bknight.tscn"),
		"Q": preload("res://Chess_Pieces/Bqueen.tscn"),
		"K": preload("res://Chess_Pieces/Bking.tscn")
	}

	# Blancas
	for i in range(8):
		var p = W["P"].instantiate()
		tablero.add_child(p)
		p.global_position = Vector2(i * square_size.x, 1 * square_size.y)
		p.ficha.team = Types.Team.White
		p.ficha.pos = char(65 + i) + "2"
		p.ficha.id = Types.PieceType.P
		p.ficha.index = i + 9
		game_logic.white_pieces.append(p)

	var wb1 = W["B"].instantiate(); tablero.add_child(wb1)
	wb1.global_position = Vector2(2 * square_size.x, 0 * square_size.y)
	wb1.ficha.team = Types.Team.White; wb1.ficha.pos = "C1"; wb1.ficha.id = Types.PieceType.B; wb1.ficha.index = 3
	game_logic.white_pieces.append(wb1)
	var wb2 = W["B"].instantiate(); tablero.add_child(wb2)
	wb2.global_position = Vector2(5 * square_size.x, 0 * square_size.y)
	wb2.ficha.team = Types.Team.White; wb2.ficha.pos = "F1"; wb2.ficha.id = Types.PieceType.B; wb2.ficha.index = 6
	game_logic.white_pieces.append(wb2)

	var wr1 = W["R"].instantiate(); tablero.add_child(wr1)
	wr1.global_position = Vector2(0 * square_size.x, 0 * square_size.y)
	wr1.ficha.team = Types.Team.White; wr1.ficha.pos = "A1"; wr1.ficha.id = Types.PieceType.R; wr1.ficha.index = 1
	game_logic.white_pieces.append(wr1)
	var wr2 = W["R"].instantiate(); tablero.add_child(wr2)
	wr2.global_position = Vector2(7 * square_size.x, 0 * square_size.y)
	wr2.ficha.team = Types.Team.White; wr2.ficha.pos = "H1"; wr2.ficha.id = Types.PieceType.R; wr2.ficha.index = 8
	game_logic.white_pieces.append(wr2)

	var wn1 = W["N"].instantiate(); tablero.add_child(wn1)
	wn1.global_position = Vector2(1 * square_size.x, 0 * square_size.y)
	wn1.ficha.team = Types.Team.White; wn1.ficha.pos = "B1"; wn1.ficha.id = Types.PieceType.N; wn1.ficha.index = 2
	game_logic.white_pieces.append(wn1)
	var wn2 = W["N"].instantiate(); tablero.add_child(wn2)
	wn2.global_position = Vector2(6 * square_size.x, 0 * square_size.y)
	wn2.ficha.team = Types.Team.White; wn2.ficha.pos = "G1"; wn2.ficha.id = Types.PieceType.N; wn2.ficha.index = 7
	game_logic.white_pieces.append(wn2)

	var wq = W["Q"].instantiate(); tablero.add_child(wq)
	wq.global_position = Vector2(3 * square_size.x, 0 * square_size.y)
	wq.ficha.team = Types.Team.White; wq.ficha.pos = "D1"; wq.ficha.id = Types.PieceType.Q; wq.ficha.index = 4
	game_logic.white_pieces.append(wq)

	var wk = W["K"].instantiate(); tablero.add_child(wk)
	wk.global_position = Vector2(4 * square_size.x, 0 * square_size.y)
	wk.ficha.team = Types.Team.White; wk.ficha.pos = "E1"; wk.ficha.id = Types.PieceType.K; wk.ficha.index = 5
	game_logic.white_pieces.append(wk)

	# Negras
	for i in range(8):
		var bp = B["P"].instantiate()
		tablero.add_child(bp)
		bp.global_position = Vector2(i * square_size.x, 6 * square_size.y)
		bp.ficha.team = Types.Team.Black
		bp.ficha.pos = char(65 + i) + "7"
		bp.ficha.id = Types.PieceType.P
		bp.ficha.index = i + 49
		game_logic.black_pieces.append(bp)

	var bb1 = B["B"].instantiate(); tablero.add_child(bb1)
	bb1.global_position = Vector2(2 * square_size.x, 7 * square_size.y)
	bb1.ficha.team = Types.Team.Black; bb1.ficha.pos = "C8"; bb1.ficha.id = Types.PieceType.B; bb1.ficha.index = 59
	game_logic.black_pieces.append(bb1)
	var bb2 = B["B"].instantiate(); tablero.add_child(bb2)
	bb2.global_position = Vector2(5 * square_size.x, 7 * square_size.y)
	bb2.ficha.team = Types.Team.Black; bb2.ficha.pos = "F8"; bb2.ficha.id = Types.PieceType.B; bb2.ficha.index = 62
	game_logic.black_pieces.append(bb2)

	var br1 = B["R"].instantiate(); tablero.add_child(br1)
	br1.global_position = Vector2(0 * square_size.x, 7 * square_size.y)
	br1.ficha.team = Types.Team.Black; br1.ficha.pos = "A8"; br1.ficha.id = Types.PieceType.R; br1.ficha.index = 57
	game_logic.black_pieces.append(br1)
	var br2 = B["R"].instantiate(); tablero.add_child(br2)
	br2.global_position = Vector2(7 * square_size.x, 7 * square_size.y)
	br2.ficha.team = Types.Team.Black; br2.ficha.pos = "H8"; br2.ficha.id = Types.PieceType.R; br2.ficha.index = 64
	game_logic.black_pieces.append(br2)

	var bn1 = B["N"].instantiate(); tablero.add_child(bn1)
	bn1.global_position = Vector2(1 * square_size.x, 7 * square_size.y)
	bn1.ficha.team = Types.Team.Black; bn1.ficha.pos = "B8"; bn1.ficha.id = Types.PieceType.N; bn1.ficha.index = 58
	game_logic.black_pieces.append(bn1)
	var bn2 = B["N"].instantiate(); tablero.add_child(bn2)
	bn2.global_position = Vector2(6 * square_size.x, 7 * square_size.y)
	bn2.ficha.team = Types.Team.Black; bn2.ficha.pos = "G8"; bn2.ficha.id = Types.PieceType.N; bn2.ficha.index = 63
	game_logic.black_pieces.append(bn2)

	var bq = B["Q"].instantiate(); tablero.add_child(bq)
	bq.global_position = Vector2(3 * square_size.x, 7 * square_size.y)
	bq.ficha.team = Types.Team.Black; bq.ficha.pos = "D8"; bq.ficha.id = Types.PieceType.Q; bq.ficha.index = 60
	game_logic.black_pieces.append(bq)

	var bk = B["K"].instantiate(); tablero.add_child(bk)
	bk.global_position = Vector2(4 * square_size.x, 7 * square_size.y)
	bk.ficha.team = Types.Team.Black; bk.ficha.pos = "E8"; bk.ficha.id = Types.PieceType.K; bk.ficha.index = 61
	game_logic.black_pieces.append(bk)

	if tablero.has_method("emit_signal") and tablero.has_signal("pieces_created"):
		tablero.emit_signal("pieces_created")
