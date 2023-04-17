extends Node2D

var white_pieces =[]
var black_pieces =[]

var first_target=null
var second_target=null

@onready var tablero = $tablero

var turn = true #true: white, false: black

@export_node_path("bishop")  var bishop
@export_node_path("peon")  var peon
@export_node_path("rook")  var rook
@export_node_path("knight")  var knight
@export_node_path("queen")  var queen
@export_node_path("king")  var king

@export_node_path("Bpeon")  var Bpeon
@export_node_path("Bbishop")  var Bbishop
@export_node_path("Brook")  var Brook
@export_node_path("Bknight")  var Bknight
@export_node_path("Bqueen")  var Bqueen
@export_node_path("Bking")  var Bking



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.	

func _input(event):
	if (event is InputEventMouseButton):
		if (event.pressed):
			var x=int((event.position.x - 243)/$tablero.square_size.x)
			var y=8-int((event.position.y)/$tablero.square_size.x)
			var sq=get_square(x, y)
			var piece=search_in(sq)
			
			if (first_target!=null): #second target
				if (piece == null):
					first_target.move_piece(sq)
				else:
					pass
			else: #assign first target
				if (piece==null):
					return
				if (turn):
					piece.ficha.team=="White"
					first_target=piece
				else:
					piece.ficha.team=="Black"
					first_target=piece
		else:
			pass
			
func get_square(x, y):
	var charini=65
	var pos=char(charini+x-1)+str(y)
	return pos
	
func search_in(sq):
	for i in white_pieces:
		if (i.ficha.pos==sq):
			return i
	for i in black_pieces:
		if (i.ficha.pos==sq):
			print(i)
			return i
	return null
