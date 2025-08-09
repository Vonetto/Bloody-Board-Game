extends Node2D
const Types = preload("res://scripts/Types.gd")

var square_size= Vector2(96,-96)
const BoardUtils = preload("res://utils/BoardUtils.gd")
const PieceFactory = preload("res://scripts/PieceFactory.gd")

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
	index_map = BoardUtils.generate_index_map()
	
	game_logic = get_tree().get_first_node_in_group("main")
	PieceFactory.setup(self, game_logic)
	
		
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
	# Obsoleto: la inicialización de piezas se mueve a PieceFactory.setup(self, game_logic)
	PieceFactory.setup(self, game_logic)
