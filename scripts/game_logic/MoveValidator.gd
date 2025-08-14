class_name MoveValidator
extends Node

const Types = preload("res://scripts/game_logic/Types.gd")
const PieceData = preload("res://scripts/game_logic/PieceData.gd")

## MoveValidator: funciones puras para validar movimientos y rutas

static func _index_of_map(mapa: Dictionary, pos: Vector2) -> int:
	for k in mapa.keys():
		if mapa[k] == pos:
			return k
	return 0

static func move_index(ficha: PieceData, cas: Vector2, pos2: Vector2, mapa: Dictionary, valid: bool) -> int:
	var ind := 0
	var indice_1 := _index_of_map(mapa, cas)
	var indice_2 := _index_of_map(mapa, pos2)

	match ficha.id:
		Types.PieceType.P:
			if ficha.team == Types.Team.White:
				if valid:
					if ((indice_2 - indice_1) == 7) or ((indice_2 - indice_1) == 9):
						ind = indice_2
				else:
					if indice_1 <= 16:
						if abs(indice_2 - indice_1) == 16:
							ind = indice_2
						elif (indice_2 - indice_1) == 8:
							ind = indice_2
					else:
						if (indice_2 - indice_1) == 8:
							ind = indice_2
			else: # Black
				if valid:
					if abs(indice_2 - indice_1) == 7 or abs(indice_2 - indice_1) == 9:
						ind = indice_2
				else:
					if indice_1 >= 49:
						if (indice_2 - indice_1) == -16:
							ind = indice_2
						elif (indice_2 - indice_1) == -8:
							ind = indice_2
					else:
						if (indice_2 - indice_1) == -8:
							ind = indice_2

		Types.PieceType.B:
			if (abs(indice_2 - indice_1) % 7 == 0) or (abs(indice_2 - indice_1) % 9 == 0):
				ind = indice_2

		Types.PieceType.N:
			var TILE := 96
			var moves = [
				Vector2(cas.x-2*TILE, cas.y-1*TILE),
				Vector2(cas.x-1*TILE, cas.y-2*TILE),
				Vector2(cas.x+1*TILE, cas.y-2*TILE),
				Vector2(cas.x+2*TILE, cas.y-1*TILE),
				Vector2(cas.x-2*TILE, cas.y+1*TILE),
				Vector2(cas.x-1*TILE, cas.y+2*TILE),
				Vector2(cas.x+1*TILE, cas.y+2*TILE),
				Vector2(cas.x+2*TILE, cas.y+1*TILE)
			]
			if pos2 in moves:
				ind = indice_2

		Types.PieceType.R:
			if (cas.x == pos2.x) or (cas.y == pos2.y):
				if (abs(indice_2 - indice_1) % 8 == 0) or (abs(indice_2 - indice_1) <= 7):
					ind = indice_2

		Types.PieceType.Q:
			if (abs(indice_2 - indice_1) % 8 == 0) or (abs(indice_2 - indice_1) <= 7) or (abs(indice_2 - indice_1) % 7 == 0) or (abs(indice_2 - indice_1) % 9 == 0):
				ind = indice_2

		Types.PieceType.K:
			if (abs(indice_2 - indice_1) in [1,7,8,9]):
				ind = indice_2

	return ind

static func obstructions_indices(ficha: PieceData, cas: Vector2, pos: Vector2, mapa: Dictionary, valid: bool) -> Array:
	var new_indx = _index_of_map(mapa, pos)
	var old_indx = _index_of_map(mapa, cas)
	var aux_indx = old_indx

	var camino_pos_indx: Array = []

	var safety_counter: int = 0
	while aux_indx != new_indx:
		safety_counter += 1
		if safety_counter > 64:
			# Evita loops infinitos por cálculos de step erróneos
			return []
		if ficha.id == Types.PieceType.P:
			if not valid:
				if ficha.team == Types.Team.White:
					aux_indx += 8
				else:
					aux_indx -= 8
				camino_pos_indx.append(aux_indx)
			else:
				if ficha.team == Types.Team.White:
					return [aux_indx + 9, aux_indx + 7]
				else:
					return [aux_indx - 9, aux_indx - 7]

		elif ficha.id == Types.PieceType.B:
			# Paso diagonal consistente sin depender del signo de Y (soporta ambas diagonales)
			var delta: int = new_indx - old_indx
			if delta == 0:
				return []
			var step: int = 0
			if mapa[new_indx].x > mapa[old_indx].x:
				step = 9 if delta > 0 else -7
			else:
				step = 7 if delta > 0 else -9
			aux_indx += step
			camino_pos_indx.append(aux_indx)

		elif ficha.id == Types.PieceType.N:
			aux_indx = new_indx

		elif ficha.id == Types.PieceType.R:
			if (mapa[new_indx].x != mapa[old_indx].x) and (mapa[new_indx].y == mapa[old_indx].y):
				if mapa[new_indx].x > mapa[old_indx].x:
					aux_indx += 1
				elif mapa[new_indx].x < mapa[old_indx].x:
					aux_indx -= 1
			elif (mapa[new_indx].y != mapa[old_indx].y) and (mapa[new_indx].x == mapa[old_indx].x):
				if mapa[new_indx].y > mapa[old_indx].y:
					aux_indx -= 8
				elif mapa[new_indx].y < mapa[old_indx].y:
					aux_indx += 8
			else:
				return []
			camino_pos_indx.append(aux_indx)

		elif ficha.id == Types.PieceType.Q:
			# Movimiento como torre o alfil
			if mapa[new_indx].x == mapa[old_indx].x or mapa[new_indx].y == mapa[old_indx].y:
				# Recto (misma fila o columna)
				var delta: int = new_indx - old_indx
				var step: int = 0
				if mapa[new_indx].x == mapa[old_indx].x:
					step = 8 if delta > 0 else -8
				else:
					step = 1 if delta > 0 else -1
				aux_indx += step
				camino_pos_indx.append(aux_indx)
			else:
				# Diagonal
				var delta_d: int = new_indx - old_indx
				var step_d: int = 0
				if mapa[new_indx].x > mapa[old_indx].x:
					step_d = 9 if delta_d > 0 else -7
				else:
					step_d = 7 if delta_d > 0 else -9
				aux_indx += step_d
				camino_pos_indx.append(aux_indx)

		elif ficha.id == Types.PieceType.K:
			aux_indx = new_indx

	if new_indx != 0:
		if len(camino_pos_indx) == 0:
			camino_pos_indx.append(new_indx)
		else:
			if camino_pos_indx[0] == old_indx:
				camino_pos_indx.pop_front()
			if camino_pos_indx[-1] != new_indx:
				camino_pos_indx.append(new_indx)

	return camino_pos_indx

static func pawn_eat_indices(ficha: PieceData, cas: Vector2, mapa: Dictionary) -> Array:
	var indice_1 = _index_of_map(mapa, cas)
	var res: Array = []
	if ficha.id != Types.PieceType.P:
		return res
	if ficha.team == Types.Team.White:
		res.append(indice_1 + 9)
		res.append(indice_1 + 7)
	else:
		res.append(indice_1 - 9)
		res.append(indice_1 - 7)
	return res
