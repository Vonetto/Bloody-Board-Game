extends Node2D

signal invalid_movement
signal piece_moved(old_index: int, new_index: int)

const TILE := 96
const MoveValidator = preload("res://scripts/MoveValidator.gd")
const Types = preload("res://scripts/Types.gd")
const PieceData = preload("res://scripts/PieceData.gd")

var ind2

var ficha: PieceData = PieceData.new()

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
	
func move_piece(cas, pos2 ,mapa, selector, full_map, valid):
	# Obsoleto: la lógica de mover se gestiona en Game.gd. 
	# Dejamos solo la actualización visual por compatibilidad si fuese llamada por código legacy.
	ficha.pos = cas
	global_position = Vector2(pos2.x - 48, pos2.y + 50)
				


func move(cas,pos2, mapa, selector, valid): #Returns the new index the selected piece will move to , if the move selected is valid
	var ind := MoveValidator.move_index(ficha, cas, pos2, mapa, valid)
	if ind == 0:
		invalid_movement.emit()
	return ind
	
func obstr(cas, pos, mapa, selector, valid): # Simulamos todos los posibles movimientos que hace una pieza hasta su posicion escogida, para ver si obstruye con alguna pieza ya existente
	return MoveValidator.obstructions_indices(ficha, cas, pos, mapa, valid)


func pawn_eat(cas, mapa, selector):
	return MoveValidator.pawn_eat_indices(ficha, cas, mapa)



	
