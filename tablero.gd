extends Node2D

var square_size= Vector2(96,-96)

@onready var instancedBishop = preload("res://bishop.tscn")
@onready var instancedPeon = preload("res://peon.tscn")


@onready var instancedBPeon = preload("res://Bpeon.tscn")

var game_logic


# Called when the node enters the scene tree for the first time.
func _ready():
	game_logic = get_tree().get_first_node_in_group("main")
	instance_pieces()
	pass
	
	
func _draw():
	var square_color = Color.BLACK
	for i in 8:
		if (square_color == Color.BLACK):
			square_color = Color.WHITE
		else:
			square_color = Color.BLACK
		for j in 8:
			if (square_color == Color.BLACK):
				square_color = Color.WHITE
			else:
				square_color = Color.BLACK
		
			draw_rect(Rect2(Vector2(i*square_size.x,j*square_size.y), square_size), square_color)


func  instance_pieces():
	
	#White 
	#Pawn
	for i in 8:
		var new_pawn = instancedPeon.instantiate()
		game_logic.get_node("tablero").add_child(new_pawn)
		new_pawn.global_position= Vector2(i*square_size.x, 1*square_size.y)
		new_pawn.ficha.team= "White"
	
	#Bishop
	var new_bishop = instancedBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_bishop)
	new_bishop.global_position = Vector2(0*square_size.x, 0*square_size.y)
	new_bishop.ficha.team= "White"
	
	var new_bishop2 = instancedBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_bishop2)
	new_bishop2.global_position = Vector2(3*square_size.x, 0*square_size.y)
	new_bishop2.ficha.team= "White"
	
	
	#Black
	#Pawn
	for i in 8:
		var new_Bpawn = instancedBPeon.instantiate()
		game_logic.get_node("tablero").add_child(new_Bpawn)
		new_Bpawn.global_position= Vector2(i*square_size.x, 6*square_size.y)
		new_Bpawn.ficha.team= "Black"
