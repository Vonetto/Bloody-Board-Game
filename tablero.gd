extends Node2D

var square_size= Vector2(96,-96)

@onready var instancedBishop = preload("res://Chess_Pieces/bishop.tscn")
@onready var instancedPeon = preload("res://Chess_Pieces/peon.tscn")
@onready var instancedRook = preload("res://Chess_Pieces/rook.tscn")
@onready var instancedKnight = preload("res://Chess_Pieces/knight.tscn")
@onready var instancedQueen = preload("res://Chess_Pieces/queen.tscn")
@onready var instancedKing = preload("res://Chess_Pieces/king.tscn")

@onready var instancedBPeon = preload("res://Chess_Pieces/Bpeon.tscn")
@onready var instancedBBishop = preload("res://Chess_Pieces/Bbishop.tscn")
@onready var instancedBRook = preload("res://Chess_Pieces/Brook.tscn")
@onready var instancedBKnight = preload("res://Chess_Pieces/Bknight.tscn")
@onready var instancedBQueen = preload("res://Chess_Pieces/Bqueen.tscn")
@onready var instancedBKing = preload("res://Chess_Pieces/Bking.tscn")


var game_logic
@export var index_map= {}


signal pieces_created

# Called when the node enters the scene tree for the first time.
func _ready():
	
	index_map[1]= Vector2(48, -48)
	
	for i in range(2,65):
		while (i<=8):
			index_map[i]= Vector2( ((i*96)-48)%768, - 48)
			i=i+1
		while (i>=9 and i <=16):
			index_map[i]= Vector2( ((i*96)-48)%768, -144)
			i=i+1
		while (i>=17 and i <=24):
			index_map[i]= Vector2( ((i*96)-48)%768, -240)
			i=i+1
			
		while (i>=25 and i <=32):
			index_map[i]= Vector2( ((i*96)-48)%768, -336)
			i=i+1	
			
		while (i>=33 and i <=40):
			index_map[i]= Vector2( ((i*96)-48)%768, -432)
			i=i+1
			
		while (i>=41 and i <=48):
			index_map[i]= Vector2( ((i*96)-48)%768, -528)
			i=i+1
			
		while (i>=49 and i <=56):
			index_map[i]= Vector2( ((i*96)-48)%768, -624)
			i=i+1
	
		while (i>=57 and i <=64):
			index_map[i]= Vector2( ((i*96)-48)%768, -720)
			i=i+1
			
	
	
	
	game_logic = get_tree().get_first_node_in_group("main")
	instance_pieces()
	
		
	for i in 8:
		for j in 8:	
			var area=Area2D.new()
			var collision=CollisionShape2D.new()
			var shape=RectangleShape2D.new()
			#add_child(area)
			#area.add_child(collision)
			#collision.shape=shape
			#shape.size=Vector2(98,98)
			#collision.position+=Vector2(square_size[0]/2, square_size[0]/2)
			#area.position=Vector2(i*square_size.x, (j+1)*square_size.y)
			#area.input_event.connect(_input_event)
			#area.input_pickable=true
	
	
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
	for i in range(8):
		var charini = 65 #a en ASCII
		
		var new_pawn = instancedPeon.instantiate()
		game_logic.get_node("tablero").add_child(new_pawn)
		new_pawn.global_position= Vector2(i*square_size.x, 1*square_size.y)
		new_pawn.ficha.team= "White"
		new_pawn.ficha.pos = char(charini+i) + "2"
		game_logic.white_pieces.append(new_pawn)
		new_pawn.ficha.index= i + 9
		
	
	#Bishop
	var new_bishop = instancedBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_bishop)
	new_bishop.global_position = Vector2(2*square_size.x, 0*square_size.y)
	new_bishop.ficha.team= "White"
	new_bishop.ficha.pos = "C1"
	new_bishop.ficha.id = "B"
	game_logic.white_pieces.append(new_bishop)
	new_bishop.ficha.index= 3
	
	var new_bishop2 = instancedBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_bishop2)
	new_bishop2.global_position = Vector2(5*square_size.x, 0*square_size.y)
	new_bishop2.ficha.team= "White"
	new_bishop2.ficha.pos = "F1"
	new_bishop2.ficha.id = "B"
	game_logic.white_pieces.append(new_bishop2)
	new_bishop2.ficha.index= 6
	
	#Rook
	var new_rook = instancedRook.instantiate()
	game_logic.get_node("tablero").add_child(new_rook)
	new_rook.global_position = Vector2(0*square_size.x, 0*square_size.y)
	new_rook.ficha.team= "White"
	new_rook.ficha.pos = "A1"
	new_rook.ficha.id = "R"
	game_logic.white_pieces.append(new_rook)
	new_rook.ficha.index =1
	
	var new_rook2 = instancedRook.instantiate()
	game_logic.get_node("tablero").add_child(new_rook2)
	new_rook2.global_position = Vector2(7*square_size.x, 0*square_size.y)
	new_rook2.ficha.team= "White"
	new_rook2.ficha.pos = "H1"
	new_rook2.ficha.id = "R"
	game_logic.white_pieces.append(new_rook2)
	new_rook2.ficha.index =8
	
	#Knight
	var new_knight = instancedKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_knight)
	new_knight.global_position = Vector2(1*square_size.x, 0*square_size.y)
	new_knight.ficha.team= "White"
	new_knight.ficha.pos = "B1"
	new_knight.ficha.id = "N"
	game_logic.white_pieces.append(new_knight)
	new_knight.ficha.index = 2
	
	var new_knight2 = instancedKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_knight2)
	new_knight2.global_position = Vector2(6*square_size.x, 0*square_size.y)
	new_knight2.ficha.team= "White"
	new_knight2.ficha.pos = "G1"
	new_knight2.ficha.id = "N"
	game_logic.white_pieces.append(new_knight2)
	new_knight2.ficha.index = 7
	
	#Queen
	var new_queen = instancedQueen.instantiate()
	game_logic.get_node("tablero").add_child(new_queen)
	new_queen.global_position = Vector2(3*square_size.x, 0*square_size.y)
	new_queen.ficha.team= "White"
	new_queen.ficha.pos = "D1"
	new_queen.ficha.id = "Q"
	game_logic.white_pieces.append(new_queen)
	new_queen.ficha.index = 4
	
	#King
	var new_king = instancedKing.instantiate()
	game_logic.get_node("tablero").add_child(new_king)
	new_king.global_position = Vector2(4*square_size.x, 0*square_size.y)
	new_king.ficha.team= "White"
	new_king.ficha.pos = "E1"
	new_king.ficha.id = "K"
	game_logic.white_pieces.append(new_king)
	new_king.ficha.index = 5
	
	
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
		new_Bpawn.ficha.index= i + 49
		
	#Bishop
	var new_Bbishop = instancedBBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_Bbishop)
	new_Bbishop.global_position = Vector2(2*square_size.x, 7*square_size.y)
	new_Bbishop.ficha.team= "Black"
	new_Bbishop.ficha.pos = "C8"
	new_Bbishop.ficha.id = "B"
	game_logic.black_pieces.append(new_Bbishop)
	new_Bbishop.ficha.index = 59
	
	var new_Bbishop2 = instancedBBishop.instantiate()
	game_logic.get_node("tablero").add_child(new_Bbishop2)
	new_Bbishop2.global_position = Vector2(5*square_size.x, 7*square_size.y)
	new_Bbishop2.ficha.team= "Black"
	new_Bbishop2.ficha.pos = "F8"
	new_Bbishop2.ficha.id = "B"
	game_logic.black_pieces.append(new_Bbishop2)
	new_Bbishop2.ficha.index = 62
	#Rook
	var new_Brook = instancedBRook.instantiate()
	game_logic.get_node("tablero").add_child(new_Brook)
	new_Brook.global_position = Vector2(0*square_size.x, 7*square_size.y)
	new_Brook.ficha.team= "Black"
	new_Brook.ficha.pos = "A8"
	new_Brook.ficha.id = "R"
	game_logic.black_pieces.append(new_Brook)
	new_Brook.ficha.index = 57
	
	var new_Brook2 = instancedBRook.instantiate()
	game_logic.get_node("tablero").add_child(new_Brook2)
	new_Brook2.global_position = Vector2(7*square_size.x, 7*square_size.y)
	new_Brook2.ficha.team= "Black"
	new_Brook2.ficha.pos = "H8"
	new_Brook2.ficha.id = "R"
	game_logic.black_pieces.append(new_Brook2)
	new_Brook2.ficha.index = 64
	
	#Knight
	var new_Bknight = instancedBKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_Bknight)
	new_Bknight.global_position = Vector2(1*square_size.x, 7*square_size.y)
	new_Bknight.ficha.team= "Black"
	new_Bknight.ficha.pos = "B8"
	new_Bknight.ficha.id = "N"
	game_logic.black_pieces.append(new_Bknight)
	new_Bknight.ficha.index = 58
	
	var new_Bknight2 = instancedBKnight.instantiate()
	game_logic.get_node("tablero").add_child(new_Bknight2)
	new_Bknight2.global_position = Vector2(6*square_size.x, 7*square_size.y)
	new_Bknight2.ficha.team= "Black"
	new_Bknight2.ficha.pos = "G8"
	new_Bknight2.ficha.id = "N"
	game_logic.black_pieces.append(new_Bknight2)
	new_Bknight2.ficha.index = 63
	
	#Queen
	var new_Bqueen = instancedBQueen.instantiate()
	game_logic.get_node("tablero").add_child(new_Bqueen)
	new_Bqueen.global_position = Vector2(3*square_size.x, 7*square_size.y)
	new_Bqueen.ficha.team= "Black"
	new_Bqueen.ficha.pos = "D8"
	new_Bqueen.ficha.id = "Q"
	game_logic.black_pieces.append(new_Bqueen)
	new_Bqueen.ficha.index = 60
	
	#King
	var new_Bking = instancedBKing.instantiate()
	game_logic.get_node("tablero").add_child(new_Bking)
	new_Bking.global_position = Vector2(4*square_size.x, 7*square_size.y)
	new_Bking.ficha.team= "Black"
	new_Bking.ficha.pos = "E8"
	new_Bking.ficha.id = "K"
	game_logic.black_pieces.append(new_Bking)
	new_Bking.ficha.index = 61
	
	
	pieces_created.emit()
