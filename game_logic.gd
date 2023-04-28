extends Node2D

var white_pieces =[]
var black_pieces =[]

var first_target
var second_target=null

@onready var tablero = $tablero

var index_map= {}
var pos1
var pos2

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

@onready var selector  = load("res://selector.tscn").instantiate()
func _ready():
	
	#tablero.pieces_created.connect(_on_pieces_created)
	
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
			
	
	_on_pieces_created()
	
	selector.vul=null
	set_process_input(true)
	var piece
	
	
	add_child(selector)
	

# Called when the node enters the scene tree for the first time.
	
	
	
func _on_pieces_created():
	for piece in white_pieces:
		piece.invalid_movement.connect(selector.invalidate)
		
	for piece in black_pieces:
		piece.invalid_movement.connect(selector.invalidate)
	
	
func _input(event):
	
	if Input.is_action_just_pressed("ui_accept") and selector.vul== false :
		
		var x=int(selector.position.x)
		var y=int(selector.position.y)
		
		print(selector.vul)
		pos1= Vector2(x,y)
		print(pos1)
		
		var piece=search_in(pos1)
		first_target=piece
	#if (event is InputEventMouseButton):
		#if (event.pressed):
			#var x=int((event.position.x - 243)/$tablero.square_size.x)
			#var y=8-int((event.position.y)/$tablero.square_size.x)
			#var sq=get_square(x, y)
			#var piece=search_in(sq)
			
		if (first_target !=null):
			if (piece != null):
				first_target=piece
				
				#first_target.move_piece(sq)
			else:
				pass
		#else: #assign first target
			#if (piece==null):
					#return
			#if (turn):
					#piece.ficha.team=="White"
					#first_target=piece
			#else:
					#piece.ficha.team=="Black"
					#first_target=piece
		#else:
			#pass
	
	
					
	
#func get_square(x, y):
		#var charini=65
		#var pos=char(charini+x-1)+str(y)
		#return pos
	
	if Input.is_action_just_pressed("ui_accept") and selector.vul== true :
		
		print(selector.vul)
		
		var x=int(selector.position.x)
		var y=int(selector.position.y)
		
		pos2=Vector2(x,y)
		print(pos2)
		
		var piece=search_in(pos2)
		
		if (first_target != null):
			first_target.move_piece(pos1 ,pos2, index_map, selector)
		
		
		
		
	
func search_in(sq):
	
	for i in white_pieces:
		if (i.ficha.index== selector.indice):
			
			return i
	for i in black_pieces:
		if (i.ficha.index==selector.indice):
			
			return i
	return null
