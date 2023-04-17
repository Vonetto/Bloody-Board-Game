extends Node2D

var square_size= Vector2(96,-96)

@onready var instancedBishop = preload("res://bishop.tscn")
@onready var instancedPeon = preload("res://peon.tscn")
@onready var instancedRook = preload("res://rook.tscn")
@onready var instancedKnight = preload("res://knight.tscn")
@onready var instancedQueen = preload("res://queen.tscn")
@onready var instancedKing = preload("res://king.tscn")

@onready var instancedBPeon = preload("res://Bpeon.tscn")
@onready var instancedBBishop = preload("res://Bbishop.tscn")
@onready var instancedBRook = preload("res://Brook.tscn")
@onready var instancedBKnight = preload("res://Bknight.tscn")
@onready var instancedBQueen = preload("res://Bqueen.tscn")
@onready var instancedBKing = preload("res://Bking.tscn")

var game_logic


# Called when the node enters the scene tree for the first time.
func _ready():
	game_logic = get_tree().get_first_node_in_group("main")
	instance_pieces()
	for i in 8:
		for j in 8:	
			var area=Area2D.new()
			var collision=CollisionShape2D.new()
			var shape=RectangleShape2D.new()
			add_child(area)
			area.add_child(collision)
			collision.shape=shape
			shape.size=Vector2(98,98)
			collision.position+=Vector2(square_size[0]/2, square_size[0]/2)
			area.position=Vector2(i*square_size.x, (j+1)*square_size.y)
			area.input_event.connect(_input_event)
			area.input_pickable=true
	
	
func _draw():
	var square_color = Color.SANDY_BROWN
	for i in 8:
		if (square_color == Color.SANDY_BROWN):
			square_color = Color.WHITE
		else:
			square_color = Color.SANDY_BROWN
		for j in 8:
			if (square_color == Color.SANDY_BROWN):
				square_color = Color.WHITE
			else:
				square_color = Color.SANDY_BROWN
		
			draw_rect(Rect2(Vector2(i*square_size.x,j*square_size.y), square_size), square_color)


func  instance_pieces():
	
	#White 
	#Pawn
	for i in 8:
		var charini = 65 #a en ASCII
		
		var new_pawn = instancedPeon.instantiate()
		game_logic.get_node("tablero").add_child(new_pawn)
		new_pawn.global_position= Vector2(i*square_size.x, 1*square_size.y)
		new_pawn.ficha.team= "White"
		new_pawn.ficha.pos = char(charini+i) + "2"
		game_logic.white_pieces.append(new_pawn)
	
	#Bishop
	var new_bishop = instancedBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_bishop)
	new_bishop.global_position = Vector2(2*square_size.x, 0*square_size.y)
	new_bishop.ficha.team= "White"
	new_bishop.ficha.pos = "C1"
	new_bishop.ficha.id = "B"
	game_logic.white_pieces.append(new_bishop)
	
	var new_bishop2 = instancedBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_bishop2)
	new_bishop2.global_position = Vector2(5*square_size.x, 0*square_size.y)
	new_bishop2.ficha.team= "White"
	new_bishop2.ficha.pos = "F1"
	new_bishop2.ficha.id = "B"
	game_logic.white_pieces.append(new_bishop2)
	
	#Rook
	var new_rook = instancedRook.instantiate()
	game_logic.get_node("tablero").add_child(new_rook)
	new_rook.global_position = Vector2(0*square_size.x, 0*square_size.y)
	new_rook.ficha.team= "White"
	new_rook.ficha.pos = "A1"
	new_rook.ficha.id = "R"
	game_logic.white_pieces.append(new_rook)
	
	var new_rook2 = instancedRook.instantiate()
	game_logic.get_node("tablero").add_child(new_rook2)
	new_rook2.global_position = Vector2(7*square_size.x, 0*square_size.y)
	new_rook2.ficha.team= "White"
	new_rook2.ficha.pos = "H1"
	new_rook2.ficha.id = "R"
	game_logic.white_pieces.append(new_rook2)
	
	#Knight
	var new_knight = instancedKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_knight)
	new_knight.global_position = Vector2(1*square_size.x, 0*square_size.y)
	new_knight.ficha.team= "White"
	new_knight.ficha.pos = "B1"
	new_knight.ficha.id = "N"
	game_logic.white_pieces.append(new_knight)
	
	var new_knight2 = instancedKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_knight2)
	new_knight2.global_position = Vector2(6*square_size.x, 0*square_size.y)
	new_knight2.ficha.team= "White"
	new_knight2.ficha.pos = "G1"
	new_knight2.ficha.id = "N"
	game_logic.white_pieces.append(new_knight2)
	
	#Queen
	var new_queen = instancedQueen.instantiate()
	game_logic.get_node("tablero").add_child(new_queen)
	new_queen.global_position = Vector2(3*square_size.x, 0*square_size.y)
	new_queen.ficha.team= "White"
	new_queen.ficha.pos = "D1"
	new_queen.ficha.id = "Q"
	game_logic.white_pieces.append(new_queen)
	
	#King
	var new_king = instancedKing.instantiate()
	game_logic.get_node("tablero").add_child(new_king)
	new_king.global_position = Vector2(4*square_size.x, 0*square_size.y)
	new_king.ficha.team= "White"
	new_king.ficha.pos = "E1"
	new_king.ficha.id = "K"
	game_logic.white_pieces.append(new_king)
	
	
	#Black
	#Pawn
	for i in 8:
		var charini = 65 #A en ASCII
		
		var new_Bpawn = instancedBPeon.instantiate()
		game_logic.get_node("tablero").add_child(new_Bpawn)
		new_Bpawn.global_position= Vector2(i*square_size.x, 6*square_size.y)
		new_Bpawn.ficha.team= "Black"
		new_Bpawn.ficha.pos = char(charini+i) + "7"
		game_logic.black_pieces.append(new_Bpawn)
		
	#Bishop
	var new_Bbishop = instancedBBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_Bbishop)
	new_Bbishop.global_position = Vector2(2*square_size.x, 7*square_size.y)
	new_Bbishop.ficha.team= "Black"
	new_Bbishop.ficha.pos = "C8"
	new_Bbishop.ficha.id = "B"
	game_logic.black_pieces.append(new_Bbishop)
	
	var new_Bbishop2 = instancedBBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_Bbishop2)
	new_Bbishop2.global_position = Vector2(5*square_size.x, 7*square_size.y)
	new_Bbishop2.ficha.team= "Black"
	new_Bbishop2.ficha.pos = "F8"
	new_Bbishop2.ficha.id = "B"
	game_logic.black_pieces.append(new_Bbishop2)
	
	#Rook
	var new_Brook = instancedBRook.instantiate()
	game_logic.get_node("tablero").add_child(new_Brook)
	new_Brook.global_position = Vector2(0*square_size.x, 7*square_size.y)
	new_Brook.ficha.team= "Black"
	new_Brook.ficha.pos = "A8"
	new_Brook.ficha.id = "R"
	game_logic.black_pieces.append(new_Brook)
	
	var new_Brook2 = instancedBRook.instantiate()
	game_logic.get_node("tablero").add_child(new_Brook2)
	new_Brook2.global_position = Vector2(7*square_size.x, 7*square_size.y)
	new_Brook2.ficha.team= "Black"
	new_Brook2.ficha.pos = "H8"
	new_Brook2.ficha.id = "R"
	game_logic.black_pieces.append(new_Brook2)
	
	#Knight
	var new_Bknight = instancedBKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_Bknight)
	new_Bknight.global_position = Vector2(1*square_size.x, 7*square_size.y)
	new_Bknight.ficha.team= "Black"
	new_Bknight.ficha.pos = "B8"
	new_Bknight.ficha.id = "N"
	game_logic.black_pieces.append(new_Bknight)
	
	var new_Bknight2 = instancedBKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_Bknight2)
	new_Bknight2.global_position = Vector2(6*square_size.x, 7*square_size.y)
	new_Bknight2.ficha.team= "Black"
	new_Bknight2.ficha.pos = "G8"
	new_Bknight2.ficha.id = "N"
	game_logic.black_pieces.append(new_Bknight2)
	
	#Queen
	var new_Bqueen = instancedBQueen.instantiate()
	game_logic.get_node("tablero").add_child(new_Bqueen)
	new_Bqueen.global_position = Vector2(3*square_size.x, 7*square_size.y)
	new_Bqueen.ficha.team= "Black"
	new_Bqueen.ficha.pos = "D8"
	new_Bqueen.ficha.id = "Q"
	game_logic.black_pieces.append(new_Bqueen)
	
	#King
	var new_Bking = instancedBKing.instantiate()
	game_logic.get_node("tablero").add_child(new_Bking)
	new_Bking.global_position = Vector2(4*square_size.x, 7*square_size.y)
	new_Bking.ficha.team= "Black"
	new_Bking.ficha.pos = "E8"
	new_Bking.ficha.id = "K"
	game_logic.black_pieces.append(new_Bking)
	
func _input_event(event, i, j):
	print(event)
	if (event is InputEventMouseButton and event.pressed):
		print("hola")
		#prints(i, j)
