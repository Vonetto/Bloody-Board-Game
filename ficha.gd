extends Node2D

signal invalid_movement
signal piece_moved(old_index: int, new_index: int)

const TILE := 96
const MoveValidator = preload("res://scripts/MoveValidator.gd")

var ind2

var ficha := {
	id = "P",
	pos = "A1",
	team = "White",
	state = "Live",
	index = 1,
	road_map = []
}

func buscar_llave_por_valor(diccionario, valor_buscado):
	for llave in diccionario:
		if diccionario[llave]== valor_buscado:
				
				return llave
	# Si no se encontró ninguna llave correspondiente al valor buscador

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func get_road_map(cas,pos,mapa,selector, valid):
	ind2 = MoveValidator.move_index(ficha, cas, pos, mapa, false)
	if ind2!=0:
		return MoveValidator.obstructions_indices(ficha, cas, pos, mapa, valid)
	return []
	
func move_piece(cas, pos2 ,mapa, selector, full_map, valid):# Moves the selected piece, to the index returned by the move funx
	
	#print("eje")
	#print("cas: ", cas)
	#print("cas num: ", cas[0].to_ascii_buffer()[0])
	ficha.pos=cas
	#self.position = Vector2(pos2.x-48, pos2.y+50)
	ind2 = MoveValidator.move_index(ficha, cas, pos2, mapa, valid)
	if ind2!=0:
		var old_ind = buscar_llave_por_valor(mapa, cas)
		var new_ind = ind2
		global_position = Vector2(pos2.x-48, pos2.y+50)
		self.ficha.index = new_ind
		# Actualiza la lista entregada (model.full_map) y emite evento para el modelo
		var idx: int = full_map.find(old_ind)
		if idx != -1:
			full_map[idx] = new_ind
		piece_moved.emit(old_ind, new_ind)
				


func move(cas,pos2, mapa, selector, valid): #Returns the new index the selected piece will move to , if the move selected is valid
	var ind := MoveValidator.move_index(ficha, cas, pos2, mapa, valid)
	if ind == 0:
		invalid_movement.emit()
	return ind
	
func obstr(cas, pos, mapa, selector, valid): # Simulamos todos los posibles movimientos que hace una pieza hasta su posicion escogida, para ver si obstruye con alguna pieza ya existente
	return MoveValidator.obstructions_indices(ficha, cas, pos, mapa, valid)


func pawn_eat(cas, mapa, selector):
	return MoveValidator.pawn_eat_indices(ficha, cas, mapa)



	
